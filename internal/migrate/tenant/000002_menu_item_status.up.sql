-- Add unique constraint on menu item name and replace is_active with status

-- Add status column (if not already present from a partial migration)
DO $$ BEGIN
    ALTER TABLE menu_items ADD COLUMN status VARCHAR(20) NOT NULL DEFAULT 'active'
        CHECK (status IN ('draft', 'active', 'deleted'));
EXCEPTION WHEN duplicate_column THEN NULL;
END $$;

-- Migrate is_active data: inactive items become 'deleted'
UPDATE menu_items SET status = 'deleted' WHERE is_active = false;

-- Drop is_active (if it still exists)
ALTER TABLE menu_items DROP COLUMN IF EXISTS is_active;

-- Deduplicate names before adding unique index:
-- For duplicate active names, append a suffix to all but the newest one.
UPDATE menu_items m
SET name = m.name || ' (' || LEFT(m.id::text, 8) || ')'
WHERE m.status != 'deleted'
  AND m.id != (
    SELECT id FROM menu_items m2
    WHERE m2.name = m.name AND m2.status != 'deleted'
    ORDER BY m2.created_at DESC
    LIMIT 1
  );

-- Add unique constraint on name (only for non-deleted items)
CREATE UNIQUE INDEX IF NOT EXISTS idx_menu_items_unique_name ON menu_items (name) WHERE status != 'deleted';

-- Index for status filtering
CREATE INDEX IF NOT EXISTS idx_menu_items_status ON menu_items(status);
