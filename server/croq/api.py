
from croq_site.api import api
from django.shortcuts import get_object_or_404
from . import models
from .schema import RegionSchema, AttractionSchema, SectorSchema


@api.get("/{country}/{region}/detail.json", response=RegionSchema)
def region_detail(request, country: str, region: str) -> RegionSchema:
    """
    Detalhes da região, assim como uma lista dos setores de escalada e 
    atrações disponíveis.
    """
    region = get_object_or_404(models.Region, country__slug=country, slug=region)
    data = RegionSchema.from_orm(region)
    data.attractions = [AttractionSchema.from_orm(x) for x in region.attractions.all()]
    data.sectors = [SectorSchema.from_orm(x) for x in region.sectors.all()]
    return data

