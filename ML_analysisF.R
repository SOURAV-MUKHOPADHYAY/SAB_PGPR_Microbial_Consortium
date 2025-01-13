################################################################################
# Analysis for W and NW datasets
################################################################################

# Load necessary libraries
install.packages(c("randomForest", "xgboost", "caret", "ggplot2", "SHAPforxgboost"))
install.packages("devtools")
install.packages("lightgbm")
library(randomForest)
library(xgboost)
library(caret)
library(ggplot2)
library(SHAPforxgboost)
library(dplyr)
library(devtools)
library(lightgbm)

# Install SHAPforxgboost from GitHub if not installed
if (!requireNamespace("SHAPforxgboost", quietly = TRUE)) {
  devtools::install_github("liuyanguu/SHAPforxgboost")
}

# Load datasets
W <- read_excel("W.xlsx")
NW <- read_excel("NW.xlsx")

# Combine W and NW datasets
comb_data <- rbind(W, NW)

# Check structure of the combined data
str(comb_data)

################################################################################
# Analysis for W dataset
################################################################################

# Prepare the W dataset for modeling
model_data_W <- W %>%
  dplyr::select(Day18, HY5, PIF, CRY, WRKY33) %>%
  mutate(all_present = HY5 * PIF * CRY * WRKY33)

# Ensure `Day18` is numeric
model_data_W$Day18 <- as.numeric(model_data_W$Day18)

# Split W data into training and testing sets
set.seed(123)  # For reproducibility
train_index_W <- createDataPartition(model_data_W$Day18, p = 0.8, list = FALSE)
train_data_W <- model_data_W[train_index_W, ]
test_data_W <- model_data_W[-train_index_W, ]

### Random Forest Model for W ###
rf_model_W <- randomForest(Day18 ~ HY5 + PIF + CRY + WRKY33 + all_present, data = train_data_W)
rf_pred_W <- predict(rf_model_W, newdata = test_data_W)
rf_rmse_W <- sqrt(mean((rf_pred_W - test_data_W$Day18)^2))

# Plot feature importance for Random Forest
rf_importance_W <- data.frame(Feature = rownames(importance(rf_model_W)), Importance = importance(rf_model_W)[, 1])
ggplot(rf_importance_W, aes(x = reorder(Feature, Importance), y = Importance)) +
  geom_bar(stat = "identity", fill = "skyblue") +
  coord_flip() +
  labs(title = "Feature Importance - Random Forest (W Dataset)", x = "Feature", y = "Importance")

### XGBoost Model for W ###
dtrain_W <- xgb.DMatrix(data = as.matrix(train_data_W[, c("HY5", "PIF", "CRY", "WRKY33", "all_present")]), label = train_data_W$Day18)
dtest_W <- xgb.DMatrix(data = as.matrix(test_data_W[, c("HY5", "PIF", "CRY", "WRKY33", "all_present")]), label = test_data_W$Day18)

xgb_model_W <- xgboost(data = dtrain_W, nrounds = 1000, objective = "reg:squarederror", eta = 0.1, max_depth = 6, verbose = 0)
xgb_pred_W <- predict(xgb_model_W, dtest_W)
xgb_rmse_W <- sqrt(mean((xgb_pred_W - test_data_W$Day18)^2))

# SHAP analysis for XGBoost
shap_values_W <- shap.values(xgb_model = xgb_model_W, X_train = as.matrix(train_data_W[, c("HY5", "PIF", "CRY", "WRKY33", "all_present")]))
shap_long_W <- shap.prep(shap_contrib = shap_values_W$shap_score, X_train = as.matrix(train_data_W[, c("HY5", "PIF", "CRY", "WRKY33", "all_present")]))
shap.plot.summary(shap_long_W)

################################################################################
# Analysis for NW dataset
################################################################################

# Prepare the NW dataset for modeling
model_data_NW <- NW %>%
  dplyr::select(Day18, HY5, PIF, CRY, WRKY33) %>%
  mutate(all_present = HY5 * PIF * CRY * WRKY33)

# Ensure `Day18` is numeric
model_data_NW$Day18 <- as.numeric(model_data_NW$Day18)

# Split NW data into training and testing sets
set.seed(123)  # For reproducibility
train_index_NW <- createDataPartition(model_data_NW$Day18, p = 0.8, list = FALSE)
train_data_NW <- model_data_NW[train_index_NW, ]
test_data_NW <- model_data_NW[-train_index_NW, ]

### Random Forest Model for NW ###
rf_model_NW <- randomForest(Day18 ~ HY5 + PIF + CRY + WRKY33 + all_present, data = train_data_NW)
rf_pred_NW <- predict(rf_model_NW, newdata = test_data_NW)
rf_rmse_NW <- sqrt(mean((rf_pred_NW - test_data_NW$Day18)^2))

# Plot feature importance for Random Forest
rf_importance_NW <- data.frame(Feature = rownames(importance(rf_model_NW)), Importance = importance(rf_model_NW)[, 1])
ggplot(rf_importance_NW, aes(x = reorder(Feature, Importance), y = Importance)) +
  geom_bar(stat = "identity", fill = "skyblue") +
  coord_flip() +
  labs(title = "Feature Importance - Random Forest (NW Dataset)", x = "Feature", y = "Importance")

### XGBoost Model for NW ###
dtrain_NW <- xgb.DMatrix(data = as.matrix(train_data_NW[, c("HY5", "PIF", "CRY", "WRKY33", "all_present")]), label = train_data_NW$Day18)
dtest_NW <- xgb.DMatrix(data = as.matrix(test_data_NW[, c("HY5", "PIF", "CRY", "WRKY33", "all_present")]), label = test_data_NW$Day18)

xgb_model_NW <- xgboost(data = dtrain_NW, nrounds = 1000, objective = "reg:squarederror", eta = 0.1, max_depth = 6, verbose = 0)
xgb_pred_NW <- predict(xgb_model_NW, dtest_NW)
xgb_rmse_NW <- sqrt(mean((xgb_pred_NW - test_data_NW$Day18)^2))

# SHAP analysis for XGBoost
shap_values_NW <- shap.values(xgb_model = xgb_model_NW, X_train = as.matrix(train_data_NW[, c("HY5", "PIF", "CRY", "WRKY33", "all_present")]))
shap_long_NW <- shap.prep(shap_contrib = shap_values_NW$shap_score, X_train = as.matrix(train_data_NW[, c("HY5", "PIF", "CRY", "WRKY33", "all_present")]))
shap.plot.summary(shap_long_NW)

################################################################################
# Model Comparison and Visualization
################################################################################

# Compile model results
model_results <- data.frame(
  Dataset = c("W", "W", "NW", "NW"),
  Model = c("Random Forest", "XGBoost", "Random Forest", "XGBoost"),
  RMSE = c(rf_rmse_W, xgb_rmse_W, rf_rmse_NW, xgb_rmse_NW)
)
print(model_results)

# Visualize predictions for W and NW datasets
ggplot(data.frame(Observed = test_data_W$Day18, Predicted = rf_pred_W), aes(x = Observed, y = Predicted)) +
  geom_point(color = "blue") +
  geom_abline(slope = 1, intercept = 0, linetype = "dashed", color = "red") +
  labs(title = "Random Forest Predictions vs Observed (W Dataset)", x = "Observed Day18", y = "Predicted Day18")

ggplot(data.frame(Observed = test_data_NW$Day18, Predicted = rf_pred_NW), aes(x = Observed, y = Predicted)) +
  geom_point(color = "blue") +
  geom_abline(slope = 1, intercept = 0, linetype = "dashed", color = "red") +
  labs(title = "Random Forest Predictions vs Observed (NW Dataset)", x = "Observed Day18", y = "Predicted Day18")
