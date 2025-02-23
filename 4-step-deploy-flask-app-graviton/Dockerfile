# Use multi-stage build for a smaller final image
FROM --platform=$BUILDPLATFORM python:3.9-slim as builder

WORKDIR /app

# Copy and install requirements
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Final stage
FROM --platform=$TARGETPLATFORM python:3.9-slim

WORKDIR /app

# Copy installed packages and binaries
COPY --from=builder /usr/local/lib/python3.9/site-packages/ /usr/local/lib/python3.9/site-packages/
COPY --from=builder /usr/local/bin/gunicorn /usr/local/bin/

# Copy application
COPY app.py .

EXPOSE 5000

CMD ["gunicorn", "--bind", "0.0.0.0:5000", "app:app"]
