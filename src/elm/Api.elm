module Api exposing (..)

import Types exposing (..)


path =
    String.replace "." "/"


sectorList : RegionId -> Url
sectorList id =
    "/api/" ++ path id ++ "/sector-list.json"


sectorDetail : RegionId -> Id -> Url
sectorDetail loc id =
    "/api/" ++ path loc ++ "/sectors/" ++ id ++ ".json"
