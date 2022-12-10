module Climb.Levels.Plus exposing (..)


type Level
    = Base
    | Plus


next : Level -> Maybe Level
next lvl =
    case lvl of
        Base ->
            Just Plus

        Plus ->
            Nothing


show : Level -> String
show lvl =
    case lvl of
        Base ->
            ""

        Plus ->
            "+"


showHalfWay : Level -> Maybe String
showHalfWay lvl =
    case lvl of
        Base ->
            Just "/+"

        Plus ->
            Nothing

