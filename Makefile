API_IMAGE_NAME := yui-lab-api
API_CONTAINER_NAME := yui-lab-api-container
API_PLATFORM := linux/amd64
API_HOST_PORT := 8080
API_CONTAINER_PORT := 80

INFRA_IMAGE_NAME := yui-lab-infra
INFRA_CONTAINER_NAME := yui-lab-infra-container
INFRA_WORKDIR := /work
INFRA_HOST_DIR := $(PWD)
INFRA_AWS_REGION := ap-northeast-1


build-api:
	docker build --platform $(API_PLATFORM) -t $(API_IMAGE_NAME) -f docker/api/Dockerfile .

rm-api:
	docker rm -f $(API_CONTAINER_NAME)

api: rm-api
	docker run -d -p $(API_HOST_PORT):$(API_CONTAINER_PORT) --name $(API_CONTAINER_NAME) $(API_IMAGE_NAME)

down-api:
	docker stop $(API_CONTAINER_NAME)
	make api-rm

push-api:
	@echo "now implements."


build-infra:
	docker build -t $(INFRA_IMAGE_NAME) -f docker/infra/Dockerfile .

rm-infra:
	docker rm -f $(INFRA_CONTAINER_NAME) || true

infra: rm-infra
	docker run -it \
		--name $(INFRA_CONTAINER_NAME) \
		-v $(INFRA_HOST_DIR):$(INFRA_WORKDIR) \
		-e AWS_ACCESS_KEY_ID=$$(aws configure get aws_access_key_id) \
		-e AWS_SECRET_ACCESS_KEY=$$(aws configure get aws_secret_access_key) \
		-e AWS_DEFAULT_REGION=$(INFRA_AWS_REGION) \
		$(INFRA_IMAGE_NAME)

down-infra:
	docker stop $(INFRA_CONTAINER_NAME)
	make rm-infra
