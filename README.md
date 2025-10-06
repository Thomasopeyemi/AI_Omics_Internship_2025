Class 1b

# 1. Set Working Directory
# Create a new folder on your computer "AI_Omics_Internship_2025".

# 2. Create Project Folder

# In RStudio, create a new project named "Module_I" in your "AI_Omics_Internship_2025" folder.

# Inside the project directory, create the following subfolders using R code:
# raw_data, clean_data, scripts, results or Tasks, plots etc

# ---------------------------------------------------------------------------
# 3. Download "patient_info.csv" dataset from GitHub repository

# load the dataset into your R environment

# Inspect the structure of the dataset using appropriate R functions

# Identify variables with incorrect or inconsistent data types.

# Convert variables to appropriate data types where needed

# Create a new variable for smoking status as a binary factor:
  
# 1 for "Yes", 0 for "No"

# Save the cleaned dataset in your clean_data folder with the name patient_info_clean.csv
# Save your R script in your script folder with name "class_Ib"
# Upload "class_Ib" R script into your GitHub repository


Class 1c

#### Try It Yourself ####
# Practice Exercises 

# ----------------------------------------------------------------------------------------------------------------

# 1. Check Cholesterol level (using if) 
# Write an If statement to check cholesterol level is greater than 240, 
# if true, it will prints “High Cholesterol”

cholesterol <- 230

# ----------------------------------------------------------------------------------------------------------------

# 2. Blood Pressure Status (using if...else)
# Write an if…else statement to check if blood pressure is normal.
# If it’s less than 120, print: “Blood Pressure is normal”
# If false then print: “Blood Pressure is high”

Systolic_bp <- 130

# ----------------------------------------------------------------------------------------------------------------

# 3. Automating Data Type Conversion with for loop

# Use patient_info.csv data and metadata.csv
# Perform the following steps separately on each dataset (patient_info.csv data and metadata.csv)
# Create a copy of the dataset to work on.
# Identify all columns that should be converted to factor type.
# Store their names in a variable (factor_cols).

# Example: factor_cols <- c("gender", "smoking_status")

# Use a for loop to convert all the columns in factor_cols to factor type.
# Pass factor_cols to the loop as a vector.

# Hint:
# for (col in factor_cols) {
#   data[[col]] <- as.factor(data[[col]])  # Replace 'data' with the name of your dataset
# }

# ----------------------------------------------------------------------------------------------------------------

# 4. Converting Factors to Numeric Codes

# Choose one or more factor columns (e.g., smoking_status).
# Convert "Yes" to 1 and "No" to 0 using a for loop.

# Hint:
# binary_cols <- c("smoking_status")   # store column names in a vector
# use ifelse() condition inside the loop to replace Yes with 1 and No with 0
# for (col in binary_cols) {
#   data[[col]] <- # insert your ifelse() code here
# }

# ----------------------------------------------------------------------------------------------------------------

#  Verification:
#    Compare the original and modified datasets to confirm changes.
#    str(original_data)
#    str(data)

# ----------------------------------------------------------------------------------------------------------------

# Final Note:
# All instructions are written as comments.
# For actual code execution, remove the # symbol from each line you want to run.


Class 2

The analysis produces two key measures for each gene:

# log2FoldChange (log2FC): 
# Indicates the magnitude and direction of change in gene expression. 
# Positive values suggest higher expression(upregulated gene) in the experimental condition compared to control. 
# Negative values suggest lower expression (downregulated gene). 
# The absolute value reflects the strength of the change.

# Adjusted p-value (padj): 
# Represents the statistical significance of the observed difference, corrected for multiple testing. 
# A smaller value indicates stronger evidence that the observed difference is not due to chance.

# Write a function classify_gene() 

# that takes:
#   - logFC (log2FoldChange)
#   - padj  (adjusted p-value)

# and returns:
#   - "Upregulated" if log2FC > 1 and padj < 0.05
#   - "Downregulated" if log2FC < -1 and padj < 0.05
#   - "Not_Significant" otherwise


# Then:
#   - Apply it in a for-loop to process both datasets (DEGs_data_1.csv, DEGs_data_2.csv)
#   - Replace missing padj values with 1
#   - Add a new column 'status'
#   - Save processed files into Results folder
#   - Print summary counts of significant, upregulated, and downregulated genes
#   - Use table() for summaries

# Data Availability
# The input files are available in the GitHub repository:
#      DEGs_Data_1.csv
#      DEGs_Data_2.csv

# Each file contains three columns: 
# Gene_Id	
# padj	
# logFC


Class 3B

# =====================================================================
#               AI and Biotechnology / Bioinformatics
# =====================================================================

# ---------------------------------------------------------------------
#              AI and Omics Research Internship (2025)
# ---------------------------------------------------------------------
#             Module II: Introduction to Genomics Data Analysis
# ---------------------------------------------------------------------
#                     Microarray Data Analysis
# =====================================================================

# Topics covered in this script:
# 1. Quality Control (QC) 
# 2. RMA Normalization
# 3. Pre-processing and Filtering

#######################################################################
#### 0. Install and Load Required Packages ####
#######################################################################

# Bioconductor provides R packages for analyzing omics data (genomics, transcriptomics, proteomics etc)

# Install Bioconductor packages

# Install CRAN packages for data manipulation

# Load Required Libraries
# -------------------------------------
#### Download Series Matrix Files ####
# -------------------------------------

# Series matrix files are preprocessed text files containing 
# expression values, sample annotations, and probe information.
# Reason: Useful for quick exploratory analysis when raw CEL files are not needed.

# Extract expression data matrix (genes/probes × samples)
# Rows corresponds to probes and columns corresponds to samples

# Extract feature (probe annotation) data
# Rows corresponds to probes and columns corresponds to samples

# Extract phenotype (sample metadata) data
# Rows corresponds to samples and columns corresponds to probes

# Check missing values in sample annotation

# --------------------------------------
#### Download Raw Data (CEL files) ####
# --------------------------------------

# CEL files contain raw probe-level intensity values for affymetrix platform.
# Raw data required full preprocessing (e.g., RMA normalization, QC)

# CEL files are large, and downloads may fail even with a good connection. 
#It's recommended to download raw data directly from NCBI GEO

# skip this step if you already downloaded data from NCBI

# Fetch GEO supplementry files

# Important Note: 
# For Affymetrix microarray data, the preprocessing pipeline is the same 
# whether raw CEL files are downloaded from NCBI GEO or ArrayExpress. 

# (See tutorial for detailed explanation of this step: https://youtu.be/DZMxkHxwWag?feature=shared) 

# Untar CEL files if compressed as .tar
# Alternatively, unzip if data is compressed as .zip

# Read CEL files into R as an AffyBatch object
# Note down the annotation (e.g annotation= hgu133plus2) from this output.
# You will need this in the next step to select and install the correct
# annotation package (e.g., hgu133plus2.db) for mapping probe IDs to genes.

# ---------------------------------------------------
#### Quality Control (QC) Before Pre-processing ####
# ---------------------------------------------------

# QC identifies outlier arrays, hybridization problems, or technical biases.
# arrayQualityMetrics: # This package generates automated QC reports for microarray data.
# It applies multiple complementary methods to detect technical issues:
#   - Boxplots and density plots: check distribution of intensities 
#   - MA-plots: visualize systematic biases between arrays 
#   - Heatmaps and distance matrices: identify clustering/outliers
#   - PCA: detect unusual variation/detecting outliers or batch effects
#
# The output is an interactive HTML report (index.html file) summarizing QC results.

# -------------------------------------------------------
#### RMA (Robust Multi-array Average) Normalization ####
# -------------------------------------------------------

# RMA is a popular method for normalizing Affymetrix microarray data by:
# 1. Background correcting, 
# 2. normalizing probe intensities using quantile normalization and 
# 3. summarizing them into gene-level expression values using a robust median polish algorithm.

# This method reduces experimental variation across multiple arrays, 
# producing more symmetrical and reliable normalized expression data 
# compared to other approaches

# QC after data normalization 

# Extract normalized expression values into a data frame

# ---------------------------------------------------------------------------
#### Filter Low-Variance Transcripts (“soft” intensity based filtering) ####
# ---------------------------------------------------------------------------
# Filtering removes probes with low or uninformative expression signals.
# Reason: Reduces noise and improves statistical power in differential expression & Machine Learning.

# Calculate median intensity per probe across samples

# Visualize distribution of probe median intensities

# Set a threshold to remove low variance probes (dataset-specific, adjust accordingly)

# Select probes above threshold
# Rename filtered expression data with sample metadata

# Overwrite processed data with filtered dataset 

# -----------------------------------
#### Phenotype Data Preparation ####
# -----------------------------------

# Phenotype data contains sample-level metadata such as condition, 
# tissue type, or disease status.
# Required to define experimental groups for statistical analysis. 
# Define experimental groups (normal vs cancer)
