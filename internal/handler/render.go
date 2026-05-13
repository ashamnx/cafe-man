package handler

import (
	"embed"
	"fmt"
	"hash/fnv"
	"html/template"
	"io/fs"
	"log/slog"
	"net/http"
	"path/filepath"
	"strconv"
	"strings"
	"time"
	"unicode"

	"searlo-cafe/internal/middleware"

	"github.com/alexedwards/scs/v2"
	"github.com/google/uuid"
)

//go:embed templates/*.html
var templateFS embed.FS

type Renderer struct {
	pages    map[string]*template.Template
	sessions *scs.SessionManager
}

func NewRenderer(sessions *scs.SessionManager, imageBaseURL string) *Renderer {
	funcMap := template.FuncMap{
		"currency": func(amount float64, symbol string) string {
			return fmt.Sprintf("%s %.2f", symbol, amount)
		},
		"pct": func(v float64) string {
			return fmt.Sprintf("%.2f%%", v)
		},
		"money": func(v float64) string {
			return fmt.Sprintf("%.2f", v)
		},
		// inputDecimal preserves DECIMAL(15,4) precision for editable form
		// fields, so editing a row doesn't silently round to 2dp like money does.
		"inputDecimal": func(v float64) string {
			s := strconv.FormatFloat(v, 'f', 4, 64)
			s = strings.TrimRight(s, "0")
			return strings.TrimRight(s, ".")
		},
		"lower": strings.ToLower,
		"join":  strings.Join,
		"deref": func(v any) any {
			switch p := v.(type) {
			case *float64:
				if p != nil {
					return *p
				}
				return 0.0
			case *string:
				if p != nil {
					return *p
				}
				return ""
			default:
				return v
			}
		},
		"mul":      func(a, b float64) float64 { return a * b },
		"add":      func(a, b int) int { return a + b },
		"subtract": func(a, b int) int { return a - b },
		"itof": func(i int) float64 { return float64(i) },
		"lt": func(a, b float64) bool { return a < b },
		"gt": func(a, b float64) bool { return a > b },
		"recipeCount": func(counts any, id uuid.UUID) float64 {
			if m, ok := counts.(map[uuid.UUID]int); ok {
				return float64(m[id])
			}
			return 0
		},
		"ingAlertCount": func(counts any, id uuid.UUID) float64 {
			if m, ok := counts.(map[uuid.UUID]int); ok {
				return float64(m[id])
			}
			return 0
		},
		"imageURL": func(objectKey string) string {
			if objectKey == "" {
				return ""
			}
			return "/images/" + objectKey
		},
		"thumbURL": func(objectKey string) string {
			if objectKey == "" {
				return ""
			}
			idx := strings.LastIndex(objectKey, "_original.")
			if idx == -1 {
				return "/images/" + objectKey
			}
			return "/images/" + objectKey[:idx] + "_thumb.webp"
		},
		// aspectClass cycles Tailwind aspect-ratio utilities by index so a
		// uniform grid feels Pinterest-like without a true masonry layout.
		"aspectClass": func(i int) string {
			switch i % 4 {
			case 0:
				return "aspect-[4/5]"
			case 1:
				return "aspect-[4/3]"
			case 2:
				return "aspect-[1/1]"
			default:
				return "aspect-[3/4]"
			}
		},
		"monogram": func(name string) string {
			for _, r := range name {
				if unicode.IsLetter(r) || unicode.IsDigit(r) {
					return string(unicode.ToUpper(r))
				}
			}
			return "?"
		},
		// monoGradient picks a deterministic warm gradient for image-less menu
		// cards. Returns template.CSS so html/template emits the literal value
		// into the style attribute (color hex chars are not safe URL/JS chars
		// but are safe in CSS context).
		"monoGradient": func(name string) template.CSS {
			palettes := [...][2]string{
				{"#C4846A", "#1A1814"}, // clay → ink
				{"#8FA68A", "#1A1814"}, // sage → ink
				{"#D9A78B", "#6B4A3A"}, // sand → cocoa
				{"#A37B6B", "#3B2A24"}, // terracotta → plum
				{"#E2B98E", "#8A5A3B"}, // honey → bronze
			}
			h := fnv.New32a()
			_, _ = h.Write([]byte(strings.ToLower(name)))
			p := palettes[int(h.Sum32())%len(palettes)]
			return template.CSS("linear-gradient(135deg, " + p[0] + " 0%, " + p[1] + " 100%)")
		},
		// dict lets templates pass multiple named values into a sub-template,
		// since Go's html/template has no built-in map literal.
		"dict": func(values ...any) (map[string]any, error) {
			if len(values)%2 != 0 {
				return nil, fmt.Errorf("dict: odd number of args")
			}
			m := make(map[string]any, len(values)/2)
			for i := 0; i < len(values); i += 2 {
				k, ok := values[i].(string)
				if !ok {
					return nil, fmt.Errorf("dict: non-string key at %d", i)
				}
				m[k] = values[i+1]
			}
			return m, nil
		},
		"timeAgo": func(t *time.Time) string {
			if t == nil {
				return ""
			}
			d := time.Since(*t)
			switch {
			case d < time.Minute:
				return "just now"
			case d < time.Hour:
				return fmt.Sprintf("%dm ago", int(d.Minutes()))
			case d < 24*time.Hour:
				return fmt.Sprintf("%dh ago", int(d.Hours()))
			case d < 30*24*time.Hour:
				return fmt.Sprintf("%dd ago", int(d.Hours()/24))
			default:
				return t.Format("Jan 02")
			}
		},
	}

	// Parse layout as the base template.
	layoutData, err := templateFS.ReadFile("templates/layout.html")
	if err != nil {
		panic("failed to read layout.html: " + err.Error())
	}

	// Pre-read all shared partials (files named "_*.html") so any page can
	// invoke their {{define}} blocks without per-page imports.
	var partialsBuf strings.Builder
	err = fs.WalkDir(templateFS, "templates", func(path string, d fs.DirEntry, walkErr error) error {
		if walkErr != nil || d.IsDir() || !strings.HasSuffix(path, ".html") {
			return walkErr
		}
		if !strings.HasPrefix(filepath.Base(path), "_") {
			return nil
		}
		data, readErr := templateFS.ReadFile(path)
		if readErr != nil {
			return readErr
		}
		partialsBuf.Write(data)
		partialsBuf.WriteByte('\n')
		return nil
	})
	if err != nil {
		panic("failed to read partials: " + err.Error())
	}
	partials := partialsBuf.String()

	// Parse each page template by cloning the layout, so each page
	// has its own "content" definition without conflicts.
	pages := make(map[string]*template.Template)

	err = fs.WalkDir(templateFS, "templates", func(path string, d fs.DirEntry, walkErr error) error {
		if walkErr != nil || d.IsDir() || !strings.HasSuffix(path, ".html") {
			return walkErr
		}
		name := filepath.Base(path)
		if name == "layout.html" || strings.HasPrefix(name, "_") {
			return nil
		}

		data, readErr := templateFS.ReadFile(path)
		if readErr != nil {
			return readErr
		}

		// Clone layout, register partials, then parse the page template.
		t, parseErr := template.New("layout.html").Funcs(funcMap).Parse(string(layoutData))
		if parseErr != nil {
			return fmt.Errorf("parse layout for %s: %w", name, parseErr)
		}
		if partials != "" {
			if _, parseErr = t.Parse(partials); parseErr != nil {
				return fmt.Errorf("parse partials for %s: %w", name, parseErr)
			}
		}
		_, parseErr = t.New(name).Parse(string(data))
		if parseErr != nil {
			return fmt.Errorf("parse %s: %w", name, parseErr)
		}
		pages[name] = t
		return nil
	})
	if err != nil {
		panic("failed to parse templates: " + err.Error())
	}

	return &Renderer{pages: pages, sessions: sessions}
}

func (ren *Renderer) HTML(w http.ResponseWriter, r *http.Request, name string, data any) {
	t, ok := ren.pages[name]
	if !ok {
		slog.Error("template not found", "template", name)
		http.Error(w, "Internal Server Error", http.StatusInternalServerError)
		return
	}

	pageData := map[string]any{
		"UserName":          ren.sessions.GetString(r.Context(), "user_name"),
		"OrgName":           ren.sessions.GetString(r.Context(), "org_name"),
		"OrgLogoKey":        ren.sessions.GetString(r.Context(), "org_logo_key"),
		"OrgSlug":           ren.sessions.GetString(r.Context(), "org_slug"),
		"OrgCurrencySymbol": ren.sessions.GetString(r.Context(), "org_currency_symbol"),
	}

	if m, ok := data.(map[string]any); ok {
		for k, v := range m {
			pageData[k] = v
		}
	} else if data != nil {
		pageData["Data"] = data
	}

	// Fetch alert count for nav badge if tenant pool is available.
	if _, hasAlert := pageData["AlertCount"]; !hasAlert {
		if pool := middleware.TenantPool(r.Context()); pool != nil {
			var count int
			pool.QueryRow(r.Context(), `SELECT COUNT(*) FROM alerts WHERE is_read = false`).Scan(&count)
			if count > 0 {
				pageData["AlertCount"] = count
			}
		}
	}

	w.Header().Set("Content-Type", "text/html; charset=utf-8")
	if err := t.ExecuteTemplate(w, name, pageData); err != nil {
		slog.Error("template render failed", "template", name, "error", err)
	}
}

// Fragment renders a template fragment for HTMX partial updates.
func (ren *Renderer) Fragment(w http.ResponseWriter, r *http.Request, name string, data any) {
	t, ok := ren.pages[name]
	if !ok {
		slog.Error("fragment not found", "template", name)
		return
	}
	w.Header().Set("Content-Type", "text/html; charset=utf-8")
	if err := t.ExecuteTemplate(w, name, data); err != nil {
		slog.Error("fragment render failed", "template", name, "error", err)
	}
}
