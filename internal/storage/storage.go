package storage

import (
	"bytes"
	"context"
	"fmt"
	"image"
	_ "image/jpeg"
	_ "image/png"
	"io"
	"net/http"
	"path/filepath"
	"strings"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/credentials"
	"github.com/aws/aws-sdk-go-v2/service/s3"
	s3types "github.com/aws/aws-sdk-go-v2/service/s3/types"
	"github.com/chai2010/webp"
	"github.com/google/uuid"
	"golang.org/x/image/draw"
	_ "golang.org/x/image/webp"
)

const (
	maxThumbWidth = 300
	webpQuality   = 80
)

// ImageStore handles uploading images to DigitalOcean Spaces (S3-compatible)
// and generating optimized WebP thumbnails.
type ImageStore struct {
	client *s3.Client
	bucket string
	prefix string // key prefix (subfolder), e.g. "searlo-cafe"
	cdnURL string
}

// NewSpacesStore creates an ImageStore configured for DigitalOcean Spaces.
// prefix is an optional key prefix (subfolder) within the bucket.
func NewSpacesStore(key, secret, endpoint, bucket, prefix, cdnURL string) *ImageStore {
	creds := credentials.NewStaticCredentialsProvider(key, secret, "")
	client := s3.New(s3.Options{
		Region:       "us-east-1", // required but ignored by DO Spaces
		BaseEndpoint: aws.String("https://" + endpoint),
		Credentials:  creds,
	})
	if cdnURL == "" {
		cdnURL = fmt.Sprintf("https://%s.%s", bucket, endpoint)
	}
	return &ImageStore{client: client, bucket: bucket, prefix: prefix, cdnURL: strings.TrimRight(cdnURL, "/")}
}

// Upload reads an image from r, uploads the original and a WebP thumbnail to Spaces.
// category is "recipes" or "ingredients". Returns the original's object key.
func (s *ImageStore) Upload(ctx context.Context, orgDB, category string, r io.Reader, filename string) (string, error) {
	data, err := io.ReadAll(r)
	if err != nil {
		return "", fmt.Errorf("read file: %w", err)
	}

	contentType := http.DetectContentType(data)
	if !isAllowedImage(contentType) {
		return "", fmt.Errorf("unsupported image type: %s", contentType)
	}

	ext := extFromContentType(contentType)
	id := uuid.New().String()

	keyBase := fmt.Sprintf("%s/%s/%s", orgDB, category, id)
	if s.prefix != "" {
		keyBase = s.prefix + "/" + keyBase
	}
	originalKey := keyBase + "_original" + ext

	// Upload original.
	if _, err := s.client.PutObject(ctx, &s3.PutObjectInput{
		Bucket:      &s.bucket,
		Key:         &originalKey,
		Body:        bytes.NewReader(data),
		ContentType: &contentType,
		ACL:         s3types.ObjectCannedACLPublicRead,
	}); err != nil {
		return "", fmt.Errorf("upload original: %w", err)
	}

	// Generate and upload thumbnail.
	thumbData, err := generateThumbnail(data)
	if err != nil {
		// Original uploaded successfully; log but don't fail.
		return originalKey, nil
	}

	thumbKey := keyBase + "_thumb.webp"
	thumbCT := "image/webp"
	if _, err := s.client.PutObject(ctx, &s3.PutObjectInput{
		Bucket:      &s.bucket,
		Key:         &thumbKey,
		Body:        bytes.NewReader(thumbData),
		ContentType: &thumbCT,
		ACL:         s3types.ObjectCannedACLPublicRead,
	}); err != nil {
		// Original uploaded; thumbnail failed — not fatal.
		return originalKey, nil
	}

	return originalKey, nil
}

// URL returns the full URL for an object key.
func (s *ImageStore) URL(objectKey string) string {
	if objectKey == "" {
		return ""
	}
	return s.cdnURL + "/" + objectKey
}

// ThumbURL derives the thumbnail URL from an original's object key.
func (s *ImageStore) ThumbURL(objectKey string) string {
	if objectKey == "" {
		return ""
	}
	idx := strings.LastIndex(objectKey, "_original.")
	if idx == -1 {
		return s.URL(objectKey)
	}
	return s.cdnURL + "/" + objectKey[:idx] + "_thumb.webp"
}

// Delete removes both original and thumbnail from Spaces.
func (s *ImageStore) Delete(ctx context.Context, objectKey string) error {
	if objectKey == "" {
		return nil
	}

	if _, err := s.client.DeleteObject(ctx, &s3.DeleteObjectInput{
		Bucket: &s.bucket,
		Key:    &objectKey,
	}); err != nil {
		return fmt.Errorf("delete original: %w", err)
	}

	// Derive and delete thumbnail.
	idx := strings.LastIndex(objectKey, "_original.")
	if idx != -1 {
		thumbKey := objectKey[:idx] + "_thumb.webp"
		s.client.DeleteObject(ctx, &s3.DeleteObjectInput{
			Bucket: &s.bucket,
			Key:    &thumbKey,
		})
	}

	return nil
}

// GetObject fetches an object from Spaces. Caller must close the body.
func (s *ImageStore) GetObject(ctx context.Context, objectKey string) (io.ReadCloser, string, error) {
	out, err := s.client.GetObject(ctx, &s3.GetObjectInput{
		Bucket: &s.bucket,
		Key:    &objectKey,
	})
	if err != nil {
		return nil, "", err
	}
	ct := "application/octet-stream"
	if out.ContentType != nil {
		ct = *out.ContentType
	}
	return out.Body, ct, nil
}

func generateThumbnail(data []byte) ([]byte, error) {
	src, _, err := image.Decode(bytes.NewReader(data))
	if err != nil {
		return nil, fmt.Errorf("decode image: %w", err)
	}

	bounds := src.Bounds()
	srcW := bounds.Dx()
	srcH := bounds.Dy()

	// Only resize if wider than max.
	dstW := srcW
	dstH := srcH
	if srcW > maxThumbWidth {
		dstW = maxThumbWidth
		dstH = srcH * maxThumbWidth / srcW
	}

	dst := image.NewRGBA(image.Rect(0, 0, dstW, dstH))
	draw.BiLinear.Scale(dst, dst.Bounds(), src, bounds, draw.Over, nil)

	var buf bytes.Buffer
	if err := webp.Encode(&buf, dst, &webp.Options{Quality: webpQuality}); err != nil {
		return nil, fmt.Errorf("encode webp: %w", err)
	}

	return buf.Bytes(), nil
}

func isAllowedImage(contentType string) bool {
	switch contentType {
	case "image/jpeg", "image/png", "image/webp":
		return true
	}
	return false
}

func extFromContentType(contentType string) string {
	switch contentType {
	case "image/jpeg":
		return ".jpg"
	case "image/png":
		return ".png"
	case "image/webp":
		return ".webp"
	default:
		return filepath.Ext(contentType)
	}
}
