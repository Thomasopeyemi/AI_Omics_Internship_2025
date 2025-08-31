#create function classify_gene
classify_gene <- function(logFC, padj) {
  ifelse(logFC > 1 & padj < 0.05, "Upregulated", ifelse(logFC < 1 & padj < 0.05, "Downregulated", "Not_Significant"))
  }
#define input and output folders
input <- "input"
output <- "output"
#delineate output creation if non-existent
if(!dir.exists(output)){
  dir.create(output)
}
#vectorize input files
file_combo <- c("DEGs_Data_1.csv", "DEGs_Data_2.csv")
#create empty list to hold results later
result_list <- list()
#for loop- iterate each file, 
#import files,
#checks for missing values,
#replace missing values with 1 for padj, mean for logFC
#use classify_gene function to classify each gene based on padj and logFC prerequisites
#save results
for (file_names in file_combo) {
  cat("\nProcessing:", file_names, "\n")
  
  input_file_path <- file.path(input, file_names)
  
  data <- read.csv(input_file_path, header = TRUE)
  cat("File imported. Checking for missing values...\n")
  
  if("logFC" %in% names(data)) {
    missing_count <- sum(is.na(data$logFC))
    cat("Missing values in 'logFC':", missing_count, "\n")
    data$logFC[is.na(data$logFC)] <- mean(data$logFC, na.rm = TRUE)
  }
  
  if("padj" %in% names(data)) {
    missing_count <- sum(is.na(data$padj))
    cat("Missing values in 'padj':", missing_count, "\n")
    data$padj[is.na(data$padj)] <- 1
  }
  
  data$status <- classify_gene(data$logFC, data$padj)
  cat("Gene classification successful\n")
  
  cat("Summary of classifications:\n")
  print(table(data$status))
  
  result_list[[file_names]] <- data
  
  result <- file.path(output, paste0("Gene Classification",file_names))
  write.csv(data, result, row.names = FALSE)
  cat("Results saved to:", result, "\n")
  
}
#save results for each iteration
result_1 <- result_list[[1]]
result_2 <- result_list[[2]]
