-- Promote utility costs from per-recipe denormalized rows to tenant-level
-- shared definitions (mirrors ingredients + ingredient_price_history),
-- with a dedicated per-recipe extras table for ad-hoc costs, and a
-- recipe_cost_snapshots append-only log for recipe cost history.

-- ============================================================
-- 1. Tenant-level utility cost definitions
-- ============================================================
CREATE TABLE utility_costs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL UNIQUE,
    cost DECIMAL(15,4) NOT NULL,
    description TEXT,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_utility_costs_name ON utility_costs(name);

-- ============================================================
-- 2. Utility cost price history (mirrors ingredient_price_history)
-- ============================================================
CREATE TABLE utility_cost_price_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    utility_cost_id UUID NOT NULL REFERENCES utility_costs(id) ON DELETE CASCADE,
    old_cost DECIMAL(15,4) NOT NULL,
    new_cost DECIMAL(15,4) NOT NULL,
    change_percentage DECIMAL(8,4) NOT NULL,
    source VARCHAR(50) NOT NULL DEFAULT 'manual',
    recorded_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_utility_cost_price_history_cost
    ON utility_cost_price_history(utility_cost_id, recorded_at DESC);

-- ============================================================
-- 3. Recipe cost snapshots (append-only log)
-- ============================================================
CREATE TABLE recipe_cost_snapshots (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    menu_item_id UUID NOT NULL REFERENCES menu_items(id) ON DELETE CASCADE,
    total_cost DECIMAL(15,4) NOT NULL,
    ingredient_cost DECIMAL(15,4) NOT NULL,
    utility_cost DECIMAL(15,4) NOT NULL,
    reason VARCHAR(255) NOT NULL,
    snapshot_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_recipe_cost_snapshots_menu_item
    ON recipe_cost_snapshots(menu_item_id, snapshot_at DESC);

-- ============================================================
-- 4. Promote existing per-recipe utility costs into tenant-level costs.
-- Uses MAX(cost) per distinct name as the canonical current value.
-- ============================================================
INSERT INTO utility_costs (name, cost)
SELECT name, MAX(cost) FROM recipe_utility_costs
GROUP BY name
ON CONFLICT (name) DO NOTHING;

-- ============================================================
-- 5. Rewrite recipe_utility_costs as a (menu_item_id, utility_cost_id) junction.
-- ============================================================
ALTER TABLE recipe_utility_costs RENAME TO recipe_utility_costs_old;

CREATE TABLE recipe_utility_costs (
    menu_item_id    UUID NOT NULL REFERENCES menu_items(id)    ON DELETE CASCADE,
    utility_cost_id UUID NOT NULL REFERENCES utility_costs(id) ON DELETE CASCADE,
    linked_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (menu_item_id, utility_cost_id)
);

CREATE INDEX idx_recipe_utility_costs_utility_cost
    ON recipe_utility_costs(utility_cost_id);

INSERT INTO recipe_utility_costs (menu_item_id, utility_cost_id)
SELECT DISTINCT r.menu_item_id, u.id
FROM recipe_utility_costs_old r
JOIN utility_costs u ON u.name = r.name;

DROP TABLE recipe_utility_costs_old;

-- ============================================================
-- 6. Per-recipe ad-hoc extras (one-off costs unique to a single recipe).
-- ============================================================
CREATE TABLE recipe_utility_cost_extras (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    menu_item_id UUID NOT NULL REFERENCES menu_items(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    cost DECIMAL(15,4) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (menu_item_id, name)
);

CREATE INDEX idx_recipe_utility_cost_extras_menu_item
    ON recipe_utility_cost_extras(menu_item_id);
