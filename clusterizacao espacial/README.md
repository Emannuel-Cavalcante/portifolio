# Clusterização Hierárquica dos Pontos do DataFrame

Este script realiza a clusterização hierárquica de pontos geográficos filtrados dentro do perímetro do MATOPIBA, utilizando dados de latitude, longitude e valores associados.

## Passos realizados pelo script

1. Carrega os dados filtrados a partir de arquivo TXT.
2. Filtra pontos que estão dentro do shapefile da região.
3. Reduz o número de pontos para "centroides" uniformemente espaçados, para otimizar o processamento.
4. Aplica clusterização hierárquica (método Ward) para identificar agrupamentos espaciais.
5. Salva os dados de cada cluster em arquivos TXT separados.
6. Gera visualizações dos clusters sobre o mapa da região.

## Dependências

- Python 3
- numpy
- pandas
- geopandas
- matplotlib
- scipy

Para instalar as dependências, execute:

```bash
pip install numpy pandas geopandas matplotlib scipy

