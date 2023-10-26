library(calendR)
library(tidyverse)
library(tsibble)
library(lubridate)

data_sales <- read_csv("data/train.csv")
data_stores <- read_csv("data/store.csv")
coke_colors_muted <- c("#842228", "#D27C00", "#FFC600", "#603021", "#6C6C6C", "#2C2C2C")
coke_colors_assortment <- c("#603021", "#6C6C6C", "#2C2C2C")
data_stores %>% names
data_stores <- 
  data_stores %>% 
  mutate(Assortment = 
           case_when(
             Assortment == "a" ~ "Basic",
             Assortment == "b" ~ "Extra",
             Assortment == "c" ~ "Extended")) %>% 
  mutate(comp_yearmon = 
           paste0(
             CompetitionOpenSinceYear, "-", 
             str_pad(CompetitionOpenSinceMonth, pad = "0", side = "left", width = 2)),
         prom_yearweek = 
           paste0(
             Promo2SinceYear, "-", 
             str_pad(Promo2SinceWeek, pad = "0", side = "left", width = 2)),
         comp_yearmon = if_else(comp_yearmon == "NA-NA", NA, comp_yearmon),
         prom_yearweek = if_else(prom_yearweek == "NA-NA", NA, prom_yearweek),
         comp_yearmon = if_else((CompetitionDistance>0 & is.na(comp_yearmon)), "1900-01", comp_yearmon)
  ) %>% 
  select(-CompetitionOpenSinceMonth, -CompetitionOpenSinceYear, -Promo2SinceWeek, -Promo2SinceYear)

# venta & clientes & ticket promedio por dia
data_sales2 <- 
  bind_rows(data_sales,   data.frame(
    Store = NA, DayOfWeek = NA,
    Date = seq(as.Date("2015-08-01"), as.Date("2015-12-31"), by = 1),
    Sales = NA, Customers = NA, Open = NA, Promo = NA, StateHoliday = NA,
    SchoolHoliday = NA
  ))  %>% 
  mutate(
    DayOfWeek = weekdays(Date),
    dia_sem = 
      case_when(
        DayOfWeek == "Monday" ~ "1-Lunes",
        DayOfWeek == "Tuesday" ~ "2-Martes",
        DayOfWeek == "Wednesday" ~ "3-Miercoles",
        DayOfWeek == "Thursday" ~ "4-Jueves",
        DayOfWeek == "Friday" ~ "5-Viernes",
        DayOfWeek == "Saturday" ~ "6-Sabado",
        DayOfWeek == "Sunday" ~ "7-Domingo"
      )
  ) %>% 
  left_join(
    data_stores, by = c("Store"="Store")
  ) %>% 
  mutate(sem = paste0(isoyear(Date), "-", 
                      str_pad(isoweek(Date),pad = "0", side = "left", width =2)),
         mon = paste0(year(Date), "-", 
                      str_pad(month(Date),pad = "0", side = "left", width =2)),
         yr = isoyear(Date),
         Date = factor(Date)) 

holidays_days <- data_sales2 %>% 
  select(Date, StateHoliday) %>% 
  unique %>% filter(StateHoliday != "0")

holidays <- data_sales2 %>% 
  select(sem, StateHoliday) %>% 
  unique %>% filter(StateHoliday != "0")


# Slide 02 ----------------------------------------------------------------
# grafica slide 2 (Dispersion de ventas por tienda)
data_sales2 %>% 
  group_by(dia_sem, StoreType) %>% 
  summarise(med = median(Sales)) %>% 
  spread(dia_sem, med) %>% 
  write.table(row.names = F,sep = ",")

data_sales2 %>% 
  filter(!is.na(Store)) %>% 
  ggplot(aes(x = factor(StoreType), y = Sales, 
             group = StoreType, 
             color = StoreType, fill = factor(StoreType)))+
  geom_boxplot(outlier.shape = NA, colour = "gray50", size = 0.3)+
  facet_grid(yr~dia_sem)+
  scale_y_continuous(labels = scales::comma_format(), limits = c(0,15000))+
  theme_minimal()+
  theme(legend.position = "bottom",
        axis.text.x = element_text(angle = 90, vjust = 0.5, size = 5),
        panel.grid.minor = element_blank())+
  labs(x = "Tipo de Tienda", y = "Distribución de venta por día", 
       title = "Dispersión de Ventas por tienda", fill = "", 
       subtitle = "Tiendas Totales: 1,115 ",
       caption = "Datos desde 2013-01-01 al 2015-07-31")+
  scale_fill_manual(values = coke_colors_muted)



# Slide 03 ----------------------------------------------------------------
data_sales2 %>%
  group_by(Date, dia_sem, StoreType,yr) %>% 
  summarise(numabiertas = sum(Open)) %>%
  ggplot(aes(x = Date, y = numabiertas, fill = StoreType))+
  facet_wrap(.~dia_sem, scales = "free")+
  geom_bar(position = "stack", stat = "identity")+
  labs(title = "Tiendas abiertas por dia",
       subtitle = "Tiendas Totales: 1,115 ",
       caption = "Datos desde 2013-01-01 al 2015-07-31", 
       x = "",
       y = "Número tiendas abiertas",
       fill = "")+
  theme_minimal()+
  theme(legend.position = "bottom",
        axis.text.x = element_text(angle = 90, vjust = 0.5, size = 3),
        panel.grid.minor = element_blank())+
  geom_vline(data = holidays_days %>% mutate(Date = factor(Date)), 
             aes(xintercept = Date), color = "blue4", linetype = "dashed", linewidth = 0.2,)+
  scale_fill_manual(values = coke_colors_muted)

# grafica 2
data_stores %>%
  count(StoreType, Assortment) %>%
  group_by(StoreType) %>%
  mutate(percent = n / sum(n),
         StoreType = factor(StoreType, levels = c("d", "c","b","a"))) %>%
  ggplot(aes(x = StoreType, y = percent, fill = Assortment)) +
  geom_bar(stat = "identity") +
  geom_text(aes(label = scales::percent_format(accuracy = 0.1)(percent)), 
            position = position_stack(vjust = 0.5), size = 2,  color = "white") +
  theme_minimal() +
  scale_fill_manual(values = coke_colors_assortment) +
  labs(x = "Tipo de tienda", 
       title = "Surtido por Tipo de Tienda", 
       subtitle = "Num A-Stores: 602, Num B-Stores: 17, Num C-Stores: 148, Num D-Stores: 348",
       fill = "") +
  scale_y_continuous(labels = scales::percent_format())+
  coord_flip()+
  theme(legend.position = "bottom")

# slide 04 ------------------------------------------------------------
data_sales2 %>%
  group_by(StoreType, sem, yr) %>% 
  summarise(sales = sum(Sales)/1000000) %>% 
  ggplot(aes(x = sem, y = sales, fill = StoreType))+
  facet_wrap(~yr, ncol = 3, scale = "free_x")+
  annotate("rect", xmin = "2014-27",
            xmax = "2014-52",
            ymin = -Inf, ymax = Inf, alpha = 0.2, fill = "red2")+
  geom_bar(stat = "identity")+
  theme_minimal() +
  scale_fill_manual(values = coke_colors_muted) +
  geom_vline(data = holidays, 
             aes(xintercept = sem), color = "blue4", linetype = "dashed", linewidth = 0.2) +
  labs(x = "", 
       y = "Venta Total (millones $)", 
       title = "Venta Total por Tipo de Tienda", 
       subtitle = "Total Stores: 1,115",
       caption = "Semanas tomadas con ISO8601",
       fill = "") +
  scale_y_continuous(labels = scales::comma_format())+
  theme(legend.position = "bottom",
        axis.text.x = element_text(angle = 90, vjust = 0.5, size = 5),
        panel.grid.minor = element_blank())+
  scale_x_discrete(breaks = sort(unique(xx2$sem))[c(1, seq(2, length(unique(xx2$sem)), by = 1))], 
                   labels = sort(unique(xx2$sem))[c(1, seq(2, length(unique(xx2$sem)), by = 1))])
  
  
# cambio en ventas
data_sales2 %>% 
  mutate(ind = if_else(sem >= "2014-27", sem <= "2014-52", 1, 0)) %>% 
  group_by(ind, sem) %>% 
  summarise(ventas = sum(Sales)) %>% ungroup() %>% 
  group_by(ind) %>% 
  summarise(mean_ventas = mean(ventas, na.rm = T))

# venta & clientes & ticket promedio por mes
data_sales2 %>% 
  mutate(sem = factor(sem)) %>% 
  group_by(yr, sem) %>% 
  summarise(Sales = sum(Sales),
            Customers = sum(Customers)) %>%
  mutate(`Ticket Promedio`= Sales/Customers) %>% 
  gather(variable, valor, -c(sem,yr)) %>% 
  ggplot(aes(x = sem, y = valor, group = variable, color = variable))+
  geom_line()+
  facet_grid(variable~yr, scales="free")+
  theme_minimal()+
  scale_y_continuous(labels = scales::comma_format())+
  labs(x = "Semana", 
       y = "$ Monto", 
       title = "Ventas/Clientes/Ticket promedio por semana", 
       subtitle = "Total Stores: 1,115",
       caption = "Semanas tomadas con ISO8601",
       fill = "",
       color = "")+
  theme(legend.position = "bottom",
        axis.text.x = element_text(angle = 90, vjust = 0.5, size = 4),
        panel.grid.minor = element_blank())+
  scale_color_manual(values = coke_colors_muted)+
  geom_smooth(gr)

# efecto promoción
data_sales2 %>% 
  filter(!is.na(Promo)) %>% 
  group_by(Store, Promo) %>% 
  summarise(`Venta Prom` = mean(Sales),
            `Clientes Prom` = mean(Customers)
            ) %>% 
  mutate(`Ticket Prom` = `Venta Prom`/`Clientes Prom`) %>%
  gather(variable, valor, -c(Store, Promo)) %>% 
  ggplot(aes(x = factor(Promo), y = valor, color = variable))+
  facet_wrap(~variable, scale = "free")+
  geom_point(alpha = 0.3)+
  geom_jitter(alpha = 0.3)+
  geom_boxplot(alpha = 0.5)+
  scale_color_manual(values = coke_colors_muted)+
  theme_minimal()+
  scale_y_continuous(labels = scales::comma_format())+
  labs(x = "Promoción", 
       y = "$ Monto", 
       title = "Ventas/Clientes/Ticket promedio efecto promoción", 
       subtitle = "Total Stores: 1,115",
       caption = "Semanas tomadas con ISO8601",
       fill = "",
       color = "")+
  theme(legend.position = "bottom",
        axis.text.x = element_text(angle = 90, vjust = 0.5, size = 4),
        panel.grid.minor = element_blank())
  
data_sales2 %>% 
  filter(!is.na(Promo)) %>% 
  group_by(Store, Promo) %>% 
  summarise(`Venta Prom` = mean(Sales),
            `Clientes Prom` = mean(Customers)
  ) %>% 
  mutate(`Ticket Prom` = `Venta Prom`/`Clientes Prom`) %>%
  gather(variable, valor, -c(Store, Promo)) %>% 
  group_by(variable, Promo) %>% 
  summarise(mean = mean(valor)) %>% 
  spread(Promo, mean) %>% 
  write.table(row.names = F, sep = ",")

# Por tipo de tienda Dispersión
data_sales2 %>%
  filter(!is.na(StoreType)) %>% 
  group_by(StoreType, Store, sem) %>%
  summarise(sales = sum(Sales)) %>%
  ggplot(aes(x = factor(sem), y = sales, fill = StoreType)) +
  geom_boxplot(outlier.shape = NA, colour = "gray50", size = 0.3) +
  facet_wrap(~StoreType, scales = "free_y", ncol =1) +
  coord_cartesian(ylim = c(0,120000))+
  geom_smooth(group = 1)+
  theme_minimal() +  # Use a minimal theme
  theme(panel.border = element_blank()) +
  labs(x = "Semana", 
       y = "Venta Total (millones $)", 
       title = "Dispersión de Venta Total por Tipo de Tienda", 
       subtitle = "Total Stores: 1,115",
       caption = "Semanas tomadas con ISO8601",
       fill = "") +
  scale_y_continuous(labels = scales::comma_format())+
  scale_fill_manual(values = coke_colors_muted) +
  theme(legend.position = "bottom",
        axis.text.x = element_text(angle = 90, vjust = 0.5, size = 5),
        panel.grid.minor = element_blank(),
        panel.grid.major.x = element_blank())+
  scale_x_discrete(breaks = sort(unique(xx2$sem))[c(1, seq(2, length(unique(xx2$sem)), by = 1))], 
                   labels = sort(unique(xx2$sem))[c(1, seq(2, length(unique(xx2$sem)), by = 1))])+
  geom_smooth(aes(group = StoreType),linewidth = 0.5)+
  geom_vline(data = holidays, 
             aes(xintercept = sem), color = "blue4", linetype = "dashed", linewidth = 0.2, alpha = 0.5)


data_sales2 %>%
  filter(!is.na(StoreType)) %>% 
  mutate(isoy = isoyear(Date)) %>% 
  group_by(StoreType, Store, isoy, sem) %>%
  summarise(sales = sum(Sales)) %>% ungroup() %>% 
  group_by(StoreType, isoy) %>% 
  summarise(avgm = mean(sales)) %>% spread(isoy, avgm)

# efecto competencia
tmp1 <- data_sales2 %>%
  filter(CompetitionDistance>0) %>% 
  mutate(distance =
           case_when(
             0 < CompetitionDistance & CompetitionDistance<= 100 ~ "1-Menor a 100 metros",
             100 < CompetitionDistance & CompetitionDistance<= 500 ~ "2-Menor a 100 metros",
             500 < CompetitionDistance & CompetitionDistance<= 1000 ~ "3-Menor a 1,000 metros",
             1000 < CompetitionDistance & CompetitionDistance<= 5000 ~ "4-Menor a 1,000 metros",
             5000 < CompetitionDistance & CompetitionDistance<= 10000 ~ "5-Menor a 10,000 metros",
             10000 < CompetitionDistance ~ "6-Mayor a 10,000 metros"
           )) %>% 
  group_by(distance, Store, sem) %>% 
  summarise(Sales = sum(Sales),
            Customers = sum(Customers)) %>% 
  mutate(`Ticket Promedio` = Sales/Customers) %>%ungroup() %>% 
  group_by(distance, Store) %>% 
  summarise(Sales = mean(Sales),
            Customers = mean(Customers),
            `Ticket Promedio` = mean(`Ticket Promedio`)) %>% 
  gather(variable, valor, -c(distance,Store)) 

tmp1 %>% 
  ggplot(aes(x = distance, y = valor, color = variable))+
  facet_wrap(~variable, scales = "free")+
  geom_point(alpha = 0.2)+
  geom_jitter(alpha = 0.2)+
  geom_boxplot(alpha = 0.5)+
  scale_color_manual(values = coke_colors_muted)+
  theme_minimal()+
  scale_y_continuous(labels = scales::comma_format())+
  labs(x = "Distancia Competencia", 
       y = "$ Monto", 
       title = "Ventas/Clientes/Ticket promedio con competencia", 
       subtitle = "Total Stores: 1,115",
       caption = "Semanas tomadas con ISO8601",
       fill = "",
       color = "")+
  theme(legend.position = "bottom",
        axis.text.x = element_text(angle = 90, vjust = 0.5, size = 5),
        panel.grid.minor = element_blank())
  


# Evaluate data quality
# Consistency
xx <- data_stores %>% 
  mutate(consist_prom2 = 
           as.numeric(Promo2==1) + 
           as.numeric(!is.na(PromoInterval)) + 
           as.numeric(!is.na(Promo2SinceWeek)) + 
           as.numeric(!is.na(Promo2SinceYear)),
         consist_comp = 
           as.numeric(!is.na(CompetitionDistance))+
           as.numeric(!is.na(CompetitionOpenSinceMonth))+
           as.numeric(!is.na(CompetitionOpenSinceYear))
         )




