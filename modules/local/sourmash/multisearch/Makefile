NAME=olgabot/sourmash_branchwater_multisearch_prob_overlap

all: build push

build:
	docker build --progress=plain -t ${NAME} .

push:
	docker push ${NAME}
