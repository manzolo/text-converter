from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    api_host: str = "0.0.0.0"
    api_port: int = 8000
    max_file_size: int = 104857600  # 100MB
    chunk_size: int = 1048576  # 1MB

    # Ollama Configuration
    ollama_host: str = "http://ollama:11434"
    ollama_model: str = "llama3.1:8b"

    # GPU Support
    use_gpu: bool = False

    # External Ollama
    use_external_ollama: bool = False
    external_ollama_host: str = "http://localhost:11434"

    class Config:
        env_file = ".env"
        case_sensitive = False


settings = Settings()
