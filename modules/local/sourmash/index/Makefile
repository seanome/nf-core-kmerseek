all: build push

build:
	docker build -t olgabot/sourmash_branchwater:0.9.7 .

push:
	docker push olgabot/sourmash_branchwater:0.9.7


test: test_branchwater test_sourmash

test_sourmash:
	docker run -it olgabot/sourmash_branchwater:0.9.7 sourmash --help

test_branchwater:
	docker run -it olgabot/sourmash_branchwater:0.9.7 sourmash scripts --help
