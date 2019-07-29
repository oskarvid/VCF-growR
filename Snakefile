CONTIGS = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22]


rule all:
	input:
		expand("hg19-vcfs/fixed-contig-{contig}.vcf.gz", contig=CONTIGS),
		expand("hg19-vcfs-bigger/bigger-chr{contig}.vcf.gz.tbi", contig=CONTIGS),

rule zcat:
	input:
		file = "hg19-vcfs/fixed-contig-{contig}.vcf.gz",
	output:
		stripped = temp("scratch/{contig}-stripped"),
		samples = temp("scratch/{contig}-samples"),
		header = temp("scratch/{contig}-header"),
	shell:
		"zcat {input.file} | tee >(grep -v '##' | tee >(cut -f -9 > {output.stripped}) >(cut -f 10- > {output.samples}) > /dev/null) \
		>(cut -f -9 | tee >(grep '##' > {output.header}) > /dev/null) > /dev/null"

rule rscript:
	input:
		r = "/data/optimized-add-samples.R",
		file = "scratch/{contig}-samples",
	output:
		temp("scratch/{contig}-samples-bigger"),
	threads: 1
	shell:
		"Rscript {input.r} {input.file}"

rule paste:
	input:
		routput = "scratch/{contig}-samples-bigger",
		stripped = "scratch/{contig}-stripped",
		header = "scratch/{contig}-header",
	output:
		file = temp("scratch/{contig}-symbolic-output-file"),
	shell:
		"paste {input.stripped} {input.routput} >> {input.header} && \
		touch {output.file}"

rule bgzip:
	input:
		tozip = "scratch/{contig}-header",
		dummy = "scratch/{contig}-symbolic-output-file"
	output:
		gzip = "hg19-vcfs-bigger/bigger-chr{contig}.vcf.gz",
		tbi = "hg19-vcfs-bigger/bigger-chr{contig}.vcf.gz.tbi",
	shell:
		"bgzip -c {input.tozip} > {output.gzip} && \
		tabix -p vcf {output.gzip}"
