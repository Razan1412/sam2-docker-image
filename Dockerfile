# Step 1: Choose a base image.
# Using an official PyTorch base image simplifies CUDA/cuDNN setup.
# This image includes Python 3.10 (or newer compatible), CUDA 12.1, and cuDNN 8, matching PyTorch >=2.5.1 requirements.
# Check PyTorch Docker Hub for the latest appropriate tags: https://hub.docker.com/r/pytorch/pytorch/tags
FROM pytorch/pytorch:2.5.1-cuda12.1-cudnn8-devel
# If you opted for a CPU-only build in requirements.txt, consider a Python base image:
# FROM python:3.10-slim

# Step 2: Set environment variables (good practice)
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1
ENV PIP_NO_CACHE_DIR=off
ENV PIP_DISABLE_PIP_VERSION_CHECK=on

# Step 3: Install system dependencies
# - git: for pip installing from git repositories.
# - build-essential: for compiling any C/C++ extensions if Python packages need it.
# - libgdal-dev: system dependency for the 'rasterio' Python package.
# - libgl1-mesa-glx, libglib2.0-0: often needed for OpenCV or Matplotlib headless operations.
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    build-essential \
    libgdal-dev \
    libgl1-mesa-glx \
    libglib2.0-0 \
    ca-certificates \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Step 4: Upgrade pip (using the python from the base image)
RUN python -m pip install --upgrade pip

# Step 5: Create a working directory
WORKDIR /opt/app

# Step 6: Copy requirements file and install Python packages
COPY requirements.txt .
RUN python -m pip install -r requirements.txt

# Step 7: Expose the JupyterLab port
EXPOSE 8888

# Step 8: Default command to run when the container starts
# This starts JupyterLab, accessible from any IP within the container's network.
# --allow-root is needed if running Jupyter as root (default in many Docker images).
# Token and password are set to empty for easier access in Kubeflow (auth is often handled by Kubeflow).
# The working directory set earlier will be the default JupyterLab directory.
CMD ["jupyter", "lab", "--ip=0.0.0.0", "--port=8888", "--no-browser", "--allow-root", "--NotebookApp.token=''", "--NotebookApp.password=''", "--NotebookApp.notebook_dir=/opt/app"]
