NAME       := staticsite
TAG        := latest
IMAGE_NAME := panubo/$(NAME)

.PHONY: build build-quick run-nginx run-s3sync shell push clean

build:
	docker build --pull -t $(IMAGE_NAME):$(TAG) .

build-quick:
	docker build -t $(IMAGE_NAME):$(TAG) .

.env:
	touch .env

run-nginx:
	docker run --rm -it -P $(IMAGE_NAME):$(TAG)

run-s3sync: .env
	@printf "AWS_SESSION_TOKEN=${AWS_SESSION_TOKEN}\nAWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}\nAWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}\nAWS_SECURITY_TOKEN=${AWS_SESSION_TOKEN}\n" > make.env
	docker run --rm -it --env-file .env --env-file make.env -v $(PWD)/html:/var/www/html $(IMAGE_NAME):$(TAG) s3sync
	-rm -f make.env

shell:
	docker run --rm -it $(IMAGE_NAME):$(TAG) bash

push:
	docker tag $(IMAGE_NAME):$(TAG) $(REGISTRY)/$(IMAGE_NAME):$(TAG)
	docker push $(REGISTRY)/$(IMAGE_NAME):$(TAG)

clean:
	docker rmi $(IMAGE_NAME):$(TAG)
