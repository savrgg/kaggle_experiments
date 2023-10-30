library(tidyverse)
library(jsonlite)

data_clientes_rits <- read_csv("~/Desktop/Clientes.csv")
data_documentos_rits <- read_csv("~/Desktop/ClientesDocumentos.csv")
data_domicilios_rits <- read_csv("~/Desktop/ClientesDomicilios.csv")
data_contactos_rits <- read_csv("~/Desktop/ClientesContactos.csv")
data_vendedores_rits <- read_csv("~/Desktop/ClientesVendedores.csv")
data_vendedoresserv_rits <- read_csv("~/Desktop/ClientesVendedoresServicios.csv")
data_sucursal_rits <- read_csv("~/Desktop/ClientesSucursal.csv")
data_consolidacion_rits <- read_csv("~/Desktop/ClientesConsolidacion.csv")
tipo_documento_rits <- read_csv("~/Desktop/tipoDocumento.csv")

clientes_duplicados_rits <- 
  data_clientes_rits %>% 
  filter(Numero %in% 
           (data_clientes_rits %>% group_by(Numero) %>% count() %>% filter(n>1))$Numero) %>% 
  arrange(desc(Numero)) %>% write_csv("rits_clientes_duplicados.csv")

clientes_duplicados_rits %>% count(Numero) %>% arrange(desc(n)) %>% head()
clientes_duplicados_rits %>% filter(is.na(Numero)) %>% data.frame() %>% arrange(desc(FechaReg)) %>% filter(Activo == 1) %>% head(100) %>% tail(1) 
clientes_duplicados_rits %>% filter(Activo == 1) %>% count(Numero) %>% arrange(desc(n))
clientes_duplicados_rits %>% filter(Numero == "001960") %>% data.frame()

clientes_noduplicados_rits <- 
  data_clientes_rits %>% 
  filter(Numero %in% 
           (data_clientes_rits %>% group_by(Numero) %>% count() %>% filter(n==1))$Numero) %>% 
  arrange(desc(Numero))


# data_documentos_rits %>% data.frame() %>% 
#   left_join(tipo_documento_rits, by = c("IDTipoDocumentoCliente" = "IDClaseDocumento")) %>% 
#   filter(!is.na(Descripcion), !is.na(Revisado), !is.na(Autorizado)) %>% head() %>% data.frame() %>% 
#   set_names(tolower(names(.))) %>% 
#   rowwise %>%
#   mutate(documents_dimensions = toJSON(
#     list(
#       tipo_documento = descripcion,
#       nombre_original = nombreoriginal,
#       nombre = nombre
#       ), 
#     auto_unbox = T)
#     ) %>% head() %>% data.frame()


data_documentos_rits_limp <- 
  data_documentos_rits %>% data.frame() %>% 
  left_join(tipo_documento_rits, by = c("IDTipoDocumentoCliente" = "IDClaseDocumento")) %>% 
  filter(!is.na(Descripcion), !is.na(Revisado), !is.na(Autorizado)) %>% 
  group_by(IdCliente, IDTipoDocumentoCliente, Descripcion, Revisado, Autorizado) %>% 
  count() %>% mutate(
    status_documento = 
      case_when((Revisado == "false" & Autorizado == "false")~"0-No Revisado y No Autorizado",
                (Revisado == "false" & Autorizado == "true")~"1-No Revisado y Autorizado",
                (Revisado == "false" & Autorizado == "false")~"2-Revisado y No Autorizado ",
                (Revisado == "false" & Autorizado == "false")~"3-Revisado y Autorizado"
                )) %>% ungroup() %>% 
  filter(!is.na(status_documento)) %>% 
  select(IdCliente, Descripcion, status_documento) %>% 
  set_names(tolower(names(.))) %>% 
  spread(descripcion, status_documento, fill = "sin documento")

data_domicilios_rits_limp <- 
  data_domicilios_rits %>% 
  group_by(IdCliente, Tipo) %>% 
  arrange(desc(FechaMod)) %>% mutate(n = 1:n()) %>% filter(n == 1) %>% 
  count() %>% spread(Tipo, n, fill = 0)

data_personal_rits_limp <- 
  clientes_noduplicados_rits %>% 
  select(IdCliente, IdSucursal, IdClienteCorporativo, 
         Numero, CURP, Nombre, ApellidoPaterno, ApellidoMaterno,
         Empresa, Tipo, Industria, Activo, Idioma, ClaTipoCliente, UsuarioReg, 
         UsuarioMod, IDTipoCliente)

data_financiero_rits_limp <- 
  clientes_noduplicados_rits %>% 
  select(IdCliente, RFC, AcuerdoFinanciero, ConceptosFinanciar, MontoPlazo,
         InstruccionFacturacion, NoReferenciaFacturacion, Banco, ReferenciaBancaria, Notas,
         NotasAdmin, RegimenCapital, RegimenFiscal
         )

data_contactos_rits_limp <- 
data_contactos_rits %>% 
  select(IdCliente, Tipo, FechaMod) %>% 
  group_by(IdCliente, Tipo) %>% 
  arrange(desc(FechaMod)) %>% mutate(n = 1:n()) %>% filter(n == 1) %>% ungroup() %>% 
  group_by(IdCliente) %>% 
  summarise(Tipo = paste(Tipo, collapse = ",")) %>% 
  mutate(
    contac_operacion = as.integer(str_detect(Tipo, "OPERA")),
    contac_administracion = as.integer(str_detect(Tipo, "ADMIN")),
    contac_emergencias = as.integer(str_detect(Tipo, "EMER")),
    contac_laboral = as.integer(str_detect(Tipo, "LABO")),
    contac_facturacion = as.integer(str_detect(Tipo, "FACT")),
    contac_facturacion = as.integer(str_detect(Tipo, "OTROS"))
  )


data_vendedores_rits_limp <- 
  data_vendedores_rits %>% 
  select(IdCliente, IdVendedor, FechaAsignacion) %>% unique %>% 
  group_by(IdCliente, IdVendedor) %>% 
  arrange(desc(FechaAsignacion)) %>% 
  mutate(n = 1:n()) %>% 
  filter(n == 1) %>% 
  select(-FechaAsignacion, -n)

  
data_personal_rits_limp %>% count(IdCliente) %>% arrange(desc(n))
data_documentos_rits_limp %>% count(idcliente) %>% arrange(desc(n))
data_domicilios_rits_limp %>% count(IdCliente) %>% arrange(desc(n))
data_financiero_rits_limp%>% count(IdCliente) %>% arrange(desc(n))
data_contactos_rits_limp%>% count(IdCliente) %>% arrange(desc(n))

data_personal_rits_limp %>% 
  left_join(data_documentos_rits_limp, by = c("IdCliente" = "idcliente")) %>% 
  left_join(data_domicilios_rits_limp, by = c("IdCliente" = "IdCliente")) %>% 
  left_join(data_financiero_rits_limp, by = c("IdCliente" = "IdCliente")) %>% 
  left_join(data_contactos_rits_limp, by = c("IdCliente" = "IdCliente")) 

# Clientes
x1 <- (data_personal_rits_limp %>% filter(Tipo %in% c("Cliente", "CLIENTE")))$IdCliente

x2 <- (data_documentos_rits_limp$idcliente)
intersect(x1, x2) %>% length()
setdiff(x1, x2) %>% length()
setdiff(x2, x1) %>% length()

x2 <- (data_domicilios_rits_limp$IdCliente)
intersect(x1, x2) %>% length()
setdiff(x1, x2) %>% length()
setdiff(x2, x1) %>% length()

x2 <- (data_contactos_rits_limp$IdCliente)
intersect(x1, x2) %>% length()
setdiff(x1, x2) %>% length()


# Alianzas
x1 <- (data_personal_rits_limp %>% filter(Tipo %in% c("Alianza")))$IdCliente

x2 <- (data_documentos_rits_limp$idcliente)
intersect(x1, x2) %>% length()
setdiff(x1, x2) %>% length()
setdiff(x2, x1) %>% length()

x2 <- (data_domicilios_rits_limp$IdCliente)
intersect(x1, x2) %>% length()
setdiff(x1, x2) %>% length()
setdiff(x2, x1) %>% length()

x2 <- (data_contactos_rits_limp$IdCliente)
intersect(x1, x2) %>% length()
setdiff(x1, x2) %>% length()

# Corresponsalias
x1 <- (data_personal_rits_limp %>%
         filter(Tipo %in% c("Corresponsalia", "Proveedor Corresponsal")))$IdCliente

x2 <- (data_documentos_rits_limp$idcliente)
intersect(x1, x2) %>% length()
setdiff(x1, x2) %>% length()
setdiff(x2, x1) %>% length()

x2 <- (data_domicilios_rits_limp$IdCliente)
intersect(x1, x2) %>% length()
setdiff(x1, x2) %>% length()
setdiff(x2, x1) %>% length()

x2 <- (data_contactos_rits_limp$IdCliente)
intersect(x1, x2) %>% length()
setdiff(x1, x2) %>% length()

# Trajosa
x1 <- (data_personal_rits_limp %>%
         filter(Tipo %in% c("Trajosa")))$IdCliente

x2 <- (data_documentos_rits_limp$idcliente)
intersect(x1, x2) %>% length()
setdiff(x1, x2) %>% length()
setdiff(x2, x1) %>% length()

x2 <- (data_domicilios_rits_limp$IdCliente)
intersect(x1, x2) %>% length()
setdiff(x1, x2) %>% length()
setdiff(x2, x1) %>% length()

x2 <- (data_contactos_rits_limp$IdCliente)
intersect(x1, x2) %>% length()
setdiff(x1, x2) %>% length()

x1 %>% length()

domicilio_entity <- 
  list(
    no_interior = 12,
    no_exterior = 12,
    calle = "Parque industrial",
    colonia = "Parque industrial",
    municipio = "Parque industrial",
    ciudad = "Parque industrial",
    estado = "Parque industrial",
    entidad = "Parque industrial",
    pais = "Parque industrial",
    codigo_postal = "Parque industrial",
    fecha_registro = "Parque industrial",
    fecha_modificacion = "Parque industrial",
    usuario_modificacion = "Parque industrial"
  )


contacto_entity <- 
  list(
    nombre = "Parque industrial",
    apellido = "Parque industrial",
    empresa = "Parque industrial",
    titulo = "Parque industrial",
    correo = "Parque industrial",
    telefono1 = "Parque industrial",
    telefono2 = "Parque industrial",
    telefono_movil = "Parque industrial",
    extension = "Parque industrial",
    fecha_nacimiento = "Parque industrial",
    departamento = "Parque industrial"
    puesto = "Parque industrial"
    tipo_notificacion = "Parque industrial"
    notificar_bodega = "Parque industrial"
    notificar_transporte = "Parque industrial"
    notificar_aduana = "Parque industrial"
    notificar_cobranza = "Parque industrial"
    fecha_registro = "Parque industrial"
    usuario_registro = "Parque industrial"
    fecha_modificacion = "Parque industrial"
    usuario_modificacion = "Parque industrial"
    notificar_rmo = "Parque industrial"
    idioma = "Parque industrial"
  )

documentos_entity <-
  list(
    nombre_original = "Parque industrial",
    nombre = "Parque industrial",
    id_folder = "Parque industrial",
    id_file = "Parque industrial",
    view_url = "Parque industrial",
    download_url = "Parque industrial",
    archivo_size = "Parque industrial",
    revisado = "Parque industrial",
    autorizado = "Parque industrial",
    aviso_revisado = "Parque industrial",
    aviso_autorizado = "Parque industrial"
    estatus_archivo = "Parque industrial"
    notas = "Parque industrial"
    usuario_registro = "Parque industrial"
    fecha_registro = "Parque industrial"
    usuario_modificacion = "Parque industrial"
    fecha_modificacion = "Parque industrial"
    download_url = "Parque industrial"
  )

# data_clientes_rits %>% filter(Numero == "C230928001", IdCliente == "3519") %>% data.frame()
# data_documentos_rits %>% filter(IdCliente == "3519") %>% data.frame()
# data_domicilios_rits %>% filter(IdCliente == "3519") %>% data.frame()
# data_vendedores_rits %>% filter(IdCliente == "3519") %>% data.frame()
# #data_vendedoresserv_rits %>% filter(IdCliente == "3519") %>% data.frame()
# #data_sucursal_rits %>% filter(IdCliente == "3519") %>% data.frame()
# data_sucursal_rits 
# 
#   
#   
#   
# data_clientes_rits %>% filter(Activo == 1) %>% select(Numero) %>% mutate(length=nchar(Numero)) %>% filter(length == 6)#%>% group_by(length) %>% count()
# 
# 
# data_clientes_rits %>% filter(Activo == 1) %>%  select(Activo, Tipo, Numero) %>% mutate(length=nchar(Numero)) %>% group_by(length, Tipo, Activo) %>% count() %>% data.frame() %>% arrange(desc(Tipo))
# 
# data_clientes_rits %>% filter(Activo == 1, Tipo %in% c("Cliente", "CLIENTE")) %>% mutate(length=nchar(Numero)) %>% filter(length == 10)
# 
