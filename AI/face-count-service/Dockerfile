FROM python:3.11-slim

WORKDIR /app

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    python3-dev \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app ./app
COPY wsgi.py .

WORKDIR /app/app/model/FaceBoxesV2/utils
RUN sh make.sh

WORKDIR /app

EXPOSE 8005

CMD ["waitress-serve", "--host=0.0.0.0", "--port=8005", "wsgi:app"]