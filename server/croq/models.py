from django.db import models
from django.core.validators import RegexValidator
from model_utils.managers import QueryManager
from model_utils.models import TimeStampedModel

from . import fields


class Country(TimeStampedModel):
    """
    Um país que contêm várias regiões/picos de escalada.
    """

    slug = models.SlugField(
        verbose_name="Código",
        primary_key=True,
        max_length=2,
        help_text="Códigdo de identificação",
        validators=[RegexValidator(r"[a-z]{2}", "Deve ser um código de identificação de duas letras.")],
    )
    name = fields.NameField()

    class Meta:
        verbose_name = "País"
        verbose_name_plural = "Países"

    def __str__(self):
        return self.name


class Region(TimeStampedModel):
    """
    Um pico de escalada (ex: Serra do Cipó).
    """

    country = models.ForeignKey(
        "Country",
        verbose_name="País",
        related_name="regions",
        on_delete=models.CASCADE,
    )
    slug = fields.AutoSlugField(
        populate_from=fields.name,
        unique_with="country",
        help_text="Códido de identificação. Único dentro de um mesmo país",
    )
    name = fields.NameField()
    latlon = fields.LatLonField()
    description = fields.DescriptionField()
    how_to_access = fields.HowToAccessField()
    
    class Meta:
        verbose_name = "Pico"
        unique_together = [("slug", "country")]

    def __str__(self):
        return self.name


class Attraction(TimeStampedModel):
    """
    Uma atração próxima a um pico de escalada (ex: Cachoeiras, trilhas, etc).
    """

    region = models.ForeignKey(
        "Region",
        verbose_name="Região",
        related_name="attractions",
        on_delete=models.CASCADE,
    )
    slug = fields.AutoSlugField(
        populate_from=fields.name,
        unique_with=["region"],
        help_text="Códigdo de identificação. Único dentro de um pico",
    )
    name = fields.NameField()
    description = fields.DescriptionField()
    how_to_access = fields.HowToAccessField()
    latlon = fields.LatLonField()

    class Meta:
        verbose_name = "Atração"
        verbose_name_plural = "Atrações"
        unique_together = [("slug", "region")]

    def __str__(self):
        return self.name


class Sector(TimeStampedModel):
    """
    Um setor dentro de um pico de escalada (ex: Morro da Urca no Rio de Janeiro).
    """

    region = models.ForeignKey(
        "Region",
        verbose_name="Região",
        related_name="sectors",
        on_delete=models.CASCADE,
    )
    slug = fields.AutoSlugField(
        populate_from=fields.name,
        unique_with=["region"],
        help_text="Códigdo de identificação. Único dentro de um pico",
    )
    name = fields.NameField()
    description = fields.DescriptionField()
    how_to_access = fields.HowToAccessField()
    is_bouldering_sector = models.BooleanField(
        "setor de boulder",
        default=False,
        help_text="Marque verdadeiro para setores de boulder.",
    )
    latlon = fields.LatLonField()

    class Meta:
        verbose_name = "Setor"
        verbose_name_plural = "Setores"
        unique_together = [("slug", "region")]

    def __str__(self):
        return self.name




class RouteSector(Sector):
    """
    Um setor de Boulder dentro de um pico de escalada (ex: Morro da Urca no Rio de Janeiro).
    """

    objects = QueryManager(is_bouldering_sector=False)

    class Meta:
        proxy = True
        verbose_name = "Setor de vias"
        verbose_name_plural = "Setores de vias"

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.is_bouldering_sector = False


class ParkingLot(TimeStampedModel):
    """
    Local mais próximo do pico para parar o carro ou chegar de transporte público.
    """

    region = models.ForeignKey(
        "Region",
        related_name="parking_lots",
        on_delete=models.CASCADE,
    )
    slug = fields.AutoSlugField(
        populate_from=fields.name,
        unique_with=["region"],
        help_text="Códigdo de identificação. Único dentro de um setor",
    )
    name = fields.NameField()
    description = fields.DescriptionField()
    is_served_by_mass_transit = models.BooleanField(
        "transporte?",
        default=False,
        help_text="Verdadeiro, se for possível chegar usando transporte público",
    )

    latlon = fields.LatLonField()

    class Meta:
        verbose_name = "Estacionamento"
        verbose_name_plural = "Estacionamentos"
        unique_together = [("slug", "region")]

    def __str__(self):
        return self.name


class Route(TimeStampedModel):
    """
    Uma via de escalada (ex: Silence).
    """
    SPORT = "sport"
    TRAD = "trad"
    MIXED = "mixed"
    AID = "aid"
    STYLE_CHOICES = [
        (SPORT, "esportiva"),
        (TRAD, "móvel"),
        (MIXED, "mista"),
        (AID, "artificial"),
    ]

    sector = models.ForeignKey(
        "Sector",
        related_name="routes",
        on_delete=models.CASCADE,
    )
    slug = fields.AutoSlugField(
        populate_from=fields.name,
        unique_with=["sector"],
        help_text="Códigdo de identificação. Único dentro de um setor",
    )
    name = fields.NameField()
    description = fields.DescriptionField()
    grade = models.CharField(
        "grau",
        max_length=16,
        blank=True,
        help_text="Pode usar o sistema francês, americano ou brasileiro (adicionando um sufixo BR, como em '7a soft BR')",
    )
    latlon = fields.LatLonField()
    style = models.CharField("Estilo", max_length=8, choices=STYLE_CHOICES)
    n_bolts = models.PositiveSmallIntegerField("Proteções", blank=True, null=True, help_text="Incluindo as proteções do topo.")
    length = models.PositiveSmallIntegerField("Extensão", blank=True, null=True, help_text="Tamanho da via em metros", )
    video_csv = models.TextField(
        "videos",
        blank=True,
        help_text="Links para vídeos, separado por vírgulas ou quebras de linha",
    )
    # Tags
    must_do = fields.TagField("clássico")
    makes_summit = fields.TagField("faz pico")
    is_dangerous = fields.TagField("perigosa")
    is_single_anchor = fields.TagField("topo simples")
    is_multipitch = fields.TagField("parede")

    class Meta:
        verbose_name = "Via"
        verbose_name_plural = "Vias"
        unique_together = [("slug", "sector")]

    def __str__(self):
        return f"{self.name} ({self.grade})"


class Pitch(TimeStampedModel):
    """
    Enfidada de uma via multi-pitch
    """
    route = models.ForeignKey(
        "Route",
        related_name="pitches",
        on_delete=models.CASCADE,
    )
    grade = models.CharField(
        "grau",
        max_length=16,
        blank=True,
        help_text="Pode usar o sistema francês, americano ou brasileiro (adicionando um sufixo BR, como em '7a soft BR')",
    )
    n_bolts = models.PositiveSmallIntegerField("Proteções", blank=True, null=True, help_text="Incluindo as proteções do topo.")
    is_single_anchor = fields.TagField("parada simples")
    style = models.CharField("Estilo", max_length=8, choices=Route.STYLE_CHOICES, blank=True)
    description = fields.DescriptionField()
    
