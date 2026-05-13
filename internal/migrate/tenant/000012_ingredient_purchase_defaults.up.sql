-- Persist the bulk purchase fields (qty + unit + total price) that the
-- ingredient form's purchase calculator collects. Previously these were
-- discarded after computing current_cost_per_unit, so the bulk context
-- (e.g., "500g for MVR 55") was lost.
--
-- Used as the fallback for the ingredients list "bulk price" column when
-- no mapped vendor_bill_items row exists yet for the ingredient.

ALTER TABLE ingredients
    ADD COLUMN IF NOT EXISTS purchase_qty DECIMAL(15,4),
    ADD COLUMN IF NOT EXISTS purchase_unit_id UUID REFERENCES units(id),
    ADD COLUMN IF NOT EXISTS purchase_price DECIMAL(15,4);
