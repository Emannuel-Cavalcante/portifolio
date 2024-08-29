# portifolio


# Previsão de Séries Temporais com Redes Neurais Artificiais (NNETAR)

Este repositório contém um script em R para a modelagem e previsão de séries temporais usando o modelo de Redes Neurais Artificiais `NNETAR`. O script inclui geração de dados fictícios de precipitação, ajuste de modelo, otimização de hiperparâmetros, e avaliação de desempenho com métricas como MAE, MSE e RMSE.

## Visão Geral

O objetivo deste projeto é demonstrar a aplicação de redes neurais artificiais na previsão de séries temporais, usando um modelo NNETAR. O script realiza as seguintes tarefas:

1. Geração de Dados Fictícios: Cria uma série temporal mensal de precipitação para uma cidade fictícia.
2. Modelagem com NNETAR: Ajusta o modelo `NNETAR` com diferentes combinações de neurônios e camadas ocultas.
3. Otimização de Hiperparâmetros: Realiza uma busca em grid para encontrar a melhor configuração de parâmetros (número de neurônios e camadas) com base na métrica MAE.
4. Previsão e Avaliação: Gera previsões, calcula métricas de desempenho, e plota os resultados comparando valores reais e previstos.

## Requisitos

Este script foi desenvolvido em R e depende dos seguintes pacotes:

- `ggplot2`
- `gridExtra`
- `forecast`
- `astsa`
- `dplyr`
- `MLmetrics`


![1](https://github.com/user-attachments/assets/f777b53c-b825-4eca-bda6-2c1dee6cfe67)

![2](https://github.com/user-attachments/assets/e9342ddc-80eb-4cdd-bb4c-93e9ba46420b)

############### SAIDAS NO TERMINAL DAS METRICAS DE DESEMPENHO 
Melhor MAE: 67.01058 
MSE Final: 11239.62 
RMSE Final: 106.0171 

####################################### COMO USAR

git clone https://github.com/Emannuel-Cavalcante/portifolio.git

Contato
Para mais informações, entre em contato através de emannuel.b.cavalcante@gmail.com.
