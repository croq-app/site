module Pages.GpsTool exposing (Model, Msg, entry, update, view)

import Config as Cfg
import Html exposing (..)
import Html.Attributes exposing (..)
import Route
import Ui.App
import Ui.Color
import Ui.Components as Ui


type Model
    = NotImpl


type Msg
    = NoOp


entry : ( Model, Cmd a )
entry =
    ( NotImpl, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg m =
    ( m, Cmd.none )


view m =
    Ui.App.appShell <|
        div [] [ text "TODO: Gps tool" ]
