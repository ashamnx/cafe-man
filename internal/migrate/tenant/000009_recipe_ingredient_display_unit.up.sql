ALTER TABLE recipe_ingredients ADD COLUMN IF NOT EXISTS display_unit_id UUID REFERENCES units(id);
