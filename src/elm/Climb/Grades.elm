module Climb.Grades exposing (..)

{-| Climbing grades representation and conversion


## Reference

Conversions are based in two pages <https://en.wikipedia.org/wiki/Grade_(bouldering)>

-}

import Climb.Systems.Br as Br
import Climb.Systems.Font as Font
import Climb.Systems.Fr as Fr
import Climb.Systems.Hueco as Hueco
import Climb.Systems.Us as Us


{-| Collect methods for a GradeT pseudo-typeclass
-}
type alias GradeT t =
    { fromLinearScale : Float -> t
    , toLinearScale : t -> Float
    , show : t -> String
    , parse : String -> Maybe t
    , simplify : t -> t
    , zero : t
    , next : t -> t
    }


type alias Hueco =
    Hueco.Grade


type alias Font =
    Font.Grade


type alias Us =
    Us.Grade


type alias Fr =
    Fr.Grade


type alias Br =
    Br.Grade


{-| The Hueco/Vermin system used for bouldering in the USA, .i.e., the v-grades.
-}
vv : GradeT Hueco.Grade
vv =
    { fromLinearScale = Hueco.fromLinearScale
    , toLinearScale = Hueco.toLinearScale
    , show = Hueco.show
    , parse = Hueco.parse
    , simplify = Hueco.simplify
    , zero = Hueco.zero
    , next = Hueco.next
    }


{-| French Fontainebleau system for bouldering.
-}
font : GradeT Font.Grade
font =
    { fromLinearScale = Font.fromLinearScale
    , toLinearScale = Font.toLinearScale
    , show = Font.show
    , parse = Font.parse
    , simplify = Font.simplify
    , zero = Font.zero
    , next = Font.next
    }


{-| The Yosemite Decimal System used in the USA.
-}
us : GradeT Us.Grade
us =
    { fromLinearScale = Us.fromLinearScale
    , toLinearScale = Us.toLinearScale
    , show = Us.show
    , parse = Us.parse
    , simplify = Us.simplify
    , zero = Us.zero
    , next = Us.next
    }


{-| The French system.
-}
fr : GradeT Fr.Grade
fr =
    { fromLinearScale = Fr.fromLinearScale
    , toLinearScale = Fr.toLinearScale
    , show = Fr.show
    , parse = Fr.parse
    , simplify = Fr.simplify
    , zero = Fr.zero
    , next = Fr.next
    }


{-| The Brazillian system.
-}
br : GradeT Br.Grade
br =
    { fromLinearScale = Br.fromLinearScale
    , toLinearScale = Br.toLinearScale
    , show = Br.show
    , parse = Br.parse
    , simplify = Br.simplify
    , zero = Br.zero
    , next = Br.next
    }



-------------------------------------------------------------------------------
--- Methods
-------------------------------------------------------------------------------


{-| Convert from the floating point universal scale

For bouldering, the floating point scale is based in the American
Hueco/Vermin system. i.e. `fromLinearScale 10.0` refers to V10,
which is 7c+ in Fontainebleau scale.

-}
fromLinearScale : GradeT a -> Float -> a
fromLinearScale tt x =
    tt.fromLinearScale x


{-| Convert to the floating point universal scale

This is useful to convert to different grading systems or
saving in a database.

    font =
        grade
            |> Font.toLinearScale
            |> Hueco.fromLinearScale

-}
toLinearScale : GradeT a -> a -> Float
toLinearScale tt a =
    tt.toLinearScale a


{-| Render grade as a string
-}
showGrade : GradeT a -> a -> String
showGrade tt =
    tt.show


{-| Render Bouldering grade in destT format.

The boolean argument tells if the final grade should be simplified or
not in the final rendering.

-}
toGrade : GradeT dest -> GradeT a -> Bool -> a -> String
toGrade destT tt isSimple a =
    a
        |> tt.toLinearScale
        |> destT.fromLinearScale
        |> askSimplify_ destT isSimple
        |> destT.show


{-| Alias to `toGrade vv`
-}
toVGrade : GradeT a -> Bool -> a -> String
toVGrade =
    toGrade vv


{-| Alias to `toGrade font`
-}
toFont : GradeT a -> Bool -> a -> String
toFont =
    toGrade font


{-| Try to read string in the srcT format.
-}
fromGrade : GradeT src -> GradeT a -> String -> Maybe a
fromGrade srcT tt st =
    st
        |> srcT.parse
        |> Maybe.map (\a -> a |> srcT.toLinearScale |> tt.fromLinearScale)


{-| Alias to `fromGrade vv`
-}
fromVGrade : GradeT a -> String -> Maybe a
fromVGrade =
    fromGrade vv


{-| Alias to `fromGrade font`
-}
fromFontGrade : GradeT a -> String -> Maybe a
fromFontGrade =
    fromGrade font


{-| Parse string representing grade

    parseGrade vv "V10/11" ==> Just (Grade 10 HalfwayNext)

-}
parseGrade : GradeT a -> String -> Maybe a
parseGrade tt st =
    tt.parse st


{-| Parse string representing grade.

If parsing fails, return the default base/zero grade. This should
never be used to handle user input.

    parse_ vv "V10/11" ==> Grade 10 HalfwayNext

-}
parseGrade_ : GradeT a -> String -> a
parseGrade_ tt st =
    parseGrade tt st |> Maybe.withDefault tt.zero


{-| Remove modifiers from grade

    parseGrade_ vv "V10+"
        |> simplify vv
        ==> Grade 10 Base

-}
simplifyGrade : GradeT a -> a -> a
simplifyGrade tt a =
    tt.simplify a


{-| Next full grade ignoring modifiers
-}
nextGrade : GradeT a -> a -> a
nextGrade tt g =
    tt.next g


{-| The lowest grade in the scale

Different scales may start from different levels

-}
zeroGrade : GradeT a -> a
zeroGrade tt =
    tt.zero



-------------------------------------------------------------------------------
--- Auxiliary functions
-------------------------------------------------------------------------------


askSimplify_ : GradeT c -> Bool -> c -> c
askSimplify_ tt isSimple a =
    if isSimple then
        simplifyGrade tt a

    else
        a
