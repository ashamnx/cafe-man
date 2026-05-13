package handler

import (
	"io"
	"net/http"
	"strings"
	"time"

	"searlo-cafe/internal/storage"
)

// ImageProxyHandler serves images from DO Spaces through the app,
// avoiding CSP issues with external domains.
type ImageProxyHandler struct {
	store *storage.ImageStore
}

func NewImageProxyHandler(store *storage.ImageStore) *ImageProxyHandler {
	return &ImageProxyHandler{store: store}
}

func (h *ImageProxyHandler) RegisterRoutes(mux *http.ServeMux) {
	mux.HandleFunc("GET /images/", h.serve)
}

func (h *ImageProxyHandler) serve(w http.ResponseWriter, r *http.Request) {
	if h.store == nil {
		http.NotFound(w, r)
		return
	}

	objectKey := strings.TrimPrefix(r.URL.Path, "/images/")
	if objectKey == "" {
		http.NotFound(w, r)
		return
	}

	body, contentType, err := h.store.GetObject(r.Context(), objectKey)
	if err != nil {
		http.NotFound(w, r)
		return
	}
	defer body.Close()

	w.Header().Set("Content-Type", contentType)
	w.Header().Set("Cache-Control", "public, max-age=86400")
	w.Header().Set("Expires", time.Now().Add(24*time.Hour).UTC().Format(http.TimeFormat))
	io.Copy(w, body)
}
