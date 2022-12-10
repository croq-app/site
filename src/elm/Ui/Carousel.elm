module Ui.Carousel exposing (..)

{-| An Image Carousel. Follows TEA.
-}

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Ui.Color exposing (..)


type alias Config data msg =
    { prefix : String
    , render : data -> Html msg
    }


view : Config data msg -> List data -> Html msg
view cfg data =
    let
        ref idx =
            "_carousel-" ++ cfg.prefix ++ "-" ++ String.fromInt (modBy size idx)

        size =
            List.length data

        viewItem idx item =
            div [ class "carousel-item relative w-full", id (ref idx) ]
                [ cfg.render item
                , div [ class "absolute flex justify-between transform -translate-y-1/2 left-5 right-5 top-1/2" ]
                    [ a [ class "btn btn-circle btn-accent", href ("#" ++ ref (idx - 1)), target "_self" ]
                        [ text "❮" ]
                    , a [ class "btn btn-circle btn-accent", href ("#" ++ ref (idx + 1)), target "_self" ]
                        [ text "❯" ]
                    ]
                ]
    in
    div [ class "carousel w-full" ] (List.indexedMap viewItem data)


config : Config String msg
config =
    { prefix = "default"
    , render =
        \url -> img [ class "w-full", src url ] []
    }


withPrefix : String -> Config String msg -> Config String msg
withPrefix prefix cfg =
    { cfg | prefix = prefix }


{-| Update config to use the given rendering function. The default implementation receives an URL and
return an <img> like in

    config
        |> withRenderer (\url -> img [ class "w-full", src url ] [])

Use this function to customize how <img> tags are rendered.

-}
withRenderer : (a -> Html msg) -> Config a msg_ -> Config a msg
withRenderer render cfg =
    { prefix = cfg.prefix
    , render =
        \item -> render item
    }


withPlaceImg : Config a msg_ -> Config String msg
withPlaceImg cfg =
    { prefix = cfg.prefix
    , render =
        \slug -> img [ class "w-full", src ("https://placeimg.com/400/300/" ++ slug) ] []
    }
