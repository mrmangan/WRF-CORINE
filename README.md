# WRF-CORINE
Directions and scripts for using CORINE land use data with WRF.

1.	Reclassify the data to match either the MODIS or the USGS land use classification schemes
a.	I used the reclassification scheme from Siewert and Kroszczynski, 2020 
2.	Convert the land use map to WGS84 in ascii format 
a.	Note, may need to regrid the data before converting to ascii to ensure that the grid boxes are squares
3.	Upload ascii file to the correct folder with the rest of the files
4.	Edit file wpsingest.f90 with the correct names for the ascii file
5.	Compile: gfortran wpsingest.f90 write_geogrid.o
6.	Run file: ./a.out
7.	Copy the file created to the correct folder with the index file
8.	Edit the new GEOGID.TBL.AWS table to update the path for the priority LU values
9.	Copy that into the WPS/GEOGRID
10.	Ls -sh GEOGRID.TBL.AWS GEOGRID.TBL
11.	Run ./geogrid.exe
12.	Can check the results of land use using ncview in the geo_em file
13.	Run ./metgrib.exe (if already have the ungrib files completed)
14.	Link the new metem files to the WRF/run folder
15.	Run ./real.exe
16.	Run ./wrf.exe

