# R01 GSH DO Mapping Code 
# Updated August 2020
# Becca Gould 

#LIVER GLUTATHIONE + NAD MAPPING - GSSG

#Load in Liver-GSH-NAD-RankZ-Sex.Rdata
#Run RankZ Transformation and Data Prep R Script before doing this**

setwd("/users/becca/R01_GSH_DO_mapping_Liver/data")

library(qtl2)
library (tidyverse)
library (readxl)
library(yaml)
library(devtools)
library(jsonlite)
library (data.table)
library (RcppEigen)
library (pander)
library (writexl)
library (RSQLite)

####################################################
## Plot Genome Scans with Permutation Tests
####################################################

qtlscan_LiverGSSG <- scan1(genoprobs = probs, pheno = pheno["zLiverGSSG"], kinship = kinship_loco, addcovar = sex, cores=10)
perm_LiverGSSG <- scan1perm(genoprobs = probs, pheno = pheno["zLiverGSSG"], addcovar = sex, n_perm = 1000, cores=10)

#set working directory
pdf(file = "GSSG QTL Results - RankZ sex.pdf")
##NOW SAVING ALL PLOTS AND TABLES ONTO A PDF##

par(mar=c(4.1, 4.1, 2.6, 2.6))
threshold_LiverGSSG = summary(perm_LiverGSSG, alpha = c(0.2, 0.1, 0.05))
plot_scan1(x = qtlscan_LiverGSSG, map = R01_GSH_DO_QTLdata$gmap,  main = "Genome Scan for Liver GSSG", ylim = c(0,11))
abline(h = threshold_LiverGSSG, col = c("purple", "red", "blue"), lwd = 2)

#using gmap (cM)
find_peaks(scan1_output = qtlscan_LiverGSSG, map = R01_GSH_DO_QTLdata$gmap, threshold = summary(perm_LiverGSSG, alpha = 0.2), peakdrop = 1.8, drop = 1.5, expand2markers = FALSE)
gmap_peaksGSSG <- find_peaks(scan1_output = qtlscan_LiverGSSG, map = R01_GSH_DO_QTLdata$gmap, threshold = summary(perm_LiverGSSG, alpha = 0.2), peakdrop = 1.8, drop = 1.5, expand2markers = FALSE)
print(gmap_peaksGSSG)

#using pmap (Mbp)
find_peaks(scan1_output = qtlscan_LiverGSSG, map = R01_GSH_DO_QTLdata$pmap, threshold = summary(perm_LiverGSSG, alpha = 0.2), peakdrop = 1.8, drop = 1.5, expand2markers = FALSE)
peaksGSSG <- find_peaks(scan1_output = qtlscan_LiverGSSG, map = R01_GSH_DO_QTLdata$pmap, threshold = summary(perm_LiverGSSG, alpha = 0.2), peakdrop = 1.8, drop = 1.5, expand2markers = FALSE)
print(peaksGSSG)


write_xlsx(list("GSSG gmap (cM)" = gmap_peaksGSSG,
                "GSSG pmap (Mbp)" = peaksGSSG),
           "GSSG Peaks - RankZ sex.xlsx")


####################################################
## Estimate QTL Effects (Coefficients) + Connect to SNP and Gene Databases
####################################################

#For Liver GSSG --- Chromosome 2
  par(mar=c(4.1, 4.1, 2.6, 2.6))
  
  #using gmap (cM)
  chr = 2
  coef_blup_LiverGSSG_chr2 <- scan1blup(genoprobs =  probs[,chr], pheno = pheno["zLiverGSSG"], kinship = kinship_loco[[chr]], addcovar = sex, cores = 10)
  plot_coefCC(x = coef_blup_LiverGSSG_chr2, map = R01_GSH_DO_QTLdata$gmap, scan1_output = qtlscan_LiverGSSG, main = "Liver GSSG BLUPs plotted with CC Founders", legend = "bottomleft", bgcolor="gray95")
  xlim <- c(40,65)
  plot_coefCC(x = coef_blup_LiverGSSG_chr2, map = R01_GSH_DO_QTLdata$gmap, scan1_output = qtlscan_LiverGSSG, main = "Liver GSSG BLUPs plotted with CC Founders", legend = "bottomleft", bgcolor="gray95", xlim = xlim)
  
  #using pmap (Mbp)
  chr = 2
  #could use ci_lo or ci_hi, but for this case, I want a specific chromosome 2 peak
  #start = peaksGSSG[peaksGSSG$chr ==  chr,"ci_lo"]
  #end = peaksGSSG[peaksGSSG$chr == chr, "ci_hi"] 
  
  pander(peaksGSSG)
  #based on peaksGSH, peak of interest is ~109 Mbp
  variants_LiverGSSG_chr2 <- query_variants(chr, 105, 112)
  out_snps_LiverGSSG_chr2 <- scan1snps(genoprobs = probs, map = R01_GSH_DO_QTLdata$pmap, pheno = pheno["zLiverGSSG"], kinship = kinship_loco[[chr]], addcovar = sex, query_func = query_variants,
                                       chr = chr, start = 105, end = 112, keep_all_snps = TRUE)
  plot_snpasso(out_snps_LiverGSSG_chr2$lod, out_snps_LiverGSSG_chr2$snpinfo, main = "Liver GSSG SNPs")
  
  LiverGSSG_Genes_MGI_chr2 <- query_genes_mgi(chr = chr, start = 105, end = 112)
  plot(out_snps_LiverGSSG_chr2$lod, out_snps_LiverGSSG_chr2$snpinfo, drop_hilit=1.5, genes = LiverGSSG_Genes_MGI_chr2, main = "Liver GSSG Genes MGI") 
  
dev.off()  
  
  
####################################################
## GWAS SNP Association Scan
## Make a Manhattan plot of the results; use altcol to define a color alternate for chromosomes and gap=0 to have no gap between chromosomes
####################################################

pdf(file = "GSSG GWAS - RankZ sex.pdf")
out_gwas_LiverGSSG <- scan1snps(genoprobs = probs, map = R01_GSH_DO_QTLdata$pmap, pheno = pheno["zLiverGSSG"], kinship = kinship_loco, addcovar = sex, query_func=query_variants, cores=10)
par(mar=c(4.1, 4.1, 2.6, 2.6))
plot(out_gwas_LiverGSSG$lod, out_gwas_LiverGSSG$snpinfo, altcol="green4", gap=0, main = "Liver GSSG GWAS", ylim = c(0,6))
dev.off()

####################################################
## Heritability calculation - the ratio of genetic variance to total variance using a linear mixed model
####################################################

herit_LiverGSSG_sex <- est_herit(pheno["zLiverGSSG"], kinship_lmm, sex, cores = 10)
herit_LiverGSSG_sexgen <- est_herit(pheno["zLiverGSSG"], kinship_lmm, sexgen, cores = 10)


