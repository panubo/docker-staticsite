NAME       := staticsite
TAG        := test
IMAGE_NAME := panubo/$(NAME)

.PHONY: help build build-quick run-nginx run-nginx-spa run-s3sync shell push clean

help:
	@printf "$$(grep -hE '^\S+:.*##' $(MAKEFILE_LIST) | sed -e 's/:.*##\s*/:/' -e 's/^\(.\+\):\(.*\)/\\x1b[36m\1\\x1b[m:\2/' | column -c2 -t -s :)\n"

build:  ## build image
	docker build --pull -t $(IMAGE_NAME):$(TAG) .

build-quick:  ## build quick image
	docker build -t $(IMAGE_NAME):$(TAG) .

.env:
	touch .env

run-nginx:
	docker run --rm -it -P $(IMAGE_NAME):$(TAG)

run-nginx-spa:
	docker run --rm -it -e NGINX_SINGLE_PAGE_ENABLED=true -P $(IMAGE_NAME):$(TAG)

run-s3sync: .env
	@printf "AWS_SESSION_TOKEN=${AWS_SESSION_TOKEN}\nAWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}\nAWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}\nAWS_SECURITY_TOKEN=${AWS_SESSION_TOKEN}\n" > make.env
	docker run --rm -it --env-file .env --env-file make.env -v $(PWD)/html:/var/www/html $(IMAGE_NAME):$(TAG) s3sync
	-rm -f make.env

shell:
	docker run --rm -it $(IMAGE_NAME):$(TAG) bash

push:
	docker push $(IMAGE_NAME):$(TAG)

clean:
	docker rmi $(IMAGE_NAME):$(TAG) || true

test:  ## run test suite
	( cd tests; bats -j 4 . )
