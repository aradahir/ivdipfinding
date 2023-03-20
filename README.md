## Influenza virus defective interfering particles detection(ivdip) pipeline

A pipeline for finding defective interfering particles in next generation sequencing of influenza HA gene via python-based environment; Snakemake. 

# general info
This project is applied the algorithm of a Virus Recombination Mapper analysis, ViRema. (source:https://github.com/BROOKELAB/Influenza-virus-DI-identification-pipeline) With a default config that is approprite for analysing HA genes of influenza virues.
it is recommended for using with the next-generation sequencing paired-end read with 250 bp of H1N1, H3N2 ,and B victoria subtypes of human influenza.

# technologies

This project created with:
	
	1. Python version ==2.7.0
	2. Python version >=3.6
	3. bowtie version ==1.1.2
	4. bowtie2 version ==2.5.0
	5. fastp version ==0.22.0
	6. snakemake version ==7.19
	7. perl version ==5.32.1
	8. ViReMa-with-fuzz ( included in this repo )

# setup and installation

1. clone this repository. Below is for linux-based manipulation:

	```
	git clone ssh https://git@github.com:aradahir/ivdipfinding.git 
	cd vidipfinding
	```

2. create anaconda environment. We need two different environment to run the pipeline. It is recommended to install via requirement.txt attached in this repository. Using this command

	```
	cd .\ivdipfinding\
	conda create -y --name snakemake python=3.6
	conda install --force-reinstall -y -q --name snakemake -c conda-forge --file requirement_snakemake.txt
	conda create -y --name virema python=3.6
	conda install --force-reinstall -y -q --name virema -c conda-forge --file requirement_virema.txt
	```

	3. activate the snakemake environment for running the pipeline.

# usage

 - Configure some parameters:
 	 
 	Adjusting the HA subytypes and working directory in config files. All other parameters are fixed in 
    the pipeline. However, for flexibility, it could be changed in the snakemake script.

 - Input format of .fastq files. The input should be placed into the /data folder.

 		{sample}_L001_{R1,R2}_001.fastq.gz

 - Open the environment
 
 		```
		conda activate snakemake
		```
 - Run the pipeline
 		thread can be adjusted by changing from 1 into the specific number of thread

 		```
 		snakemake -j 1
		```
# result interpretation

there are 4 output folder from this pipeline 
1. fastp_results: 
	- fastp report 
	- merged files of two reads from the same sample, uses in the next processes
2. bowtie2_results:
	- .fastq file of aligned part
	- .fastq file of unaligned part: uses in the next processes
	- .sam file of alignment file
3. verima_results:
	- Deduplication result for next processes
	- virus insertion.txt
	- virus micro deletion.txt
	- virus micro insertion.txt
	- virus recombination.txt
	- virus substitution.txt
4. output:
	- perl files of unpassed/passed cutoff depth to called as defective interfering particles (default = 5).
	- expect files to observed is in format {sample}_{subtype}_Virus_Recombination_Results.par5, which can be opened as a table.
	- interpretation of result files:

	Let's take a look at the result file:
```
Segment	Start	Stop	Forward_support	Reverse_support	Total_support	Fuzz_factor
h1n1Pa  136	1914		27		11		38		136
h1n1Pa  172	1903		5		0		5		172
h1n1Pb1 115	2086		5		0		5		115
h1n1Pb1 115	2115		8		0		8		115
h1n1Pb1 118	2074		0		17		17		2074
h1n1Pb1 120	2020		2		4		6		120
h1n1Pb1 120	2076		17	        0		17		120
h1n1Pb1 126	2072		5		0		5		126
h1n1Pb1 132	2050		32		32		64		132
h1n1Pb1 137	2021		380		272		652		137
```
where the definitions are:

1. segment: subtypes and genes from references
2. start: approximate start sites for defective interfering particles(bp unit)
3. stop: approximate stop sites for defective interfering particles(bp unit)
4. forward_support: depth of reads that found as the forward read
5. reverse_support: depth of reads that found as the reverse read
6. total_support: forward + reverse support
7. fuzz_factor: the report of repeated sequence adjacent the junction sites.(default is 3'end)

Example of output visualization can be found here ([h1n1Pb1.pdf](https://github.com/aradahir/ivdipfinding/files/10779420/h1n1Pb1.pdf))

# warning
this pipeline is ready to use. most of parameter tunning cannot be adjusted by using config. for further adjustment, the changes can be done in snakemake scripts. (named snakefile)

# acknowledgement
this pipeline created by referencing the pipeline from this repository (https://github.com/BROOKELAB/Influenza-virus-DI-identification-pipeline)

- resources

Alnaji FG, Holmes JR, Rendon G, Vera JC, Fields CJ, Martin BE, Brooke CB. Sequencing Framework for the Sensitive Detection and Precise Mapping of Defective Interfering Particle-Associated Deletions across Influenza A and B Viruses. J Virol. 2019 May 15;93(11):e00354-19. doi: 10.1128/JVI.00354-19. PMID: 30867305; PMCID: PMC6532088.
