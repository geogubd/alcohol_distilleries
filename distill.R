library(rgdal)
library(leaflet)
library(rvest)
library(dplyr)
library(tidyr)

setwd("Desktop/blogs/distill/")

census <- read.csv("ACS_14_5YR_S1901_with_ann.csv")

distill_data <- read.csv("my.csv")

distill_data$ZIP <- as.character(distill_data$ZIP)
distill_data$ZIP <- ifelse(nchar(distill_data$ZIP) == 4, paste("0", distill_data$ZIP, sep=""), distill_data$ZIP)


# From https://www.census.gov/geo/maps-data/data/cbf/cbf_state.html

county <- readOGR(dsn = "cb_2015_us_county_500k/cb_2015_us_county_500k.shp",
                  layer = "cb_2015_us_county_500k", verbose = FALSE)

county@data <- data.frame(county@data, census[match(county@data[, "AFFGEOID"], 
                                                    census[, "GEO.id"]), ])

pal <- colorNumeric(
  palette = "Oranges",
  domain = county@data$HC01_EST_VC13
)

county_popup <- paste(sep = "<br/>",
                      paste0("<b>County: </b>", county@data$GEO.display.label),
                      paste0("<b>Median Income: </b>$", prettyNum(county@data$HC01_EST_VC13, big.mark=",",scientific=FALSE) ))

marker_popup <- paste(sep = "<br/>",
                      paste0("<b>Facility: </b>", distill_data$OWNER.NAME))

leaflet(county) %>%
  addProviderTiles("Stamen.Toner") %>%
  addPolygons(
    stroke = FALSE, fillOpacity = 0.5, smoothFactor = 0.5,
    color = ~pal(HC01_EST_VC13),
    popup = county_popup
  ) %>%
  addCircleMarkers(lat = distill_data$Lat, lng = distill_data$Lng, radius = 5, color = 'blue', stroke = FALSE, fillOpacity = .1, popup = marker_popup) %>%
  addLegend("bottomright", pal = pal, values = ~HC01_EST_VC13,
            title = "County Median Income",
            labFormat = labelFormat(prefix = "$"),
            opacity = .5
  ) %>%
  setView(-100.690940, 41.651426, zoom = 2)
  
