DELETE FROM role_permissions WHERE permission_id IN (SELECT id FROM permissions WHERE resource IN ('sales', 'wastage', 'stock_movements'));
DELETE FROM permissions WHERE resource IN ('sales', 'wastage', 'stock_movements');
DROP TABLE IF EXISTS stock_movements;
DROP TABLE IF EXISTS wastage_records;
DROP TABLE IF EXISTS sale_entry_deductions;
DROP TABLE IF EXISTS sale_entry_items;
DROP TABLE IF EXISTS sale_entries;
