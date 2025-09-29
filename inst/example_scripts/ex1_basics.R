# load wham
is.repo <- try(pkgload::load_all(compile=FALSE)) #this is needed to run from repo without using installed version of wham
if(is.character(is.repo)) library(wham) #not using repo
#by default do not perform bias-correction
if(!exists("basic_info")) basic_info <- NULL

# create directory for analysis, E.g.,
#write.dir <- "/path/to/save/output"
if(!exists("write.dir")) write.dir <- tempdir(check=TRUE)
if(!dir.exists(write.dir)) dir.create(write.dir)
setwd(write.dir)
# read asap3 data file and convert to input list for wham
path_to_examples <- system.file("extdata", package="wham")
asap3 <- read_asap3_dat(file.path(path_to_examples,"ex1_SNEMAYT.dat"))

# ---------------------------------------------------------------
# model 1
#   recruitment expectation (recruit_model): random about mean (no S-R function)
#   recruitment deviations (NAA_re): independent random effects
#   selectivity: age-specific (fix sel=1 for ages 4-5 in fishery, age 4 in index1, and ages 2-4 in index2)
input1 <- prepare_wham_input(asap3, recruit_model=2, model_name="Ex 1: SNEMA Yellowtail Flounder",
                                selectivity=list(model=rep("age-specific",3), 
                                    re=rep("none",3), 
                                    initial_pars=list(c(0.5,0.5,0.5,1,1,0.5),c(0.5,0.5,0.5,1,0.5,0.5),c(0.5,1,1,1,0.5,0.5)), 
                                    fix_pars=list(4:5,4,2:4)),
                                NAA_re = list(sigma="rec", cor="iid"), basic_info = basic_info)
m1 <- fit_wham(input1, do.osa = F) # turn off OSA residuals to save time

# Check that m1 converged (m1$opt$convergence should be 0, and the maximum gradiet should be < 1e-06)
check_convergence(m1)

# ---------------------------------------------------------------
# model 2
#   as m1, but change age comp likelihoods to logistic normal (treat 0 observations as missing)
input2 <- prepare_wham_input(asap3, recruit_model=2, model_name="Ex 1: SNEMA Yellowtail Flounder",
                                    selectivity=list(model=rep("age-specific",3), 
                                        re=rep("none",3), 
                                    initial_pars=list(c(0.5,0.5,0.5,1,1,0.5),c(0.5,0.5,0.5,1,0.5,0.5),c(0.5,1,1,1,0.5,0.5)), 
                                        fix_pars=list(4:5,4,2:4)),
                                    NAA_re = list(sigma="rec", cor="iid"),
                                    age_comp = "logistic-normal-miss0", basic_info = basic_info)
m2 <- fit_wham(input2, do.osa = F) # turn off OSA residuals to save time

# Check that m2 converged
check_convergence(m2)

# ---------------------------------------------------------------
# model 3
#   full state-space model, numbers at all ages are random effects (NAA_re$sigma = "rec+1")
input3 <- prepare_wham_input(asap3, recruit_model=2, model_name="Ex 1: SNEMA Yellowtail Flounder",
                                selectivity=list(model=rep("age-specific",3), 
                                    re=rep("none",3), 
                                    initial_pars=list(c(0.5,0.5,0.5,1,1,0.5),c(0.5,0.5,0.5,1,0.5,0.5),c(0.5,1,1,1,0.5,0.5)), 
                                    fix_pars=list(4:5,4,2:4)),
                                NAA_re = list(sigma="rec+1", cor="iid"), basic_info = basic_info)
m3 <- fit_wham(input3, do.osa = F) # turn off OSA residuals to save time

# Check that m3 converged
check_convergence(m3)

# ---------------------------------------------------------------
# model 4
#   as m3, but change age comp likelihoods to logistic normal
input4 <- prepare_wham_input(asap3, recruit_model=2, model_name="Ex 1: SNEMA Yellowtail Flounder",
                             selectivity=list(model=rep("age-specific",3), 
                                              re=rep("none",3), 
                                              initial_pars=list(c(0.5,0.5,0.5,1,1,0.5),c(0.5,0.5,0.5,1,0.5,0.5),c(0.5,1,1,1,0.5,0.5)), 
                                              fix_pars=list(4:5,4,2:4)),
                             NAA_re = list(sigma="rec+1", cor="iid"),
                             age_comp = "logistic-normal-miss0")
## 0) m4 のパラメタ器を取得（まだフィットはしない）
m4_skeleton <- fit_wham(input4, do.fit = FALSE)

## 1) m3 → m4 に “名前一致”で初期値を移植（存在する分だけ）
par4 <- m4_skeleton$parList
par3 <- m3$parList
common_names <- intersect(names(par4), names(par3))
par4[common_names] <- par3[common_names]

## 2) m4固有パラメタに安全な初期値を与える
##    - ロジット正規 年齢組成の分散（sigma系）は小さめ（例: 0.2）を log で
##    - 相関係数のロジット（phi等）は弱相関（0 に近い）を初期値に
safe_init <- function(x){
  nms <- names(x)
  for(nm in nms){
    if(grepl("age[_]*comp.*sigma|EAA.*sigma|ln_.*comp.*sigma", nm, ignore.case=TRUE)){
      x[[nm]][] <- log(0.2)   # SD ~ 0.2 を素直に
    }
    if(grepl("logit_.*phi|logit_.*rho", nm, ignore.case=TRUE)){
      x[[nm]][] <- 0          # 相関=0 初期（logit(0.5)=0 のノリ）
    }
    if(grepl("logit_q", nm, ignore.case=TRUE) && any(!is.finite(as.numeric(x[[nm]])))){
      x[[nm]][] <- 0          # q のロジット初期も無難に0
    }
  }
  x
}
par4 <- safe_init(par4)

## 3) 一時的に“気難しい”パラメタを固定してスケルトン収束点へ寄せる
##    - 名称パターンで age-comp の分散だけ一旦固定 → 位置合わせ → 解放
map_fixed <- m4_skeleton$map
idx_fix <- logical(0)
# 固定対象：age-compのsigma系（名前で抽出）
sig_keys <- names(par4)[grepl("age[_]*comp.*sigma|EAA.*sigma|ln_.*comp.*sigma", names(par4), ignore.case=TRUE)]
if(length(sig_keys)){
  for(k in sig_keys){
    # parList成分がベクトルのこともあるので NA に置き換える
    n <- length(par4[[k]])
    map_fixed[[k]] <- factor(rep(NA, n))
  }
}

## 4) “段階1”：sigma類を固定したまま短距離で最適化して姿勢を整える
## control の設定は input$control に直接入れる
input4_stage1 <- input4
input4_stage1$par <- par4
input4_stage1$map <- map_fixed
input4_stage1$control <- list(eval.max=200, iter.max=200, rel.tol=1e-8)

m4_stage1 <- fit_wham(input4_stage1,
                      do.osa=FALSE,
                      do.retro=FALSE,
                      do.sdrep=FALSE,
                      MakeADFun.silent=TRUE)
check_convergence(m4_stage1)

## 段階2も同じ要領
par4_free <- m4_stage1$parList
input4_stage2 <- input4
input4_stage2$par <- par4_free
input4_stage2$control <- list(eval.max=1000, iter.max=1000, rel.tol=1e-10)

m4 <- fit_wham(input4_stage2,
               do.osa=FALSE,
               do.retro=FALSE,
               do.sdrep=TRUE,
               MakeADFun.silent=TRUE)
check_convergence(m4)

## 6) OSA 残差（必要なら）
m4_rev <- make_osa_residuals(m4)


# ------------------------------------------------------------
# Save list of all fit models
mods <- list(m1=m1, m2=m2, m3=m3, m4=m4_rev)
save("mods", file="ex1_models.RData")

# Compare models by AIC and Mohn's rho
res <- compare_wham_models(mods, table.opts=list(fname="ex1_table", sort=TRUE))
res$best

# Project best model, m4,
# Use default values: 3-year projection, use average selectivity, M, etc. from last 5 years
m3_proj <- project_wham(model=mods[[3]])

# WHAM output plots for best model with projections
plot_wham_output(mod=m3_proj)

# Project best model, m4,
# Use default values: 3-year projection, use average selectivity, M, etc. from last 5 years
m4_proj <- project_wham(model=mods[[4]])

# WHAM output plots for best model with projections
plot_wham_output(mod=m4_proj)
