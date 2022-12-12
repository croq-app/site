from django.db import models
from django.core import validators
from model_utils.managers import QueryManager
from model_utils.models import TimeStampedModel

import croq.fields as fields
from croq.models import Sector

from . import validators


class BoulderingSector(Sector):
    """
    Um setor de Boulder dentro de um pico de escalada (ex: Casa da cobra em Cocal).
    """

    objects = QueryManager(is_bouldering_sector=True)

    class Meta:
        proxy = True
        verbose_name = "Setor de boulder"
        verbose_name_plural = "Setores de boulder"

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.is_bouldering_sector = True
        

class BoulderFormation(TimeStampedModel):
    """
    Um bloco que contêm problemas de boulder.
    """

    sector = models.ForeignKey(
        Sector,
        related_name="boulder_formations",
        on_delete=models.CASCADE,
    )
    slug = fields.AutoSlugField(
        populate_from=fields.name,
        unique_with=["sector"],
        help_text="Códigdo de identificação. Único dentro de um setor",
    )
    name = fields.NameField()
    description = fields.DescriptionField()
    how_to_access = fields.HowToAccessField()
    latlon = fields.LatLonField()

    class Meta:
        verbose_name = "Bloco de boulder"
        verbose_name_plural = "Blocos de boulder"
        unique_together = [("slug", "sector")]

    def __str__(self):
        return self.name


class BoulderProblem(TimeStampedModel):
    """
    Um problema de boulder específico.
    """

    formation = models.ForeignKey(
        "BoulderFormation",
        related_name="problems",
        on_delete=models.CASCADE,
    )
    slug = fields.AutoSlugField(
        populate_from=fields.name,
        unique_with=["formation"],
        help_text="Códigdo de identificação. Único dentro de um setor",
    )
    name = fields.NameField()
    description = fields.DescriptionField()
    grade = models.CharField(
        "grau",
        blank=True,
        max_length=16,
        help_text="Pode ser especificado na escala-V ou Fountainebleau",
        validators=[validators.boulder_grade_validator],
    )
    latlon = fields.LatLonField()
    video_csv = models.TextField(
        "videos",
        blank=True,
        help_text="Links para vídeos, separado por vírgulas ou quebras de linha",
    )
    is_draft = models.BooleanField("Rascunho", default=False, help_text="Problemas marcados como rascunho não serão mostrados no site.")
    must_do = fields.TagField("clássico")
    is_highball = fields.TagField("highball")
    is_dangerous = fields.TagField("perigoso")

    class Meta:
        verbose_name = "Problema de boulder"
        verbose_name_plural = "Problemas de boulder"
        unique_together = [("slug", "formation")]

    def __str__(self):
        return f"{self.name} ({self.grade})"

