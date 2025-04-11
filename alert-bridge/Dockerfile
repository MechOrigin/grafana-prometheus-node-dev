FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Install curl for health checks and dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl && \
    rm -rf /var/lib/apt/lists/*

# Install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy source code
COPY src/ .

# Create non-root user
RUN useradd -m appuser && chown -R appuser /app

# Switch to non-root user
USER appuser

# Health check
HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:9094/health || exit 1

# Expose port
EXPOSE 9094

# Run the application
CMD ["gunicorn", "--bind", "0.0.0.0:9094", "--workers", "4", "--access-logfile", "-", "main:app"] 