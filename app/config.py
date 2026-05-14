from functools import lru_cache
from pydantic import computed_field
from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    database_url: str = "postgresql://postgres:postgres@db:5432/appdb"
    app_name: str = "For Hyun"

    @computed_field
    @property
    def sync_database_url(self) -> str:
        return self.database_url

    class Config:
        env_file = ".env"
        env_file_encoding = "utf-8"


@lru_cache
def get_settings() -> Settings:
    return Settings()
