## Splicing Efficiency Score Calculator

**SE calculator** extensively use Samtools for calculating the score. This script relies on "coordinates" and 
annotation file EXACTLY matching i.e. belongs to same genomic build and source.

#### This code can be used for both short and long reads

There are mainly 4 steps for SE score calculation

STEP 1 parse the input file and format for further analysis. Please uncheck "#" if you are using .GTF file

STEP 2 is optional if you are using the same genomic build (Mus_musculus.GRCm38.91.gtf) for querying genes. Please uncheck "#" if you are using new Ensembl_Genome.gtf file.

STEP 3 is the main step where all the stats will be computed for given Gene_list.bed

STEP 4 calculate the SE score by formula.

Usage:

    sh Splicing_Efficiency_Calculator.sh <sample.bam> <Gene_list.bed> <Ensembl_Genome.gtf>

#Note: The formula needs to proofread/ re-implement again!
