BINARY    = searlo-cafe
SERVER    = root@178.128.208.168
DEPLOY_DIR = /opt/searlo-cafe

.PHONY: build deploy run

build:
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

run:
	go run ./cmd/server
