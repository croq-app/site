module Pages.Simple exposing (Model, Msg, entry, update, view)

{-| Example bare bones page
-}

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


update : Msg -> Cfg.Model -> Model -> ( Model, Cmd Msg )
update msg cfg m =
    ( m, Cmd.none )


view cfg m =
    Ui.App.appShell <|
        div [] [ text "Simple Example page" ]
