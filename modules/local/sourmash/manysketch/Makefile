all: build push

# TOOD: Switch to podman for building and quay.io for hosting images at some point
build:
	docker build -t olgabot/sourmash_branchwater .

push:
	docker push olgabot/sourmash_branchwater
