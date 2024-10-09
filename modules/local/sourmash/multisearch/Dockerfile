# Miniconda3 uses a faster solver than the one available for nf-core/base:2.1
FROM continuumio/miniconda3
LABEL \
    author="Olga Botvinnik" \
    description="sourmash branchwater image with specialized probability of overlap calculation for multisearch for nf-core pipelines" \
    maintainer="olga.botvinnik@gmail.com"

# Install the conda environment

ADD https://api.github.com/repos/sourmash-bio/sourmash_plugin_branchwater/git/refs/heads/olgabot/multisearch-evalue version.json
RUN git clone --depth 1 --branch olgabot/multisearch-evalue https://github.com/sourmash-bio/sourmash_plugin_branchwater/
RUN cd sourmash_plugin_branchwater \
    && conda env create -y -n sourmash-branchwater-multisearch-prob-overlap -f environment.yml

# COPY environment.yml /
# RUN conda env create -f /environment.yml && conda clean -a

# ARG SOURMASH_BRANCHWATER_VERSION=0.9.3

# Add conda installation dir to PATH (instead of doing 'conda activate')
ENV PATH /opt/conda/envs/sourmash-branchwater-multisearch-prob-overlap/bin:$PATH


RUN which -a conda
RUN which -a pip
RUN which -a maturin

# Need to install clang libraries
RUN apt update && apt-get install -y clang

RUN which -a clang

RUN cd sourmash_plugin_branchwater \
    && which -a pip \
    && which -a clang \
    && which -a maturin \
    && export LIBCLANG_PATH=/usr/lib/x86_64-linux-gnu/ \
    && export CONDA_PREFIX=/opt/conda \
    && pip install -e . \
    && maturin develop


# Dump the details of the installed packages to a file for posterity
RUN conda env export --name sourmash-branchwater-multisearch-prob-overlap > nf-core-sourmash-branchwater-${SOURMASH_BRANCHWATER_VERSION}.yml
