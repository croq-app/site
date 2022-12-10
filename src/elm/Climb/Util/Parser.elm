module Climb.Util.Parser exposing (..)

import Climb.Levels.Mod exposing (..)
import Parser exposing (..)


positiveInt : Parser Int
positiveInt =
    int |> map (max 0)


optionalSuffix : String -> Parser Bool
optionalSuffix suffix =
    oneOf
        [ succeed True
            |. token suffix
            |. end
        , succeed False
            |. end
        ]


modifierSuffixSlash : Parser a -> Parser (Result a DifficultyMod)
modifierSuffixSlash parser =
    oneOf
        [ succeed (Ok Base)
            |. end
        , succeed (Ok Hard)
            |. token "+"
            |. end
        , succeed (Ok Soft)
            |. token "-"
            |. end
        , succeed Err
            |. token "/"
            |= parser
            |. end
        ]


flattenMaybe : String -> Parser (Maybe a) -> Parser a
flattenMaybe err parser =
    parser |> andThen (\x -> x |> Maybe.map succeed |> Maybe.withDefault (problem err))


flattenResult : Parser (Result String a) -> Parser a
flattenResult parser =
    parser
        |> andThen
            (\result ->
                case result of
                    Ok x ->
                        succeed x

                    Err e ->
                        problem e
            )
