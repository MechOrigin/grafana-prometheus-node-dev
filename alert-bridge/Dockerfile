FROM python:3.11-slim

WORKDIR /app

RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

ENV FLASK_APP=src/main.py
ENV FLASK_ENV=production
ENV FLASK_DEBUG=0
ENV PORT=10000

EXPOSE 10000

USER nobody

CMD ["python", "-m", "uvicorn", "src.main:app", "--host", "0.0.0.0", "--port", "10000"] 