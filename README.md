# Generating CDL Training Data Chips
This repository contains the pipeline for generating a training dataset for crop type segmentation using USDA CDL data.

The main notebook, workflow.ipynb, runs through 5 main steps, tracking the completion of each step at the HLS tile level. The completion of these steps is tracked in "tile_tracker.csv". Chip level statistics are tracked in "chip_tracker.csv".

The "workflow.ipyng" notebook should be able to be run from start to finish. The "tile_tracker.csv" tracker per tile completion for each step. 

The "calc_mean_sd.ipynb" notebook calculates per band mean and sd for HLS bands. (both for each date separately, and when combining bands across dates). It also calculates CDL per-class counts across all chips. 

***PLEASE NOTE: YOU MUST MANUALLY REPLACE 'FMASK', with 'QA' in the 'hls_hdf_to_cog.py' script, under S30_BAND_NAMES and S30_DEBUG_BAND_NAMES. This script is located in /hls-hdf_to_cog/hls_hdf_to_cog/***

### Assumptions

Here are the 5 steps for chip generation in "workflow.ipynb".
- Download HLS files in HDF format (downloaded for specified months, for all HLS tiles with chips)
- Convert HDF files to TIF (3 images converted per HLS tile based on cloud cover and spatial coverage criteria. The cloud cover criteria is < 5% total cloud in entire image. The spatial coverage criteria first attempts to find 3 candidate images with 100% spatial coverage, and then decreases this threshold to 90%, 80%... 50%.) Of the candidate images that meet these criteria, the algorithm converts the first, last, and middle image.
- Reproject TIF files to CDL projection
- Chip HLS and CDL images based on chip geojson. (Outputs are in "chips", "chips_binary", and "chips_multi". Each of these folders contains a 12 band HLS image e.g. "chip_000_000_merged.tif" per chip, with band order R, G, B, NIR for first date, then second date, then third date. The CDL chip is contained in the "chip_000_000.mask" file. In the "chips" directory, the CDL chip contains raw CDL values. In "chips_binary", the CDL values are reclassed so 0 is non-crop and 1 is crop. In "chips_multi", the CDL values are reclassed to 13 classes as in "cdl_freq.csv")
- Filter chips based on QA values and NA values. (The QA values and NA values per chip are tracked in "chip_tracker.csv". The filter logic excludes chips that have >5% image values (for any of the three HLS image dates) for a single "bad" QA class. The filter logic also excludes any chips that have 1 or more NA pixels in any HLS image, in any band.)

Also, when first determining which HLS tiles to use in the pipeline, please check that there are erroneous HLS tiles (see step 0a in "workflow.ipynb". In our use case, we found that certain chips in southern CONUS were associated with HLS tile "01SBU", which is wrong.


### Requirements

Docker should be installed in your machine. 

The `workflow.ipynb` notebook requires 3 external files.
- the file `data/2021_30m_cdls_clipped.tif` and this should be generated using the code in `clip.ipynb`. You need to include the raw CDL data for this code. The raw data can be downloaded from [here](https://www.nass.usda.gov/Research_and_Science/Cropland/Release) (the 2021 version).
- the file "chip_bbox.geojson" which contains chip boundaries (in CDL crs), and attributes for chip centroids (in long, lat coordinates). The chip centroids are needed to associate each chip to an HLS tile.
- the file "sentinel_tile_grid.kml" for associating chips to HLS tiles.

### Instructionss

Build the Docker image as following:
```
docker build -t cdl .
```

Run the Docker image as a container using the following command. You need to mount the local folder that contains (or will contain) the HLS data to the container as well as the folder than contains this repo. The following assumes you are running the `docker run` command inside this folder.

```
docker run -it -v <local_path_HLS_data_folder>:/data/ -v "$(pwd)":/cdl_training_data/ -p 8888:8888 cdl
```

This will launch a jupyterlab server and by pasting the server url in the browser you can run any code. 

### Notes
