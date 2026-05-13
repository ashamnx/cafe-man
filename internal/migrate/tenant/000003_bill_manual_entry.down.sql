ALTER TABLE vendor_bills DROP COLUMN entry_type;
UPDATE vendor_bills SET image_path = '' WHERE image_path IS NULL;
ALTER TABLE vendor_bills ALTER COLUMN image_path SET NOT NULL;
