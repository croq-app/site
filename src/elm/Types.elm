module Types exposing (..)

import Html exposing (Attribute, Html)


type alias HtmlElem msg =
    List (Attribute msg) -> List (Html msg) -> Html msg


type alias Slug =
    String


type alias Url =
    String


type alias Name =
    String

type alias Id =
    String

type alias RegionId =
    String


type alias SectorId =
    ( RegionId, RegionId )


type alias ElemId =
    ( SectorId, RegionId )


type alias ProblemId =
    ( ElemId, RegionId )


type alias RefPath =
    List String




type alias Grade =
    String


type alias GeoLoc =
    String


type alias LoadingError =
    String


regionId : RegionId -> RegionId -> RegionId
regionId a b =
    a ++ "." ++ b


splitRegionId : RegionId -> ( RegionId, RegionId )
splitRegionId id =
    case String.split "." id of
        [ a, b ] ->
            ( a, b )

        _ ->
            ( "root", id )


regionSlug : RegionId -> RegionId
regionSlug =
    splitRegionId >> Tuple.second


sectorId : RegionId -> RegionId -> SectorId
sectorId a b =
    ( a, b )


splitSectorId : SectorId -> ( RegionId, RegionId )
splitSectorId =
    identity


sectorSlug : SectorId -> RegionId
sectorSlug =
    splitSectorId >> Tuple.second


elemId : SectorId -> RegionId -> ElemId
elemId a b =
    ( a, b )


splitElemId : ElemId -> ( SectorId, RegionId )
splitElemId =
    identity


elemSlug : ElemId -> RegionId
elemSlug =
    splitElemId >> Tuple.second


problemId : ElemId -> RegionId -> ProblemId
problemId a b =
    ( a, b )


splitProblemId : ProblemId -> ( ElemId, RegionId )
splitProblemId =
    identity


problemSlug : ProblemId -> RegionId
problemSlug =
    splitProblemId >> Tuple.second
