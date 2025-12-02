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

The workflow uses the default Docker driver (not Buildx) to ensure images are immediately available in the local Docker daemon after building.

### Important Note About Docker Buildx

If you're using Docker Buildx with the `docker-container` driver, images won't be automatically loaded. Use one of these solutions:

```bash
# Option 1: Load the image after build
docker buildx build --load -t text-converter:cpu .

# Option 2: Use docker-compose with default driver
DOCKER_BUILDKIT=0 docker-compose build

# Option 3: Configure buildx to use docker driver
docker buildx use default
```

The GitHub Actions workflow avoids this issue by not using the `docker/setup-buildx-action`.
