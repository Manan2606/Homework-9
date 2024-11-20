# Use an official lightweight Python image.
# 3.12-slim variant is chosen for a balance between size and utility.
FROM python:3.12-slim-bullseye as base

# Set environment variables
ENV PYTHONUNBUFFERED=1 \
    PYTHONFAULTHANDLER=1 \
    PIP_NO_CACHE_DIR=off \
    PIP_DEFAULT_TIMEOUT=100 \
    PIP_DISABLE_PIP_VERSION_CHECK=on

# Set the working directory
WORKDIR /myapp

# Install system dependencies
RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y --no-install-recommends \
    gcc \
    libpq-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies and fix known issues
COPY ./requirements.txt /myapp/requirements.txt
RUN pip install --upgrade pip setuptools wheel \
    && pip install --upgrade -r requirements.txt

# Copy application code
COPY . /myapp

# Add a non-root user for security
RUN useradd -m myuser
USER myuser

# Add the startup script
COPY start.sh /start.sh
RUN chmod +x /start.sh

# Expose application port
EXPOSE 8000

# Run the application
CMD ["/start.sh"]
