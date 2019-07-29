FROM oskarv/snakemake-germline-tools

RUN apt update && apt -y install \
tabix \
r-base