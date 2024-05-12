test:
	nextflow run -profile docker,test --outdir ./results .

clean:
	rm -rf .nextflow* results work

lint:
	pre-commit run --all-files 
	nf-core lint