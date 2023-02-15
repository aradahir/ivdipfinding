import snakemake
import glob
from os import path

#place config file at the same directory with snakemake scripts
configfile: "config.yaml"

(ppID,readID) = glob_wildcards("data/{pp}_L001_{read}_001.fastq.gz")
workspace = config['work_dir']
subtype = config['subtype']

rule all:
	input:
		expand('output/{ppID}_{subtype}_Virus_Recombination_Results.par5', ppID = ppID, subtype = subtype)
	
rule fastp:
	message: "Merging fastq files"
	input:
		input_R1 = 'data/{ppID}_L001_R1_001.fastq.gz',
		input_R2 = 'data/{ppID}_L001_R2_001.fastq.gz'
	output:
		fastq = 'fastp_result/{ppID}_merged_out.fastq'
	shell:
 		"fastp --in1 {input.input_R1} --in2 {input.input_R2} --dedup -m --merged_out {output.fastq} --detect_adapter_for_pe"
		

rule bowtie2:
	message: "Aligning to reference using Bowtie2"
	input:
		merged_fastq = 'fastp_result/{ppID}_merged_out.fastq'
	output:
		status = 'bowtie2_result/{ppID}_bowtie_result_{subtype}.txt'
	params:
		ref = 'config/reference/bowtie2_index/' + subtype + '/' + subtype,
		name_align = 'bowtie2_result/{ppID}_aligned_{subtype}.fq',
		sam_file = 'bowtie2_result/{ppID}_{subtype}.sam',
		unaligned_fq = 'bowtie2_result/{ppID}_unalign_{subtype}.fq'
	shell: '''	
 		bowtie2 \
 		-x {params.ref} \
 		-U {input.merged_fastq} \
 		--score-min L,0,-0.3 \
 		--al {params.name_align} \
 		--un {params.unaligned_fq} > {params.sam_file}
 		touch {output.status}
		'''

rule virema:
	message: "Running virema"
	input:
		'bowtie2_result/{ppID}_bowtie_result_{subtype}.txt'
	output:
		'virema_result/{ppID}_result_{subtype}.txt'
	params:
		ref_index = 'config/reference/bowtie_index/padded_' + subtype,
		out_tag = 'virema_result/{ppID}_{subtype}',
		out = 'virema_result/{ppID}_result_{subtype}.results',
		in_file = 'bowtie2_result/{ppID}_unalign_{subtype}.fq',
		rename_file = 'bowtie2_result/{ppID}_unalign_{subtype}_rename.fq',
		dedup_file = 'DeDuped_{ppID}_result_{subtype}.results',
		ddedup_file = 'DeDuped_DeDuped_{ppID}_result_{subtype}.results'
	conda:
		'virema'
	shell:'''
		awk '{{print (NR%4 == 1) ? "@1_" ++i : $0}}' {params.in_file} >  {params.rename_file}
		python libs/ViReMa_0.25/ViReMa.py \
		--MicroInDel_Length 20 \
		-DeDup \
		--Defuzz 3 \
		--N 1 \
		--X 8 \
		--Output_Tag {params.out_tag} \
		-ReadNamesEntry \
		--p 6 {params.ref_index} {params.in_file} {params.dedup_file}
		
		mv {params.dedup_file} virema_result
		mv {params.ddedup_file} virema_result
		touch {output}
		'''

rule output_pearl:
	message: "Generating output"
	input:
		'virema_result/{ppID}_result_{subtype}.txt'
	output:
		'output/{ppID}_{subtype}_Virus_Recombination_Results.par5'
	params:
		in_file  = 'virema_result/{ppID}_{subtype}_Virus_Recombination_Results.txt',
	shell:
		"perl scripts/parse-recomb-results-Fuzz.pl -d 5 -i {params.in_file} -o {output}"


