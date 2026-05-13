package handler

import (
	"bytes"
	"strings"
	"testing"
	"time"

	"searlo-cafe/internal/model"

	"github.com/alexedwards/scs/v2"
	"github.com/google/uuid"
)

// TestRenderRecipesList renders recipes.html with a synthetic dataset to
// catch runtime template errors like the "partial row render" bug seen in
// production (body truncates mid-row with only the name visible).
func TestRenderRecipesList(t *testing.T) {
	sessions := scs.New()
	r := NewRenderer(sessions, "")

	catID := uuid.New()
	single := model.MenuItem{
		ID:           uuid.New(),
		CategoryID:   &catID,
		Name:         "Americano - Hot",
		SellingPrice: 40,
		Status:       "active",
		Yield:        1,
		TotalCost:    5,
		CostMargin:   87.5,
		NetProfit:    35,
		Category:     &model.MenuCategory{Name: "Coffee"},
		CreatedAt:    time.Now(),
		UpdatedAt:    time.Now(),
	}

	batch := single
	batch.ID = uuid.New()
	batch.Name = "Caramel Pudding"
	batch.Yield = 8
	batch.YieldUnit = "slice"
	batch.SellingPrice = 25
	batch.CostPerPortion = 10
	batch.NetProfit = 15
	batch.CostMargin = 60

	items := []model.MenuItem{single, batch}
	g := recipeGroup{Category: "Coffee", Items: items, TotalCost: 45, TotalRevenue: 200, TotalProfit: 150}

	data := map[string]any{
		"UserName":       "test",
		"OrgName":        "Test Org",
		"Groups":         []recipeGroup{g},
		"Items":          items,
		"Categories":     []model.MenuCategory{{Name: "Coffee"}},
		"AllIngredients": []model.Ingredient{},
		"Filters":        map[string]string{"search": "", "category": "", "status": "", "ingredients": "", "sort": ""},
	}

	tpl, ok := r.pages["recipes.html"]
	if !ok {
		t.Fatal("recipes.html template not loaded")
	}

	var buf bytes.Buffer
	if err := tpl.ExecuteTemplate(&buf, "recipes.html", data); err != nil {
		t.Fatalf("template execution error: %v", err)
	}

	body := buf.String()
	if !strings.Contains(body, "Americano - Hot") {
		t.Fatal("missing Americano row")
	}
	if !strings.Contains(body, "Caramel Pudding") {
		t.Fatal("missing Caramel Pudding row")
	}
	if !strings.Contains(body, "</body>") {
		t.Fatal("</body> missing — rendering stopped early")
	}
}

// TestRenderRecipeDetail validates the detail page with both yield=1 and
// yield>1 variants so the yield-aware cards don't truncate rendering.
func TestRenderRecipeDetail(t *testing.T) {
	sessions := scs.New()
	r := NewRenderer(sessions, "")

	for _, tc := range []struct {
		name string
		item model.MenuItem
	}{
		{"single", model.MenuItem{ID: uuid.New(), Name: "Tuna Sandwich", Yield: 1, SellingPrice: 40, TotalCost: 10, CostPerPortion: 10, CostMargin: 75, NetProfit: 30, Status: "active"}},
		{"batch", model.MenuItem{ID: uuid.New(), Name: "Caramel Pudding", Yield: 8, YieldUnit: "slice", SellingPrice: 25, TotalCost: 80, CostPerPortion: 10, CostMargin: 60, NetProfit: 15, Status: "active"}},
	} {
		t.Run(tc.name, func(t *testing.T) {
			data := map[string]any{
				"UserName":             "test",
				"OrgName":              "Test Org",
				"Item":                 &tc.item,
				"AllIngredients":       []model.Ingredient{},
				"AlertCounts":          map[uuid.UUID]int{},
				"Units":                []model.Unit{},
				"AllUtilityCosts":      []model.UtilityCost{},
				"LinkedUtilityCostIDs": map[uuid.UUID]bool{},
				"CostHistory":          []model.RecipeCostSnapshot{},
				"UtilityTotal":         0.0,
			}
			tpl := r.pages["recipe_detail.html"]
			var buf bytes.Buffer
			if err := tpl.ExecuteTemplate(&buf, "recipe_detail.html", data); err != nil {
				t.Fatalf("template execution error: %v", err)
			}
			body := buf.String()
			if !strings.Contains(body, tc.item.Name) {
				t.Fatalf("name %q missing", tc.item.Name)
			}
			if !strings.Contains(body, "</body>") {
				t.Fatal("</body> missing — rendering stopped early")
			}
		})
	}
}

// TestCheckboxHxVals verifies the hx-vals attribute renders without HTML
// encoding that would break HTMX's js: expression parsing. The curly
// braces and colons in `js:{linked: event.target.checked}` must pass
// through Go's html/template intact.
func TestCheckboxHxVals(t *testing.T) {
	sessions := scs.New()
	r := NewRenderer(sessions, "")

	ucID := uuid.New()
	item := model.MenuItem{ID: uuid.New(), Name: "Test", Yield: 1, Status: "active"}

	data := map[string]any{
		"UserName":             "t",
		"OrgName":              "o",
		"Item":                 &item,
		"AllIngredients":       []model.Ingredient{},
		"AlertCounts":          map[uuid.UUID]int{},
		"Units":                []model.Unit{},
		"AllUtilityCosts":      []model.UtilityCost{{ID: ucID, Name: "Electricity", Cost: 5}},
		"LinkedUtilityCostIDs": map[uuid.UUID]bool{},
		"CostHistory":          []model.RecipeCostSnapshot{},
		"UtilityTotal":         0.0,
	}
	tpl := r.pages["recipe_detail.html"]
	var buf bytes.Buffer
	if err := tpl.ExecuteTemplate(&buf, "recipe_detail.html", data); err != nil {
		t.Fatalf("render: %v", err)
	}
	body := buf.String()

	// Find the checkbox for Electricity and verify hx-vals is intact.
	idx := strings.Index(body, "Electricity")
	if idx == -1 {
		t.Fatal("Electricity missing")
	}
	start := idx - 1000
	if start < 0 {
		start = 0
	}
	near := body[start:idx]

	// Per-checkbox form with name="linked" value="true" is the CSP-safe
	// way to toggle: browsers submit the value only when the checkbox is
	// ticked, and the server reads r.FormValue("linked") == "true".
	for _, want := range []string{
		`hx-put="/recipes/`,
		`name="linked"`,
		`value="true"`,
	} {
		if !strings.Contains(near, want) {
			t.Fatalf("missing %q in checkbox markup.\nsurrounding html:\n%s", want, near)
		}
	}
}
