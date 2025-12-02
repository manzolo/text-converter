# Testing Guide

Simple and practical integration testing for the AI Text Converter application.

## Quick Start

```bash
# Run all tests
./test.sh

# Run against different URL
API_URL=http://localhost:8000 ./test.sh

# Use different test file
TEST_FILE=my_test.txt ./test.sh
```

## Test Script

The `test.sh` script performs comprehensive integration tests using curl:

### What Gets Tested

1. **API Health** - Verify the API is responding
2. **Markdown Conversion** - Test text to markdown (without AI)
3. **HTML Conversion** - Test text to HTML (without AI)
4. **DOCX Conversion** - Test text to Word document (without AI)
5. **PDF Conversion** - Test text to PDF (using ReportLab Canvas)
6. **Preview Endpoint** - Test preview functionality
7. **API Documentation** - Check docs are accessible
8. **AI Enhancement** - Test conversion with AI processing
9. **Error Handling** - Verify proper error responses

### Test Output

Tests generate output files in `test_output/`:
- `output.md` - Markdown output
- `output.html` - HTML output
- `output.docx` - Word document
- `output.pdf` - PDF document (may fail)
- `output_ai.md` - AI-enhanced markdown
- `preview.json` - Preview API response
- `error.txt` - Error response sample

## Running Tests Locally

### Prerequisites

- Docker and docker-compose running
- Application running at http://localhost:8000
- `sample.txt` file in project root

### Steps

```bash
# Start the application
make up

# Run tests
./test.sh

# Check test outputs
ls -lh test_output/
```

## Running Tests in CI

Tests run automatically on every push via GitHub Actions.

See `.github/workflows/test.yml` for configuration.

### GitHub Actions Workflow

```yaml
- Start docker-compose services
- Wait for API to be ready
- Pull Ollama model (optional)
- Run ./test.sh
- Upload test outputs
- Show logs on failure
- Cleanup
```

## Test Configuration

### Environment Variables

- `API_URL` - API endpoint (default: http://localhost:8000)
- `TEST_FILE` - Input file for testing (default: sample.txt)
- `OUTPUT_DIR` - Directory for outputs (default: test_output)

### Example

```bash
# Test against production
API_URL=https://api.example.com TEST_FILE=large.txt ./test.sh
```

## Adding New Tests

Edit `test.sh` and add your test:

```bash
# Test X: Your new test
echo -e "\n${YELLOW}Testing new feature...${NC}"
if curl -s -X POST "$API_URL/your-endpoint" \
    -F "param=value" \
    -o "$OUTPUT_DIR/output.txt" 2>/dev/null; then

    if [ -f "$OUTPUT_DIR/output.txt" ] && [ -s "$OUTPUT_DIR/output.txt" ]; then
        print_result "Your new test" "PASS"
    else
        print_result "Your new test" "FAIL"
    fi
else
    print_result "Your new test" "FAIL"
fi
```

## PDF Generation

PDF conversion now works reliably using ReportLab's Canvas API with:
- Automatic word wrapping
- Support for headings (H1, H2, H3)
- Automatic page breaks
- Letter-sized pages (8.5" x 11")

The implementation uses a simplified approach that avoids the layout issues previously encountered with ReportLab's platypus framework.

### AI Processing

AI tests require:
- Ollama running and accessible
- Model downloaded (llama3.1:8b or configured model)
- Network connectivity to Ollama

Tests will still pass if AI is unavailable (checks for 500 errors).

## Debugging

### View API Logs

```bash
# If using docker-compose
make logs

# Or directly
docker logs text-converter-external
```

### Check Test Outputs

```bash
# View generated files
ls -lh test_output/

# Check HTML output
cat test_output/output.html

# Verify DOCX is valid
file test_output/output.docx

# Check PDF signature
head -c 4 test_output/output.pdf
```

### Verbose Mode

Edit `test.sh` and add `-v` to curl commands:

```bash
curl -v -X POST ...
```

## Performance

Typical test execution time:
- Without AI: ~5-10 seconds
- With AI: ~20-60 seconds (depends on model and file size)

## Best Practices

1. **Always use sample.txt** or similar for consistent results
2. **Clean test_output/** between runs if needed
3. **Check test_output/ files** if tests fail
4. **Run locally before pushing** to catch issues early
5. **Keep test file small** for fast execution

## Continuous Integration

GitHub Actions automatically runs tests on:
- Every push to main/develop
- Every pull request
- Manual workflow dispatch

View results in the "Actions" tab on GitHub.

## Questions?

Check:
- Test script comments in `test.sh`
- GitHub Actions logs
- Application logs with `make logs`
- API docs at http://localhost:8000/docs
