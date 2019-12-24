#####################################################
#              		           A      C         #
# Splicing Efficiency Calculator= --- x -----       #
# 				  A+B   D x E       #
#####################################################

#Usage:sh C3.sh <sample.bam> <Gene_list.bed> <Ensembl_Genome.gtf>

FILE1=$1  #Treg_4.sorted.bam
FILE2=$2  #Gene_list.bed (1 100006020 100006584 ENSMUSG00000100662; Queried gene coordinates and .gtf files MUST be from the same Ensembl version)
#FILE3=$3 #Mus_musculus.GRCm38.91.gtf

#STEP_1 (~15 min, run once)
#mkdir temp
#python ./gtftools.py -m ./temp/Merged_Exon.bed -g ./temp/Gene.bed -d ./temp/Merged_Intron.bed $FILE3 #(~15 min, run once, if using same genome build)
awk '{print $4}' $FILE2 > ./temp/Gene_ID.txt
awk '{print $1":"$2"-"$3}' $FILE2 > ./temp/Gene_Coordinate.txt


#STEP_2 (~15 min, run once)
#module load samtools/1.5
#samtools bedcov ./temp/Gene.bed $FILE1 |awk '{print $1, $2, $3, $5, $7/($3-$2), $4, $6, $7, ($3-$2), $7/($3-$2)}'|sort -nk 4 > ./temp/Gene_calc.txt &  #10th col can be removed
#samtools bedcov ./temp/Merged_Exon.bed $FILE1| awk '{print $1,$2,$3,$4,$7/($3-$2),$6,$4,$7,($3-$2),$7/($3-$2)}'|sort -nk 4 > ./temp/Exon_calc.txt &    #10th col can be removed
#samtools bedcov ./temp/Merged_Intron.bed $FILE1| awk '{print $1,$2,$3,$4,$6/$5,"+",$4,$6, $5, $6/$5}'|sort -nk 4 > ./temp/Intron_calc.txt &            #10th col can be removed
#sum of per-base read depths per BED region

#STEP_3 (Standard Input)
#for i in $(awk '{print $4}' ./temp/Gene_calc.txt)
'''
for i in $(cat ./temp/Gene_ID.txt)
	do 
	A=$((grep "$i" ./temp/Exon_calc.txt||echo "NA")|awk '{(sum += $5)} END {print sum}')   #Sum_of_Average_read_per_exon [A]
	AE=$((grep "$i" ./temp/Exon_calc.txt||echo "NA")|awk '{(sum += $8)} END {print sum}')   #Sum_of_read_depth_per_base_for_exons [AE]
	B=$((grep "$i" ./temp/Intron_calc.txt||echo "NA")|awk '{(sum += $5)} END {print sum}') #Sum_of_Average_read_per_intron [B]
	E=$(grep "$i" ./temp/Gene_calc.txt|awk '{print $7, $9}')				   #Gene_length [E]
	echo $i $A $AE $B $E
done > ./temp/Stats1AE.txt
'''
for i in $(cat ./temp/Gene_ID.txt)
	do 
	DE=$((grep "$i" ./temp/Exon_calc.txt||echo "NA")|awk '{(sum += $7)} END {print sum}')
	LE=$((grep "$i" ./temp/Exon_calc.txt||echo "NA")|awk '{(sum += $8)} END {print sum}')
	GLE=$(grep "$i" ./temp/Gene_calc.txt|awk '{print $7, "chr"$1":"$2"-"$3,$8, $9}')
	echo $i $GLE $DE $LE
done > ./temp/Stats2AE.txt


#module load samtools/1.5
#for j in $(awk '{print $1":"$2"-"$3}' ./temp/Gene_calc.txt)
for j in $(cat ./temp/Gene_Coordinate.txt)
	do
	C=$(samtools view $FILE1 "$j"|awk '{sum += length($10)} END {print sum}')		   #Sum_Length_mapped_reads [C]
	D=$(samtools view $FILE1 "$j"|wc -l)							   #Number_of_Mapped_Reads [D] # Bedtools multicov does the same
	echo $j $C $D
done > ./temp/Stats2.txt
paste ./temp/Stats1.txt ./temp/Stats2.txt|awk '{print $1,$4,$6,$5,$2,$3,$7,$8}'|sed 's/ $/ 0/g'>./temp/Statistics.txt
#ENSG_ID Gene Coordinate Gene_Length Sum_Average_read_per_exon Sum_Average_read_per_Intron Sum_Length_mapped_reads Number_of_Mapped_Reads

#STEP_4 (SE Calculator)
awk '{print $1,$2,$3,(($5/($5+$6+0.000001))*($7/(($8*$4)+0.000001)))}' ./temp/Statistics.txt > SE_Score.txt
#cd ./temp/
#rm Stats2.txt Statistics.txt Stats1.txt Gene_ID.txt Gene_Coordinate.txt
#SE_Score_header:ENSG Gene Coordinate SE_Score