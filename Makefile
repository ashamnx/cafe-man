BINARY    = searlo-cafe
SERVER    = root@178.128.208.168
DEPLOY_DIR = /opt/searlo-cafe

CSS_INPUT  = tailwind.input.css
CSS_OUTPUT = internal/handler/static/css/tailwind.css
CSS_SOURCES = $(CSS_INPUT) tailwind.config.js $(shell find internal/handler/templates -name '*.html')

.PHONY: build deploy run css css-watch

# Rebuild the Tailwind CSS bundle. The Go binary embeds internal/handler/static,
# so a fresh CSS file requires a Go rebuild/restart to take effect.
css: $(CSS_OUTPUT)

$(CSS_OUTPUT): $(CSS_SOURCES)
	npx --yes tailwindcss@3 -i $(CSS_INPUT) -o $(CSS_OUTPUT) --minify

css-watch:
	npx --yes tailwindcss@3 -i $(CSS_INPUT) -o $(CSS_OUTPUT) --watch

build: css
	docker run --rm \
		-v $(CURDIR):/src \
		-v searlo-cafe-gomod:/go/pkg/mod \
		-v searlo-cafe-gobuild:/root/.cache/go-build \
		-w /src --platform linux/amd64 golang:1.26 \
		go build -o $(BINARY) ./cmd/server

deploy: build
	ssh $(SERVER) 'systemctl stop $(BINARY)'
	scp $(BINARY) $(SERVER):$(DEPLOY_DIR)/$(BINARY)
	ssh $(SERVER) 'chmod +x $(DEPLOY_DIR)/$(BINARY) && systemctl start $(BINARY)'
	@echo "Deployed. Checking status..."
	@sleep 2
	ssh $(SERVER) 'systemctl status $(BINARY) --no-pager'

run: css
	go run ./cmd/server
