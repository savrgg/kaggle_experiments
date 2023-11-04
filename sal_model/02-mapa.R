library(ggplot2)
library(dplyr)
library(httr) 
library(jsonlite)  
library(sf)
world_map <- rnaturalearth::ne_countries(scale = "medium", returnclass = "sf")


# Set API key
api_key <- "b818a1d4070c457fb5444e0e869c997e"

geocode_postal_code("03300")
postal_code = "03300"
country = "MXN"
# Define function to geocode postal codes
geocode_postal_code <- function(postal_code, country) {
  url <- sprintf("https://api.opencagedata.com/geocode/v1/json?q=%s&components=country:%s&key=%s", 
                 URLencode(postal_code), URLencode(country), api_key)
  response <- GET(url)
  data <- fromJSON(content(response, "text"))
  if (data$total_results > 0) {
    indice <- which(data$results[[1]]$currency$iso_code == country)
    coords <- data$results$geometry[8,]
    return(data.frame(Latitude = coords$lat, Longitude = coords$lng))
  } else {
    return(data.frame(Latitude = NA, Longitude = NA))
  }
}


# Apply function to postal codes
your_data <- 
  xx2 %>% head(1) %>% 
  rowwise() %>%
  mutate(coords = geocode_postal_code("03300", "MXN"))

world_map <- rnaturalearth::ne_countries(scale = "medium", returnclass = "sf")


ggplot() +
  geom_sf(data = world_map, fill = "white", color = "gray", size = 0.5) +
  geom_point(data = your_data, aes(x = coords$Longitude, y = coords$Latitude), color = "blue", size = 0.3) +
  labs(title = "Postal Code Locations")

