library(ggplot2)
library(shiny)
library(shinyBS)
library(ggmap)
library(leaflet)
library(RColorBrewer)

library(readODS)
library(tidyr)
library(dplyr)
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

# Define UI for application that draws a histogram
ui <- fluidPage(
   
   # Application title
   titlePanel("Saobraćajke"),
   
   # Sidebar with a slider input for number of bins 
   sidebarLayout(
      sidebarPanel(
         
        sliderInput("bins",
                     "Number of bins:",
                     min = 1,
                     max = 50,
                     value = 30),
         
         selectInput("acc", "Vrsta Nezgode",
                     c("mat.demage" = "1",
                       "death" = "2",
                       "injured" = "3",
                       "all" = "4"))
         
      ),
      
      # Show a plot of the generated distribution
      mainPanel(
        leafletOutput("mymap", width = "100%", height = 600)
      )
   )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
   
  output$mymap <- renderLeaflet({
    # Use leaflet() here, and only include aspects of the map that
    # won't need to change dynamically (at least, not unless the
    # entire map is being torn down and recreated).
    leaflet(md1) %>% addTiles() %>%
      fitBounds(~min(long), ~min(lat), ~max(long), ~max(lat)) %>% 
      addCircles(radius = 20, weight = 5, color = "black",
                 fillColor = "red", fillOpacity = 0.7, popup = ~paste(
                   "<b>", accident, "<br>", descrip, "<br>"
                 ))
  })
  
   
}

# Run the application 
shinyApp(ui = ui, server = server)

