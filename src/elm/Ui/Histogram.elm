module Ui.Histogram exposing (..)

{-| An Histogram of climbing grades (or anything else). Follows TEA.
-}

import Chart as C
import Chart.Attributes as CA
import Chart.Events as CE
import Chart.Item as CI
import Html exposing (..)
import Html.Attributes exposing (..)
import List.Extra
import Ui.Color exposing (..)


type alias Model =
    { hovering : List (CI.Many Datum CI.Any) }


type Msg
    = OnHover (List (CI.Many Datum CI.Any))


type alias Datum =
    ( String, Float )


init : Model
init =
    { hovering = [] }


view : Model -> List Datum -> Html Msg
view model data =
    div [ class "w-96 h-48 mt-8 mb-12 mx-auto" ]
        [ C.chart
            [ CA.height 240
            , CA.width 480
            , CE.onMouseMove OnHover (CE.getNearest CI.bins)
            , CE.onMouseLeave (OnHover [])
            ]
            [ C.xLabels
                [ CA.rotate 90
                , CA.ints
                , CA.amount (List.length data)
                , CA.moveRight 5
                , CA.format (\x -> List.Extra.getAt (round (x - 1)) data |> Maybe.map Tuple.first |> Maybe.withDefault "?")
                ]
            , C.bars []
                [ C.bar Tuple.second
                    [ CA.gradient [ "#529B03", CA.green ]
                    , CA.roundBottom 0.5
                    , CA.roundTop 0.5
                    ]
                ]
                data
            , C.barLabels [ CA.moveUp 5 ]
            , C.each model.hovering <|
                \p item ->
                    [ C.tooltip item [] [] [] ]
            ]
        ]


update : Msg -> Model -> Model
update msg m =
    m
