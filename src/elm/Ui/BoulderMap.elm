module Ui.BoulderMap exposing (..)

{-| A topdown vision of a Map with some highlighted boulders. Follows TEA.
-}

import Html exposing (..)
import Html.Attributes as Attr exposing (..)
import Html.Events as Ev exposing (..)
import Ui.Color exposing (..)


type alias Model =
    ()


type alias Msg =
    ()


view : Model -> Html msg
view m =
    div [] [ text "TODO: Topdown view of boulders in a sector" ]


update : Msg -> Model -> Model
update msg m =
    m


init : Model
init =
    ()
