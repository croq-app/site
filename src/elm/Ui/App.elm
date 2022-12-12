module Ui.App exposing (appShell, header, viewLoading, viewLoadingResult)

import Html exposing (..)
import Html.Attributes exposing (..)
import Route
import Ui.Components as Ui
import Ui.Svg as Icons
import Api exposing (ApiResult)


appShell : Html msg -> Html msg
appShell content =
    div
        [ class "bg-base w-100"
        , attribute "data-theme" "lemonade"
        ]
        [ header
        , main_ [] [ content ]
        ]


viewLoading : Maybe a -> (a -> Html msg) -> Html msg
viewLoading data render =
    case data of
        Just content ->
            render content

        Nothing ->
            div [ class "card m-4 p-4 bg-focus" ] [ text "Carregando..." ]


viewLoadingResult : ApiResult a -> (a -> Html msg) -> Html msg
viewLoadingResult data render =
    case data of
        Ok content ->
            render content

        Err (Just error) ->
            div [ class "card m-4 p-4 bg-focus" ] [ text error ]

        Err Nothing ->
            div [ class "card m-4 p-4 bg-focus" ] [ text "Carregando..." ]


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
