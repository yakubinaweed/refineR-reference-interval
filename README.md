# 📊 refineR-reference-interval

**refineR-reference-interval** is an R-based application for estimating clinical reference intervals from laboratory data. Built on the [`refineR`](https://cran.r-project.org/package=refineR) package, the tool supports robust, non-parametric, and transformation-based statistical methods. It provides an interactive interface for filtering data by age and gender and computing appropriate reference intervals based on data distribution characteristics.

---

## Features

- Import measurement data from Excel (`.xlsx`) files
- Filter datasets by gender and age range
- Specify custom column names for values, age, and gender
- Automatically detect data skewness and apply:
  - Non-parametric estimation
  - Box-Cox or modified Box-Cox transformations
- Visualize reference intervals with confidence bounds
- Optional export of plots to a user-defined directory

---

## Installation

Install the required R packages:

```r
install.packages(c("shiny", "bslib", "readxl", "moments", "shinyjs", "shinyWidgets"))
install.packages("refineR")  # From CRAN
