# Group-6-Homeworks

Naming conventions for individual assignments = name_letter.qmd

Final rendered relevant HW submission = index.qmd  

## HW 2 - 9/2/2026
Practice basic R skills with if-else loops, vectors, data frames, lists etc.

## HW 3 - 9/9/2026
Practice reading in different types of data, and creating custom functions.

## HW 4 - 9/16/2026
Practice data manipulation with dplyr chaining (mutate, filter, group_by/summarize, across) and querying a SQL database with dplyr and raw SQL. Added the repo's landing page (index.qmd) linking out to each homework.

## HW 5 - 9/23/2026
Practice querying a web API (httr, jsonlite) and writing a reusable query function, plus exploratory data analysis (contingency tables, stacked/side-by-side bar graphs) on a new dataset.

## HW 8 - 10/21/2026
Practice building a Shiny app: complete the starter app (selectize inputs, radio buttons, a sample-size slider, reactiveValues, observeEvent and a scatter plot) to recreate the correlation-guessing app. All files are in the HW8 folder (app.R, helpers.R, my_sample_temp.rds).
**Note:** Don't edit app.R directly. Each participant should make a copy of app.R in the HW8 folder and name it app_[first name]_[letter assigned].R.

## HW 9 - 11/04/2026
Practice fitting multiple linear regression (MLR) models with tidymodels on the Seoul bike-sharing data (SeoulBikeData.csv in the HW9 folder). Covers EDA, a 75/25 training/test split stratified on season, 10-fold CV to compare three MLR models (main effects, + interactions, + squared temperature and humidity), and a final fit with last_fit() reporting the test RMSE and coefficient table.

## HW 10 - 11/11/2026
Continues the HW9 analysis in a copy of the HW9 document. Adds tuned LASSO, regression tree, bagged tree, and random forest models using the first (main effects) recipe, compares every final model, including the best MLR model from HW9, on the test set with RMSE and MAE, summarizes each final fit (coefficient tables, a tree plot, variable importance plots), and fits the overall best model to the entire data set.
