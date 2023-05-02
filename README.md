# Generating CDL Training Data Chips
This repository contains the pipeline for generating a training dataset for crop type segmentation using USDA CDL data.


### Requirements

Docker should be installed in your machine. 

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
