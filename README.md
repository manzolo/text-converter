# AI Text Converter with Ollama

<a href="https://www.buymeacoffee.com/manzolo">
  <img src=".github/blue-button.png" alt="Buy Me A Coffee" width="200">
</a>

A powerful Docker-based text conversion system that uses **Ollama** (local AI) to transform and format text files into multiple output formats including DOCX, PDF, HTML, and Markdown. No external API keys required!

## Features

- **Local AI with Ollama**: Completely local AI processing - no cloud APIs, no API keys needed
- **Multiple Output Formats**: Convert to DOCX, PDF, HTML, or Markdown
- **Large File Support**: Handles large files with automatic chunking
- **GPU Support**: Optional GPU acceleration for faster processing
- **Web Interface**: Beautiful, intuitive web UI for easy file conversion
- **REST API**: Full REST API with interactive documentation
- **Docker-Based**: Easy deployment with CPU or GPU support
- **Makefile Commands**: Simple management with make commands
- **External Ollama Support**: Can connect to existing Ollama instances

## Supported Formats

### Input
- Plain text files (.txt)
- Markdown files (.md)
- Any UTF-8 text file

### Output
- **Markdown** (.md) - Clean, formatted markdown
- **HTML** (.html) - Semantic HTML with styling
- **DOCX** (.docx) - Microsoft Word documents
- **PDF** (.pdf) - Professional PDF documents

## Quick Start

### Prerequisites

- Docker and Docker Compose
- (Optional) NVIDIA GPU with Docker GPU support for GPU version
- No API keys needed!

### Installation

1. **Clone or navigate to the project directory**:
```bash
cd text-converter
```

2. **Initial setup**:
```bash
make setup
```

3. **Start the application with local Ollama**:

For CPU version (default):
```bash
make up
```

For GPU version:
```bash
make up-gpu
```

4. **Pull an Ollama model** (required first time):
```bash
# Default model (llama3.1:8b)
make pull-model

# Or specify a different model
make pull-model OLLAMA_MODEL=mistral

# Other popular models: llama3.1, llama3.1:70b, mistral, phi3, codellama
```

5. **Access the application**:
- Web Interface: http://localhost:8000/static/
- API Documentation: http://localhost:8000/docs
- Health Check: http://localhost:8000/health
- Ollama API: http://localhost:11434

## Usage Modes

### Mode 1: Local Ollama in Docker (Default)

This runs Ollama inside a Docker container alongside the application:

```bash
# CPU version
make up

# GPU version
make up-gpu

# Pull a model
make pull-model OLLAMA_MODEL=llama3.1:8b
```

### Mode 2: External Ollama Instance

If you already have Ollama running on your host or another machine:

```bash
# Edit .env and set:
USE_EXTERNAL_OLLAMA=true
EXTERNAL_OLLAMA_HOST=http://localhost:11434

# Start the application
make up-external
```

## Usage

### Web Interface

1. Open http://localhost:8000/static/ in your browser
2. Upload a text file (drag & drop or click to browse)
3. Select your desired output format
4. Toggle AI enhancement on/off
5. (Optional) Add custom instructions for AI processing
6. Click "Preview" to see a preview or "Convert & Download" to download the result

### API Usage

#### Convert a file:

```bash
curl -X POST "http://localhost:8000/convert" \
  -F "file=@yourfile.txt" \
  -F "output_format=pdf" \
  -F "use_ai=true" \
  -F "prompt_context=Make it more formal" \
  -o output.pdf
```

#### Preview conversion:

```bash
curl -X POST "http://localhost:8000/preview" \
  -F "file=@yourfile.txt" \
  -F "output_format=markdown" \
  -F "use_ai=true"
```

### Python API Example

```python
import requests

url = "http://localhost:8000/convert"

files = {'file': open('document.txt', 'rb')}
data = {
    'output_format': 'docx',
    'use_ai': True,
    'prompt_context': 'Add section headings and make it professional'
}

response = requests.post(url, files=files, data=data)

with open('output.docx', 'wb') as f:
    f.write(response.content)
```

## Makefile Commands

### Basic Commands

```bash
make help           # Show all available commands
make setup          # Initial setup (create .env file)
make up             # Start with local Ollama (CPU)
make up-gpu         # Start with local Ollama (GPU)
make up-external    # Use external Ollama instance
make down           # Stop and remove containers
make logs           # View application logs
make status         # Show application status
```

### Ollama Commands

```bash
make pull-model OLLAMA_MODEL=llama3.1:8b  # Pull a specific model
make pull-model OLLAMA_MODEL=mistral      # Pull Mistral model
make pull-model OLLAMA_MODEL=phi3         # Pull Phi-3 model
make list-models                          # List installed models
make logs-ollama                          # View Ollama logs
make shell-ollama                         # Open Ollama shell
```

### Build Commands

```bash
make build          # Build Docker image (CPU)
make build-gpu      # Build Docker image (GPU)
make rebuild        # Rebuild and restart (CPU)
make rebuild-gpu    # Rebuild and restart (GPU)
```

### Management Commands

```bash
make restart        # Restart application (CPU)
make restart-gpu    # Restart application (GPU)
make stop           # Stop containers
make start          # Start existing containers (CPU)
make start-gpu      # Start existing containers (GPU)
make shell          # Open shell in container
make ps             # Show running containers
make health         # Check application health
```

### Development Commands

```bash
make dev            # Start in development mode (CPU)
make dev-gpu        # Start in development mode (GPU)
make clean          # Remove everything (preserves Ollama models)
make clean-temp     # Clean temporary files only
```

## Configuration

### Environment Variables

Edit the `.env` file to configure:

```bash
# API Configuration
API_HOST=0.0.0.0
API_PORT=8000
MAX_FILE_SIZE=104857600  # 100MB in bytes
CHUNK_SIZE=1048576       # 1MB chunks for large files

# Ollama Configuration
OLLAMA_HOST=http://ollama:11434  # For local docker
OLLAMA_MODEL=llama3.1:8b         # Default model to use

# GPU Support
USE_GPU=false                    # Set to true for GPU version

# External Ollama (optional)
USE_EXTERNAL_OLLAMA=false
EXTERNAL_OLLAMA_HOST=http://localhost:11434
```

## Available Ollama Models

Popular models you can use:

| Model | Size | Best For | Command |
|-------|------|----------|---------|
| llama3.1:8b | ~4.7GB | General purpose | `make pull-model OLLAMA_MODEL=llama3.1:8b` |
| llama3.1:70b | ~40GB | High quality (needs GPU) | `make pull-model OLLAMA_MODEL=llama3.1:70b` |
| mistral | ~4.1GB | Fast, efficient | `make pull-model OLLAMA_MODEL=mistral` |
| phi3 | ~2.3GB | Small, fast | `make pull-model OLLAMA_MODEL=phi3` |
| codellama | ~3.8GB | Code formatting | `make pull-model OLLAMA_MODEL=codellama` |

View all available models at: https://ollama.com/library

## Architecture

### Project Structure

```
text-converter/
├── backend/
│   ├── __init__.py
│   ├── main.py              # FastAPI application
│   ├── config.py            # Configuration management
│   ├── ai_processor.py      # Ollama AI processing
│   └── converters.py        # Format converters
├── frontend/
│   └── index.html           # Web interface
├── docker/                  # Docker configuration files
├── temp/                    # Temporary file storage
├── Dockerfile               # CPU Docker image
├── Dockerfile.gpu           # GPU Docker image
├── docker-compose.yml       # CPU compose with Ollama
├── docker-compose.gpu.yml   # GPU compose with Ollama
├── docker-compose.external.yml  # External Ollama
├── Makefile                 # Management commands
├── requirements.txt         # Python dependencies
├── .env.example             # Environment template
└── README.md
```

### Components

1. **Ollama**:
   - Runs locally in Docker
   - Supports CPU and GPU
   - Models stored in persistent volume
   - No internet required after model download

2. **Backend (FastAPI)**:
   - REST API endpoints
   - Ollama integration
   - Format conversion
   - Large file handling with chunking

3. **Frontend (HTML/JS)**:
   - File upload interface
   - Format selection
   - Preview functionality
   - Progress tracking

4. **AI Processor**:
   - Connects to Ollama API
   - Intelligent text chunking
   - Context-aware processing
   - Fallback to original text if AI fails

5. **Converters**:
   - Markdown to HTML
   - HTML to PDF (WeasyPrint)
   - PDF generation (ReportLab fallback)
   - DOCX generation

## Large File Handling

The system automatically handles large files by:

1. **Chunking**: Breaking text into manageable chunks (default 1MB)
2. **Smart Splitting**: Respecting paragraph boundaries
3. **Context Preservation**: Maintaining context across chunks
4. **Progressive Processing**: Processing chunks sequentially
5. **Memory Efficiency**: Streaming responses to avoid memory overflow

## GPU Support

To use GPU acceleration:

1. **Install NVIDIA Docker runtime**:
```bash
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list

sudo apt-get update && sudo apt-get install -y nvidia-docker2
sudo systemctl restart docker
```

2. **Start with GPU support**:
```bash
make up-gpu
```

3. **Pull a model**:
```bash
make pull-model OLLAMA_MODEL=llama3.1:8b
```

4. **Verify GPU is being used**:
```bash
make shell-ollama
nvidia-smi
```

## Troubleshooting

### Container won't start

```bash
# Check logs
make logs

# Check Ollama logs specifically
make logs-ollama

# Rebuild from scratch
make clean
make build
make up
```

### No models available

```bash
# Pull the default model
make pull-model

# Or pull a specific model
make pull-model OLLAMA_MODEL=mistral

# List installed models
make list-models
```

### Out of memory errors

```bash
# Use a smaller model
make pull-model OLLAMA_MODEL=phi3

# Or reduce chunk size in .env
CHUNK_SIZE=524288  # 512KB instead of 1MB

# Restart application
make restart
```

### Ollama not responding

```bash
# Check Ollama status
docker ps | grep ollama

# Restart Ollama
docker restart ollama-cpu  # or ollama-gpu

# Check Ollama logs
make logs-ollama

# Test Ollama directly
curl http://localhost:11434/api/tags
```

### GPU not detected

```bash
# Test NVIDIA Docker
docker run --rm --gpus all nvidia/cuda:12.2.0-base-ubuntu22.04 nvidia-smi

# Rebuild GPU image
make build-gpu
make up-gpu
```

### External Ollama connection fails

```bash
# Test external Ollama
curl http://localhost:11434/api/tags

# Check .env settings
cat .env | grep OLLAMA

# Make sure USE_EXTERNAL_OLLAMA=true
# Make sure EXTERNAL_OLLAMA_HOST is correct
```

## Development

### Running locally without Docker

```bash
# Install Ollama on your host
curl -fsSL https://ollama.com/install.sh | sh

# Start Ollama
ollama serve

# Pull a model
ollama pull llama3.1:8b

# Create virtual environment
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Set environment variables
export USE_EXTERNAL_OLLAMA=true
export EXTERNAL_OLLAMA_HOST=http://localhost:11434
export OLLAMA_MODEL=llama3.1:8b

# Run application
uvicorn backend.main:app --reload --host 0.0.0.0 --port 8000
```

### Adding new output formats

1. Add converter method in `backend/converters.py`
2. Update the `convert_text` endpoint in `backend/main.py`
3. Add the format to the frontend dropdown in `frontend/index.html`

## API Documentation

Once running, access interactive API documentation at:
- Swagger UI: http://localhost:8000/docs
- ReDoc: http://localhost:8000/redoc

## Why Ollama?

- **100% Local**: All processing happens on your machine
- **No API Keys**: No need for OpenAI, Anthropic, or other cloud services
- **Privacy**: Your documents never leave your server
- **Cost-Free**: No per-token charges
- **Offline Capable**: Works without internet (after model download)
- **Fast**: Especially with GPU support
- **Open Source**: Built on open models

## Performance Tips

1. **Use GPU version** for 5-10x faster processing
2. **Choose appropriate model size**:
   - Small files: phi3 (fastest)
   - Medium files: mistral or llama3.1:8b
   - Large files with GPU: llama3.1:70b
3. **Adjust chunk size** based on your needs and memory
4. **Disable AI** for simple format conversions (much faster)
5. **Use preview** before full conversion for large files

## Security Notes

- No API keys stored or required
- File size limits are enforced (default 100MB)
- Input validation for file types
- Automatic cleanup of temporary files
- Health checks for container monitoring
- All processing is local - no external API calls

## Benchmarks

Typical processing times (on a modern CPU):

| Model | Document Size | Time (CPU) | Time (GPU) |
|-------|--------------|-----------|-----------|
| phi3 | 1KB | ~2s | ~1s |
| phi3 | 100KB | ~30s | ~10s |
| mistral | 1KB | ~3s | ~1s |
| mistral | 100KB | ~45s | ~15s |
| llama3.1:8b | 1KB | ~3s | ~1s |
| llama3.1:8b | 100KB | ~50s | ~15s |

*Times include AI processing. Without AI (use_ai=false), conversion is instant.*

## Testing

The project includes comprehensive tests with CI/CD integration via GitHub Actions.

### Running Tests

**Local testing** (recommended for development):
```bash
# Install test dependencies
pip install -r requirements.txt

# Run all tests
make test-local

# Run with coverage report
make test-cov

# Run specific test file
pytest tests/test_api.py -v

# Run specific test
pytest tests/test_api.py::TestHealthEndpoint::test_health_check_success -v
```

**In-container testing**:
```bash
# Make sure containers are running
make up

# Run tests in container
make test
```

### Test Categories

The test suite includes:

1. **API Tests** (`tests/test_api.py`):
   - Health check endpoint
   - File conversion endpoints
   - Preview functionality
   - Error handling
   - File size validation

2. **Converter Tests** (`tests/test_converters.py`):
   - Markdown conversion
   - HTML generation
   - DOCX creation
   - PDF generation
   - Edge cases and special characters

3. **AI Processor Tests** (`tests/test_ai_processor.py`):
   - Ollama integration
   - Text chunking
   - Large file handling
   - Error recovery
   - Health checks

4. **Configuration Tests** (`tests/test_config.py`):
   - Environment variable loading
   - Default settings
   - External Ollama configuration

### Coverage Reports

Generate coverage reports:

```bash
# Generate HTML coverage report
make test-cov

# Open coverage report
open htmlcov/index.html  # macOS
xdg-open htmlcov/index.html  # Linux
```

### Code Quality

Run linters:

```bash
# Run all linters
make lint

# Auto-format code
make format

# Individual linters
flake8 backend tests --max-line-length=120
black backend tests
isort backend tests
```

### Continuous Integration

GitHub Actions workflows automatically run on push and pull requests:

1. **Tests Workflow** (`.github/workflows/test.yml`):
   - Tests on Python 3.10, 3.11, 3.12
   - Installs Ollama
   - Runs full test suite
   - Generates coverage reports
   - Uploads to Codecov

2. **Docker Build Workflow** (`.github/workflows/docker-build.yml`):
   - Builds CPU and GPU images
   - Tests image integrity
   - (Optional) Pushes to Docker Hub

3. **Lint Workflow** (`.github/workflows/lint.yml`):
   - Runs flake8, black, isort
   - Checks code formatting
   - Type checking with mypy

### Writing New Tests

When adding new features:

1. Add tests to appropriate test file in `tests/`
2. Use fixtures from `tests/conftest.py`
3. Mock external dependencies (Ollama API)
4. Run tests locally before committing

Example test:

```python
import pytest
from unittest.mock import patch

def test_my_feature(client, sample_text_file):
    """Test description."""
    with open(sample_text_file, 'rb') as f:
        response = client.post(
            "/my-endpoint",
            files={"file": ("test.txt", f, "text/plain")},
            data={"param": "value"}
        )

    assert response.status_code == 200
    assert "expected" in response.json()
```

### Test Configuration

Test settings in `pytest.ini`:
- Coverage tracking enabled by default
- HTML and terminal reports
- Async test support
- Custom markers for test categorization

## License

This project is provided as-is for educational and commercial use.

## Support

For issues, questions, or contributions:
1. Check the logs: `make logs` and `make logs-ollama`
2. Verify configuration: `make health`
3. List models: `make list-models`
4. Review API docs: http://localhost:8000/docs

## Roadmap

- [x] Local AI with Ollama
- [x] GPU support
- [x] External Ollama support
- [x] Comprehensive test suite
- [x] GitHub Actions CI/CD
- [ ] Support for more input formats (PDF, DOCX input)
- [ ] Batch processing multiple files
- [ ] Custom styling templates
- [ ] Advanced text analysis and summarization
- [ ] Multi-language support
- [ ] User authentication
- [ ] File storage and history
- [ ] Model auto-download on first use

## Credits

Built with:
- Ollama (local AI)
- FastAPI
- python-docx
- WeasyPrint
- ReportLab
- Docker

## Learn More

- Ollama: https://ollama.com
- Available Models: https://ollama.com/library
- Ollama API Docs: https://github.com/ollama/ollama/blob/main/docs/api.md
