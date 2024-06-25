## Descrição do Projeto

Este projeto utiliza o amostrador de Gibbs (Inferência Bayesiana) para modelar o preço de venda de carros com base em diversas variáveis, como ano de fabricação, quilometragem rodada e tipo de transmissão. Após a leitura e limpeza dos dados do arquivo "CARSDEKHO.csv", o modelo de regressão é construído utilizando amostragem MCMC para obter distribuições posteriores dos parâmetros. A análise inclui diagnósticos de convergência de Gelman-Rubin, visualização das distribuições posteriores e previsão dos preços de venda com base nas médias dos parâmetros amostrados.

## Ferramentas Utilizadas

- **R**: Linguagem de programação utilizada para todo o processamento e análise dos dados.
- **dplyr**: Biblioteca para manipulação e transformação dos dados.
- **tidyr**: Biblioteca para pivotar tabelas.
- **readr**: Biblioteca para leitura de arquivos CSV.
- **coda**: Biblioteca para análise de convergência.
- **MCMCpack**: Biblioteca para realizar amostragem MCMC.
- **ggplot2**: Biblioteca para criação de gráficos.
- **ggpubr**: Biblioteca para combinar gráficos.

### Análise de Dados

- **Limpeza dos Dados**: Conversão da moeda indiana para ajuste dos preços de venda.
- **Modelo de Regressão**: Construção do modelo utilizando variáveis como ano, quilometragem e tipo de transmissão.
- **Amostragem MCMC**: Utilização do método MCMC para amostrar distribuições posteriores dos parâmetros do modelo.
- **Diagnóstico de Convergência**: Verificação da convergência do modelo utilizando o critério de Gelman-Rubin.
- **Visualização das Distribuições Posteriores**: Gráficos de densidade para visualizar as distribuições dos parâmetros estimados.
- **Previsão de Preços de Venda**: Utilização das médias dos parâmetros amostrados para prever os preços de venda dos carros.

### Referências

- Dados utilizados: "CARSDEKHO.csv"
- Análise estatística: Métodos de amostragem MCMC e diagnóstico de convergência.
