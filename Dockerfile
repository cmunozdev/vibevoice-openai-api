FROM python:3.13-slim

WORKDIR /app

# Dependencias del sistema
RUN apt-get update && apt-get install -y --no-install-recommends \
    ffmpeg git \
 && rm -rf /var/lib/apt/lists/*

# Copiar código
COPY . /app

# Instalar uv
RUN pip install --no-cache-dir uv

# Crear venv e instalar deps
RUN uv venv .venv --python 3.13 --seed && \
    . .venv/bin/activate && \
    uv pip install --no-cache-dir -r requirements.txt

# Variables para CPU
ENV MODELS_DIR=/app/models \
    VIBEVOICE_DEVICE=cpu \
    CFG_SCALE=1.25

EXPOSE 8880

CMD ["/bin/bash", "-lc", ". .venv/bin/activate && python vibevoice_realtime_openai_api.py --port 8880"]
