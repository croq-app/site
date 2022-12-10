module Climb.Systems.Br exposing (..)

import Climb.Levels.ABC as Lvl
import Climb.Systems.Common exposing (..)
import Climb.Levels.Mod exposing (..)
import Climb.Util.Roman exposing (..)


type alias Grade =
    { n : Int
    , cat : Lvl.Level
    , mod : DifficultyMod
    }


show : Grade -> String
show grade =
    let
        { n, cat, mod } =
            grade
    in
    if n == 6 && cat /= Lvl.A && mod == HalfwayNext then
        -- Special cases
        "6sup/7a"

    else if n <= 6 && mod == HalfwayNext && cat == Lvl.A then
        -- Easy grades (I to VIsup) treat Lvl.B3 and Lvl.C3 as
        -- equivalent and correspond to the "sup" modifier
        toRoman n ++ "/sup"

    else if n <= 6 then
        case showModSoftHard mod of
            Just suffix ->
                toRoman n ++ select (cat == Lvl.A) "" "sup" ++ suffix

            Nothing ->
                toRoman n ++ "sup/" ++ toRoman (n + 1)

    else
        -- Grades such as 7a, 9c, etc are more regular
        case showModSoftHard mod of
            Just suffix ->
                String.fromInt n ++ Lvl.show cat ++ suffix

            Nothing ->
                case Lvl.showHalfWay cat of
                    Just lvl ->
                        String.fromInt n ++ lvl

                    Nothing ->
                        show (grade |> simplify) ++ "/" ++ show (grade |> simplify |> next)


parse : String -> Maybe Grade
parse st =
    Nothing


simplify : Grade -> Grade
simplify { n, cat } =
    Grade n cat Base


fromLinearScale : Float -> Grade
fromLinearScale x =
    zero


toLinearScale : Grade -> Float
toLinearScale g =
    0.0


zero : Grade
zero =
    { n = 1, cat = Lvl.A, mod = Base }


next : Grade -> Grade
next { n, cat, mod } =
    if n <= 6 && cat == Lvl.A then
        Grade n Lvl.B mod

    else if n <= 6 then
        Grade (n + 1) Lvl.A mod

    else
        case Lvl.next cat of
            Just lvl ->
                Grade n lvl mod

            Nothing ->
                Grade (n + 1) Lvl.A mod
