FROM osgeo/gdal:ubuntu-full-3.5.3

ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8

RUN apt-get update
RUN apt-get install sudo  python3-pip python3-venv git -y
RUN pip3 install rasterio==1.1.3 rio-cogeo==1.1.10 --no-binary rasterio
RUN pip3 install git+https://github.com/benmack/nasa_hls.git
RUN python3 -m pip install -U pip
RUN python3 -m pip install jupyterlab
RUN python3 -m pip install pystac-client==0.5.0
COPY ./requirements.txt ./requirements.txt
RUN pip3 install -r ./requirements.txt

RUN git clone https://github.com/NASA-IMPACT/hls-hdf_to_cog
RUN mkdir ./data
RUN mkdir ./cdl_training_data

EXPOSE 8888

ENTRYPOINT ["jupyter", "lab", "--ip=0.0.0.0", "--allow-root"]
