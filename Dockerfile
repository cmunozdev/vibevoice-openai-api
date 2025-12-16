version: '3.8'

services:
  vibevoice-cpu:
    build:
      context: .
      dockerfile: Dockerfile.cpu  # Usa el Dockerfile para CPU
    container_name: vibevoice-tts-cpu
    ports:
      - "8880:8880"
    volumes:
      - ./models:/home/ubuntu/app/models
      - ./vibevoice_realtime_openai_api.py:/home/ubuntu/app/vibevoice_realtime_openai_api.py
    environment:
      - VIBEVOICE_DEVICE=cpu
      - CFG_SCALE=1.25
      - OPTIMIZE_FOR_SPEED=0
      - MODELS_DIR=/home/ubuntu/app/models
    restart: unless-stopped
    # Limitar recursos para evitar sobrecargar el servidor
    deploy:
      resources:
        limits:
          cpus: '4.0'      # Máximo 4 CPUs
          memory: 8G       # Máximo 8GB RAM
        reservations:
          memory: 4G       # Reservar 4GB RAM
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8880/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 120s  # Dar 2 minutos para que cargue el modelo
