# 📊 refineR-reference-interval

**refineR-reference-interval** is an R-based application designed to simplify the process of estimating clinical reference intervals. Developed by **[Naweed Yakubi](https://github.com/yakubinaweed)**, this tool leverages the powerful [`refineR`](https://cran.r-project.org/package=refineR) package to provide an easy-to-use solution for scientists and researchers. Whether you're working with laboratory data or conducting clinical studies, this application aims to make the complex task of generating accurate reference intervals more accessible and less time-consuming.

The application supports a variety of statistical methods, including non-parametric, Box-Cox, and robust approaches, to ensure flexibility and reliability in reference interval estimation. Its goal is to help scientists quickly analyze and visualize reference intervals, saving time and effort on statistical computations.

---

<img width="1022" alt="image" src="https://github.com/user-attachments/assets/77554d61-98d8-430c-a972-12a1c237b963" />

## Features

- **Data Import**: Import measurement data from Excel (`.xlsx`) files.
- **Data Filtering**: Filter datasets by gender and age range.
- **Column Customization**: Specify custom column names for values, age, and gender.
- **Automatic Data Transformation**: Automatically detect data skewness and apply:
  - Non-parametric estimation
  - Box-Cox or modified Box-Cox transformations
- **Visualization**: Visualize reference intervals with confidence bounds.
- **Export Options**: Optionally export plots to a user-defined directory.

---

## Installation

### Prerequisites

To run the app, you will need to have **R** and **RStudio** installed:

1. **Install R**: Download and install R from the official [CRAN website](https://cran.r-project.org/).
2. **Install RStudio**: RStudio is a powerful IDE for R. Download and install it from [Posit](https://posit.co/download/rstudio-desktop/).

### R Package Installation

Once you have **R** and **RStudio** installed, open RStudio and run the following commands to install the required R packages:

```r
install.packages(c("shiny", "bslib", "readxl", "moments", "shinyjs", "shinyWidgets"))
install.packages("refineR")  # From CRAN
