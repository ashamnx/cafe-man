DELETE FROM role_permissions WHERE permission_id IN (SELECT id FROM permissions WHERE resource = 'audit_log');
DELETE FROM permissions WHERE resource = 'audit_log';
DROP TABLE IF EXISTS audit_log;
