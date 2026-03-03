FROM python:3.11-slim

WORKDIR /app

# Install system dependencies (e.g., for psycopg2)
RUN apt-get update && apt-get install -y \
    libpq-dev \
    gcc \
    && rm -rf /var/lib/apt/lists/*

COPY backend/requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

COPY backend/ .

# Expose port (default for uvicorn)
EXPOSE 8000

# Start the FastAPI application via Uvicorn (configured for cloud deployments like Railway)
CMD uvicorn app.main:app --host 0.0.0.0 --port ${PORT:-8000}
