# R01 GSH DO Mapping Code 
# Updated December 2020
# Becca Gould 

#KIDNEY GLUTATHIONE + BLOOD (BUN) MAPPING - Exporting QTL results

#Load in Kidney-QTL-Mapping-RankZ-sex.Rdata

#load the command line tools 
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


#set working directory to store the plots

#setwd

#tells you all of the qtlscans that you have
ls(pattern = "qtl")


####################################################
## Grab the QTL from all of the qtl scans 
####################################################
  
## I just set threshold to 6 (tells you all of the important qtl peaks with a LOD score > 6)
## map is the qtl2 map you want to use (gmap or pmap)
  qtl_gmap <- find_peaks(scans, map = R01_GSH_DO_QTLdata$gmap, threshold = 6, peakdrop = 1.8, drop = 1.5, expand2markers = FALSE)
  
  #shows you the first 6 results
  head(qtl_gmap)
  #shows you all of the results - check that these match your records
  qtl_gmap
  


####################################################
## exporting data
####################################################
  #set working directory
  write_xlsx(list("GSH chr2" = KidneyGSH_Genes_MGI_chr2, 
                  "GSSG chr2" = KidneyGSSG_Genes_MGI_chr2, 
                  "Total GSH chr2" = KidneyTotalGSH_Genes_MGI_chr2, 
                  "GSH GSSG Ratio chr16" = KidneyGSH_GSSGRatio_Genes_MGI_chr16),
             "GlutathioneGenesMGI-RankZ-sex.xlsx")
  
  #set working directory
  write_xlsx(list("NADP chr2" = KidneyNADP_Genes_MGI_chr2,
                  "NADP chr8" = KidneyNADP_Genes_MGI_chr8,
                  "NADP NADPH Ratio chr2" = KidneyNADP_NADPHRatio_Genes_MGI_chr2,
                  "NADP NADPH Ratio chr12a" = KidneyNADP_NADPHRatio_Genes_MGI_chr12a,
                  "NADP NADPH Ratio chr12b" = KidneyNADP_NADPHRatio_Genes_MGI_chr12b),
             "NADSystemsGenesMGI-RankZ-sex.xlsx")
  
  #set working directory - no BUN results
  #write_xlsx(list("BUN chr16" = BUN_Genes_MGI_chr16), "BloodValuesGenesMGI-RankZ-sex.xlsx")
  
  

