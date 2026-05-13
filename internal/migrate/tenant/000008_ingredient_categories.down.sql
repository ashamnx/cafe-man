ALTER TABLE ingredients ADD COLUMN category VARCHAR(100);
CREATE INDEX idx_ingredients_category ON ingredients(category);

UPDATE ingredients i
   SET category = c.name
  FROM ingredient_categories c
 WHERE i.category_id = c.id;

DROP INDEX IF EXISTS idx_ingredients_category_id;
ALTER TABLE ingredients DROP COLUMN category_id;
DROP INDEX IF EXISTS idx_ingredient_categories_name_lower;
DROP TABLE IF EXISTS ingredient_categories;
