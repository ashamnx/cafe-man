-- Per-tenant database schema
-- Contains all business data: RBAC, ingredients, vendors, bills, menu items, alerts

CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ============================================================
-- RBAC
-- ============================================================

CREATE TABLE roles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) UNIQUE NOT NULL,
    description TEXT,
    is_system BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE permissions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    resource VARCHAR(100) NOT NULL,
    action VARCHAR(50) NOT NULL,
    description TEXT,
    UNIQUE(resource, action)
);

CREATE TABLE role_permissions (
    role_id UUID NOT NULL REFERENCES roles(id) ON DELETE CASCADE,
    permission_id UUID NOT NULL REFERENCES permissions(id) ON DELETE CASCADE,
    PRIMARY KEY (role_id, permission_id)
);

-- user_id references users in the platform DB (not a FK since cross-DB)
CREATE TABLE user_roles (
    user_id UUID NOT NULL,
    role_id UUID NOT NULL REFERENCES roles(id) ON DELETE CASCADE,
    PRIMARY KEY (user_id, role_id)
);

CREATE INDEX idx_user_roles_user ON user_roles(user_id);

-- ============================================================
-- Units of measure
-- ============================================================

CREATE TABLE units (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(50) UNIQUE NOT NULL,
    abbreviation VARCHAR(10) NOT NULL,
    unit_type VARCHAR(20) NOT NULL CHECK (unit_type IN ('weight', 'volume', 'count')),
    base_unit_id UUID REFERENCES units(id),
    conversion_factor DECIMAL(15,6),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================
-- Ingredients
-- ============================================================

CREATE TABLE ingredients (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    unit_id UUID NOT NULL REFERENCES units(id),
    current_stock DECIMAL(15,4) NOT NULL DEFAULT 0,
    current_cost_per_unit DECIMAL(15,4) NOT NULL DEFAULT 0,
    low_stock_threshold DECIMAL(15,4),
    price_alert_percentage DECIMAL(5,2) DEFAULT 10.00,
    category VARCHAR(100),
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_ingredients_name ON ingredients(name);
CREATE INDEX idx_ingredients_category ON ingredients(category);

CREATE TABLE ingredient_price_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ingredient_id UUID NOT NULL REFERENCES ingredients(id) ON DELETE CASCADE,
    old_cost_per_unit DECIMAL(15,4) NOT NULL,
    new_cost_per_unit DECIMAL(15,4) NOT NULL,
    change_percentage DECIMAL(8,4) NOT NULL,
    source VARCHAR(50) NOT NULL CHECK (source IN ('bill_scan', 'manual')),
    bill_id UUID,
    recorded_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_price_history_ingredient ON ingredient_price_history(ingredient_id, recorded_at DESC);

-- ============================================================
-- Vendors
-- ============================================================

CREATE TABLE vendors (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    contact_name VARCHAR(255),
    phone VARCHAR(50),
    email VARCHAR(255),
    address TEXT,
    notes TEXT,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_vendors_name ON vendors(name);

-- ============================================================
-- Vendor Bills
-- ============================================================

CREATE TABLE vendor_bills (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    vendor_id UUID REFERENCES vendors(id),
    bill_number VARCHAR(100),
    bill_date DATE,
    total_amount DECIMAL(15,4),
    image_path TEXT NOT NULL,
    ai_raw_response JSONB,
    status VARCHAR(20) NOT NULL DEFAULT 'pending'
        CHECK (status IN ('pending', 'processing', 'mapped', 'partially_mapped', 'failed')),
    notes TEXT,
    created_by UUID NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_vendor_bills_vendor ON vendor_bills(vendor_id);
CREATE INDEX idx_vendor_bills_status ON vendor_bills(status);

CREATE TABLE vendor_bill_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    bill_id UUID NOT NULL REFERENCES vendor_bills(id) ON DELETE CASCADE,
    raw_item_name VARCHAR(255) NOT NULL,
    raw_quantity DECIMAL(15,4),
    raw_unit VARCHAR(50),
    raw_unit_price DECIMAL(15,4),
    raw_total_price DECIMAL(15,4),
    ingredient_id UUID REFERENCES ingredients(id),
    mapped_quantity DECIMAL(15,4),
    mapping_status VARCHAR(20) NOT NULL DEFAULT 'unmapped'
        CHECK (mapping_status IN ('auto_mapped', 'manually_mapped', 'unmapped', 'skipped')),
    mapped_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_bill_items_bill ON vendor_bill_items(bill_id);
CREATE INDEX idx_bill_items_mapping ON vendor_bill_items(mapping_status);

-- ============================================================
-- Menu
-- ============================================================

CREATE TABLE menu_categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL,
    sort_order INT NOT NULL DEFAULT 0,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE menu_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    category_id UUID REFERENCES menu_categories(id),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    image_path TEXT,
    selling_price DECIMAL(15,4) NOT NULL DEFAULT 0,
    is_active BOOLEAN NOT NULL DEFAULT true,
    preparation_notes TEXT,
    allergens TEXT[],
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_menu_items_category ON menu_items(category_id);

CREATE TABLE recipe_ingredients (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    menu_item_id UUID NOT NULL REFERENCES menu_items(id) ON DELETE CASCADE,
    ingredient_id UUID NOT NULL REFERENCES ingredients(id),
    quantity DECIMAL(15,4) NOT NULL,
    ingredient_type VARCHAR(20) NOT NULL DEFAULT 'primary'
        CHECK (ingredient_type IN ('primary', 'secondary')),
    notes TEXT,
    UNIQUE(menu_item_id, ingredient_id)
);

CREATE INDEX idx_recipe_ingredients_menu ON recipe_ingredients(menu_item_id);

CREATE TABLE recipe_utility_costs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    menu_item_id UUID NOT NULL REFERENCES menu_items(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    cost DECIMAL(15,4) NOT NULL,
    UNIQUE(menu_item_id, name)
);

-- ============================================================
-- Alerts
-- ============================================================

CREATE TABLE alerts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    alert_type VARCHAR(30) NOT NULL CHECK (alert_type IN ('price_increase', 'low_stock')),
    ingredient_id UUID NOT NULL REFERENCES ingredients(id),
    message TEXT NOT NULL,
    details JSONB,
    is_read BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_alerts_unread ON alerts(is_read, created_at DESC);
CREATE INDEX idx_alerts_ingredient ON alerts(ingredient_id);

-- ============================================================
-- Seed: default units
-- ============================================================

INSERT INTO units (name, abbreviation, unit_type) VALUES
    ('kilogram', 'kg', 'weight'),
    ('gram', 'g', 'weight'),
    ('liter', 'L', 'volume'),
    ('milliliter', 'ml', 'volume'),
    ('piece', 'pc', 'count'),
    ('pack', 'pack', 'count'),
    ('bottle', 'btl', 'count'),
    ('box', 'box', 'count');

-- Set base unit relationships
UPDATE units SET base_unit_id = (SELECT id FROM units WHERE name = 'kilogram'), conversion_factor = 0.001 WHERE name = 'gram';
UPDATE units SET base_unit_id = (SELECT id FROM units WHERE name = 'liter'), conversion_factor = 0.001 WHERE name = 'milliliter';

-- ============================================================
-- Seed: default permissions
-- ============================================================

INSERT INTO permissions (resource, action, description) VALUES
    ('ingredients', 'create', 'Create ingredients'),
    ('ingredients', 'read', 'View ingredients'),
    ('ingredients', 'update', 'Edit ingredients'),
    ('ingredients', 'delete', 'Delete ingredients'),
    ('vendors', 'create', 'Create vendors'),
    ('vendors', 'read', 'View vendors'),
    ('vendors', 'update', 'Edit vendors'),
    ('vendors', 'delete', 'Delete vendors'),
    ('bills', 'create', 'Upload vendor bills'),
    ('bills', 'read', 'View vendor bills'),
    ('bills', 'update', 'Edit/map vendor bills'),
    ('bills', 'delete', 'Delete vendor bills'),
    ('menu_items', 'create', 'Create menu items'),
    ('menu_items', 'read', 'View menu items'),
    ('menu_items', 'update', 'Edit menu items'),
    ('menu_items', 'delete', 'Delete menu items'),
    ('alerts', 'read', 'View alerts'),
    ('alerts', 'update', 'Manage alerts'),
    ('roles', 'create', 'Create roles'),
    ('roles', 'read', 'View roles'),
    ('roles', 'update', 'Edit roles'),
    ('roles', 'delete', 'Delete roles'),
    ('users', 'create', 'Invite users'),
    ('users', 'read', 'View users'),
    ('users', 'update', 'Edit user roles'),
    ('users', 'delete', 'Remove users'),
    ('settings', 'read', 'View settings'),
    ('settings', 'update', 'Edit settings');

-- ============================================================
-- Seed: default roles with permissions
-- ============================================================

INSERT INTO roles (name, description, is_system) VALUES
    ('owner', 'Full access to everything', true),
    ('manager', 'Manage ingredients, vendors, bills, and menu', true),
    ('staff', 'View-only access with bill upload', true);

-- Owner gets all permissions
INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id FROM roles r CROSS JOIN permissions p WHERE r.name = 'owner';

-- Manager gets most permissions except role/user management
INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id FROM roles r CROSS JOIN permissions p
WHERE r.name = 'manager'
  AND p.resource NOT IN ('roles', 'users', 'settings');

-- Staff gets read + bill upload
INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id FROM roles r CROSS JOIN permissions p
WHERE r.name = 'staff'
  AND (p.action = 'read' OR (p.resource = 'bills' AND p.action = 'create'));
