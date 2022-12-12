module Api exposing (..)

import Config as Cfg
import Http
import String.Extra
import Types exposing (..)


type alias ApiResult a =
    Result (Maybe String) a


path : String -> String
path =
    String.replace "." "/"


url : Cfg.Model -> String -> Url
url cfg rest =
    String.Extra.unsurround "/" cfg.api ++ "/" ++ String.Extra.unsurround "/" rest


region : Cfg.Model -> RegionId -> Url
region cfg id =
    url cfg <| path id ++ "/detail.json"


boulderSector : Cfg.Model -> SectorId -> Url
boulderSector cfg id =
    let
        ( loc, slug ) =
            splitSectorId id
    in
    url cfg <| path loc ++ "/b/sectors/" ++ slug ++ "/detail.json"


resultFromError : Http.Error -> ApiResult a
resultFromError e =
    Err (Just <| showHttpError e)


resultFromData : a -> ApiResult a
resultFromData data =
    Ok data


resultFromMsg : String -> ApiResult a
resultFromMsg msg =
    Err (Just msg)


showHttpError : Http.Error -> String
showHttpError error =
    case error of
        Http.BadUrl str ->
            "bad url: " ++ str

        Http.Timeout ->
            "operation timedout"

        Http.NetworkError ->
            "network error"

        Http.BadStatus code ->
            "bad status code: " ++ String.fromInt code

        Http.BadBody body ->
            "invalid response: " ++ body
