package database

import (
	"context"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"
)

// SessionStore implements alexedwards/scs CtxStore interface using pgx v5.
type SessionStore struct {
	pool *pgxpool.Pool
}

func NewSessionStore(pool *pgxpool.Pool) *SessionStore {
	return &SessionStore{pool: pool}
}

func (s *SessionStore) Find(token string) ([]byte, bool, error) {
	return s.FindCtx(context.Background(), token)
}

func (s *SessionStore) Commit(token string, data []byte, expiry time.Time) error {
	return s.CommitCtx(context.Background(), token, data, expiry)
}

func (s *SessionStore) Delete(token string) error {
	return s.DeleteCtx(context.Background(), token)
}

func (s *SessionStore) FindCtx(ctx context.Context, token string) ([]byte, bool, error) {
	var data []byte
	err := s.pool.QueryRow(ctx,
		"SELECT data FROM sessions WHERE token = $1 AND expiry > $2",
		token, time.Now(),
	).Scan(&data)

	if err != nil {
		// pgx returns no rows as an error; treat as not found.
		return nil, false, nil
	}
	return data, true, nil
}

func (s *SessionStore) CommitCtx(ctx context.Context, token string, data []byte, expiry time.Time) error {
	_, err := s.pool.Exec(ctx,
		`INSERT INTO sessions (token, data, expiry)
		 VALUES ($1, $2, $3)
		 ON CONFLICT (token) DO UPDATE SET data = $2, expiry = $3`,
		token, data, expiry,
	)
	return err
}

func (s *SessionStore) DeleteCtx(ctx context.Context, token string) error {
	_, err := s.pool.Exec(ctx, "DELETE FROM sessions WHERE token = $1", token)
	return err
}

func (s *SessionStore) AllCtx(ctx context.Context) (map[string][]byte, error) {
	rows, err := s.pool.Query(ctx,
		"SELECT token, data FROM sessions WHERE expiry > $1",
		time.Now(),
	)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	sessions := make(map[string][]byte)
	for rows.Next() {
		var token string
		var data []byte
		if err := rows.Scan(&token, &data); err != nil {
			return nil, err
		}
		sessions[token] = data
	}
	return sessions, rows.Err()
}
