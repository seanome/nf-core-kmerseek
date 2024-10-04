NAME=olgabot/sourmash_branchwater_multisearch_prob_overlap

all: build login push

# TOOD: Switch to podman for building and quay.io for hosting images at some point
build:
	docker build -t ${NAME} .

login:
	docker login

push:
	docker push ${NAME}
