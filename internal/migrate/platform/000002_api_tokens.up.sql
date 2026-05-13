-- API refresh tokens for mobile/external clients
CREATE TABLE api_refresh_tokens (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token_hash TEXT NOT NULL UNIQUE,
    expires_at TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_refresh_tokens_user ON api_refresh_tokens(user_id);
CREATE INDEX idx_refresh_tokens_expiry ON api_refresh_tokens(expires_at);
