# Use a base image with Python
FROM python:3.9-slim

# Install necessary tools: Git, Maven, and others
RUN apt-get update && apt-get install -y \
    git \
    maven \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Set the working directory
WORKDIR /usr/src/git_repo

# Expose port for Flask API
EXPOSE 5000

# Default command (can be overridden when running the container)
CMD ["bash"]
