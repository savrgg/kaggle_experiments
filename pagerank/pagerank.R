
# 1) Representacion de redes ----------------------------------------------

library(tidyverse)
library(tidygraph)
library(ggraph)
library(visNetwork)

set.seed(13)

aristas <- 
  tibble(from = c(1, 1, 1, 1, 2), 
         to =   c(2, 3, 4, 5, 3))

red_tbl <- tidygraph::as_tbl_graph(aristas, directed = TRUE)

graficar_red_dirigida <- function(red_tbl){
  ggraph(red_tbl) + 
    geom_edge_link(arrow = arrow(), end_cap = circle(4, 'mm')) +
    geom_node_point(size = 10, colour = 'salmon') +
    geom_node_text(aes(label = name)) +
    theme_graph() + coord_fixed()
}

graficar_red_dirigida(red_tbl)

matriz_ad <- igraph::get.adjacency(red_tbl)
matriz_ad

# 2) Visualización de redes -----------------------------------------------

set.seed(1234)
g <- play_erdos_renyi(n = 20, p = 0.1, directed = FALSE) |> as_tbl_graph()

# Representación aleatoria
ggraph(g, layout = 'randomly') + geom_edge_link() +
  geom_node_point(size = 2, colour = 'salmon') +
  theme_graph()

# representacion por fuerzas
ggraph(g, layout = 'fr') + geom_edge_link() +
  geom_node_point(size = 2, colour = 'salmon') +
  theme_graph()


# con distintas fuerzas
edges <- g |> activate(edges) |> as_tibble()

red_vis <- 
  visNetwork(nodes = tibble(id = 1:20, label = 1:20), edges, width = "100%") |>
  visPhysics(solver ='forceAtlas2Based', 
             forceAtlas2Based = list(gravitationalConstant = - 50, # negativo!
                                     centralGravity = 0.01, 
                                     springLength = 100,
                                     springConstant = 1,
                                     avoidOverlap = 1
             ))
red_vis


ggraph(g, layout = 'tree') +
  geom_edge_link() +
  geom_node_point(size = 2, colour = 'salmon') +
  theme_graph()

# 3) Centralidad de redes -------------------------------------------------


# Degree ================
graficar_red_nd <- function(dat_g, layout = 'kk'){
  ggraph(dat_g, layout = layout) +
    geom_edge_link(alpha=0.2) +
    geom_node_point(aes(size = importancia), colour = 'salmon') +
    geom_node_text(aes(label = nombre), nudge_y = 0.2, size=3) +
    theme_graph(base_family = 'sans')
}


g_grado <- g |> activate(nodes) |>
  mutate(importancia = centrality_degree()) |>
  mutate(nombre = 1:20) 

graficar_red_nd(g_grado)

# nodo c más cercano a todos los demas (grado no lo captura)
g_simple <- igraph::graph(c(1, 2, 2, 3, 3, 4, 4, 5), directed = FALSE) |> 
  as_tbl_graph() |>
  mutate(importancia = centrality_degree()) |>
  mutate(nombre  = LETTERS[1:5])
graficar_red_nd(g_simple)

# nodo G es importante por que captura conexion entre partes de la red
triangulo_1 <- c(1,2,2,3,3,1)
triangulo_2 <- triangulo_1 + 3
red_3 <- igraph::graph(c(triangulo_1, triangulo_2, c(7,1,7,4)), directed = FALSE) |> 
  as_tbl_graph() |>
  mutate(importancia = centrality_degree()) |>
  mutate(nombre  = LETTERS[1:7])
graficar_red_nd(red_3)

# nodo D conectado a otro nodo importante
red_4 <- igraph::graph(c(2,1,3,1,4,1,5,1,2,3,6,2,1,7,1,8), directed=FALSE) |> 
  as_tbl_graph() |>
  mutate(importancia = centrality_degree()) |>
  mutate(nombre  = LETTERS[1:8])
graficar_red_nd(red_4)

# Betweeness ================
# Cercania ================
# Centralidad de eigenvector ================
