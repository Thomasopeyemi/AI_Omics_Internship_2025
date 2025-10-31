BiocManager::install(c("limma", "AnnotationDbi", "hgu133plus2.db"))
install.packages(c("dplyr", "tibble", "ggplot2", "pheatmap"))
library(AnnotationDbi)
library(dplyr)
library(hgu133plus2.db)
library(limma)
library(tibble)
library(ggplot2)
library(pheatmap)

load("GSE79973.RData")

#checking for annotation package
annotation(raw_data)
raw_data

ls("package:hgu133plus2.db")

#checking columns matching keys
columns(hgu133plus2.db)
keytypes(hgu133plus2.db)
probe_ids <- rownames(processed_data)

#Mapping PROBEID to gene SYMBOLS
gene_symbols <- mapIds(
  hgu133plus2.db,
  keys = probe_ids,
  keytype = "PROBEID",
  column = "SYMBOL",
  multiVals = "first"
)

gene_map_df <- gene_symbols %>%
  as.data.frame() %>%
  tibble::rownames_to_column("PROBEID") %>%
  dplyr::rename(SYMBOL = 2)

#check for duplicates
duplicate_summary <- gene_map_df %>%
  group_by(SYMBOL) %>%
  summarise(probes_per_gene = n()) %>%
  arrange(desc(probes_per_gene))

duplicate_genes <- duplicate_summary %>%
  filter(probes_per_gene > 1)

sum(duplicate_genes$probes_per_gene)

all(gene_map_df$PROBEID == rownames(processed_data))

processed_data_df <- processed_data %>%
  as.data.frame() %>%
  tibble::rownames_to_column("PROBEID") %>%
  dplyr::mutate(SYMBOL = gene_symbols[PROBEID]) %>%
  dplyr::relocate(SYMBOL, .after = PROBEID)

processed_data_df <- processed_data_df %>%
  dplyr::filter(!is.na(SYMBOL))

expr_only <- processed_data_df %>%
  dplyr::select(-PROBEID, -SYMBOL)

#take average of probe expr
averaged_data <- limma::avereps(expr_only, ID = processed_data_df$SYMBOL)

dim(averaged_data)

data <- as.data.frame(averaged_data)
data <- data.matrix(data)
data
str(data)
is.numeric(data)

#Differential Gene Expressions using limma
groups <- factor(phenotype_data$source_name_ch1,
                 levels = c("gastric mucosa", "gastric adenocarcinoma"),
                 labels = c("normal", "cancer")
                 )

class(groups)
levels(groups)

design <- model.matrix(~0 + groups)

colnames(design) <- levels(groups)

fit_1 <- lmFit(data, design)

contrast_matrix <- makeContrasts(cancer_vs_normal = cancer - normal,
                                 levels = design)
fit_contrast <- contrasts.fit(fit_1, contrast_matrix)

fit_2 <- eBayes(fit_contrast)

#Extracting DEGs
deg_results <- topTable(fit_2,
                        coef = "cancer_vs_normal",
                        number = Inf,
                        adjust.method = "BH")

deg_results$threshold <- as.factor(ifelse(
  deg_results$adj.P.Val < 0.05 & deg_results$logFC > 1, "Upregulated",
  ifelse(deg_results$adj.P.Val < 0.05 & deg_results$logFC < -1, "Downregulated",
         "Not expressed")
))

upregulated <- subset(deg_results, threshold == "Upregulated")
downregulated <- subset(deg_results, threshold == "Downregulated")

deg_updown <- rbind(upregulated, downregulated)

write.csv(deg_results, file = "Results/DEGs_Results.csv")
write.csv(upregulated, file = "Results/Upregulated_DEGs.csv")
write.csv(downregulated, file = "Results/Downregulated_DEGs.csv")
write.csv(deg_updown, file = "Results/Updown_DEGs.csv")


#creating a volcano plot
png("Result_Plot/volcano_plot.png", width = 2000, height = 1500, res = 300)

ggplot(deg_results, aes(x = logFC, y = -log10(adj.P.Val), color = threshold)) +
  geom_point(alpha = 0.7, size = 2) +
  scale_color_manual(values = c("Upregulated" = "red",
                                "Downregulated" = "blue",
                                "Not expressed" = "grey")) +
  theme_minimal() +
  labs(title = "Volcano Plot of Differentially Expressed Genes",
       x = "log2 Fold Change",
       y = "-log10(P-value)",
       color = "Regulation")

dev.off()

#HeatMap of Top25 DEGs
top_genes <- head(rownames(deg_updown[order(deg_updown$adj.P.Val), ]), 25)
heatmap_data <- data[top_genes, ]
group_char <- as.character(groups)
heatmap_names <- ave(group_char, group_char, FUN = function(x) paste0(x, "_", seq_along(x)))

colnames(heatmap_data) <- heatmap_names

png("Result_Plot/heatmap_top25_DEGs.png", width = 2000, height = 1500, res = 300)

pheatmap(
  heatmap_data,
  scale = "none", # for already normalized data
  cluster_rows = FALSE,              # Disable row clustering
  cluster_cols = TRUE,               # Cluster samples
  show_rownames = TRUE,              # Display gene names
  show_colnames = TRUE,              # Display sample labels
  color = colorRampPalette(c("blue", "white", "red"))(100),
  fontsize_row = 6,
  fontsize_col = 8,
  main = "Top 25 Differentially Expressed Genes"
)

dev.off()

