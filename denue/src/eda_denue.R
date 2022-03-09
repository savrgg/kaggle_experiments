library(tidyverse)
library(viridis)
library(janitor)
library(flextable)
library(cowplot)
library(grid)


# 1) read data ------------------------------------------------------------

data_1 <- read_csv("data/denue_inegi_43_.csv", col_types = cols(.default = "c"), locale = readr::locale(encoding = "latin1"))
data_2 <- read_csv("data/denue_inegi_46111_.csv", col_types = cols(.default = "c"), locale = readr::locale(encoding = "latin1"))
data_3 <- read_csv("data/denue_inegi_46112-46311_.csv", col_types = cols(.default = "c"), locale = readr::locale(encoding = "latin1"))
data_4 <- read_csv("data/denue_inegi_46321-46531_.csv", col_types = cols(.default = "c"), locale = readr::locale(encoding = "latin1"))
data_5 <- read_csv("data/denue_inegi_46591-46911_.csv", col_types = cols(.default = "c"), locale = readr::locale(encoding = "latin1"))

datos <-
  bind_rows(
  data_1,
  data_2,
  data_3,
  data_4,
  data_5
)

datos

# 2) read cats ------------------------------------------------------------

cat_scian <- readxl::read_excel("catalog/SCIAN_202238_211157230.xlsx", sheet = "cat")

datos2 <- datos %>% 
  left_join(cat_scian, by = c("codigo_act"="Código")) %>% 
  select(id, nom_estab, raz_social, nombre_act, per_ocu, tipo_vial, tipo_asent, 
         nomb_asent, tipoCenCom, cod_postal, cve_ent, entidad, cve_mun, municipio, 
         ageb, latitud, longitud, fecha_alta)

# grafica totales
base <- datos2 %>% 
  mutate(entidad = fct_rev(fct_infreq(entidad, ordered = F))) %>% 
  mutate(nombre_act = forcats::fct_lump(f = nombre_act, prop = .025)) %>% 
  count(entidad, nombre_act) 

table_1 <- 
  base %>% 
  mutate(n = round(n/1000,1)) %>% 
  mutate(nombre_act = str_to_title(str_replace(nombre_act, pattern = "(Comercio al por menor de |Comercio al por menor en )", ""))) %>% 
  spread(nombre_act, n) %>%
  adorn_totals(where = c("col")) %>% 
  arrange(desc(Total)) %>% 
  adorn_totals(where = c("row")) %>% 
  flextable::flextable() %>% 
  theme_booktabs() %>%
  bg(i = c(33), bg = "gray90", part = "body") %>% 
  bg(j = c(9), bg = "gray90", part = "body") %>% 
  bg(j = c(9), bg = "gray90", part = "header") %>% 
  bold(i = c(1), part = "header") %>% 
  bold(j = c(1), part = "body") %>% 
  as_raster() %>% 
  rasterGrob()

table_1 <- 
  ggplot() + 
  theme_void() + 
  annotation_custom(table_1, xmin=-Inf, xmax=Inf, ymin=-Inf, ymax=Inf)

plot_1 <- 
  base %>% 
  ggplot(aes(x = entidad, y = n/1000, fill = nombre_act))+
  geom_bar(stat = "identity")+
  theme_minimal()+
  scale_y_continuous(labels = scales::comma_format())+
  labs(x = "Entidad Federativa", y = "Miles de establecimientos", fill = "")+
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1), 
        legend.position = "bottom",
        legend.key.size = unit(0.3, 'cm'),
        legend.text = element_text(size=7))+
  guides(fill = guide_legend(nrow = 2, keyheight = 1))+
  coord_flip()+
  scale_fill_brewer(palette = "Set2")




cowplot::plot_grid(
  cowplot::plot_grid(plot_1 + theme(legend.position = "none"), 
                     table_1, nrow = 1, ncol = 2, rel_widths = c(1, 1) ),
  get_legend(plot_1), nrow = 2, ncol = 1, rel_heights = c(10, 1) 
)




datos2 %>% 
  mutate(entidad = fct_rev(fct_infreq(entidad, ordered = F))) %>% 
  count(entidad, nombre_act) %>% 
  mutate(nombre_act = forcats::fct_lump(f = nombre_act,w = n, prop = .025)) %>% 
  ggplot(aes(x = entidad, y = n/1000, fill = nombre_act))+
  geom_bar(stat = "identity", position = "fill")+
  theme_minimal()+
  scale_y_continuous(labels = scales::percent_format())+
  labs(x = "Entidad Federativa", y = "Miles de establecimientos", fill = "")+
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1), 
        legend.position = "bottom")+
  coord_flip()+
  scale_fill_brewer(palette = "Set2")








  




