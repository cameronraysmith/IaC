#!/usr/bin/env sh

#########
#
# development environment:
#
# install conda environment and associated packages
# for development 
# 
#########

set -x

GITHUB_ORG=pinellolab
GITHUB_REPO=pyrovelocity
CONDA_PY_VER=3.8.8
CONDA_PATH=/opt/conda/bin
JUPYTER_USER=jupyter

$CONDA_PATH/conda init --all --system 
sudo -u $JUPYTER_USER $CONDA_PATH/conda init bash

$CONDA_PATH/conda install -n base -c conda-forge -y mamba 
$CONDA_PATH/conda config --add channels bioconda
$CONDA_PATH/conda config --add channels conda-forge
$CONDA_PATH/conda config --set channel_priority flexible
$CONDA_PATH/mamba update --all -n base -y
$CONDA_PATH/mamba install -n base -c conda-forge jupyterlab-nvdashboard jupyterlab_execute_time dask-labextension bat fzf ripgrep gpustat expect

sudo git clone https://github.com/$GITHUB_ORG/$GITHUB_REPO /home/$JUPYTER_USER/$GITHUB_REPO
sudo chown -R $JUPYTER_USER:$JUPYTER_USER /home/$JUPYTER_USER 
sudo chmod -R 755 /home/$JUPYTER_USER

$CONDA_PATH/conda create -n $GITHUB_REPO python=$CONDA_PY_VER -y
$CONDA_PATH/mamba install -n $GITHUB_REPO -y $GITHUB_REPO

/opt/conda/envs/$GITHUB_REPO/bin/python -m ipykernel install --prefix=/opt/conda/ --name=$GITHUB_REPO

sudo systemctl restart jupyter.service