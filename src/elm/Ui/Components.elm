module Ui.Components exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Types exposing (..)
import Ui.Color exposing (Color, colorString, fullColor)
import Ui.Svg as Svg



----------------------------------------------------------------
---                         TYPES                            ---
----------------------------------------------------------------


type alias CardListItem msg =
    ( String, List (Attribute msg) )



----------------------------------------------------------------
---                       COMPONENTS                         ---
----------------------------------------------------------------


{-| A simple button
-}
btn : List (Attribute msg) -> List (Html msg) -> Html msg
btn attrs body =
    button (attrs ++ []) body


{-| A simple rounded counter with specific color
-}
counter : Color -> Int -> Html msg
counter color i =
    div
        [ class "h-5 w-5 font-bold text-sm text-center rounded-full shadow-sm"
        , fullColor color
        ]
        [ text (String.fromInt i) ]


{-|

    Renders a list of pairs of (title, [attrs]) as cards.

    Each card triggers the corresponding message onClick events.

-}
cardList : HtmlElem msg -> Color -> List (CardListItem msg) -> Html msg
cardList elem color items =
    let
        viewItem i ( name, attrs ) =
            card i color elem attrs [ text name ]
    in
    div [ class "grid grid-cols-2 gap-1" ] (List.indexedMap viewItem items)


card : Int -> Color -> (List (Attribute msg) -> List (Html msg) -> Html msg) -> List (Attribute msg) -> List (Html msg) -> Html msg
card i color elem attrs content =
    elem
        ([ class "block flex items-center px-4 py-2 h-14 rounded-sm shadow-md"
         , class "text-left text-sm"
         , class ("focus:bg-slate-100 hover:outline-none hover:ring hover:ring-" ++ colorString color ++ "-focus")
         ]
            ++ attrs
        )
        [ counter color (i + 1)
        , span [ class "flex-1 mx-3" ] content
        ]


breadcrumbs : List ( String, String ) -> Html msg
breadcrumbs links =
    div [ class "text-sm breadcrumbs" ]
        [ ul [] <|
            List.indexedMap
                (\i ( link, name ) ->
                    let
                        data =
                            if i == 0 then
                                [ Svg.home, span [ class "pl-1" ] [ text name ] ]

                            else
                                [ text name ]
                    in
                    li [] [ a [ href link ] data ]
                )
                links
        ]


tag : String -> Html msg
tag txt =
    span [ class "badge badge-outline badge-primary" ] [ text txt ]


tags : List String -> Html msg
tags xs =
    div [ class "space-x-1" ] (List.map tag xs)


container : List (Html msg) -> Html msg
container content =
    div [ class "mx-auto px-4 my-2 max-w-lg" ] content


title : String -> Html msg
title txt =
    h1 [ class "font-bold text-xl mb-2" ] [ text txt ]


sections : List ( String, List (Html msg) ) -> Html msg
sections data =
    let
        item ( st, children ) =
            [ dt [ class "text-lg font-bold my-2" ] [ text st ]
            , dd [ class "mb-4" ] children
            ]
    in
    dl [] <|
        List.concat (List.map item data)


shortPlaceholder = "░░░░░ ░ ░░░░"
longPlaceholder = "░░░░░ ░ ░░░░ ░░░░ ░░░ ░░ ░░░░░ ░ ░░░░ ░ ░░░░ ░░░ ░░░ ░░░░ ░░░ ░░ ░░░░░ ░ ░░░░ ░ ░░░░"