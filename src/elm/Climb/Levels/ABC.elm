module Climb.Levels.ABC exposing (..)


type Level
    = A
    | B
    | C


next : Level -> Maybe Level
next lvl =
    case lvl of
        A ->
            Just B

        B ->
            Just C

        C ->
            Nothing


show : Level -> String
show lvl =
    case lvl of
        A ->
            "a"

        B ->
            "b"

        C ->
            "c"


showHalfWay : Level -> Maybe String
showHalfWay lvl =
    case lvl of
        A ->
            Just "a/b"

        B ->
            Just "b/c"

        C ->
            Nothing
