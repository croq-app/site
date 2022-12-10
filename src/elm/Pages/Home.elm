module Pages.Home exposing (Model, Msg, entry, update, view)

import Config as Cfg
import Html exposing (..)
import Html.Attributes exposing (..)
import Route
import Ui.App
import Ui.Color
import Ui.Components as Ui


type Model
    = NotImpl


type alias Msg =
    ()


entry : Cfg.Model -> ( Model, Cmd a )
entry _ =
    ( NotImpl, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update _ m =
    ( m, Cmd.none )


view _ =
    Ui.App.appShell <|
        div []
            [ div
                [ class "hero min-h-screen"
                , style "background-image" "url(/static/boulder-ex.jpg)"
                ]
                [ div
                    [ class "hero-overlay bg-opacity-30" ]
                    []
                , div
                    [ class "hero-content text-center text-white"
                    ]
                    [ div
                        [ class "max-w-md" ]
                        [ h1 [ class "mb-5 text-5xl font-bold" ] [ text "faaala, lek!" ]
                        , p [ class "mb-5" ]
                            [ text "Provident cupiditate voluptatem et in. Quaerat fugiat ut assumenda excepturi exercitationem quasi. In deleniti eaque aut repudiandae et a id nisi." ]
                        , div [ class "btn-group" ]
                            [ a
                                [ class "btn btn-secondary"
                                , class "hover:ring"
                                , href (Route.region "br/belchi")
                                ]
                                [ text "Ir para Belchi" ]
                            , a
                                [ class "btn btn-primary"
                                , class "hover:ring"
                                , href (Route.region "br/cocal")
                                ]
                                [ text "Ir para Cocal" ]
                            ]
                        ]
                    ]
                ]
            ]


sectorDetail =
    let
        tags =
            [ div [ class "badge badge-outline badge-primary text-xs mx-1" ] [ text "40 boulders" ]
            , div [ class "badge badge-outline badge-primary text-xs mx-1" ] [ text "fácil acesso" ]
            ]
    in
    div [ class "overflow" ]
        [ img [ src "/static/boulder-ex.jpg", class "block mx-0 object-cover" ] []
        , h1 [ class "font-bold text-2xl m-4" ] [ text "Setor Mocó" ]
        , div [ class "flex mx-4" ] tags
        , h2 [ class "font-bold text-lg mx-4 my-3" ] [ text "Sobre" ]
        , p [ class "mx-4 my-2 text-sm" ] [ text loremIpsum ]
        , div [ class "mx-auto" ] [ histogram histEx ]
        , div [ class "flex flex-col py-4" ]
            [ button [ class "block mx-4 my-1 btn btn-primary" ] [ text "Visitar setor" ]
            , button [ class "block mx-4 my-1 btn btn-primary btn-outline" ] [ text "Voltar" ]
            ]
        ]


loremIpsum =
    "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat."


histogram : List ( String, Int ) -> Html msg
histogram lst =
    let
        size =
            10

        norm =
            lst
                |> List.map Tuple.second
                |> List.maximum
                |> Maybe.withDefault 1
                |> toFloat

        pcHeight n =
            String.fromFloat (toFloat n / norm * size) ++ "rem"

        viewPair ( st, n ) =
            div [ class "flex flex-col justify-end align-center m-1.5 text-sm text-center" ]
                [ div [] [ text (String.fromInt n) ]
                , div [ class "bg-secondary hover:bg-accent rounded-sm w-5 h-full", style "height" (pcHeight n) ] [ text " " ]
                , div [] [ text st ]
                ]

        items =
            List.map viewPair lst
    in
    div [ class "flex justify-center" ] items


histEx =
    [ ( "V0", 8 ), ( "V1", 10 ), ( "V2", 14 ), ( "V3", 9 ), ( "V4", 12 ), ( "V5", 4 ) ]


boulderDetail =
    let
        viewItem idx { name, grade } =
            div [ class "flex px-4 py-3 items-center border-t-2 first:border-0 border-focus" ]
                [ Ui.counter Ui.Color.Secondary (idx + 1)
                , div [ class "mx-4 font-bold grow" ] [ text (name ++ " (" ++ grade ++ ")") ]
                , div [ class "font-bold text-xl grow-0" ] [ text "+" ]
                ]

        items =
            List.indexedMap viewItem itemsEx
    in
    div []
        [ div [ class "mx-4 my-3" ]
            [ span [ class "text-xs" ] [ text "❮" ]
            , a [ href "#", class "text-primary mx-2" ] [ text "Setor Mocó" ]
            ]
        , h1 [ class "font-bold text-2xl mx-4 my-3" ] [ text "Bloco do Moai" ]
        , div [ class "mx-4 shadow-md rounded-md" ]
            (carousel [ "static/boulder-ex.jpg", "static/boulder-ex.jpg", "static/boulder-ex.jpg" ] :: items)
        ]


carousel imgs =
    let
        size =
            List.length imgs

        toID idx =
            "carousel-slide" ++ String.fromInt (remainderBy size idx)

        viewItem idx url =
            div [ class "carousel-item relative w-full", id (toID idx) ]
                [ img [ class "w-full", src url ]
                    []
                , div [ class "absolute flex justify-between transform -translate-y-1/2 left-5 right-5 top-1/2" ]
                    [ a [ class "btn btn-circle", href ("#" ++ toID (idx - 1)) ]
                        [ text "❮" ]
                    , a [ class "btn btn-circle", href ("#" ++ toID (idx + 1)) ]
                        [ text "❯" ]
                    ]
                ]
    in
    div [ class "carousel w-full" ] (List.indexedMap viewItem imgs)


type alias Item =
    { name : String
    , grade : String
    }


itemsEx =
    [ Item "Fendinha" "V1", Item "Moai" "V5", Item "Thai" "V7" ]
