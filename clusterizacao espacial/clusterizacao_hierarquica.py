import numpy as np
import matplotlib.pyplot as plt
from scipy.cluster.hierarchy import linkage, fcluster
import geopandas as gpd
import pandas as pd
from matplotlib.patches import Patch
import os

# Caminho para o arquivo TXT com dados tabulados
# Atenção: o arquivo deve conter colunas 'Nome', 'Dia', 'Latitude', 'Longitude' e 'Valor'
file_path = 'H:/Meu Drive/TESE MESTRADO/MATOPIBA/dados em dataframe/anual.txt'

# Lê o arquivo CSV com delimitador tab (\t)
df = pd.read_csv(file_path, delimiter='\t')

# Carrega o shapefile que contém o perímetro da região MATOPIBA
shapefile_path = 'H:/Meu Drive/TESE MESTRADO/shapefile MATOPIBA/dados matopiba/Matopiba_Perimetro.shp'
gdf = gpd.read_file(shapefile_path)

# Extrai os limites geográficos do shapefile (bounding box)
xmin, ymin, xmax, ymax = gdf.total_bounds

# Filtra os pontos do dataframe que estão dentro da área delimitada pelo shapefile
mask = (df['Longitude'].astype(float) >= xmin) & (df['Longitude'].astype(float) <= xmax) & \
       (df['Latitude'].astype(float) >= ymin) & (df['Latitude'].astype(float) <= ymax)
df_filtered = df[mask]

# Plot inicial: contorno da região e os pontos filtrados para checagem visual
fig, ax = plt.subplots()
gdf.plot(ax=ax, facecolor='none', edgecolor='black')
scatter = plt.scatter(df_filtered['Longitude'].astype(float), df_filtered['Latitude'].astype(float),
                      c=df_filtered['Valor'].astype(float), cmap='jet', marker='o', edgecolors='k')
plt.title('Contorno do Shapefile com Pontos do DataFrame')
plt.xlabel('Longitude')
plt.ylabel('Latitude')
ax.set_xlim([xmin, xmax])
ax.set_ylim([ymin, ymax])

# Para otimizar o processamento, selecionamos um número reduzido de pontos (centroides) uniformemente espaçados
num_centroids = 33138  # Pode ajustar esse valor conforme necessidade
centroid_indices = np.linspace(0, len(df_filtered) - 1, num_centroids, dtype=int)
df_filtered_centroids = df_filtered.iloc[centroid_indices]

# Prepara os dados de longitude e latitude para a clusterização hierárquica
data_points = df_filtered_centroids[['Longitude', 'Latitude']].astype(float).values

# Aplica o método 'ward' de linkage para agrupamento hierárquico
Z = linkage(data_points, method='ward')

# Define o número desejado de clusters
num_clusters = 6

# Extrai os rótulos dos clusters
labels = fcluster(Z, num_clusters, criterion='maxclust')

# Define cores fixas para cada cluster para facilitar visualização
cluster_colors = ['red', 'blue', 'green', 'purple', 'orange', 'blanchedalmond',
                  'pink', 'gray', 'cyan', 'magenta']
cluster_color_mapping = {cluster_id: color for cluster_id, color in zip(range(1, num_clusters + 1), cluster_colors)}
cluster_colors_assigned = [cluster_color_mapping[label] for label in labels]

# Cria diretório para salvar arquivos de saída, se não existir
output_dir = 'I:/Meu Drive/TESE MESTRADO/MATOPIBA/dados em dataframe/clusters_output'
os.makedirs(output_dir, exist_ok=True)

# Para cada cluster, salva os dados correspondentes em arquivos TXT separados
for cluster_id in range(1, num_clusters + 1):
    cluster_mask = (labels == cluster_id)
    cluster_data = df_filtered_centroids[cluster_mask]
    output_file_path = os.path.join(output_dir, f'cluster_{cluster_id}.txt')
    cluster_data.to_csv(output_file_path, sep='\t', index=False)

print(f'Os arquivos de saída foram salvos em: {output_dir}')

# Visualização final: mapa com clusters coloridos sobre o contorno do MATOPIBA
fig, ax = plt.subplots()
gdf.plot(ax=ax, facecolor='none', edgecolor='black')
scatter = plt.scatter(df_filtered_centroids['Longitude'].astype(float), df_filtered_centroids['Latitude'].astype(float),
                      c=cluster_colors_assigned, marker='o', edgecolors='k')
plt.title('Clusterização Hierárquica dos Pontos do DataFrame')
plt.xlabel('Longitude')
plt.ylabel('Latitude')
ax.set_xlim([xmin, xmax])
ax.set_ylim([ymin, ymax])

# Legenda customizada para indicar qual cor representa cada cluster
legend_labels = [f'Cluster {i}' for i in range(1, num_clusters + 1)]
legend_handles = [Patch(color=color, label=label) for color, label in zip(cluster_colors, legend_labels)]
plt.legend(handles=legend_handles, title='Clusters', bbox_to_anchor=(1.05, 1), loc='upper left')

plt.show()
