
# deersim

<!-- badges: start -->
[![R-CMD-check](https://github.com/JustinCally/deersim/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/JustinCally/deersim/actions/workflows/R-CMD-check.yaml)
[![Codecov test coverage](https://codecov.io/gh/JustinCally/deersim/branch/main/graph/badge.svg)](https://app.codecov.io/gh/JustinCally/deersim?branch=main)
[![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
<!-- badges: end -->

This package contains code to run basic simulations of deer abundance on Victorian public land. A shiny app helps choose sites and evaluates expected precision of a camera trap survey program if deployed at those sites. 

## Installation

You can install the development version of deersim from [GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("JustinCally/deersim")
```

## Example

To run this app just call the function: 

``` r
library(deersim)
simulation_app()
```

