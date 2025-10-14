# Run all WHAM examples
# wdにex1~13の結果を保存するフォルダーを生成（1回のみ実行）
base <- file.path(getwd(), "ex_res")
dir.create(base, showWarnings = FALSE)
invisible(lapply(file.path(base, sprintf("ex%d", c(1:6, 8:13))), dir.create, showWarnings = FALSE))

ex.dir <- file.path(getwd(), "inst", "example_scripts")

library(wham)

# Ex 1
source(file.path(ex.dir, "ex1_basics.R"))

# Ex 2
source(file.path(ex.dir, "ex2_CPI_recruitment.R"))

# Ex 3
source(file.path(ex.dir, "ex3_projections.R"))

# Ex 4
source(file.path(ex.dir, "ex4_selectivity.R"))

# Ex 5
source(file.path(ex.dir, "ex5_M_GSI.R"))

# Ex 6
source(file.path(ex.dir, "ex6_NAA.R"))

# Ex 8
source(file.path(ex.dir, "ex8_compare_asap.R"))

# Ex 9
source(file.path(ex.dir, "ex9_retro_pred.R"))

# Ex 10
source(file.path(ex.dir, "ex10_simulation.R"))

# Ex 11
source(file.path(ex.dir, "ex11_catchability.R"))
