module Climb.Levels.ABCPlus exposing (..)

import Climb.Levels.ABC as ABC


type Level
    = A6
    | A6Plus
    | B6
    | B6Plus
    | C6
    | C6Plus


next : Level -> Maybe Level
next lvl =
    case lvl of
        A6 ->
            Just A6Plus

        A6Plus ->
            Just B6

        B6 ->
            Just B6Plus

        B6Plus ->
            Just C6

        C6 ->
            Just C6Plus

        C6Plus ->
            Nothing


toABC : Level -> ABC.Level
toABC lvl =
    case lvl of
        A6 ->
            ABC.A

        A6Plus ->
            ABC.A

        B6 ->
            ABC.B

        B6Plus ->
            ABC.B

        C6 ->
            ABC.C

        C6Plus ->
            ABC.C


show : Level -> String
show lvl =
    case lvl of
        A6 ->
            "a"

        A6Plus ->
            "a+"

        B6 ->
            "b"

        B6Plus ->
            "b+"

        C6 ->
            "c"

        C6Plus ->
            "c+"


showHalfway : Level -> Maybe String
showHalfway cat =
    case cat of
        A6 ->
            Just "a/+"

        A6Plus ->
            Just "a+/b"

        B6 ->
            Just "b/+"

        B6Plus ->
            Just "b+/c"

        C6 ->
            Just "c/+"

        C6Plus ->
            Nothing
