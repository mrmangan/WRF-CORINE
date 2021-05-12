# Script to make Ascii for CORINE dataset
# MR Mangan
# May 12, 2021

#set wd
setwd('') #set work directory

#import libraries
library(raster)
library(sp)
library(maps)
library(mapdata)
library(maptools)
library(rgdal)

inputDir <- '' #set directory with file

file <- '.TIF' #add name of the file

clc = raster(file.path(inputDir, file))

tt <- crop(clc,extent(3.3e6, 3.7e6, 2e6, 2.3e6))  #crop the raster larger than outter domain in WRF

#set missing values all to NA
values(tt)[which(values(tt) == 128)] <- NA

#Project raster
test = projectRaster(tt, crs = "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0", res = 0.0012, method = 'ngb')

#Graph the file (optional check)

library(RColorBrewer)
qual_col_pals = brewer.pal.info[brewer.pal.info$category == 'qual',]
col_vector = unlist(mapply(brewer.pal, qual_col_pals$maxcolors, rownames(qual_col_pals)))

classcolor <- col_vector[1:48]


plot(test, ylab = 'Latitude', xlab = 'Longitude', main = 'Land Use (100m)', ylim = c(40.5, 43.5), xlim = c(-3.1, 3.5), col = classcolor, legend = FALSE, axes = TRUE)
r.range <- c(minValue(tt), maxValue(tt))
plot(tt, legend.only=TRUE, col=classcolor,
     legend.width=1, legend.shrink=1,
     axis.args=list(at=seq(0, r.range[2], 5),
                    labels=seq(0, r.range[2], 5), 
                    cex.axis=0.6),
     legend.args=list(text='Land Use Class', side=4, font=2, line=2.5, cex=0.8))
grid()

#Reclassify - based on Siewert & Kroszczynski, 2020
v=c(rep(13, 9), 4, 13, 12, 12, 12, 14, 14, 14, 10, 14, 14, 14, 14, 4, 1, 5, 10, 7, 7, 7, 16, 16, 16, 16, 15, rep(11, 5), rep(21, 4), 17)
u = c(1:44)
r_mats = as.matrix(data.frame(u, v))
z = reclassify(round(tt), r_mats)
y = reclassify(round(test), r_mats)

reclass_labs = c('Evergreen Needleleaf Forest', 'Evergreen Broadleaf Forest', 'Deciduous Neddleleaf Forest', 'Deciduous Broadleaf Forest', 'Mixed Forests', 'Closed Shrublands', 'Open Shrublands', 'Woody Savannas', 'Savannas', 'Grasslands','Permanent wetland', 'Croplands',  'Urban and Built-up', 'Cropland/nNatural Vegetation Mosaic', 'Snow and Ice', 'Barren or Sparsely vegetated', 'Ocean', 'Wooded Tundra', 'Mixed Tundra', 'Bare Ground Tundra')
reclass_labs <- data.frame(classvalue1 = seq(1, 20, by = 1), classnames1 = reclass_labs)

#clean y data:
values(y)[values(y)< 1] = NA
values(y)[values(y) > 20] = NA

#optional - plot
par(mar = c(5, 4, 4, 1) + .1, oma = c(0, 0, 0, 1.5))
plot(y, ylab = 'Latitude', xlab = 'Longitude', main = 'MODIS Land Use Classes\n Outer Domain ',col = cols[1:20], 
     ylim = c(40.5, 43.5), xlim = c(-3.1, 3.5), legend = FALSE, axes = TRUE)
plot(y, legend.only=TRUE, col=cols[1:20],
     legend.width=1, legend.shrink=1,
     axis.args=list(at=c(1:20),
                    labels=labs, 
                    cex.axis=.6),
     legend.args=list(text='Land Use Class', side=4, font=2, line=3.7, cex=1))
map.scale(x = -3, y = 40.9, relwidth = 0.15, metric = TRUE, ratio = FALSE, cex = 1.2)
grid()

#write ascii to work directry
writeRaster(y, 'raster_ascii_wgs84_modis.asc', format = 'ascii', overwrite=TRUE)
