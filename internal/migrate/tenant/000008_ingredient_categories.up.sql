-- Ingredient categories (independent from menu_categories).
CREATE TABLE ingredient_categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL,
    sort_order INT NOT NULL DEFAULT 0,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE UNIQUE INDEX idx_ingredient_categories_name_lower
    ON ingredient_categories (LOWER(name));

ALTER TABLE ingredients
    ADD COLUMN category_id UUID REFERENCES ingredient_categories(id) ON DELETE SET NULL;

CREATE INDEX idx_ingredients_category_id ON ingredients(category_id);

INSERT INTO ingredient_categories (name, sort_order)
SELECT DISTINCT ON (LOWER(TRIM(category))) TRIM(category), 0
FROM ingredients
WHERE category IS NOT NULL AND TRIM(category) <> ''
ORDER BY LOWER(TRIM(category)), TRIM(category);

UPDATE ingredients i
   SET category_id = c.id
  FROM ingredient_categories c
 WHERE i.category IS NOT NULL
   AND TRIM(i.category) <> ''
   AND LOWER(TRIM(i.category)) = LOWER(c.name);

DROP INDEX IF EXISTS idx_ingredients_category;
ALTER TABLE ingredients DROP COLUMN category;
