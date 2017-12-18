### Running simple life cycle model in Stan
### The model file is "simple.stan"

library(rstan)

rstan_options(auto_write = TRUE)
options(mc.cores = parallel::detectCores())

# creating dummy dataset
data_example <- list("N" = 10,
  "s1" = 0.005,
  "s2" = c(0.25,0.23,0.21,0.20,0.175,0.15,0.10,0.05,0.05, 0.05), 
  # note that variable s2 only had 9 values before, so I added one at the end
  "s3" = 0.5,
  "propf" = 0.5,
  "fec" = 4000,
  "h" = c(0.2,0.2,0.2,0.2,0.2,0.15,0.10,0.10,0.10,0.10),
  "cvdummy" = 0.05)

str(data_example)

# compiling the model takes a few minutes but it should provide a considerable
# speed advantage for large models as the model is converted to C++ which
# is much faster than R
mstan <- stan_model("simple.stan")

# Sampling from the model object, default algorithm is NUTS
fit <- sampling(object = mstan, data = data_example, iter = 5000, chains = 2)
fit

# output showing only selected variables
print(fit, pars = c("catches", "pfa"))

# traceplot of first 10 variables
rstan::traceplot(fit, inc_warmup = TRUE)

# posterior distributions
stan_plot(fit, pars = "pfa")
stan_plot(fit, pars = "returns")
stan_plot(fit, pars = "smolts")

# posterior densities
stan_dens(fit, nrow = 3, ncol=10, pars = c("smolts", "pfa", "returns"))

# scatter plot of posteriors of two variables
stan_scat(fit, pars = c("smolts[1]", "smolts[2]"))
