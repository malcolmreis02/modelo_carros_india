library(dplyr)
library(readr)
library(lrgs)
library(coda)
library(MCMCpack)

rm(list = ls())

setwd("~/R/projetos/me705_infbay/trabalho_final")

dados = read_csv("CARSDEKHO.csv") 

dados = dados %>% 
  mutate_at(vars(name,fuel,seller_type,transmission, owner), as.factor) %>%
  mutate(selling_price = selling_price/73) # conversao da moeda indiana

design <- model.matrix(~ selling_price + year + km_driven + transmission*year + transmission*km_driven, 
                        data = dados, 
                        contrasts.arg = list(transmission = "contr.sum")) %>% data.frame()

mu.vector1 <- rep(-40, 5)
mu.vector2 <- rep(40, 5)

cov.vector1 <- diag(c(0.0001, rep(0.01, 4)))

n_itera <- 1e5
intervalo <- n_itera/10

fit.1.mcmc <- MCMCregress(log(selling_price) ~ year + km_driven + year.transmission1 + km_driven.transmission1, 
                          data = design,
                          burnin = n_itera, mcmc = n_itera, thin = intervalo,
                          b0 = mu.vector1, B0 = cov.vector1,
                          verbose = intervalo)

fit.2.mcmc <- MCMCregress(log(selling_price) ~ year + km_driven + year.transmission1 + km_driven.transmission1, 
                          data = design,
                          burnin = n_itera, mcmc = n_itera, thin = intervalo,
                          b0 = mu.vector2, B0 = cov.vector1,
                          verbose = intervalo)

list(fit.1.mcmc[,1], fit.2.mcmc[,1]) %>% gelman.diag(confidence = 0.95)
list(fit.1.mcmc[,2], fit.2.mcmc[,2]) %>% gelman.diag(confidence = 0.95)
list(fit.1.mcmc[,3], fit.2.mcmc[,3]) %>% gelman.diag(confidence = 0.95)
list(fit.1.mcmc[,4], fit.2.mcmc[,4]) %>% gelman.diag(confidence = 0.95)
list(fit.1.mcmc[,5], fit.2.mcmc[,5]) %>% gelman.diag(confidence = 0.95)
list(fit.1.mcmc[,6], fit.2.mcmc[,6]) %>% gelman.diag(confidence = 0.95)

### Data frame de cada cadeia
fit.1.mcmc %>% data.frame() %>% summary()
fit.2.mcmc %>% data.frame() %>% summary()


