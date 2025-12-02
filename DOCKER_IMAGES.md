# Docker Images Reference

## Image Names

This project uses specific image tags for different deployment modes:

### CPU Version (Local Ollama)
- **Image**: `text-converter:cpu`
- **Compose File**: `docker-compose.yml`
- **Command**: `make up` or `docker-compose -f docker-compose.yml up`

### GPU Version (Local Ollama with NVIDIA GPU)
- **Image**: `text-converter:gpu`
- **Compose File**: `docker-compose.gpu.yml`
- **Command**: `make up-gpu` or `docker-compose -f docker-compose.gpu.yml up`

### External Ollama Version
- **Image**: `text-converter:external`
- **Compose File**: `docker-compose.external.yml`
- **Command**: `make up-external` or `docker-compose -f docker-compose.external.yml up`

## Building Images

```bash
# Build CPU version
make build
# or
docker-compose -f docker-compose.yml build

# Build GPU version
make build-gpu
# or
docker-compose -f docker-compose.gpu.yml build

# Build external version
docker-compose -f docker-compose.external.yml build
```

## Listing Images

```bash
# List all text-converter images
docker images text-converter

# Expected output:
# text-converter:cpu        <image-id>   633MB   ...
# text-converter:gpu        <image-id>   XXX MB  ...
# text-converter:external   <image-id>   633MB   ...
```

## GitHub Actions

The CI/CD workflow builds and tests the `text-converter:cpu` image automatically on push to main/develop branches.

The workflow expects the image to be available after running `docker-compose -f docker-compose.yml build`.
