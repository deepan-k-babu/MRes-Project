The "Amplicon_sequence.ipynb" contains analysis of amplicon sequences from the phyllosphere of Teqing, IR64, Jasmine 85, Cypress, La Grue, and Bengal rice cultivar. Initially, the sequencing data was analysed using qiime 2 and dada 2 in terminal and the output files are analysed using Phyton.
The qiime 2 code employed in this project is shown below.


#install qiime
qiime 
```
Import the reads (qiime2)
qiime2-2023.9.1 

Prepare the manifest file
check qiime docs
###############################################
####For loop command to import the files
#On the terminal
for file in *.fq.gz; do
    qiime tools import \
      --type 'SampleData[PairedEndSequencesWithQuality]' \
      --input-path import_manifest_cluster \
      --output-path ~/Amplicon_sequences/amplicon.qza \
      --input-format PairedEndFastqManifestPhred33
done
###############################################
#### Quality Check
cd Amplicon_sequences/
qiime demux summarize --i-data amplicon.qza --o-visualization amplicon.qzv

#Visualize the output (# check for Qiime2 view for quality and verify length.)
qiime tools view ./amplicon.qzv

#Quality was good so no trimming required.
##no trim pr truncation of the reads
qiime dada2 denoise-paired --i-demultiplexed-seqs amplicon.qza --p-trim-left-f 0 --p-trim-left-r 0 --p-trunc-len-f 0 --p-trunc-len-r 0 --p-n-threads 2 --o-representative-sequences amplicon_repSeq_1.qza --o-table ./amplicon_table.qza --o-denoising-stats denoiseStats.qza --verbose


##command to visualise the statistics:  
qiime metadata tabulate --m-input-file denoiseStats.qza --o-visualization denoiseStats.qzv
qiime tools view denoiseStats.qzv

#Create the feature table and taxonomony
qiime feature-classifier classify-consensus-vsearch --i-query amplicon_repSeq.qza --i-reference-reads silva-138.2-ssu-nr99-dna-seqs.qza --i-reference-taxonomy silva-138.2-taxonomy.qza --p-threads 40 --o-classification taxonomy.qza --o-search-results amplicon_tophits.qza / --verbose

#view the feature table and taxonomony
###Feature table
qiime feature-table summarize --i-table amplicon_table.qza --o-visualization amplicon_table.qzv
qiime tools view amplicon_table.qzv

###Taxonomy
qiime metadata tabulate --m-input-file taxonomy.qza --o-visualization taxonomy.qzv
qiime tools view taxonomy.qzv
