data_domicilios_rits <- read_csv("data/ClientesDomicilios.csv")
data_domicilios_rits %>% head %>% data.frame()

# Paso 1: Limpieza de datos
data_clean <- data_domicilios_rits %>%
  mutate(
    # Limpieza de espacios en blanco al inicio y final de los campos
    Calle = str_squish(Calle),
    Colonia = str_squish(Colonia),
    Municipio = str_squish(Municipio),
    Ciudad = str_squish(Ciudad),
    Estado = str_squish(Estado),
    Entidad = str_squish(Entidad),
    Pais = str_squish(Pais),
    
    # Convertir todo a mayúsculas para uniformidad
    Calle = toupper(Calle),
    Colonia = toupper(Colonia),
    Municipio = toupper(Municipio),
    Ciudad = toupper(Ciudad),
    Estado = toupper(Estado),
    Entidad = toupper(Entidad),
    Pais = toupper(Pais)
  )

# Paso 2: Verificación de datos
data_quality <- data_clean %>%
  mutate(
    # Verificación de códigos postales válidos (5 dígitos)
    CodigoPostalValido = str_detect(CP, "^[0-9]{5}$"),
    
    # Verificación de números exteriores válidos (pueden ser alfanuméricos)
    NumeroExteriorValido = str_detect(NoExterior, "^[A-Za-z0-9]+$"),
    
    # Verificación de números interiores válidos (pueden ser alfanuméricos)
    NumeroInteriorValido = str_detect(NoInterior, "^[A-Za-z0-9]*$"),
    
    # Verificación de que los campos no estén vacíos
    CamposNoVacios = !is.na(Calle) & !is.na(Colonia) & !is.na(Municipio) &
      !is.na(Ciudad) & !is.na(Estado) & !is.na(Pais) & !is.na(CP),
    
    # Verificación de que los campos de dirección no contengan caracteres especiales
    CaracteresEspeciales = str_detect(Calle, "[^A-Z0-9, ]") | str_detect(Colonia, "[^A-Z0-9, ]") |
      str_detect(Municipio, "[^A-Z, ]") | str_detect(Ciudad, "[^A-Z, ]") |
      str_detect(Estado, "[^A-Z, ]") | str_detect(Entidad, "[^A-Z, ]") |
      str_detect(Pais, "[^A-Z, ]"),
    
    # Verificación de que el código postal sea válido para México
    CodigoPostalMexicano = str_detect(CP, "^[0-9]{5}$") &
      substr(CP, 1, 2) %in% c("01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", "25", "26", "27", "28", "29", "30", "31", "32", "33", "34", "35") &
      !str_detect(CP, "0000$"),
    
    # Verificación de que el estado sea un estado válido en México
    #EstadoMexicano = Estado %in% c("AGUASCALIENTES", "BAJA CALIFORNIA", "BAJA CALIFORNIA SUR", "CAMPECHE", "CHIAPAS", "CHIHUAHUA", "CIUDAD DE MÉXICO", "COAHUILA", "COLIMA", "DURANGO", "ESTADO DE MÉXICO", "GUANAJUATO", "GUERRERO", "HIDALGO", "JALISCO", "MICHOACÁN", "MORELOS", "NAYARIT", "NUEVO LEÓN", "OAXACA", "PUEBLA", "QUERÉTARO", "QUINTANA ROO", "SAN LUIS POTOSÍ", "SINALOA", "SONORA", "TABASCO", "TAMAULIPAS", "TLAXCALA", "VERACRUZ", "YUCATÁN", "ZACATECAS"),
    
    # Verificación de que el país sea México
    #PaisMexicano = Pais == "MÉXICO"
  )



