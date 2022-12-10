module Config exposing (..)

import Browser.Navigation as Nav exposing (Key)
import Http exposing (Error(..))
import Util exposing (dbg1)


type alias Model =
    { navKey : Key }


type Msg
    = NoOp


init : Key -> Model
init key =
    { navKey = key
    }


update : Msg -> Model -> ( Model, Cmd Msg )
update _ m =
    ( m, Cmd.none )


pushUrl : String -> Model -> Cmd msg
pushUrl url m =
    Nav.pushUrl m.navKey url


pushErrorUrl : Error -> Model -> Cmd msg
pushErrorUrl e m =
    Nav.pushUrl m.navKey ("/error?msg=" ++ dbg1 (errorMsg e))


errorMsg : Error -> String
errorMsg e =
    case e of
        BadUrl url ->
            "bad url: " ++ url

        Timeout ->
            "operation timed out"

        NetworkError ->
            "network error"

        BadStatus i ->
            "bad status: " ++ String.fromInt i

        BadBody st ->
            "bad body: " ++ st
