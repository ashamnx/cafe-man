ALTER TABLE vendor_bill_items ADD COLUMN IF NOT EXISTS bill_unit_id UUID REFERENCES units(id);
ALTER TABLE vendor_bill_items ADD COLUMN IF NOT EXISTS mapped_unit_price DECIMAL(15,4);
