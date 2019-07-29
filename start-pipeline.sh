docker run --rm -u $UID:1000 -ti -v `pwd`:/data -w /data oskarv/bigger-vcfs snakemake -j -p
