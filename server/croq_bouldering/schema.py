from ninja.orm import create_schema
from ninja import Field
from croq.schema import SectorSchema
from . import models


class BoulderProblemSchema(create_schema(models.BoulderProblem, fields=["id", "name", "grade", "description"])):
    id: str

    @staticmethod
    def resolve_id(obj: models.BoulderProblem):
        return f"{BoulderFormationSchema.resolve_id(obj.formation)}/{obj.slug}"


class BoulderFormationSchema(create_schema(models.BoulderFormation, fields=["id", "name"])):
    id: str
    short_name: str = Field(alias ="name")
    problems: list[BoulderProblemSchema]

    @staticmethod
    def resolve_id(obj: models.BoulderFormation):
        return f"{SectorSchema.resolve_id(obj.sector)}/{obj.slug}"

    @staticmethod
    def resolve_short_name(obj: models.BoulderFormation):
        return obj.name


