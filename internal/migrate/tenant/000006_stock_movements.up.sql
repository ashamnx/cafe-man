-- Stock out (sales), wastage tracking, and unified stock movements ledger.

-- ============================================================
-- Sales entries: daily sales batch (similar to vendor_bills)
-- ============================================================

CREATE TABLE sale_entries (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    sale_date DATE NOT NULL,
    notes TEXT,
    status VARCHAR(20) NOT NULL DEFAULT 'draft'
        CHECK (status IN ('draft', 'applied')),
    created_by UUID NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_sale_entries_date ON sale_entries(sale_date DESC);
CREATE INDEX idx_sale_entries_status ON sale_entries(status);

-- Line items: which menu items were sold and how many
CREATE TABLE sale_entry_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    sale_entry_id UUID NOT NULL REFERENCES sale_entries(id) ON DELETE CASCADE,
    menu_item_id UUID NOT NULL REFERENCES menu_items(id),
    quantity INT NOT NULL CHECK (quantity > 0),
    selling_price DECIMAL(15,4) NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_sale_entry_items_entry ON sale_entry_items(sale_entry_id);

-- Deduction snapshot: ingredient quantities actually deducted when the sale was applied.
-- Captures recipe state at apply time so future recipe changes don't corrupt history.
CREATE TABLE sale_entry_deductions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    sale_entry_id UUID NOT NULL REFERENCES sale_entries(id) ON DELETE CASCADE,
    sale_entry_item_id UUID NOT NULL REFERENCES sale_entry_items(id) ON DELETE CASCADE,
    ingredient_id UUID NOT NULL REFERENCES ingredients(id),
    quantity_per_unit DECIMAL(15,4) NOT NULL,
    total_quantity DECIMAL(15,4) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_sale_deductions_entry ON sale_entry_deductions(sale_entry_id);
CREATE INDEX idx_sale_deductions_ingredient ON sale_entry_deductions(ingredient_id);

-- ============================================================
-- Wastage records
-- ============================================================

CREATE TABLE wastage_records (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ingredient_id UUID NOT NULL REFERENCES ingredients(id),
    quantity DECIMAL(15,4) NOT NULL CHECK (quantity > 0),
    wastage_type VARCHAR(30) NOT NULL
        CHECK (wastage_type IN ('expired', 'preparation_loss', 'damaged', 'returned')),
    wastage_date DATE NOT NULL DEFAULT CURRENT_DATE,
    notes TEXT,
    created_by UUID NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_wastage_records_ingredient ON wastage_records(ingredient_id);
CREATE INDEX idx_wastage_records_date ON wastage_records(wastage_date DESC);
CREATE INDEX idx_wastage_records_type ON wastage_records(wastage_type);

-- ============================================================
-- Unified stock movements ledger
-- ============================================================

CREATE TABLE stock_movements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ingredient_id UUID NOT NULL REFERENCES ingredients(id),
    quantity DECIMAL(15,4) NOT NULL,
    movement_type VARCHAR(20) NOT NULL
        CHECK (movement_type IN ('purchase', 'sale', 'wastage', 'adjustment')),
    reference_type VARCHAR(20),
    reference_id UUID,
    notes TEXT,
    created_by UUID NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_stock_movements_ingredient ON stock_movements(ingredient_id, created_at DESC);
CREATE INDEX idx_stock_movements_type ON stock_movements(movement_type);
CREATE INDEX idx_stock_movements_date ON stock_movements(created_at DESC);
CREATE INDEX idx_stock_movements_ref ON stock_movements(reference_type, reference_id);

-- ============================================================
-- Permissions
-- ============================================================

INSERT INTO permissions (resource, action, description) VALUES
    ('sales', 'create', 'Record daily sales'),
    ('sales', 'read', 'View sales entries'),
    ('sales', 'update', 'Edit and apply sales entries'),
    ('sales', 'delete', 'Delete sales entries'),
    ('wastage', 'create', 'Record wastage'),
    ('wastage', 'read', 'View wastage records'),
    ('wastage', 'update', 'Edit wastage records'),
    ('wastage', 'delete', 'Delete wastage records'),
    ('stock_movements', 'read', 'View stock movement history');

-- Owner gets all new permissions
INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id FROM roles r CROSS JOIN permissions p
WHERE r.name = 'owner' AND p.resource IN ('sales', 'wastage', 'stock_movements');

-- Manager gets all new permissions
INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id FROM roles r CROSS JOIN permissions p
WHERE r.name = 'manager' AND p.resource IN ('sales', 'wastage', 'stock_movements');

-- Staff gets read + create on sales and wastage, read on stock_movements
INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id FROM roles r CROSS JOIN permissions p
WHERE r.name = 'staff'
  AND ((p.resource IN ('sales', 'wastage') AND p.action IN ('read', 'create'))
    OR (p.resource = 'stock_movements' AND p.action = 'read'));
