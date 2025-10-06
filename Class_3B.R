#Downloading BioCmanager and installing packages
if (!requireNamespace("BiocManager", quietly = TRUE)) 
  install.packages("BiocManager")
BiocManager::install(c("GEOquery","affy","arrayQualityMetrics"))
install.packages("dplyr")

#removing current environment variables
rm(list = ls())

#loading libraries
library(GEOquery)
library(affy)
library(arrayQualityMetrics)
library(dplyr)


#downloading the data, untaring and loading.
gse_data <- getGEO("GSE79973", GSEMatrix = TRUE)
expression_data <- exprs(gse_data$GSE79973_series_matrix.txt.gz)
feature_data <- fData(gse_data$GSE79973_series_matrix.txt.gz)
phenotype_data <- pData(gse_data$GSE79973_series_matrix.txt.gz)
sum(is.na(phenotype_data$source_name_ch1))

untar("raw_data/GSE79973_RAW.tar", exdir = "raw_data/CEL_files")
raw_data <- ReadAffy(celfile.path = "raw_data/CEL_files")
raw_data

#increasing vmemory for task
install.packages("usethis")
library(usethis)
usethis::edit_r_environ()

#Quality Control
arrayQualityMetrics(expressionset = raw_data,
                    outdir = "Results/QC_Raw_Data",
                    force = TRUE,
                    do.logtransform = TRUE)

#Normalization
normalized_data <- rma(raw_data)

#check QC after normalization
arrayQualityMetrics(expressionset = normalized_data,
                    outdir = "Results/QC_Normalized_Data",
                    force = TRUE)

#normalized data into data frame
processed_data <- as.data.frame(exprs(normalized_data))
dim(processed_data)

#intensity-based filtering
row_median <- rowMedians(as.matrix(processed_data))
hist(row_median,
     breaks = 100,
     freq = FALSE,
     main = "Median Intensity Distribution")

#setting a threshold to remove low variance probes
threshold <- 3.5
abline(v = threshold, col = "black", lwd = 2)

indx <- row_median > threshold
indx
filtered_data <- processed_data[indx, ]

#swapping rows and columns
colnames(filtered_data) <- rownames(phenotype_data)

processed_data <- filtered_data


#preparation of phenotype_data
class(phenotype_data$source_name_ch1)

groups <- factor(phenotype_data$source_name_ch1,
                 levels = c("gastric mucosa", "gastric adenocarcinoma"),
                 label = c("normal", "cancer"))

class(groups)
levels(groups)
groups


