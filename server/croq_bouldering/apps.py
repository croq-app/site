from django.apps import AppConfig


class CroqBoulderingConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'croq_bouldering'
    verbose_name = "Croq: boulder"

    def ready(self) -> None:
        from . import api