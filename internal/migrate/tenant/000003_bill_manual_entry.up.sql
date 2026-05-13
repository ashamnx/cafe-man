-- Allow manual bill entry without an image
ALTER TABLE vendor_bills ALTER COLUMN image_path DROP NOT NULL;

-- Track how the bill was created
ALTER TABLE vendor_bills ADD COLUMN entry_type VARCHAR(10) NOT NULL DEFAULT 'scan'
    CHECK (entry_type IN ('scan', 'manual'));
