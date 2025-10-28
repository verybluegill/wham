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
                                    age_comp = "logistic-normal-miss0", basic_info = basic_info)
m4 <- fit_wham(input4, do.retro = F, do.sdrep = F, do.osa = F) # turn off extras because it turns out convergence is not good.

# Check that m4 converged. Bad max absolute gradient
check_convergence(m4)

# Copy inits from m3 where names match
m4_skeleton <- fit_wham(input4, do.fit=FALSE)
par4 <- m4_skeleton$parList; par3 <- m3$parList
par4[intersect(names(par4), names(par3))] <- par3[intersect(names(par4), names(par3))]

# Temporarily fix all "sigma" parameters (exclude from estimation)
map_fixed <- m4_skeleton$map
for(k in names(par4)[grepl("sigma", names(par4), ignore.case=TRUE)]) 
  map_fixed[[k]] <- factor(rep(NA, length(par4[[k]])))

# Stage 1 (with sigmas fixed)
input4_stage1 <- input4; input4_stage1$par <- par4; input4_stage1$map <- map_fixed
m4_stage1 <- fit_wham(input4_stage1, do.osa=FALSE, do.retro=FALSE, do.sdrep=FALSE)

# Stage 2 (free all, full fit)
input4_stage2 <- input4; input4_stage2$par <- m4_stage1$parList
m4_stage2 <- fit_wham(input4_stage2, do.osa=F)

# Now convergence is good
check_convergence(m4_stage2)

#add OSA residuals
m4_stage2 <- make_osa_residuals(m4_stage2)

# ------------------------------------------------------------
# Save list of all fit models
mods <- list(m1=m1, m2=m2, m3=m3, m4=m4_stage2)
save("mods", file="ex1_models.RData")

# Compare models by AIC and Mohn's rho
res <- compare_wham_models(mods, table.opts=list(fname="ex1_table", sort=TRUE))
res$best

# Project best model, m4,
# Use default values: 3-year projection, use average selectivity, M, etc. from last 5 years
m4_proj <- project_wham(model=mods[[4]])

# WHAM output plots for best model with projections
plot_wham_output(mod=m4_proj)
