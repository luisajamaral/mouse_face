# Snakefile.pre_process
#snakemake -j30 --snakefile Snakemake.pre_process
#Fix mate: 
for sample in Mouse_Face_E11_5_rep1 Mouse_Face_E12_5_rep1 Mouse_Face_E14_5_rep1 Mouse_Face_E15_5_rep1; do 
  samtools fixmate -m ../data/bam.filter.nsort/$sample/${sample}.filter.nsort.bam ../data/TSSvsFrag.out/${sample}.fixmate.bam -@ 8 &
  done

# generate TSS enrichment
for sample in Mouse_Face_E11_5_rep1 Mouse_Face_E12_5_rep1 Mouse_Face_E14_5_rep1 Mouse_Face_E15_5_rep1; do 
/projects/ps-renlab/yangli/scripts/snATACutils/snapATAC.qc.TSSvsFrag \
  ../annotations/mm10.gencode.vM16.annotation.gtf \
  ../data/TSSvsFrag.out/${sample}.fixmate.bam \
  ../data/TSSvsFrag.out/${sample}/ &
  done

for sample in Mouse_Face_E11_5_rep1 Mouse_Face_E12_5_rep1 Mouse_Face_E14_5_rep1 Mouse_Face_E15_5_rep1; do 
  Rscript summalize_bc_info.per_sample.r $sample; 
done
# Snakefile.snap_pre
snakemake -j30 --snakefile Snakefile.snap_pre
# merge and cluster on each tissue.
bash merge_and_cluster.sh

## generate the bam files.
mkdir ../analysis/$tissue/bam.cluster_age_rep
python split_bam_files.py \
  --tissue $tissue \
  --bam-prefix ../data/bam.filter/  \
  --bam-suffix .filter.bam \
  --statH ../analysis/$tissue/${tissue}.pool.barcode.meta_info.txt \
  -o ../analysis/$tissue/bam.cluster_age_rep/${tissue} \
  -p 30


Rscript plot_celltype_fraction.r ../analysis/$tissue/${tissue}.pool.barcode.meta_info.txt ../analysis/$tissue/${tissue}.celltype.fraction.pdf
Rscript plot_cluster_specific_qc.r $tissue
Rscript plot_umap_qc.r $tissue


## differential test.
#Rscript cluster.difftest.edgeR.r FC FC.pool.snapATAC.Frag500.TSS7.AllCells.seed1.dimPC20.K20.res0.7.harmony.cluster.RData
