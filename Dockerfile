# Base image - Ubuntu 24.04
FROM ubuntu:24.04

# Install system packages + deadsnakes PPA for Python 3.13
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    sudo git curl ffmpeg ca-certificates software-properties-common && \
    add-apt-repository ppa:deadsnakes/ppa -y && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    python3.13 python3.13-venv python3.13-dev python3-pip && \
    rm -rf /var/lib/apt/lists/*

# Create ubuntu user (UID/GID 1000 for volume compatibility)
RUN (getent group 1000 || groupadd -g 1000 ubuntu) && \
    (getent passwd 1000 || useradd -m -s /bin/bash -u 1000 -g 1000 ubuntu) && \
    echo "ubuntu ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/ubuntu && \
    chmod 0440 /etc/sudoers.d/ubuntu && \
    usermod -aG video ubuntu && \
    chown -R ubuntu:ubuntu /home/ubuntu

# Switch to ubuntu user
USER ubuntu
WORKDIR /home/ubuntu/app

# Install uv
RUN curl -LsSf https://astral.sh/uv/install.sh | sh

# Set ENV for non-interactive CMD
ENV PATH=/home/ubuntu/.local/bin:$PATH

# Copy files
COPY --chown=ubuntu:ubuntu requirements.txt .
COPY --chown=ubuntu:ubuntu vibevoice_realtime_openai_api.py .
COPY --chown=ubuntu:ubuntu entrypoint.sh .

# Create venv with Python 3.13 and install deps (CPU version)
RUN /home/ubuntu/.local/bin/uv venv .venv --python 3.13 --seed && \
    . .venv/bin/activate && \
    # Instalar PyTorch CPU version
    /home/ubuntu/.local/bin/uv pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu && \
    # Instalar dependencias básicas
    /home/ubuntu/.local/bin/uv pip install \
        fastapi \
        uvicorn[standard] \
        transformers \
        accelerate \
        soundfile \
        scipy \
        librosa \
        pydantic \
        python-multipart \
        requests && \
    /home/ubuntu/.local/bin/uv cache clean

# Make entrypoint executable
RUN chmod +x entrypoint.sh

# App environment - Configurado para CPU
ENV OPTIMIZE_FOR_SPEED=0
ENV CFG_SCALE=1.25
ENV MODELS_DIR=/home/ubuntu/app/models
ENV VIBEVOICE_DEVICE=cpu

# Models volume
VOLUME /home/ubuntu/app/models

EXPOSE 8880

CMD ["./entrypoint.sh"]
