package ai

import (
	"context"
	"searlo-cafe/internal/model"
)

// BillScanner is the pluggable interface for AI-powered bill extraction.
// Implement this interface for different AI providers (Claude, OpenAI, etc.).
type BillScanner interface {
	// ExtractBillData takes a bill image (as bytes) and returns structured data.
	ExtractBillData(ctx context.Context, imageData []byte, mimeType string) (*model.AIBillExtraction, error)
}

// NoOpScanner is a placeholder that returns empty results.
// Used when no AI provider is configured.
type NoOpScanner struct{}

func (n *NoOpScanner) ExtractBillData(ctx context.Context, imageData []byte, mimeType string) (*model.AIBillExtraction, error) {
	return &model.AIBillExtraction{}, nil
}
