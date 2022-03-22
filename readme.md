Normalized stimulated Raman scattering Imaging (NoRI)
=====================================================

Description
-----------

This is an example code for implementing light-scattering normalization algorithm of Normalized stimulated Raman scattering Imaging (NoRI). 
The code is written in Matlab version 2020a.

Instructions
------------

This code has two parts -- the calibration step and the sample data processing step which is executed by calibration_data_processing_code.m and sample_image_processing_code.m. Example calbration data and example sample data are found under 'cal' and 'cell image' subfolders. To adapt this algorithm to user's microscope system, users should acquire images of calibration standard samples and biological samples from their own microscope under the identical optical configuration.

## Contents

| files  | type | description | instructions |
| ------------- |:-------------:|:-------------:|:-------------:|
| fasttifread.m | Matlab function  | Read tif files     |Download to the rootpath.|
| writeTIFF.m     | Matlab function  | Write tif files     |Download to the rootpath.|
|readcalstackmax2.m| Matlab function  | Detect the optimal z planes of the calibration data|Download to the rootpath.|
|intensityFlatFieldMask.m| Matlab function  |  Take input from a calibration image and generate a flat field correction mask |Download to the rootpath.|
| getdecompmatrix.m | Matlab function  |  Read a calibration data and compute the decomposition matrix |Download to the rootpath.|
| decomp1.m      | Matlab function  |  Function for applying a decomposition matrix to an input SRS data     |Download to the rootpath.|
| decompM3_folder.m | Matlab function  |  Applies decomp1.m function to a directory |Download to the rootpath.|
|cal\decomp_data_bg.m| Matlab function  | Concentration information of calibration standard samples|Download to 'cal' subfolder.|
|calibration_data_processing_code.m| Matlab script  | Script for processing calibration data|Download to the rootpath. Update the rootpath in line 3.|
|sample_image_processing_code.m| Matlab script  |  Script for processing sample data|Download to the rootpath. Update the rootpath in line 3.|
|cal\signalX\bg.tif| TIF file| Measurement of the detector background level |Download to the cal\signalX\ subfolder.|
|cal\signalX\sample_BSA30_channel_lipidUP.tif cal\signalX\sample_BSA30_channel_proteinUP.tif cal\signalX\sample_BSA30_channel_waterUP.tif cal\signalX\sample_DOPC35_channel_lipidUP.tif cal\signalX\sample_DOPC35_channel_proteinUP.tif cal\signalX\sample_DOPC35_channel_waterUP.tif cal\signalX\sample_water_channel_lipidUP.tif cal\signalX\sample_water_channel_proteinUP.tif cal\signalX\sample_water_channel_waterUP.tif cal\signalX\sample_dmethanol_channel_lipidUP.tif cal\signalX\sample_dmethanol_channel_proteinUP.tif cal\signalX\sample_dmethanol_channel_waterUP.tif| TIF files| Measurement of the calibration standard samples |Download to the cal\signalX\ subfolder. Process with calibration_data_processing_code.m script.|
|cell image\signalX\MDCK_channel_lipidUP.tif  <br> cell image\signalX\MDCK_channel_proteinUP.tif <br> cell image\signalX\MDCK_channel_waterUP.tif | TIF files| SRS images of live MDCK cells | Download to cell image\signalX\ subfolder. Process with sample_image_processing_code.m script.|
