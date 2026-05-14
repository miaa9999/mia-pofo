FROM node:20-alpine AS tailwind
WORKDIR /usr/src/app

COPY package.json .
RUN npm install

COPY tailwind.config.js postcss.config.js ./
COPY app/templates app/templates
COPY app/static/src app/static/src
RUN npx tailwindcss -i ./app/static/src/styles.css -o /tmp/styles.css --minify

FROM python:3.12-slim
WORKDIR /usr/src/app

RUN apt-get update && apt-get install -y --no-install-recommends gcc libpq-dev && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app app
COPY --from=tailwind /tmp/styles.css app/static/css/styles.css

ENV PYTHONUNBUFFERED=1
EXPOSE 8000
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
