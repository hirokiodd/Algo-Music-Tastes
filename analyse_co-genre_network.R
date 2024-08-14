#===============================================================================
# analyse_co-genre_network.R
# Purpose: Analyse the co-genre network data
# Author: Hiroki Oda
#===============================================================================

library(ggplot2)
library(igraph)
library(dplyr)

# Load the edge data
edges <- read.csv("../data/cogenre_network/edges.csv")

# Create node list from edge list
nodes <- data.frame(Id = unique(c(edges$Source, edges$Target)))

# Create a graph object
g <- graph_from_data_frame(edges, directed = FALSE, vertices = nodes)

# Number of nodes and edges
num_nodes <- vcount(g)
num_edges <- ecount(g)

# Degree distribution
degree_dist <- degree_distribution(g)

# Clustering coefficient
clustering_coef <- transitivity(g, type = "global")

# Assortativity
assortativity <- assortativity_degree(g)

# Centrality measures
#centrality <- centrality(g, measures = c("degree", "betweenness", "closeness", "eigen"))

# Output the results
print("Number of nodes")
num_nodes
print("Number of edges")
num_edges
#degree_dist
print("Clustering coefficient")
clustering_coef
print("Assortativity")
assortativity

# Visualise the degree distribution
degree_dist_df <- data.frame(degree = 1:length(degree_dist), frequency = degree_dist)
ggplot(degree_dist_df, aes(x = degree, y = frequency)) +
  geom_point() +
  geom_line() +
  scale_x_log10() +
  scale_y_log10() +
  xlab("Degree") +
  ylab("Frequency") +
  ggtitle("Degree distribution")

# Load the category data
categories <- read.csv("../data/cogenre_network/category_stats.csv")
subgenres <- read.csv("../data/cogenre_network/category_sub-genre.csv")

# Number of categories and sub-genres
num_categories <- nrow(categories)
num_subgenres <- nrow(subgenres)

# Statistics of categories
category_stats <- categories %>%
  select(category, num_nodes, num_edges, num_inter_category_edges, average_atypicality)

# Output the results
print("Number of categories")
num_categories
print("Number of sub-genres")
num_subgenres

# Load the atypicality data
atypicality <- read.csv("../data/cogenre_network/genre_atypicality.csv")

# Categories with high atypicality
high_atypicality <- atypicality %>%
  arrange(desc(atypicality)) %>%
  head(5)

# Categories with low atypicality
low_atypicality <- atypicality %>%
  arrange(atypicality) %>%
  head(5)

# Description of the atypicality distribution
atypicality_dist <- atypicality %>%
  summarise(mean = mean(atypicality), sd = sd(atypicality), median = median(atypicality), min = min(atypicality), q25 = quantile(atypicality, 0.25), q75 = quantile(atypicality, 0.75), max = max(atypicality))

# Output the results
high_atypicality
low_atypicality
atypicality_dist
