module Decoder exposing (..)

import Data exposing (..)
import Json.Decode exposing (..)
import Json.Decode.Pipeline exposing (hardcoded, optional, required)
import Types as T exposing (..)


regionId : Decoder RegionId
regionId =
    string
        |> andThen
            (\st ->
                case String.split "/" st of
                    [ a, b ] ->
                        succeed (T.regionId a b)

                    _ ->
                        fail <| "required id in the format <country>/<slug>, got " ++ st
            )


sectorId : Decoder SectorId
sectorId =
    string
        |> andThen
            (\st ->
                case String.split "/" st of
                    [ a, b, c ] ->
                        succeed (T.sectorId (T.regionId a b) c)

                    _ ->
                        fail <| "required id in the format <country>/<region>/<slug>, got " ++ st
            )


elemId : Decoder ElemId
elemId =
    string
        |> andThen
            (\st ->
                case String.split "/" st of
                    [ a, b, c, d ] ->
                        succeed (T.elemId (T.sectorId (T.regionId a b) c) d)

                    _ ->
                        fail <| "required id in the format <country>/<region>/<sector>/<slug>, got " ++ st
            )


problemId : Decoder ProblemId
problemId =
    string
        |> andThen
            (\st ->
                case String.split "/" st of
                    [ a, b, c, d, e ] ->
                        succeed (T.problemId (T.elemId (T.sectorId (T.regionId a b) c) d) e)

                    _ ->
                        fail <| "required id in the format <country>/<region>/<sector>/<boulder>/<slug>, got " ++ st
            )


geoLoc =
    string


region : Decoder Region
region =
    succeed Region
        |> required "id" regionId
        |> required "country" string
        |> required "name" string
        |> optional "description" string ""
        |> optional "how_to_access" string ""
        |> required "latlon" string
        |> optional "attractions" (list attraction) []
        |> optional "sectors" (list sector) []


attraction : Decoder Attraction
attraction =
    succeed Attraction
        |> required "id" sectorId
        |> required "name" string
        |> optional "description" string ""
        |> optional "how_to_access" string ""
        |> required "latlon" geoLoc


sector : Decoder Sector
sector =
    succeed Sector
        |> required "id" sectorId
        |> required "name" string
        |> optional "description" string ""
        |> required "region_name" string
        |> optional "how_to_access" string ""
        |> required "latlon" geoLoc
        |> required "is_bouldering_sector" bool
        |> optional "routes" (list route) []
        |> optional "boulder_formations" (list boulderFormation) []


route : Decoder Route
route =
    succeed Route
        |> required "id" elemId
        |> required "name" string
        |> required "grade" string


boulderFormation : Decoder BoulderFormation
boulderFormation =
    succeed BoulderFormation
        |> required "id" elemId
        |> required "name" string
        |> required "short_name" string
        |> optional "problems" (list boulderProblem) []


boulderProblem : Decoder BoulderProblem
boulderProblem =
    succeed BoulderProblem
        |> required "id" problemId
        |> required "name" string
        |> required "grade" string
        |> required "description" string
