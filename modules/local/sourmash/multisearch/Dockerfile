FROM nfcore/base:2.1
LABEL \
    author="Olga Botvinnik" \
    description="sourmash branchwater image for nf-core pipelines" \
    maintainer="olga.botvinnik@gmail.com"

# Install the conda environment

RUN git clone --depth 1 --branch olgabot/multisearch-evalue https://github.com/sourmash-bio/sourmash_plugin_branchwater/
RUN cd sourmash_plugin_branchwater
COPY environment.yml /
RUN conda env create -f /environment.yml && conda clean -a

ARG SOURMASH_BRANCHWATER_VERSION=0.9.3

# Add conda installation dir to PATH (instead of doing 'conda activate')
ENV PATH /opt/conda/envs/nf-core-sourmash-branchwater-${SOURMASH_BRANCHWATER_VERSION}/bin:$PATH

# Dump the details of the installed packages to a file for posterity
RUN conda env export --name nf-core-sourmash-branchwater-${SOURMASH_BRANCHWATER_VERSION} > nf-core-sourmash-branchwater-${SOURMASH_BRANCHWATER_VERSION}.yml

# Install the python module
RUN pip install -e .

# Build rust dependencies
RUN maturin develop
