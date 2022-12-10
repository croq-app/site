module Climb.Systems.Font exposing (..)

import Climb.Systems.Common exposing (..)
import Climb.Levels.Mod exposing (..)
import Climb.Levels.ABC as ABC
import Climb.Levels.ABCPlus as Lvl


type alias Grade =
    { n : Int
    , cat : Lvl.Level
    , mod : DifficultyMod
    }


show : Grade -> String
show grade =
    if grade.n <= 3 then
        showFrEasy show simplify next grade

    else if grade.n <= 5 then
        showFrPlus show simplify next grade

    else
        showFrFull show simplify next grade


parse : String -> Maybe Grade
parse st =
    Nothing


simplify : Grade -> Grade
simplify { n, cat } =
    Grade n cat Base


toLinearScale : Grade -> Float
toLinearScale { n, cat, mod } =
    -1.0


fromLinearScale : Float -> Grade
fromLinearScale x =
    zero


zero : Grade
zero =
    { n = 1, cat = Lvl.A6, mod = Base }


next : Grade -> Grade
next { n, cat, mod } =
    if n <= 3 then
        Grade (n + 1) Lvl.A6 mod

    else if n <= 5 && Lvl.toABC cat == ABC.A then
        Grade n Lvl.B6 mod

    else if n <= 5 then
        Grade (n + 1) Lvl.A6 mod

    else
        case Lvl.next cat of
            Just lvl ->
                Grade n lvl mod

            Nothing ->
                Grade (n + 1) Lvl.A6 mod
