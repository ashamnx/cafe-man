DROP INDEX IF EXISTS idx_menu_items_status;
DROP INDEX IF EXISTS idx_menu_items_unique_name;
ALTER TABLE menu_items ADD COLUMN is_active BOOLEAN NOT NULL DEFAULT true;
UPDATE menu_items SET is_active = (status != 'deleted');
ALTER TABLE menu_items DROP COLUMN status;
