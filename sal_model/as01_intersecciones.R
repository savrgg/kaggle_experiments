library(tidyverse)
library(jsonlite)
library(stringr)
# limpieza
data_rits_clientes <- read_csv("data/Clientes.csv")
data_erp_clientes <- read_csv("data/RM00101.csv")
data_vt_clientes <- read_csv("data/VT_Clientes.csv")

data_vt_clientes %>%nrow()
# hacer prueba con Estatus = 1
Estatus = 1

elim_var0_rits <- data_rits_clientes %>% select(where(~ length(unique(.)) == 1)) #%>% ncol()
elim_var0_erp <- data_erp_clientes %>% select(where(~ length(unique(.)) == 1)) #%>% ncol()
elim_var0_vt <-  data_vt_clientes %>% select(where(~ length(unique(.)) == 1)) #%>% ncol()

data_rits_clientes <- data_rits_clientes %>% select(where(~ length(unique(.)) > 1))
data_erp_clientes <- data_erp_clientes %>% select(where(~ length(unique(.)) > 1))
data_vt_clientes <- data_vt_clientes %>% select(where(~ length(unique(.)) > 1))


get_conjunto <- function(set1, set2, set3){
  
  gc_total <- c(set1, set2, set3) %>% unique %>% length()  
  gc_all <- intersect(intersect(set1, set2), set3) %>% length()
  gc_1 <- setdiff(setdiff(set1, set2), set3) %>% length()
  gc_2 <- setdiff(setdiff(set2, set1), set3) %>% length()
  gc_3 <- setdiff(setdiff(set3, set1), set2) %>% length()
  gc_12 <- setdiff(intersect(set1, set2), set3) %>% length()
  gc_13 <- setdiff(intersect(set1, set3), set2) %>% length()
  gc_23 <- setdiff(intersect(set2, set3), set1) %>% length()
  
  list(df = 
  data.frame(
    conjunto = c("all", "set1", "set2", "set3", "set12", "set13", "set23"),
    numero = c(gc_all, gc_1, gc_2, gc_3, gc_12, gc_13, gc_23)
  ),
  valid = if(gc_total == gc_all+gc_1+gc_2+gc_3+gc_12+gc_13+gc_23){T}else{F}
  )
}

# 1) sin filtros ----------------------------------------------------------
data_rits_clientes2 <- data_rits_clientes #%>% select(Numero, Nombre, Tipo) 
data_erp_clientes2 <- data_erp_clientes #%>% select(CUSTNMBR, CUSTNAME)
data_vt_clientes2 <- data_vt_clientes #%>% select(Numero, Nombre)

get_conjunto(data_rits_clientes2$Numero, data_erp_clientes2$CUSTNMBR, data_vt_clientes2$Numero)

# 1) clientes en 3 sistemas -----------------------------------------------
data_rits_clientes2 <- data_rits_clientes %>% filter(Tipo %in% c("Cliente", "CLIENTE")) #%>% select(Numero, Nombre, Tipo) 
data_erp_clientes2 <- data_erp_clientes #%>% select(CUSTNMBR, CUSTNAME)
data_vt_clientes2 <- data_vt_clientes #%>% select(Numero, Nombre)

get_conjunto(data_rits_clientes2$Numero, data_erp_clientes2$CUSTNMBR, data_vt_clientes2$Numero)



## clientes funnel
data_rits_limpio <- data_rits_clientes %>% filter(!is.na(Numero)) %>% 
  group_by(Numero) %>% 
  summarise(RFC = toString(sort(unique(RFC))),
            Nombre = toString(sort(unique(Nombre))),
            Tipo = toString(sort(unique(Tipo))))


data_rits_clientes2 <- data_rits_limpio 
data_erp_clientes2 <- data_erp_clientes 
data_vt_clientes2 <- data_vt_clientes

get_conjunto(data_rits_clientes2$Numero, data_erp_clientes2$CUSTNMBR, data_vt_clientes2$Numero)


data_rits_clientes2 <- data_rits_limpio %>% filter(str_detect(tolower(Tipo), "cliente"))
data_erp_clientes2 <- data_erp_clientes 
data_vt_clientes2 <- data_vt_clientes

get_conjunto(data_rits_clientes2$Numero, data_erp_clientes2$CUSTNMBR, data_vt_clientes2$Numero)

data_domicilios_rits <- read_csv("data/ClientesDomicilios.csv")

xx <- data_rits_clientes %>% 
  mutate(Tipo2 = 
           case_when(
             str_detect(tolower(Tipo), "cliente")~"Cliente",
             str_detect(tolower(Tipo), "alianza")~"Alianza",
             str_detect(tolower(Tipo), "corr")~"Corresponsalia",
             str_detect(tolower(Tipo), "traj")~"Trajosa",
             str_detect(tolower(Tipo), "fisc")~"Fiscal"
           )) %>% 
  left_join(data_domicilios_rits %>% select(IdCliente, Tipo), c("IdCliente"= "IdCliente")) %>% 
  filter(!is.na(Numero)) %>% 
  group_by(Numero) %>% 
  summarise(RFC = toString(sort(unique(RFC))),
            Nombre = toString(sort(unique(Nombre))),
            Tipo = toString(sort(unique(Tipo2))),
            TipoDom = toString(sort(unique(Tipo.y))))
xx %>% count(Tipo, TipoDom)



data_contactos_rits <- read_csv("data/ClientesContactos.csv")
data_contactos_rits2 <- (data_contactos_rits %>% select(IdCliente, Tipo) %>% mutate(Tipo= str_trim(Tipo, side = "both")) %>% unique %>% 
                           mutate(
                             facturacion = if_else(str_detect(Tipo, "FACT")==TRUE, "Facturacion", NA),
                             otros =if_else(str_detect(Tipo, "OTR")==TRUE,"Otros", NA),
                             administracion =if_else(str_detect(Tipo, "ADMIN")==TRUE, "Administracion", NA),
                             operacion =if_else(str_detect(Tipo, "OPER")==TRUE,"Operacion", NA),
                             laboral =if_else(str_detect(Tipo, "LABOR")==TRUE, "Laboral", NA),
                             emergencias =if_else(str_detect(Tipo, "Emer")==TRUE,"Emergencias", NA)
                           )
) %>% select(-Tipo) %>% gather(Variable, valor, -IdCliente) %>% filter(!is.na(valor)) %>% select(-Variable)

xx <- data_rits_clientes %>% 
  mutate(Tipo2 = 
           case_when(
             str_detect(tolower(Tipo), "cliente")~"Cliente",
             str_detect(tolower(Tipo), "alianza")~"Alianza",
             str_detect(tolower(Tipo), "corr")~"Corresponsalia",
             str_detect(tolower(Tipo), "traj")~"Trajosa",
             str_detect(tolower(Tipo), "fisc")~"Fiscal"
           )) %>% 
  left_join(data_contactos_rits2, c("IdCliente"= "IdCliente")) %>% 
  filter(!is.na(Numero)) %>% 
  group_by(Numero) %>% 
  summarise(RFC = toString(sort(unique(RFC))),
            Nombre = toString(sort(unique(Nombre))),
            Tipo = toString(sort(unique(Tipo2))),
            TipoCont = toString(sort(unique(valor))))


xx %>% count(Tipo, TipoCont) %>% data.frame()









## Documentos

data_documentos_rits <- read_csv("data/ClientesDocumentos.csv")
data_documentos_rits2 <- (data_documentos_rits %>% select(IdCliente, IDTipoDocumentoCliente) %>% 
                            mutate(TipoDoc= str_trim(IDTipoDocumentoCliente, side = "both"))) %>% 
  select(-IDTipoDocumentoCliente)

xx <- data_rits_clientes %>% 
  mutate(Tipo2 = 
           case_when(
             str_detect(tolower(Tipo), "cliente")~"Cliente",
             str_detect(tolower(Tipo), "alianza")~"Alianza",
             str_detect(tolower(Tipo), "corr")~"Corresponsalia",
             str_detect(tolower(Tipo), "traj")~"Trajosa",
             str_detect(tolower(Tipo), "fisc")~"Fiscal"
           )) %>% 
  left_join(data_documentos_rits2, c("IdCliente"= "IdCliente")) %>% 
  filter(!is.na(Numero)) %>% 
  group_by(Numero) %>% 
  summarise(RFC = toString(sort(unique(RFC))),
            Nombre = toString(sort(unique(Nombre))),
            Tipo = toString(sort(unique(Tipo2))),
            TipoDoc = toString(sort(unique(TipoDoc))))

xx %>% count(Tipo, TipoDoc)

data_rits_clientes
ServicioContratado
tabla ClientesPuertosServicios
# checar servicios contratados por clinete
# revisar que tenga documentos requeridos
# catalogo de servicios


# Jose Luis, entregar un reporte de los clientes 
# con las unidades de negocio que operan/facturan
# [2:00 PM] Jovanny Hernandez
# rits..UnidadNegocio
