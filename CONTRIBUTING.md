# Contributing to AI Text Converter

Thank you for your interest in contributing! This document provides guidelines for contributing to the project.

## Getting Started

1. **Fork the repository**
2. **Clone your fork**:
   ```bash
   git clone https://github.com/your-username/text-converter.git
   cd text-converter
   ```
3. **Create a branch**:
   ```bash
   git checkout -b feature/your-feature-name
   ```

## Development Setup

### Local Development

```bash
# Create virtual environment
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Install development dependencies
pip install black isort flake8 mypy pytest pytest-cov

# Install Ollama (for testing)
curl -fsSL https://ollama.com/install.sh | sh
ollama serve &
ollama pull llama3.1:8b
```

### Docker Development

```bash
# Start development environment
make dev

# Or with GPU
make dev-gpu
```

## Code Style

We follow PEP 8 with some modifications:
- Maximum line length: 120 characters
- Use black for formatting
- Use isort for import sorting

```bash
# Format code
make format

# Check formatting
make lint
```

## Testing

All contributions must include tests.

### Running Tests

```bash
# Run all tests
make test-local

# Run with coverage
make test-cov

# Run specific test file
pytest tests/test_api.py -v

# Run in watch mode (during development)
make test-watch
```

### Writing Tests

1. Add tests to the appropriate file in `tests/`
2. Use fixtures from `conftest.py`
3. Mock external dependencies
4. Aim for >80% code coverage

Example:

```python
import pytest
from unittest.mock import patch

class TestMyFeature:
    """Tests for my new feature."""

    def test_basic_functionality(self, client):
        """Test basic functionality."""
        response = client.get("/my-endpoint")
        assert response.status_code == 200

    @patch('backend.my_module.external_api')
    def test_with_mock(self, mock_api, client):
        """Test with mocked external API."""
        mock_api.return_value = {"data": "test"}
        # ... test code
```

## Making Changes

### Before Committing

1. **Run tests**:
   ```bash
   make test-local
   ```

2. **Run linters**:
   ```bash
   make lint
   ```

3. **Format code**:
   ```bash
   make format
   ```

4. **Check coverage** (aim for >80%):
   ```bash
   make test-cov
   ```

### Commit Messages

Follow conventional commits:

```
type(scope): brief description

Longer description if needed.

Fixes #123
```

Types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Formatting changes
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

Examples:
```
feat(api): add batch conversion endpoint
fix(converter): handle unicode characters in PDF
docs(readme): update installation instructions
test(api): add tests for preview endpoint
```

## Pull Request Process

1. **Update documentation** if needed
2. **Add tests** for new features
3. **Ensure all tests pass**
4. **Update CHANGELOG.md** (if applicable)
5. **Create pull request** with clear description

### PR Description Template

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
- [ ] Tests added/updated
- [ ] All tests pass
- [ ] Coverage maintained/improved

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Documentation updated
- [ ] No new warnings
```

## Project Structure

```
text-converter/
├── backend/              # Python backend
│   ├── main.py          # FastAPI app
│   ├── ai_processor.py  # Ollama integration
│   ├── converters.py    # Format converters
│   └── config.py        # Configuration
├── frontend/            # Web interface
│   └── index.html
├── tests/               # Test suite
│   ├── conftest.py      # Test fixtures
│   ├── test_api.py
│   ├── test_converters.py
│   └── test_ai_processor.py
├── .github/workflows/   # CI/CD
└── docker/              # Docker configs
```

## Adding New Features

### New Output Format

1. Add converter method in `backend/converters.py`
2. Update API endpoint in `backend/main.py`
3. Add frontend option in `frontend/index.html`
4. Add tests in `tests/test_converters.py`
5. Update documentation

### New AI Model Support

1. Update `backend/ai_processor.py`
2. Add configuration in `backend/config.py`
3. Update `.env.example`
4. Add tests
5. Update documentation

## Reporting Issues

When reporting issues, please include:

1. **Description**: Clear description of the issue
2. **Steps to reproduce**: Detailed steps
3. **Expected behavior**: What should happen
4. **Actual behavior**: What actually happens
5. **Environment**:
   - OS and version
   - Python version
   - Docker version
   - Ollama version
6. **Logs**: Relevant log output

## Code Review Process

1. At least one maintainer must approve
2. All CI checks must pass
3. Code coverage must not decrease
4. Documentation must be updated

## Questions?

Feel free to:
- Open an issue for discussion
- Ask in pull request comments
- Check existing issues/PRs

## License

By contributing, you agree that your contributions will be licensed under the same license as the project.

Thank you for contributing! 🚀
