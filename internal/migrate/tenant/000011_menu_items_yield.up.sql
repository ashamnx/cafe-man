-- Batch recipes: some items are made once and sold as N portions
-- (slice/piece/cup). Yield stores how many portions a single batch produces.
-- yield=1 is the default and preserves today's single-serve semantics.

ALTER TABLE menu_items
    ADD COLUMN yield      INT         NOT NULL DEFAULT 1 CHECK (yield > 0),
    ADD COLUMN yield_unit VARCHAR(30) NOT NULL DEFAULT '';

-- Snapshots must pin the yield value as of the snapshot time so per-portion
-- cost history stays truthful even if the user later edits yield.
ALTER TABLE recipe_cost_snapshots
    ADD COLUMN yield_at_snapshot INT NOT NULL DEFAULT 1;
