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


type alias RegionId =
    String


type alias SectorId =
    ( RegionId, Id )


type alias ElemId =
    ( SectorId, Id )


type alias ProblemId =
    ( ElemId, Id )


type alias RefPath =
    List String


type alias Id =
    String


type alias Grade =
    String


sectorId : RegionId -> Id -> SectorId
sectorId a b =
    ( a, b )


elemId : SectorId -> Id -> ElemId
elemId a b =
    ( a, b )


problemId : ElemId -> Id -> ProblemId
problemId a b =
    ( a, b )
