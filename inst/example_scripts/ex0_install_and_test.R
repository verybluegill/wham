# Recommend you to make a RStudio project in "wham-master" folder

# the way to load wham (Requires R >= 4.2.2 and the matching Rtools. Confirmed to work with R 4.3.1.)
library(Matrix) # Matrix を先にロード（Matrixのバージョンに TMB のバージョンを合わせるため）
install.packages("TMB", type = "source") # TMB を "source" で再インストール
library(TMB)
install.packages("pak") # pak が無ければ
pak::pkg_install("timjmiller/wham") # WHAM をインストール → 読み込み
library(wham)

# R 4.3.1 でのバージョン例
#> packageVersion("Matrix")
#[1] ‘1.5.4.1’
#> packageVersion("TMB")
#[1] ‘1.9.18’
#> packageVersion("wham")
#[1] ‘2.1.0.9004’

## 作業用ディレクトリの用意（今回はWHAM の出力を一時フォルダに保存）
if(!exists("write.dir")) write.dir <- tempdir(check=TRUE)
if(!dir.exists(write.dir)) dir.create(write.dir)
setwd(write.dir)

basic_info <- NULL # Use WHAM defaults

# read asap3 data file and convert to input list for wham
path_to_examples <- system.file("extdata", package="wham")
asap3 <- read_asap3_dat(file.path(path_to_examples,"ex1_SNEMAYT.dat"))

# ---------------------------------------------------------------
# model 1
#   recruitment expectation (recruit_model): random about mean (no S-R function)
#   recruitment deviations (NAA_re): independent random effects
#   selectivity: age-specific (fix sel=1 for ages 4-5 in fishery, age 4 in index1, and ages 2-4 in index2)
input1 <- prepare_wham_input(
  asap3,
  recruit_model = 2, # recruitment around constant mean
  model_name = "Ex 1: SNEMA Yellowtail Flounder",
  selectivity = list(
    model = rep("age-specific", 3), # fishery, index1, index2
    re = rep("none", 3),            # no random effects in selectivity
    initial_pars = list(
      c(0.5,0.5,0.5,1,1,0.5),   # fishery: set initial values (ages 1–6)
      c(0.5,0.5,0.5,1,0.5,0.5), # index1
      c(0.5,1,1,1,0.5,0.5)      # index2
    ),
    fix_pars = list(4:5, 4, 2:4) # fix these ages = 1 (as reference points), others will be estimated
  ),
  NAA_re = list(
    sigma = "rec", # only recruitment has random effect
    cor   = "iid"  # iid = errors independent across years & ages
                   # → no persistence, no age correlation
  ),
  basic_info = basic_info
)

m1 <- fit_wham(input1, do.osa = F) 
check_convergence(m1)              