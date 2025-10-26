# Run all WHAM examples

# Ex 1
ex.dir <- file.path(here::here(), "inst", "example_scripts")
source(file.path(ex.dir, "ex1_basics.R"))

# Ex 2
rm(list=ls()) # remove all variables
ex.dir <- file.path(here::here(), "inst", "example_scripts") #set ex-file folder PATH
source(file.path(ex.dir, "ex2_CPI_recruitment.R"))

# Ex 3
rm(list=ls())
ex.dir <- file.path(here::here(), "inst", "example_scripts")
source(file.path(ex.dir, "ex3_projections.R"))

# Ex 4
rm(list=ls())
ex.dir <- file.path(here::here(), "inst", "example_scripts")
source(file.path(ex.dir, "ex4_selectivity.R"))

# Ex 5
rm(list=ls())
ex.dir <- file.path(here::here(), "inst", "example_scripts")
source(file.path(ex.dir, "ex5_M_GSI.R"))

# Ex 6
rm(list=ls())
ex.dir <- file.path(here::here(), "inst", "example_scripts")
source(file.path(ex.dir, "ex6_NAA.R"))

# Ex 8
rm(list=ls())
ex.dir <- file.path(here::here(), "inst", "example_scripts")
source(file.path(ex.dir, "ex8_compare_asap.R"))

# Ex 9
rm(list=ls())
ex.dir <- file.path(here::here(), "inst", "example_scripts")
source(file.path(ex.dir, "ex9_retro_pred.R"))

# Ex 10
rm(list=ls())
ex.dir <- file.path(here::here(), "inst", "example_scripts")
source(file.path(ex.dir, "ex10_simulation.R"))

# Ex 11
rm(list=ls())
ex.dir <- file.path(here::here(), "inst", "example_scripts")
source(file.path(ex.dir, "ex11_catchability.R"))
