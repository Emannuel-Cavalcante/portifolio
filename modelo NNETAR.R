# Função para verificar e instalar pacotes
verificar_instalar_pacote = function(pacote) {
  if (!require(pacote, character.only = TRUE)) {
    install.packages(pacote, dependencies = TRUE)
    library(pacote, character.only = TRUE)
  }
}

# Verificar e instalar pacotes necessários
pacotes = c('ggplot2', 'gridExtra', 'forecast', 'astsa', 'dplyr', 'MLmetrics')
sapply(pacotes, verificar_instalar_pacote)

# Criando um vetor de datas mensais de janeiro de 1990 a dezembro de 2019
data = seq(as.Date("1990-01-01"), as.Date("2019-12-31"), by = "month")

# Definindo o desvio padrão
desvio_padrao = 90

# Definir a semente para garantir resultados reprodutíveis
set.seed(42)

# Função para gerar dados de precipitação para uma localidade
gerar_dados_precipitacao = function(nome_cidade, mean_precip, sd_precip, limite_maximo, limite_minimo, amplitude_sazonal) {
  # Gerando valores aleatórios com base na distribuição normal
  precipitacao = rnorm(length(data), mean = mean_precip, sd = sd_precip)
  
  # Ajustando os valores gerados para ficarem dentro dos limites
  precipitacao = pmax(pmin(precipitacao, limite_maximo), limite_minimo)
  
  # Criando o dataframe com datas e valores de precipitação
  dados_precipitacao = data.frame(Data = data, precipitacao = precipitacao)
  
  # Adicionar uma coluna chamada "mes" com base na coluna de "Data"
  dados_precipitacao$mes = format(dados_precipitacao$Data, "%m")
  
  # Criar um vetor de ângulos com base nos meses (janeiro = 0, fevereiro = π/6, julho = π, etc.)
  angulos = seq(0, 2 * pi, length.out = 12)
  
  # Calcular os valores sazonais usando a função seno com amplitudes
  sazonalidade = amplitude_sazonal * sin(angulos)
  
  # Repetir os valores sazonais para todos os anos
  sazonalidade_repetida = rep(sazonalidade, length.out = length(data))
  
  # Adicionar a sazonalidade aos dados de precipitação
  dados_precipitacao$precipitacao_sazonal = dados_precipitacao$precipitacao + sazonalidade_repetida
  
  # Ajustar os valores de precipitação sazonal para ficarem dentro dos limites
  dados_precipitacao$precipitacao_sazonal = pmax(pmin(dados_precipitacao$precipitacao_sazonal, limite_maximo), limite_minimo)
  
  # Renomear as colunas para incluir o nome da cidade
  colnames(dados_precipitacao) = c("Data", paste0("prec_", nome_cidade), "mes", paste0("prec_", nome_cidade, "_sazonal"))
  
  return(dados_precipitacao)
}

# Gerar dados para a cidade fictícia
cidade_A = gerar_dados_precipitacao("Cidade_A", mean_precip = 224, sd_precip = desvio_padrao,
                                    limite_minimo = 41, limite_maximo = 615, amplitude_sazonal = 67)

# Transformando em série temporal
prec = ts(cidade_A$prec_Cidade_A_sazonal, start = c(1990,1), end = c(2019,12), frequency = 12)

# Plot da série temporal com linha mais grossa
plot(prec, lwd = 2)

# Separando em dados de treino e teste
# Número total de observações
total_observacoes = length(prec)
# Ponto de divisão para 70% treino e 30% teste
ponto_divisao = round(total_observacoes * 0.7)

# Dados de treino
prec_treino = window(prec, start = c(1990, 1), end = c(1990 + (ponto_divisao %/% 12) - 1, (ponto_divisao %% 12)))

# Dados de teste
prec_teste = window(prec, start = c(1990 + (ponto_divisao %/% 12), (ponto_divisao %% 12) + 1))

# Definir uma grid de parâmetros para teste
grid_size = c(5,6,7,8,9, 10,11,12,13,14, 15)  # Número de neurônios
grid_layers = c(1, 2, 3,4,5,6,7,8,9)  # Número de camadas ocultas

# Inicializar variáveis para armazenar o melhor modelo e suas métricas
melhor_modelo = NULL
melhor_mae = Inf
melhor_size = NULL
melhor_layers = NULL

# Realizando o Grid Search
for (size in grid_size) {
  for (layers in grid_layers) {
    cat("Treinando modelo com size =", size, "e layers =", layers, "\n")
    
    # Ajustar o modelo com os dados de treino
    modelo_treino = nnetar(prec_treino, p = 19, size = size, repeats = layers)
    
    # Previsão com os dados de teste
    previsao_teste = forecast(modelo_treino, h = length(prec_teste))
    
    # Valores reais e previstos
    valores_reais = as.numeric(prec_teste)
    valores_previstos = as.numeric(previsao_teste$mean)
    
    # Ajustar as Previsões ao Tamanho dos Dados de Teste
    if (length(valores_previstos) > length(valores_reais)) {
      valores_previstos = valores_previstos[1:length(valores_reais)]
    } else if (length(valores_previstos) < length(valores_reais)) {
      stop("O comprimento das previsões é menor que o comprimento dos dados reais.")
    }
    
    # Calcular métricas de desempenho
    mae = MAE(valores_previstos, valores_reais)
    
    cat("MAE para size =", size, "e layers =", layers, "é", mae, "\n")
    
    # Atualizar o melhor modelo se o MAE for menor
    if (mae < melhor_mae) {
      melhor_mae = mae
      melhor_modelo = modelo_treino
      melhor_size = size
      melhor_layers = layers
    }
  }
}

cat("Melhor configuração: size =", melhor_size, ", layers =", melhor_layers, "\n")
cat("Melhor MAE:", melhor_mae, "\n")

# Previsão final usando o melhor modelo
previsao_final = forecast(melhor_modelo, h = length(prec_teste))

# Plotar a previsão final com linha mais grossa
plot(previsao_final, lwd = 2)
lines(prec_teste, col = 'red', lwd = 2)

# Legenda acima do gráfico
legend('topright', legend = c('Valores Reais', 'Previsão'), col = c('red', 'blue'), lty = 1:2, lwd = 2, bty = 'n', xpd = TRUE, inset = c(0, -0.15))

# Criar Data Frame para as Métricas de Desempenho
metrica_comparacao = data.frame(
  Valores_Reais = valores_reais,
  Valores_Previstos = valores_previstos
)

# Calcular Métricas de Desempenho
mse_final = MSE(metrica_comparacao$Valores_Previstos, metrica_comparacao$Valores_Reais)
rmse_final = RMSE(metrica_comparacao$Valores_Previstos, metrica_comparacao$Valores_Reais)
cat("MSE Final:", mse_final, "\n")
cat("RMSE Final:", rmse_final, "\n")

# Opcional: Plotar Comparação entre Valores Reais e Previstos com título ajustado
titulo_grafico = paste('Valores Reais vs. Valores Previstos\nMelhor Configuração: size =', melhor_size, ', layers =', melhor_layers)

plot(metrica_comparacao$Valores_Reais, type = 'l', col = 'blue', lwd = 2, lty = 1, ylab = 'Valor', xlab = 'Tempo', main = titulo_grafico)
lines(metrica_comparacao$Valores_Previstos, col = 'red', lwd = 2, lty = 2)

# Legenda acima do gráfico
legend('topright', legend = c('Valores Reais', 'Valores Previstos'), col = c('blue', 'red'), lty = c(1, 2), lwd = 2, bty = 'n', xpd = TRUE, inset = c(0, -0.15))
