module Ui.Carousel exposing (..)

{-| An Image Carousel. Follows TEA.
-}

import Html exposing (..)
import Html.Attributes as Attr exposing (..)
import Html.Events as Ev exposing (..)
import Ui.Color exposing (..)


type alias Model =
    List ( String, Int )


type alias Msg =
    ()


view : Model -> Html msg
view _ =
    div [] [ text "TODO: Carousel" ]


update : Msg -> Model -> Model
update _ m =
    m


init : Model
init =
    [ ( "A", 10 ), ( "B", 15 ), ( "C", 11 ), ( "D", 20 ) ]
