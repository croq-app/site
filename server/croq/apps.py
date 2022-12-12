from django.apps import AppConfig


class CroqConfig(AppConfig):
    default_auto_field = "django.db.models.BigAutoField"
    name = "croq"

    def ready(self) -> None:
        from . import api