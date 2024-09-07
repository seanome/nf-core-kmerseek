FROM continuumio/miniconda3
LABEL \
    author="Olga Botvinnik" \
    description="sourmash branchwater image for nf-core pipelines" \
    maintainer="olga.botvinnik@gmail.com"

# Install the conda environment
COPY environment.yml /
ARG SOURMASH_BRANCHWATER_VERSION=0.9.7

RUN conda env create --name nf-core-sourmash-branchwater-${SOURMASH_BRANCHWATER_VERSION} -f /environment.yml && conda clean -a


# Add conda installation dir to PATH (instead of doing 'conda activate')
ENV PATH /opt/conda/envs/nf-core-sourmash-branchwater-${SOURMASH_BRANCHWATER_VERSION}/bin:$PATH

# Dump the details of the installed packages to a file for posterity
RUN conda env export --name nf-core-kmerseek-${SOURMASH_BRANCHWATER_VERSION} > nf-core-kmerseek-${SOURMASH_BRANCHWATER_VERSION}.yml
