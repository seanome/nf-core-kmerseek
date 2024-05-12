test: clean
	nextflow run -profile docker,test --outdir ./results .

debug: clean
	nextflow run . -profile debug,test,docker --outdir ./results

clean:
	rm -rf .nextflow* results work

lint:
	pre-commit run --all-files 
	nf-core lint