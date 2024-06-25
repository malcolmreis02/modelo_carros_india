library(dplyr)
library(tidyr)
library(readr)
library(coda)
library(MCMCpack)
library(ggplot2)
library(ggpubr)

### Limpando o ambiente

rm(list = ls())
setwd("~/R/projetos/me705_infbay/trabalho_final")
options(scipen = 999) # nao ter notacao cientifica
set.seed(123456)


### Lendo os dados

dados = read_csv("CARSDEKHO.csv") 


### Fazendo a limpeza do banco

dados = dados %>% 
  mutate_at(vars(name,fuel,seller_type,transmission, owner), as.factor) %>%
  mutate(selling_price = selling_price/73) # conversao da moeda indiana


### Criando a matriz de desenho do modelo

design <- model.matrix(~ selling_price + km_driven + year + transmission, data = dados) %>% data.frame()


### Fazendo a amostragem

amostragem <- function(desenho = desing, n_iteracoes = 1e4, espacamento = 1e2, vetor_mu, matriz_cov) {
  mcmc1 <- MCMCregress(formula = log(selling_price) ~ year + transmissionManual + km_driven,
                       data = desenho,
                       burnin = n_iteracoes, # usando o burnin como metade do numero das iteracoes
                       mcmc = n_iteracoes, # esse eh o numero de iteracoes apos o burnin
                       thin = espacamento,
                       b0 = vetor_mu, 
                       B0 = matriz_cov)
  return(mcmc1)
}


### Definindo as distribuicoes prioris dos betas

mu.vector1 <- rep(-40, 4) # Medias das prioris para a primeira cadeia
mu.vector2 <- rep(40, 4) # Medias das prioris para a segunda cadeia

cov.vector1 <- diag(c(0.0001, rep(0.01, 3))) # matriz de covariancia 

n_iter <- 1e5
espac <- n_iter/1000

fit.1.mcmc <- amostragem(design, n_iteracoes = n_iter, espacamento = espac, mu.vector1, cov.vector1)
fit.2.mcmc <- amostragem(design, n_iteracoes = n_iter, espacamento = espac, mu.vector2, cov.vector1)


### Observando o diagnostico de convergencia de Gelman e Rubin

obtendo_r <- function(cadeia1 = fit.1.mcmc, cadeia2 = fit.2.mcmc, beta_num = 1, confianca = 0.95){
  r <- list(cadeia1[,beta_num], cadeia2[,beta_num]) %>% gelman.diag(confidence = confianca)
  return(r)
}

R0 = obtendo_r(beta_num = 1)
R1 = obtendo_r(beta_num = 2)
R2 = obtendo_r(beta_num = 3)
R3 = obtendo_r(beta_num = 4)
RS = obtendo_r(beta_num = 5)


### Amostras de Gibbs (dataframe)

df_beta_cadeia <- function(cadeia1 = fit.1.mcmc, cadeia2 = fit.2.mcmc, beta_num = 1) {
  amostras.beta = data.frame(cbind(fit.1.mcmc[,beta_num], fit.2.mcmc[,beta_num], seq(1, nrow(fit.1.mcmc)))) %>% 
    pivot_longer(cols = c(X1, X2), names_to = "cadeia", values_to = "valor") %>%
    rename(iteracao = X3) %>%
    mutate(cadeia = as.factor(ifelse(cadeia == "X1",1,2)))
}

amostra.b0 <- df_beta_cadeia(beta_num = 1)
amostra.b1 <- df_beta_cadeia(beta_num = 2)
amostra.b2 <- df_beta_cadeia(beta_num = 3)
amostra.b3 <- df_beta_cadeia(beta_num = 4)
amostra.s <- df_beta_cadeia(beta_num = 5)


### Quartis dos betas

betas.1 <- fit.1.mcmc %>% data.frame()
betas.2 <- fit.2.mcmc %>% data.frame() 

betas.1 %>% summary()
betas.2 %>% summary()

### Observando a densidade das distribuicoes posterioris dos betas

graf_post <- function(data = amostra.bn, string = "beta"){
  g <- data %>% 
    ggplot(aes(x = valor, colour = cadeia, fill = cadeia)) +
    geom_density(linewidth = 1, alpha = 0.1) +
    labs(x = "", y = "", colour = "Cadeia", fill = "Cadeia", tag = string) +
    theme_bw()
  return(g)
}

graf.b0 <- graf_post(amostra.b0, string = "beta0")
graf.b1 <- graf_post(amostra.b1, string = "beta1")
graf.b2 <- graf_post(amostra.b2, string = "beta2")
graf.b3 <- graf_post(amostra.b3, string = "beta3")
graf.s <- graf_post(amostra.s, string = "sigma")

ggarrange(graf.b0, graf.b1, graf.b2, graf.b3, graf.s, 
          ncol = 2, nrow = 3,
          common.legend = TRUE)

### Usando as medias para fazer um modelo

medias <- apply(betas.1, 2, mean)

ypred <- medias[1] + design$year * medias[2] + design$transmissionManual * medias[3] + design$km_driven * medias[4]
residuo <- data.frame(res = log(design$selling_price) - ypred, it = 1:length(ypred))


res.point <- residuo %>%
  ggplot(aes(y = res, x = it)) +
  geom_point(stat = "identity", col = "steelblue") +
  labs(x = "", y = "Resíduo") +
  geom_hline(yintercept = 0, col = "red") +
  theme_bw()

res.dens <- residuo %>% 
  ggplot(aes(x = res)) +
  geom_density(col = "steelblue", fill = "steelblue", alpha = 0.1) +
  labs(x = "", y = "Densidade") +
  theme_bw()

ggarrange(res.point, res.dens, nrow = 1)  















