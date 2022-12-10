module Climb.Systems.Hueco exposing (Grade, fromLinearScale, parse, show, simplify, toLinearScale, zero, next)

import Climb.Levels.Mod exposing (..)
import Parser exposing (..)
import Climb.Util.Parser exposing (flattenResult, modifierSuffixSlash, positiveInt)


type Grade
    = Grade Int DifficultyMod


zero : Grade
zero =
    Grade 0 Base


next : Grade -> Grade
next (Grade n mod) =
    Grade (n + 1) mod


show : Grade -> String
show (Grade n mod) =
    let
        base =
            if n <= 0 then
                "VB"

            else
                "V" ++ String.fromInt n
    in
    case mod of
        Base ->
            base

        Soft ->
            base ++ "-"

        Hard ->
            base ++ "+"

        HalfwayNext ->
            base ++ "/" ++ String.fromInt (n + 1)


parse : String -> Maybe Grade
parse st =
    st
        |> String.toLower
        |> run parser
        |> Result.toMaybe


simplify : Grade -> Grade
simplify (Grade n _) =
    Grade n Base


{-| Convert to the floating point universal scale

This is useful to convert to different grading systems or
saving in a database.

    font =
        grade
            |> Hueco.toLinearScale
            |> Font.fromLinearScale

-}
toLinearScale : Grade -> Float
toLinearScale (Grade n mod) =
    toFloat n + modToLinearScale mod


fromLinearScale : Float -> Grade
fromLinearScale x =
    let
        n =
            floor x

        err =
            x - toFloat n

        ( m, mod ) =
            modFromLinearScale n err
    in
    Grade m mod


parser : Parser Grade
parser =
    let
        validate n rmod =
            case rmod of
                Ok m ->
                    Ok <| Grade n m

                Err m ->
                    if m == n + 1 then
                        Ok <| Grade n HalfwayNext

                    else
                        Err "not a sequence of grades"
    in
    flattenResult <|
        (succeed validate
            |. symbol "v"
            |= oneOf [ succeed -1 |. symbol "b", positiveInt ]
            |= modifierSuffixSlash positiveInt
        )