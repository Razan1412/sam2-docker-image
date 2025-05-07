# Step 1: Choose a base image.
# Using an official PyTorch base image.
# This image includes Python 3.10, PyTorch 2.3.1, CUDA 12.1, and cuDNN 8.
FROM pytorch/pytorch:2.3.1-cuda12.1-cudnn8-devel
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
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    build-essential \
    libgdal-dev \
    libgl1-mesa-glx \
    libglib2.0-0 \
    ca-certificates \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Step 4: Upgrade pip
RUN python -m pip install --upgrade pip

# Step 5: Create a working directory
WORKDIR /opt/app

# Step 6: Copy requirements file and install Python packages
COPY requirements.txt .
# This will install PyTorch 2.3.1+cu121 from requirements.txt,
# which is compatible with the base image.
RUN python -m pip install -r requirements.txt

# Step 7: Expose the JupyterLab port
EXPOSE 8888

# Step 8: Default command to run when the container starts
CMD ["jupyter", "lab", "--ip=0.0.0.0", "--port=8888", "--no-browser", "--allow-root", "--NotebookApp.token=''", "--NotebookApp.password=''", "--NotebookApp.notebook_dir=/opt/app"]
