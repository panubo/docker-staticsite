NAME       := staticsite-example
TAG        := latest
IMAGE_NAME := panubo/$(NAME)

.PHONY: *

build:
	docker build --pull -t $(IMAGE_NAME):$(TAG) .

run:
	docker run --rm -it -P -e MYCONFIG=somevalue $(IMAGE_NAME):$(TAG)

shell:
	docker run --rm -it $(IMAGE_NAME):$(TAG) bash

clean:
	docker rmi $(IMAGE_NAME):$(TAG) || true
