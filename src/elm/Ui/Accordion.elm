module Ui.Accordion exposing (..)

{-| Accordion. Follows TEA.
-}

import Html exposing (..)
import Html.Attributes as Attr exposing (..)
import Html.Events as Ev exposing (..)
import Ui.Color as Color
import Ui.Components as Ui


type alias State =
    { selected : Int }


type alias Config data msg =
    { toMsg : State -> msg
    , render : data -> Html msg
    , title : data -> String
    }


view : Config data msg -> State -> List data -> Html msg
view cfg m data =
    let
        item i elem =
            let
                handle =
                    if i == m.selected then
                        span [ class "align-right font-bold" ] [ text " -" ]

                    else
                        span [ class "align-right font-bold" ] [ text " +" ]

                title =
                    span [ class "px-2" ] [ text (cfg.title elem) ]

                expand =
                    if i == m.selected then
                        cfg.render elem

                    else
                        text ""

                msg =
                    if i == m.selected then
                        cfg.toMsg { selected = -1 }

                    else
                        cfg.toMsg { selected = i }
            in
            div
                [ class "px-4 py-2 rounded-sm shadow-md"
                , class "text-left text-sm"
                , class "focus:bg-slate-100 hover:outline-none hover:ring hover:ring primary-focus"
                , onClick msg
                ]
                [ div [ class "block flex items-center h-14" ] [ Ui.counter Color.Primary (i + 1), title, handle ]
                , expand
                ]
    in
    div [] (List.indexedMap item data)


init : State
init =
    { selected = -1 }


config : Config data msg -> Config data msg
config cfg =
    cfg
