# Gene Expression and Transcription Factor Analysis

This repository contains code and data for the analysis of gene expression data and the impact of transcription factors, specifically focusing on WRKY33. The analysis includes both data visualization using chord diagrams and machine learning (ML) modeling for feature importance assessment.

## Chord Diagram
Gene expression data, represented as log-fold changes, for a selected set of genes were visualized using chord diagrams with their associated transcription factors. The `dplyr` and `circlize` R packages were used for data processing and visualization.

### Methodology:
- **Dataset Division:** The dataset was divided into two groups: genes with WRKY33 (`W`) and genes without WRKY33 (`NW`).
- **Normalization:** Fold change values were normalized to a range of -1 to +1 using a custom rescaling function.
- **Visualization:** Normalized gene expression values on day 18 were visualized in separate chord diagrams for the `W` and `NW` groups, highlighting the presence or absence of WRKY33 as a transcription factor.

## Machine Learning Analysis
Machine learning techniques were employed to predict the impact of transcription factors on gene expression on day 18, using R for both modeling and visualization. Linear models were avoided due to assumption violations

### Methodology:
- **Models Used:** Random Forest and XGBoost were applied for modeling, both implemented in R.
- **Feature Importance:**
   - Random Forest: Feature importance was assessed directly.
   - XGBoost: SHAP values were used to quantify feature contributions.
- **Separate Modeling:** Gene sets with and without WRKY33 were modeled separately.
- **Performance Evaluation:**
   - Root Mean Square Error (RMSE) was used as the primary performance metric.
   - Cross-validation was applied to ensure the robustness and reliability of the findings.

## Requirements
- R (`dplyr`, `circlize`, `randomForest`, `xgboost`, `SHAPforxgboost`)

## Citation
If you use this code or data in your research, you must cite the following paper:

**Title:**
An Ecologically Designed Microbial Consortium Enhances Plant Growth and Immunity While Minimizing the Impact of Rhizspheric Microbial Community for Sustainable Agriculture

**Authors:**
Mrinmoy Mazumder1†, Hitesh Tikariha2†, Sevugan Mayalagu3, Seyed Mohammad Majedi2, Nur Ashikin Binti Abdul Hamid2, Sourav Mukhopadhyay3, Shruti Pavagadhi2, Poonguzhali Selvaraj4, Naqvi Naweed Isaak3,4,5, Sanjay Swarup1,2,3,5*

## License
This project is licensed under the MIT License - see the `LICENSE` file for details.


## Contact
For questions or collaboration inquiries, please contact [sourav_mukhopadhyay@u.nus.edu].

