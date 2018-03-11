install.packages("readODS")
#
library(readODS)
library(tidyr)
library(magrittr)
md <- read_ods("NEZ_OPENDATA_20182_20180225.ODS")
dim(md)
head(md)
names(md) <- letters[1:7]
head(md)
str(md)
glimpse(md)
md <- separate(md, b, c("date", "time"), sep = ",")
cols <- c("e", "f", "g")
md[cols] <- lapply(md[cols], as.factor) 
md$date <- format(as.POSIXct(md$date,format="%d.%m.%Y"),"%d/%m/%Y")
md$time <- format(as.POSIXct(md$time, format="%H:%M"),"%H:%M")
md$date <- as.Date(md$date, "%d/%m/%Y")
str(md)
levels(md$e) <- c("mat.demage", "deaths", "injured")
levels(md$f) <- c("one_vehicle", "two_vehicle_no_turn", "two_vehicle", "parked_vehicle", "pedestrian")
md <- rename(md, id = a, long = c, lat = d, accident = e, type_acc = f, descrip = g)
names(md)
glimpse(md)

md1 <- md %>% 
  separate(time, c("hour", "minutes"), sep = ":") %>% 
  separate(date, c("year", "month", "day"), sep = "-")

cols <- c("hour", "minutes", "year", "month", "day")
md1[cols] <- lapply(md1[cols], as.integer)  

glimpse(md1)

