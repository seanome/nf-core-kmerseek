test_podman: clean
	nextflow run -profile test,podman --outdir ./results .

test_conda: clean
	nextflow run -profile conda,test --outdir ./results .

test_docker: clean
	nextflow run -profile docker,test --outdir ./results .

resume_docker:
	nextflow run -profile docker,test -resume --outdir ./results .

debug_conda: clean
	nextflow run . -profile debug,test,conda --outdir ./results

debug_docker: clean
	nextflow run . -profile debug,test,docker --outdir ./results

clean:
	rm -rf .nextflow* results work

lint:
	pre-commit run --all-files
	nf-core lint
