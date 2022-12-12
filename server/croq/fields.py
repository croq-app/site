from django.db import models
from autoslug import AutoSlugField


def NameField():
    return models.CharField("nome", max_length=50)


def HowToAccessField():
    return models.TextField(
        "acesso",
        blank=True,
        help_text="Descrição de como chegar no local (formato markdown)",
    )


def DescriptionField():
    return models.TextField(
        "descrição", blank=True, help_text="Descrição detalhada em formato markdown"
    )


def LatLonField():
    return models.CharField("coordenadas", blank=True, max_length=64)


def TagField(name, **kwargs):
    return models.BooleanField(name, default=False, **kwargs)


def name(obj):
    return obj.name
