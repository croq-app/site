from ninja.orm import create_schema
from ninja import Schema, Field
from typing import TypeVar, TYPE_CHECKING
from . import models

T = TypeVar("T") 
S = TypeVar("S", bound="SectorSchema") 

if TYPE_CHECKING:
    from croq_bouldering.models import BoulderFormation


class RouteSchema(create_schema(models.Route, fields=["id", "name", "grade"])):
    id: str

    @staticmethod
    def resolve_id(obj: models.Route):
        return f"{SectorSchema.resolve_id(obj.sector)}/{obj.slug}"

class AttractionSchema(create_schema(models.Attraction, fields=["id", "name", "description", "latlon", "how_to_access"])):
    id: str

    @staticmethod
    def resolve_id(obj: models.Attraction):
        return f"{RegionSchema.resolve_id(obj.region)}/{obj.slug}"


class SectorSchema(create_schema(models.Sector, fields=["id", "name", "description", "latlon", "how_to_access", "is_bouldering_sector"])):
    id: str
    region_name: str
    routes: list[RouteSchema] = Field(default_factory=list)
    boulder_formations: list["BoulderFormationSchema"] = Field(default_factory=list)
    
    @staticmethod
    def resolve_id(obj: models.Sector):
        return f"{RegionSchema.resolve_id(obj.region)}/{obj.slug}"

    @staticmethod
    def resolve_boulder_formations(obj: models.Sector):
        return []

    @staticmethod
    def resolve_region_name(obj: models.Sector):
        return obj.region.name

    def populate_formations_from(self: S, obj: "BoulderFormation") -> S:
        for boulder in obj.boulder_formations.all():
            self.boulder_formations.append(BoulderFormationSchema.from_orm(boulder))
        return self


class RegionSchema(create_schema(models.Region, fields=["id", "country", "name", "latlon", "description", "how_to_access"])):
    id: str
    attractions: list[AttractionSchema]
    sectors: list[SectorSchema]

    @staticmethod
    def resolve_id(obj: models.Region):
        return f"{obj.country.slug}/{obj.slug}"

CountrySchema = create_schema(models.Country)
ParkingLotSchema = create_schema(models.ParkingLot)

from croq_bouldering.schema import BoulderFormationSchema
SectorSchema.update_forward_refs()