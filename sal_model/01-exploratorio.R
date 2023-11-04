library(tidyverse)
library(readr)
library(httr)
library(countrycode)

data_rits <- read_csv("data/Clientes.csv") %>% 
  mutate(Tipo=if_else(Tipo == "NULL"| is.na(Tipo), "CLIENTE", toupper(Tipo)),
         Tipo=if_else(str_detect(Tipo,"PROV"), "TRAJOSA", Tipo),
         Activo = if_else(Activo == 1, "Activo", "Inactivo")
         ) %>% 
  mutate_all(~ifelse(. == "NULL", NA, .))


# 01) Datos personales ----------------------------------------------------
# Define a function to categorize RFCs and EINs
categorize_identifier <- function(identifier) {
  if (is.na(identifier)) {
    return("Sin RFC")
  } else if (grepl("XEXX010101000", identifier)) {
    return("Extranjero")
  } else if (grepl("^[A-Z]{4}\\d{6}[A-Z0-9]{3}$", identifier)) {
    return("Fisica")
  } else if (grepl("^[A-Z]{3}\\d{6}[A-Z0-9]{3}$", identifier)) {
    return("Moral")
  } else if (grepl("^\\d{2}-\\d{7}$", identifier)) {
    return("EIN")
  } else if (grepl("^[A-Z]{4}\\d{6}$", identifier)) {
    return("Fisica sin homoclave")
  } else if (grepl("^[A-Z]{3}\\d{6}$", identifier)) {
    return("Moral sin homoclave")
  } else {
    return("RFC/EIN Inválido")
  }
}

# RFC
data_rits_valid <- 
  data_rits %>% 
  mutate(valid_rfc = sapply(as.character(RFC), categorize_identifier))

joffroy_colors <- c("#004477", "#1673c2", "#315c80", "#56a4d9", "chocolate3", "gray50")

data_rits_valid %>%
  count(valid_rfc, Activo, Tipo) %>%
  ggplot(aes(x = factor(Activo), y = n, fill = valid_rfc)) +
  facet_wrap(~Tipo, nrow = 1, scales = "free_y")+
  geom_bar(stat = "identity") +
  scale_fill_manual(values = joffroy_colors) +
  theme_minimal() +
  theme(legend.position = "bottom")+
  scale_y_continuous(labels = scales::comma_format()) +
  geom_text(aes(label = scales::comma(if_else(n>0, n, NA))), position = position_stack(vjust = 0.5), size = 2) +
  labs(title = "Validación de RFC de clientes RITS",
       subtitle = "Total de Registros Activos: 3,251. Inactivos: 131",
       fill = "",
       x = "",
       y = "# Clientes",
       caption = "Total Activos: Clientes:3,128 Alianzas:48, Corresponsalias:50, Fiscal:1, Trajosa:24")

(data_rits_valid %>% filter(valid_rfc == "RFC/EIN Inválido"))$RFC
(data_rits_valid %>% count(valid_rfc))

#cat_regimencapital <- 
data_rits_valid <-  data_rits_valid %>% 
  mutate(valid_regimencapital = if_else(str_trim(as.character(RegimenCapital)) == "NULL", NA, RegimenCapital),
         valid_regimencapital = case_when(
           str_detect(str_replace_all(str_replace_all(Nombre, "\\.", ""), " ", ""), "(SADECV|SACV|SACECV|SA\\\r\\\nDECV|SOCIEDADANONIMADECAPITALVARIABLE)") ~ "SA DE CV",
           str_detect(str_replace_all(str_replace_all(Nombre, "\\.", ""), " ", ""), "SAPIDECV") ~ "S A P I DE CV" ,
           str_detect(str_replace_all(str_replace_all(Nombre, "\\.", ""), " ", ""), "RLDECV|SOCIEDADDERESPONSABILIDADLIMITADADECAPITALVARIABLE") ~ "S DE RL DE CV" ,
           str_detect(str_replace_all(str_replace_all(Nombre, "\\.", ""), " ", ""), "SPRDERI") ~ "SPR DE RI",
           str_detect(str_replace_all(str_replace_all(Nombre, "\\.", ""), " ", ""), "SC$") ~ "SPR DE RI",
           str_detect(str_replace_all(str_replace_all(Nombre, "\\.", ""), " ", ""), "AC$") ~ "AC",
           str_detect(str_replace_all(str_replace_all(Nombre, "\\.", ""), " ", ""), "SA$") ~ "SA",
           str_detect(str_replace_all(str_replace_all(Nombre, "\\.", ""), " ", ""), "SDEPRDERL$") ~ "S.P.R. DE R.L.",
           str_detect(str_replace_all(str_replace_all(Nombre, "\\.", ""), " ", ""), "SPRDERL$") ~ "S.P.R. DE R.L.",
           str_detect(str_replace_all(str_replace_all(Nombre, "\\.", ""), " ", ""), "SCL$") ~ "SCL",
           str_detect(str_replace_all(str_replace_all(Nombre, "\\.", ""), " ", ""), "SDERL$") ~ "S DE RL",
           str_detect(str_replace_all(str_replace_all(Nombre, "\\.", ""), " ", ""), "SDERLDEMI$") ~ "S DE RL DE MI",
           str_detect(str_replace_all(str_replace_all(Nombre, "\\.", ""), " ", ""), "SASDECV$") ~ "SAS DE CV",
          TRUE ~ RegimenCapital
          ))

big_palette <- c("#1f77b4", "#ff7f0e", "#2ca02c", "#d62728",
                "#9467bd", "#8c564b", "#e377c2", "#7f7f7f",
                "#bcbd22", "#17becf", "#1a9850", "#fc8d59",
                "#c2a5cf", "#8dd3c7", "#b3de69", "#bebada", "grey15")
  
data_rits_valid %>% 
  count(valid_rfc, valid_regimencapital, Tipo, Activo) %>% 
  ggplot(aes(x = valid_rfc, y = n, fill = valid_regimencapital))+
  geom_bar(stat = "identity")+
  facet_grid(Tipo~Activo, scales = "free_y")+
  theme_minimal()+
  theme(axis.text.x = element_text(angle = 90, hjust = 1))+
  scale_fill_manual(values = big_palette)+
  labs(x = "Tipo de Sociedad", y = "Número de registros", fill = "",
       title = "Número de Clientes por Tipo de Sociedad y Activo",
       subtitle = "Total de Registros Activos: 3,251. Inactivos: 131",
       caption = "Total Activos: Clientes:3,128 Alianzas:48, Corresponsalias:50, Fiscal:1, Trajosa:24")
    


  
  # nombre
  data_rits_valid2 <- 
    data_rits_valid %>% 
    mutate(
      Nombre2 = Nombre,
      Nombre = paste(Nombre, ApellidoPaterno, ApellidoMaterno, sep = " ")) %>%
    separate(
      Nombre,
      into = c("Nombre", "ApellidoPaterno", "ApellidoMaterno"),
      sep = " ",
      extra = "merge"
    ) %>% 
    mutate(
      Nombre = ifelse(!(valid_rfc %in% c("Fisica", "Fisica sin homoclave")), 
                      paste(Nombre, ApellidoPaterno, ApellidoMaterno, sep = " "), Nombre)) 
  
  data_rits_valid2 %>% 
    filter(valid_rfc %in% c("Fisica", "Fisica sin homoclave")) %>% 
    select(Nombre2, Nombre,ApellidoPaterno, ApellidoMaterno, valid_rfc, RFC) %>% 
    data.frame()
  





# 01) Domicilios ----------------------------------------------------

data_rits_domicilios <- read_csv("data/ClientesDomicilios.csv") %>% 
    mutate_all(~ifelse(. == "NULL", NA, .))

  
validate_postal_code <- function(country, postal_code) {
  country <- ifelse(is.na(country), NA, toupper(country))
  postal_code <- toupper(postal_code)

  # Check if the country code is valid
  valid_country <- 
    case_when(
      is.na(country) ~ NA,  
      country == "MEX" ~ str_detect(postal_code, "^[0-9]{5}$"),
      country == "USA" ~ str_detect(postal_code, "^\\d{5}(-\\d{4})?$"),
      country == "ABW" ~ str_detect(postal_code, "^[0-9]{4}$"),
      country == "DEU" ~ str_detect(postal_code, "^[0-9]{5}$"),
      country == "NLD" ~ str_detect(postal_code, "^[1-9][0-9]{3} ?(?!sa|sd|ss)[A-Z]{2}$"),
      country == "THA" ~ str_detect(postal_code, "^[0-9]{5}$"),
      country == "COL" ~ str_detect(postal_code, "^[0-9]{6}$"),
      country == "CAN" ~ str_detect(postal_code, "^[A-Z][0-9][A-Z] [0-9][A-Z][0-9]$"),
      country == "KOR" ~ str_detect(postal_code, "^[0-9]{5}$"),
      country == "GBR" ~ str_detect(postal_code, "^(GIR 0AA|[A-PR-UWYZ][A-HK-Y0-9][A-HJKPS-UW0-9][ABEHMNPRV-Y0-9]?[0-9][ABD-HJLNP-UW-Z]{2}|BFPO [0-9]{1,4})$"),
      country == "ROU" ~ str_detect(postal_code, "^[0-9]{6}$"),
      country == "PAN" ~ str_detect(postal_code, "^[0-9]{4}$"),
      country == "ITA" ~ str_detect(postal_code, "^[0-9]{5}$"),
      country == "CHN" ~ str_detect(postal_code, "^[0-9]{6}$"),
      country == "SWE" ~ str_detect(postal_code, "^[0-9]{5}(-[0-9]{4})?$"),
      country == "ESP" ~ str_detect(postal_code, "^(0[1-9]|[1-4][0-9]|5[0-2])\\d{3}$"),
      country == "ARG" ~ str_detect(postal_code, "^[0-9]{4}$"),
      country == "SLV" ~ str_detect(postal_code, "^[0-9]{4}$"),
      country == "SRB" ~ str_detect(postal_code, "^[0-9]{5}$"),
      country == "TWN" ~ str_detect(postal_code, "^[0-9]{3}(-[0-9]{2})?$"),
      country == "RUS" ~ str_detect(postal_code, "^[0-9]{6}$"),
      country == "FRA" ~ str_detect(postal_code, "^(97[0-8]|98[0-9])\\d{3}$"),
      country == "PHL" ~ str_detect(postal_code, "^[0-9]{4}$"),
      country == "IRL" ~ str_detect(postal_code, "^[A-Z0-9]{7}$"),
      country == "PER" ~ str_detect(postal_code, "^[0-9]{5}$"),
      country == "POL" ~ str_detect(postal_code, "^[0-9]{5}$"),
      country == "TUR" ~ str_detect(postal_code, "^[0-9]{5}$"),
      country == "MEX" ~ str_detect(postal_code, "^[0-9]{5}$")
  )
  
  return(valid_country)
}

get_city_from_postal_code <- function(postal_code, country_code) {
  base_url <- "https://api.zippopotam.us"
  api_url <- paste(base_url, country_code, postal_code, sep = "/")
  response <- GET(api_url)
  if (http_type(response) == "application/json") {
    data <- content(response, "parsed")
    city <- data$places[[1]]$place_name
    return(city)
  } else {
    return(NA)
  }
}

get_city_from_postal_code

alpha3_code <- "USA"
alpha2_code <- countrycode(alpha3_code, origin = "iso3c", destination = "iso2c")
print(alpha2_code)

data_rits_domicilios %>% head(2) %>% 
  mutate(Pais2 = countrycode(Pais, origin = "iso3c", destination = "iso2c")) %>% 
  mutate(valid_cp = map2_chr(Pais, CP, validate_postal_code),
         valid_city = if_else(!is.na(Pais2), map2_chr(CP, Pais2, get_city_from_postal_code), NA)) %>% 
  select(Pais, Entidad, CP, Ciudad, valid_cp, valid_city)

country_code <- "USA"
postal_code <- "90210"

get_city_from_postal_code("84065", "mx")
print(city)

# Si el cliente está en Darwin y tiene pedimento, el dato que está en Darwin es el que manda
# Si el cliente está en Darwin y no tiene pedimento, el dato que está en Mefactura es el que manda (por ejemplo en Almacen)
# Descartar empresa Trajosa, ya no se está utilizando
# El que se utiliza es ClientesEmpresas (ahi viene la relación)
# Sobre la Base de SAC está esa separación de los datos. En Darwin no se puede hacer esa modificación

# IDSucursal -- Empresa
data_rits_domicilios$Tipo %>% unique
data_rits_domicilios %>% filter(IdCliente == 1454) %>% data.frame()
data_rits %>% filter(IdCliente == 1454) %>% data.frame()
data_rits$IdSucursal %>% unique %>% sort()

# Se revisa el fiscal (Vantec no hay tabla de domicilio, se guarda cliente solamente, dan de alta CTA cuando son solo factura)
# en pedimentos se hace registro del banco (dependiendo la patente y la aduana se activa la cuenta, si no tiene cuenta se le paga la cuenta bancaria de Joffory)
data_vantec <- read_csv("data/VT_Clientes.csv")




xx <- data_rits_valid2 %>% select(IdCliente, Numero, Nombre, Empresa, Tipo, Activo) %>% 
  left_join(
    data_rits_domicilios %>% 
      filter(Tipo == "Fiscal") %>% 
      select(IdCliente, Calle, CP), by = c("IdCliente" = "IdCliente")
  ) %>% 
  filter(Activo == "Activo", Tipo == "CLIENTE")


excluir <- (xx %>% count(Numero) %>% arrange(desc(n)) %>% filter(n>1))$Numero

xx <- xx %>% filter(!(Numero %in% excluir))

xx2 <- data_vantec %>% 
  select(Oficina, Numero, Nombre, Calle, CP) %>% 
  left_join(xx, by = "Numero")

xx2 %>% 
  filter(!is.na(IdCliente)) %>% 
  mutate(ind_valid = CP.x == CP.y) %>% 
  count(ind_valid)
  
# registros recientes o algunos años -- recientemente (algunos años para hoy hay controles por parte de legal)
# Bitacora modificaciones sobre el cliente (identificar algún dato particular) - DArwin hay bitacora y da movimientos, pero están algo pesadas 
# Bitacora


# Tareas evaluar direcciones
# Explorar tabla de bitacora

  


