import asyncio
from typing import AsyncGenerator, Literal
import httpx
from .config import settings


class AIProcessor:
    def __init__(self):
        # Determine Ollama host
        if settings.use_external_ollama:
            self.ollama_host = settings.external_ollama_host
        else:
            self.ollama_host = settings.ollama_host

        self.model = settings.ollama_model
        self.base_url = f"{self.ollama_host}/api"

    async def process_text_chunk(
        self,
        text: str,
        output_format: Literal["docx", "pdf", "html", "markdown", "structured_text"],
        prompt_context: str = ""
    ) -> str:
        """Process a text chunk with Ollama to enhance/format it."""

        format_instructions = {
            "docx": "Format this text for a professional Word document with appropriate headings and structure. Use markdown syntax for headings (# for h1, ## for h2, etc.).",
            "pdf": "Format this text for a clean, readable PDF with proper paragraphs and sections. Use markdown syntax for structure.",
            "html": "Convert this text to semantic HTML structure. Use markdown syntax that can be converted to HTML.",
            "markdown": "Convert this text to well-formatted Markdown with proper headings, lists, and emphasis.",
            "structured_text": "Organize this text with clear structure, headings, and logical sections using markdown format."
        }

        instruction = format_instructions.get(output_format, format_instructions["structured_text"])
        system_prompt = f"{instruction}\n\n{prompt_context}" if prompt_context else instruction

        # Prepare the prompt
        full_prompt = f"{system_prompt}\n\nText to process:\n\n{text}"

        # Call Ollama API
        async with httpx.AsyncClient(timeout=120.0) as client:
            try:
                response = await client.post(
                    f"{self.base_url}/generate",
                    json={
                        "model": self.model,
                        "prompt": full_prompt,
                        "stream": False,
                        "options": {
                            "temperature": 0.3,
                            "num_predict": 4000
                        }
                    }
                )
                response.raise_for_status()
                result = response.json()
                return result.get("response", text)
            except Exception as e:
                print(f"Ollama API error: {e}")
                # Fallback to original text if AI processing fails
                return text

    async def process_large_text(
        self,
        text: str,
        output_format: str,
        chunk_size: int = None,
        prompt_context: str = ""
    ) -> AsyncGenerator[str, None]:
        """Process large text in chunks."""

        if chunk_size is None:
            chunk_size = settings.chunk_size

        # Split text into chunks (by characters, respecting paragraph boundaries)
        chunks = self._split_into_chunks(text, chunk_size)

        for i, chunk in enumerate(chunks):
            context = f"{prompt_context}\n\nThis is part {i+1} of {len(chunks)}."
            processed = await self.process_text_chunk(chunk, output_format, context)
            yield processed
            # Small delay between chunks
            if i < len(chunks) - 1:
                await asyncio.sleep(0.5)

    def _split_into_chunks(self, text: str, chunk_size: int) -> list[str]:
        """Split text into chunks, trying to respect paragraph boundaries."""

        chunks = []
        paragraphs = text.split('\n\n')
        current_chunk = ""

        for para in paragraphs:
            if len(current_chunk) + len(para) + 2 <= chunk_size:
                current_chunk += para + "\n\n"
            else:
                if current_chunk:
                    chunks.append(current_chunk.strip())

                # If a single paragraph is larger than chunk_size, split it
                if len(para) > chunk_size:
                    words = para.split()
                    temp_chunk = ""
                    for word in words:
                        if len(temp_chunk) + len(word) + 1 <= chunk_size:
                            temp_chunk += word + " "
                        else:
                            chunks.append(temp_chunk.strip())
                            temp_chunk = word + " "
                    current_chunk = temp_chunk
                else:
                    current_chunk = para + "\n\n"

        if current_chunk:
            chunks.append(current_chunk.strip())

        return chunks

    async def health_check(self) -> dict:
        """Check if Ollama is available and return status."""
        async with httpx.AsyncClient(timeout=5.0) as client:
            try:
                response = await client.get(f"{self.ollama_host}/api/tags")
                response.raise_for_status()
                models = response.json().get("models", [])
                return {
                    "status": "healthy",
                    "host": self.ollama_host,
                    "model": self.model,
                    "available_models": [m.get("name") for m in models]
                }
            except Exception as e:
                return {
                    "status": "unhealthy",
                    "host": self.ollama_host,
                    "error": str(e)
                }
