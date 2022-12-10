module Ui.App exposing (appShell, header)

import Html exposing (..)
import Html.Attributes exposing (..)
import Route
import Ui.Components as Ui
import Ui.Svg as Icons


appShell : Html msg -> Html msg
appShell content =
    div
        [ class "bg-base w-100"
        , attribute "data-theme" "lemonade"
        ]
        [ header
        , main_ [] [ content ]
        ]


header : Html msg
header =
    let
        icon svg =
            button [ class "btn btn-square btn-ghost" ] [ svg ]
    in
    div
        [ class "navbar shadow-lg"
        ]
        [ div [ class "flex-none" ] [ icon Icons.menu ]
        , div
            [ class "flex-1" ]
            [ a
                [ class "btn btn-ghost normal-case text-xl"
                , href Route.home
                ]
                [ text "croq.app" ]
            ]
        , div [ class "flex-none" ] [ icon Icons.dots ]
        ]
