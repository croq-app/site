from django.http import Http404
from django.shortcuts import get_object_or_404
from croq_site.api import api
from croq.schema import SectorSchema
from .schema import BoulderFormationSchema, BoulderProblemSchema
from . import models


@api.get("/{country}/{region}/b/sectors/{slug}/detail.json", response=SectorSchema)
def boulder_sector_detail(request, country: str, region: str, slug: str) -> SectorSchema:
    """
    Detalhes sobre um setor de Boulder, assim como uma lista de blocos e os problemas disponíveis.
    """
    sector = get_object_or_404(
        models.Sector, region__country__slug=country, region__slug=region, slug=slug
    )
    if not sector.is_bouldering_sector:
        raise Http404
    
    return (
        SectorSchema.from_orm(sector)
            .populate_formations_from(sector)
    )