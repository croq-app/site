module Climb.Systems.Us exposing (..)

import Climb.Levels.Mod exposing (..)


type Grade
    = Grade Int DifficultyMod


show : Grade -> String
show g =
    ""


parse : String -> Maybe Grade
parse st =
    Nothing


simplify : Grade -> Grade
simplify g =
    g


fromLinearScale : Float -> Grade
fromLinearScale x =
    zero


toLinearScale : Grade -> Float
toLinearScale g =
    0.0


zero : Grade
zero =
    Grade 0 Base


next : Grade -> Grade
next grade =
    grade
