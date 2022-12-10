module Climb.Levels.Mod exposing (..)

{-| Sub-levels and categories inside a given grade class.
-}


{-| Difficulty modifier
-}
type DifficultyMod
    = Base
    | Soft
    | Hard
    | HalfwayNext


type ABCDLvl
    = A4
    | B4
    | C4
    | D4


showModExt : ( String, String ) -> DifficultyMod -> Maybe String
showModExt mods mod =
    case mod of
        Base ->
            Just ""

        Soft ->
            Just <| Tuple.first mods

        Hard ->
            Just <| Tuple.second mods

        HalfwayNext ->
            Nothing


showMod : DifficultyMod -> Maybe String
showMod =
    showModExt ( "-", "+" )


showModSoftHard : DifficultyMod -> Maybe String
showModSoftHard =
    showModExt ( " soft", " hard" )


modToLinearScale : DifficultyMod -> Float
modToLinearScale mod =
    case mod of
        Base ->
            0.0

        Soft ->
            -0.2

        Hard ->
            0.2

        HalfwayNext ->
            0.5


modFromLinearScale : number -> Float -> ( number, DifficultyMod )
modFromLinearScale n x =
    if x <= -0.2 then
        ( n, Soft )

    else if x <= 0.2 then
        ( n, Base )

    else if x <= 0.4 then
        ( n, Hard )

    else if x <= 0.6 then
        ( n, HalfwayNext )

    else if x <= 0.8 then
        ( n + 1, Soft )

    else
        ( n + 1, Base )
