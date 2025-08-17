cholesterol <- 230
if(cholesterol > 240) {
  print("High Cholesterol")
}

systolic_bp = 130
if(systolic_bp < 120) {
  print("Blood Pressure is normal")
} else {
  print("Blood Pressure is high")
}

patient_copy <- read.csv(file.choose())
View(patient_copy)
str(patient_copy)

factor_cols <- c("gender", "diagnosis", "smoker")

for (cols in factor_cols) {
  patient_copy[[cols]] <- as.factor(patient_copy[[cols]])
}
View(patient_copy)
str(patient_copy)

binary_cols <- c("smoker")
for (cols in binary_cols) {
  patient_copy[[cols]] <- ifelse(patient_copy[[cols]] == "Yes", 1, 0)
}

str(patient_copy)

binary_col <- c("gender")
for (col in binary_col) {
  patient_copy[[col]] <- ifelse(patient_copy[[col]] == "Male", 1, 2)
}

str(patient_copy)

metadata_copy <- read.csv(file.choose())
View(metadata_copy)

factor_colls <- c("height", "gender")

for (colls in factor_colls) {
  metadata_copy[[colls]] <- as.factor(metadata_copy[[colls]])
}
str(metadata_copy)

trinary_colll <- c("height")
for (colll in trinary_col) {
  metadata_copy[[colll]] <- ifelse(metadata_copy[[colll]] == "Tall", 1, ifelse(metadata_copy[[colll]] == "Medium", 2, 3))
}
str(metadata_copy)

