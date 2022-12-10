module Climb.Systems.Common exposing (..)

import Climb.Levels.Mod exposing (DifficultyMod, showModSoftHard)
import Climb.Levels.ABC as ABC
import Climb.Levels.ABCPlus as ABCPlus


select : Bool -> c -> c -> c
select cond a b =
    if cond then
        a

    else
        b


type alias FrGrade a =
    { a | mod : DifficultyMod, n : Int, cat : ABCPlus.Level }


type alias ShowFunc a =
    (a -> String) -> (a -> a) -> (a -> a) -> a -> String


showFrEasy : ShowFunc (FrGrade a)
showFrEasy show simplify next g =
    case showModSoftHard g.mod of
        Just suffix ->
            String.fromInt g.n ++ suffix

        Nothing ->
            String.fromInt g.n ++ "/" ++ show (g |> simplify |> next)


showFrPlus : ShowFunc (FrGrade a)
showFrPlus show simplify next g =
    case showModSoftHard g.mod of
        Just suffix ->
            String.fromInt g.n ++ select (ABCPlus.toABC g.cat == ABC.A) "" "+" ++ suffix

        Nothing ->
            case ABCPlus.showHalfway g.cat of
                Just suffix ->
                    String.fromInt g.n ++ suffix

                Nothing ->
                    show (g |> simplify) ++ "/" ++ show (g |> simplify |> next)


showFrFull : ShowFunc (FrGrade a)
showFrFull show simplify next g =
    case showModSoftHard g.mod of
        Just suffix ->
            String.fromInt g.n ++ ABCPlus.show g.cat ++ suffix

        Nothing ->
            case ABCPlus.showHalfway g.cat of
                Just suffix ->
                    String.fromInt g.n ++ suffix

                Nothing ->
                    show (g |> simplify) ++ "/" ++ show (g |> simplify |> next)
