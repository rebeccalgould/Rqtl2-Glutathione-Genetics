# R01 GSH DO Mapping Code 
# Updated August 2020
# Becca Gould 

#LIVER QTL MAPPING - GSH

#Load in Liver QTL Mapping - Log - SexGen.Rdata
#Run Log Transformation and Data Prep R Script before doing this**


setwd("/users/becca/R01_GSH_DO_mapping_Liver/data")

library(qtl2)
library (tidyverse)
library (readxl)
library(yaml)
library(devtools)
library(RSQLite)
library(jsonlite)
library (data.table)
library (RcppEigen)
library (RSQLite)

####################################################
## Plot Genome Scans with Permutation Tests
####################################################

qtlscan_LiverGSH <- scan1(genoprobs = probs, pheno = pheno["logLiverGSH"], kinship = kinship_loco, addcovar = sexgen, cores=10)
perm_LiverGSH <- scan1perm(genoprobs = probs, pheno = pheno["logLiverGSH"], addcovar = sexgen, n_perm = 1000, cores=10)

par(mar=c(4.1, 4.1, 2.6, 2.6))
threshold_LiverGSH = summary(perm_LiverGSH, alpha = c(0.35, 0.2, 0.1, 0.05))
plot_scan1(x = qtlscan_LiverGSH, map = R01_GSH_DO_QTLdata$gmap,  main = "Genome Scan for Liver GSH", ylim = c(0,11))
abline(h = threshold_LiverGSH, col = c("orange", "purple", "red", "blue"), lwd = 2)
#using gmap (cM)
find_peaks(scan1_output = qtlscan_LiverGSH, map = R01_GSH_DO_QTLdata$gmap, threshold = summary(perm_LiverGSH, alpha = 0.1), prob = 0.95, expand2markers = FALSE)
#using pmap (cM)
find_peaks(scan1_output = qtlscan_LiverGSH, map = R01_GSH_DO_QTLdata$pmap, threshold = summary(perm_LiverGSH, alpha = 0.1), prob = 0.95, expand2markers = FALSE)

####################################################
## Estimate QTL Effects (Coefficients) + Connect to SNP and Gene Databases
####################################################

#For Liver GSH --- Chromosome 14 
  par(mar=c(4.1, 4.1, 2.6, 2.6))

  #using gmap (cM)
  chr = 14
  coef_blup_LiverGSH_chr14 <- scan1blup(genoprobs =  probs[,chr], pheno = pheno["logLiverGSH"], kinship = kinship_loco[[chr]], addcovar = sexgen, cores = 10)
  plot_coefCC(x = coef_blup_LiverGSH_chr14, map = R01_GSH_DO_QTLdata$gmap, scan1_output = qtlscan_LiverGSH, main = "Liver GSH BLUPs plotted with CC Founders", legend = "bottomleft", bgcolor="gray95")
  xlim <- c(1,20)
  plot_coefCC(x = coef_blup_LiverGSH_chr14, map = R01_GSH_DO_QTLdata$gmap, scan1_output = qtlscan_LiverGSH, main = "Liver GSH BLUPs plotted with CC Founders", legend = "bottomleft", bgcolor="gray95", xlim = xlim)
  
  #using pmap (Mbp)
  chr = 14
  peaksGSH <- find_peaks(scan1_output = qtlscan_LiverGSH, map = R01_GSH_DO_QTLdata$pmap, threshold = 6, drop = 1.5)
  start = peaksGSH[peaksGSH$chr ==  chr,"ci_lo"]
  end = peaksGSH[peaksGSH$chr == chr, "ci_hi"] 
    
  variants_LiverGSH_chr14 <- query_variants(chr, start - 1, end + 1)
  out_snps_LiverGSH_chr14 <- scan1snps(genoprobs = probs, map = R01_GSH_DO_QTLdata$pmap, pheno = pheno["logLiverGSH"], kinship = kinship_loco[[chr]], addcovar = sexgen, query_func = query_variants,
                                         chr = chr, start = start-1, end = end+1, keep_all_snps = TRUE)
  plot_snpasso(out_snps_LiverGSH_chr14$lod, out_snps_LiverGSH_chr14$snpinfo, main = "Liver GSH SNPs")
    
  LiverGSH_Genes_MGI_chr14 <- query_genes_mgi(chr = chr, start = start-1, end = end+1)
  plot(out_snps_LiverGSH_chr14$lod, out_snps_LiverGSH_chr14$snpinfo, drop_hilit=1.5, genes = LiverGSH_Genes_MGI_chr14, main = "Liver GSH Genes MGI")

#For Liver GSH --- Chromosome 18 
  par(mar=c(4.1, 4.1, 2.6, 2.6))
  
  #using gmap (cM)
  chr = 18
  coef_blup_LiverGSH_chr18 <- scan1blup(genoprobs =  probs[,chr], pheno = pheno["logLiverGSH"], kinship = kinship_loco[[chr]], addcovar = sexgen, cores = 10)
  plot_coefCC(x = coef_blup_LiverGSH_chr18, map = R01_GSH_DO_QTLdata$gmap, scan1_output = qtlscan_LiverGSH, main = "Liver GSH BLUPs plotted with CC Founders", legend = "bottomleft", bgcolor="gray95")
  xlim <- c(20,40)
  plot_coefCC(x = coef_blup_LiverGSH_chr18, map = R01_GSH_DO_QTLdata$gmap, scan1_output = qtlscan_LiverGSH, main = "Liver GSH BLUPs plotted with CC Founders", legend = "bottomleft", bgcolor="gray95", xlim = xlim)
  
  #using pmap (Mbp)
  chr = 18
  peaksGSH <- find_peaks(scan1_output = qtlscan_LiverGSH, map = R01_GSH_DO_QTLdata$pmap, threshold = 6, drop = 1.5)
  start = peaksGSH[peaksGSH$chr ==  chr,"ci_lo"]
  end = peaksGSH[peaksGSH$chr == chr, "ci_hi"] 
  
  variants_LiverGSH_chr18 <- query_variants(chr, start - 1, end + 1)
  out_snps_LiverGSH_chr18 <- scan1snps(genoprobs = probs, map = R01_GSH_DO_QTLdata$pmap, pheno = pheno["logLiverGSH"], kinship = kinship_loco[[chr]], addcovar = sexgen, query_func = query_variants,
                                       chr = chr, start = start-1, end = end+1, keep_all_snps = TRUE)
  plot_snpasso(out_snps_LiverGSH_chr18$lod, out_snps_LiverGSH_chr18$snpinfo, main = "Liver GSH SNPs")
  
  LiverGSH_Genes_MGI_chr18 <- query_genes_mgi(chr = chr, start = start-1, end = end+1)
  plot(out_snps_LiverGSH_chr18$lod, out_snps_LiverGSH_chr18$snpinfo, drop_hilit=1.5, genes = LiverGSH_Genes_MGI_chr18, main = "Liver GSH Genes MGI")
  
####################################################
## GWAS SNP Association Scan
## Make a Manhattan plot of the results; use altcol to define a color alternate for chromosomes and gap=0 to have no gap between chromosomes
####################################################

out_gwas_LiverGSH <- scan1snps(genoprobs = probs, map = R01_GSH_DO_QTLdata$pmap, pheno = pheno["logLiverGSH"], kinship = kinship_loco, addcovar = sexgen, query_func=query_variants, cores=10)
par(mar=c(4.1, 4.1, 2.6, 2.6))
plot(out_gwas_LiverGSH$lod, out_gwas_LiverGSH$snpinfo, altcol="green4", gap=0, main = "Liver GSH GWAS", ylim = c(0,6))

####################################################
## Heritability calculation - the ratio of genetic variance to total variance using a linear mixed model
####################################################

herit_LiverGSH_sexgen <- est_herit(pheno["logLiverGSH"], kinship_lmm, sexgen, cores = 10)
herit_LiverGSH_sex <- est_herit(pheno["logLiverGSH"], kinship_lmm, sex, cores = 10)



