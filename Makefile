IMAGE_NAME := yui-infra-lab-api
CONTAINER_NAME := yui-infra-lab-api-container
PLATFORM := linux/amd64
HOST_PORT := 8080
CONTAINER_PORT := 80


api-build:
	@echo "Building $(IMAGE_NAME) ..."
	docker build --platform $(PLATFORM) -t $(IMAGE_NAME) -f docker/api/Dockerfile .

api-rm:
	@echo "Removing existing container $(CONTAINER_NAME) ..."
	docker rm -f $(CONTAINER_NAME) || true

api-log:
	@echo "Showing logs for $(CONTAINER_NAME) ..."
	docker logs -f $(CONTAINER_NAME)

api-run: api-rm
	@echo "Running container $(CONTAINER_NAME) ..."
	docker run -d -p $(HOST_PORT):$(CONTAINER_PORT) --name $(CONTAINER_NAME) $(IMAGE_NAME)

api-build-run: api-build api-run

api-stop:
	@echo "Stopping container $(CONTAINER_NAME) ..."
	docker stop $(CONTAINER_NAME) || true

api-down: api-stop api-rm

api-push:
	@echo "now implements."
