package ai

import (
	"bytes"
	"context"
	"encoding/base64"
	"encoding/json"
	"fmt"
	"io"
	"log/slog"
	"net/http"
	"time"

	"searlo-cafe/internal/model"
)

const geminiModel = "gemini-2.5-flash"
const geminiEndpoint = "https://generativelanguage.googleapis.com/v1beta/models/" + geminiModel + ":generateContent"

const billExtractionPrompt = `You are a bill/invoice data extraction assistant. Analyze this vendor bill image and extract the vendor details and all line items.

Return a JSON object with this exact structure (no markdown, no code fences, just raw JSON):
{
  "vendor_name": "name of the vendor/supplier if visible",
  "vendor_phone": "vendor phone number from the bill header if visible",
  "vendor_address": "vendor address from the bill header if visible",
  "bill_number": "invoice/bill number if visible",
  "bill_date": "date in YYYY-MM-DD format if visible",
  "total_amount": 123.45,
  "items": [
    {
      "name": "item name as written on the bill",
      "quantity": 10,
      "unit": "kg or liter or piece or pack or box or bottle or gram or ml",
      "unit_price": 5.50,
      "total": 55.00
    }
  ]
}

Rules:
- Extract EVERY line item from the bill
- For quantity, unit_price, and total: use numbers (not strings). Use null if not visible.
- For unit: normalize to one of: kg, g, liter, ml, piece, pack, box, bottle. Use the closest match.
- If a field is not visible or unclear, use an empty string for text fields or null for numbers
- For vendor_phone: capture just the digits and common separators (no labels like "Phone:" or "Tel:")
- For vendor_address: return a single line — collapse multi-line postal addresses by joining lines with ", "
- Do NOT include tax/service charge/discount as line items
- Return ONLY the JSON object, no other text`

type GeminiScanner struct {
	apiKey string
	client *http.Client
}

func NewGeminiScanner(apiKey string) *GeminiScanner {
	return &GeminiScanner{
		apiKey: apiKey,
		client: &http.Client{Timeout: 60 * time.Second},
	}
}

// geminiRequest is the Gemini API request format.
type geminiRequest struct {
	Contents []geminiContent `json:"contents"`
}

type geminiContent struct {
	Parts []geminiPart `json:"parts"`
}

type geminiPart struct {
	Text       string          `json:"text,omitempty"`
	InlineData *geminiInline   `json:"inline_data,omitempty"`
}

type geminiInline struct {
	MimeType string `json:"mime_type"`
	Data     string `json:"data"`
}

// geminiResponse is the Gemini API response format.
type geminiResponse struct {
	Candidates []struct {
		Content struct {
			Parts []struct {
				Text string `json:"text"`
			} `json:"parts"`
		} `json:"content"`
	} `json:"candidates"`
	Error *struct {
		Message string `json:"message"`
		Code    int    `json:"code"`
	} `json:"error"`
}

func (g *GeminiScanner) ExtractBillData(ctx context.Context, imageData []byte, mimeType string) (*model.AIBillExtraction, error) {
	b64Image := base64.StdEncoding.EncodeToString(imageData)

	reqBody := geminiRequest{
		Contents: []geminiContent{
			{
				Parts: []geminiPart{
					{Text: billExtractionPrompt},
					{InlineData: &geminiInline{
						MimeType: mimeType,
						Data:     b64Image,
					}},
				},
			},
		},
	}

	jsonBody, err := json.Marshal(reqBody)
	if err != nil {
		return nil, fmt.Errorf("marshal request: %w", err)
	}

	url := geminiEndpoint + "?key=" + g.apiKey
	req, err := http.NewRequestWithContext(ctx, http.MethodPost, url, bytes.NewReader(jsonBody))
	if err != nil {
		return nil, fmt.Errorf("create request: %w", err)
	}
	req.Header.Set("Content-Type", "application/json")

	resp, err := g.client.Do(req)
	if err != nil {
		return nil, fmt.Errorf("gemini api call: %w", err)
	}
	defer resp.Body.Close()

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, fmt.Errorf("read response: %w", err)
	}

	if resp.StatusCode != http.StatusOK {
		slog.Error("gemini api error", "status", resp.StatusCode, "body", string(body))
		return nil, fmt.Errorf("gemini api returned %d: %s", resp.StatusCode, string(body))
	}

	var gemResp geminiResponse
	if err := json.Unmarshal(body, &gemResp); err != nil {
		return nil, fmt.Errorf("unmarshal response: %w", err)
	}

	if gemResp.Error != nil {
		return nil, fmt.Errorf("gemini error: %s", gemResp.Error.Message)
	}

	if len(gemResp.Candidates) == 0 || len(gemResp.Candidates[0].Content.Parts) == 0 {
		return nil, fmt.Errorf("gemini returned no content")
	}

	rawText := gemResp.Candidates[0].Content.Parts[0].Text
	slog.Info("gemini extraction raw", "text", rawText)

	// Strip markdown code fences if present.
	cleaned := cleanJSON(rawText)

	var extraction model.AIBillExtraction
	if err := json.Unmarshal([]byte(cleaned), &extraction); err != nil {
		slog.Error("failed to parse gemini output", "raw", rawText, "error", err)
		return nil, fmt.Errorf("parse extraction json: %w", err)
	}

	slog.Info("gemini extraction success",
		"vendor", extraction.VendorName,
		"items", len(extraction.Items),
	)

	return &extraction, nil
}

// cleanJSON strips markdown code fences and whitespace from the response.
func cleanJSON(s string) string {
	// Remove ```json ... ``` wrapper if present.
	start := 0
	end := len(s)

	for i := 0; i < len(s); i++ {
		if s[i] == '{' || s[i] == '[' {
			start = i
			break
		}
	}
	for i := len(s) - 1; i >= 0; i-- {
		if s[i] == '}' || s[i] == ']' {
			end = i + 1
			break
		}
	}

	if start < end {
		return s[start:end]
	}
	return s
}
