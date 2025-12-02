from fastapi import FastAPI, File, UploadFile, Form, HTTPException
from fastapi.responses import StreamingResponse, JSONResponse
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
import aiofiles
import os
from typing import Literal
from .config import settings
from .ai_processor import AIProcessor
from .converters import TextConverter

app = FastAPI(title="AI Text Converter", version="1.0.0")

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Mount frontend
frontend_path = os.path.join(os.path.dirname(os.path.dirname(__file__)), "frontend")
if os.path.exists(frontend_path):
    app.mount("/static", StaticFiles(directory=frontend_path, html=True), name="static")

ai_processor = AIProcessor()
converter = TextConverter()


@app.get("/")
async def root():
    return {"message": "AI Text Converter API", "version": "1.0.0"}


@app.get("/health")
async def health():
    ollama_status = await ai_processor.health_check()
    return {
        "status": "healthy",
        "use_gpu": settings.use_gpu,
        "ollama": ollama_status
    }


@app.post("/convert")
async def convert_text(
    file: UploadFile = File(...),
    output_format: Literal["docx", "pdf", "html", "markdown"] = Form(...),
    use_ai: bool = Form(True),
    prompt_context: str = Form("")
):
    """
    Convert uploaded text file to specified format.

    Args:
        file: Text file to convert
        output_format: Target format (docx, pdf, html, markdown)
        use_ai: Whether to use AI for processing/enhancement
        prompt_context: Additional context for AI processing
    """

    # Check file size
    content = await file.read()
    if len(content) > settings.max_file_size:
        raise HTTPException(
            status_code=413,
            detail=f"File too large. Maximum size is {settings.max_file_size} bytes"
        )

    try:
        text = content.decode('utf-8')
    except UnicodeDecodeError:
        raise HTTPException(status_code=400, detail="File must be valid UTF-8 text")

    # Process with AI if requested
    if use_ai:
        processed_chunks = []
        async for chunk in ai_processor.process_large_text(
            text,
            output_format,
            prompt_context=prompt_context
        ):
            processed_chunks.append(chunk)

        processed_text = "\n\n".join(processed_chunks)
    else:
        processed_text = text

    # Convert to target format
    if output_format == "markdown":
        output_content = converter.to_markdown(processed_text)
        media_type = "text/markdown"
        filename = "converted.md"
        return StreamingResponse(
            iter([output_content.encode('utf-8')]),
            media_type=media_type,
            headers={"Content-Disposition": f"attachment; filename={filename}"}
        )

    elif output_format == "html":
        output_content = converter.to_html(processed_text)
        media_type = "text/html"
        filename = "converted.html"
        return StreamingResponse(
            iter([output_content.encode('utf-8')]),
            media_type=media_type,
            headers={"Content-Disposition": f"attachment; filename={filename}"}
        )

    elif output_format == "docx":
        output_buffer = converter.to_docx(processed_text)
        media_type = "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
        filename = "converted.docx"
        return StreamingResponse(
            output_buffer,
            media_type=media_type,
            headers={"Content-Disposition": f"attachment; filename={filename}"}
        )

    elif output_format == "pdf":
        # Use ReportLab for PDF generation (reliable and well-tested)
        try:
            output_buffer = converter.to_pdf_reportlab(processed_text)
        except Exception as e:
            raise HTTPException(
                status_code=500,
                detail=f"PDF generation failed: {str(e)}"
            )

        media_type = "application/pdf"
        filename = "converted.pdf"
        return StreamingResponse(
            output_buffer,
            media_type=media_type,
            headers={"Content-Disposition": f"attachment; filename={filename}"}
        )

    else:
        raise HTTPException(status_code=400, detail="Invalid output format")


@app.post("/preview")
async def preview_conversion(
    file: UploadFile = File(...),
    output_format: Literal["docx", "pdf", "html", "markdown"] = Form(...),
    use_ai: bool = Form(True),
    prompt_context: str = Form(""),
    max_preview_length: int = Form(1000)
):
    """
    Preview the conversion without downloading the full file.
    Returns first chunk processed.
    """

    content = await file.read()
    if len(content) > settings.max_file_size:
        raise HTTPException(
            status_code=413,
            detail=f"File too large. Maximum size is {settings.max_file_size} bytes"
        )

    try:
        text = content.decode('utf-8')
    except UnicodeDecodeError:
        raise HTTPException(status_code=400, detail="File must be valid UTF-8 text")

    # Take only first part for preview
    preview_text = text[:max_preview_length]

    if use_ai:
        processed = await ai_processor.process_text_chunk(
            preview_text,
            output_format,
            prompt_context
        )
    else:
        processed = preview_text

    return JSONResponse({
        "preview": processed,
        "original_length": len(text),
        "preview_length": len(preview_text),
        "is_truncated": len(text) > max_preview_length
    })


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host=settings.api_host, port=settings.api_port)
