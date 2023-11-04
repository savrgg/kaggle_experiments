library(tidyverse)

data_rits_contactos <- read_csv("data/ClientesContactos.csv")

data_rits_contactos$TipoNotificacion %>% 
  select(IdCliente, Tipo)

data_rits_contactos %>% count(Idioma)
data_rits_contactos %>% count(NotificarRMO)

# Telefono 1, Telefono 2, TelefonoMovil, Extensión, Fecha Nacimiento, Departamento,  


# Entidad Contactos

# Empresa ¿debe ser la misma que del cliente?

data_rits_contactos %>% count(Tipo) %>% data.frame



data_rits_clientes <- read_csv("data/Clientes.csv")


data_rits_clientes %>% head() %>% data.frame()

data_rits_clientes$IdClienteCorporativo %>% unique


data_rits_clientes <- read_csv("data/ClientesDocumentos.csv")


data_rits_clientes$Revisado %>% unique
data_rits_clientes$Autorizado %>% unique
data_rits_clientes$AvisoRevisado %>% unique
data_rits_clientes$AvisoAutorizado %>% unique

data_rits_clientes$

