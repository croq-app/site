module Climb.Util.Roman exposing (toRoman, fromRoman)

{-| Read and write in roman numerals

Exposes two functions: toRoman and fromRoman, which are responsible for the conversion
between integers and strings representing roman numerals.

@docs toRoman, fromRoman

-}

import Climb.Util.List exposing (..)


type Parser
    = Parser Int String


readN : String -> Int -> Parser -> ( Int, Parser )
readN tk n (Parser idx src) =
    let
        len =
            String.length tk
    in
    if n >= 0 && String.slice idx (idx + len) src == tk then
        let
            ( m, newParser ) =
                readN tk (n - 1) (Parser (idx + len) src)
        in
        ( m + 1, newParser )

    else
        ( 0, Parser idx src )


end : Parser -> Bool
end (Parser idx src) =
    String.length src <= idx


conversionSequence : List ( String, Int, ( Int, Int ) )
conversionSequence =
    [ ( "M", 1000, ( 3, 0 ) )
    , ( "CM", 900, ( 1, 3 ) )
    , ( "D", 500, ( 1, 1 ) )
    , ( "CD", 400, ( 1, 1 ) )
    , ( "C", 100, ( 3, 0 ) )
    , ( "XC", 90, ( 1, 3 ) )
    , ( "L", 50, ( 1, 1 ) )
    , ( "XL", 40, ( 1, 1 ) )
    , ( "X", 10, ( 3, 0 ) )
    , ( "IX", 9, ( 1, 3 ) )
    , ( "V", 5, ( 1, 1 ) )
    , ( "IV", 4, ( 1, 1 ) )
    , ( "I", 1, ( 3, 0 ) )
    ]


{-| Render number as Roman numeral.

Invalid numbers are rendered in arabic.

-}
toRoman : Int -> String
toRoman n =
    let
        invalid _ =
            "roman(" ++ String.fromInt n ++ ")"

        worker num acc bases =
            case ( num, bases ) of
                ( 0, _ ) ->
                    acc

                ( _, ( st, value, ( maxReps, drop ) ) :: moreBases ) ->
                    let
                        reps =
                            min (num // value) maxReps

                        newNum =
                            num - value * reps
                    in
                    if reps /= 0 then
                        worker newNum (String.repeat reps st :: acc) (List.drop drop moreBases)

                    else
                        worker num acc moreBases

                ( _, _ ) ->
                    [ invalid () ]
    in
    if n > 0 && n <= 4000 then
        worker n [] conversionSequence
            |> List.reverse
            |> String.concat

    else
        invalid ()


{-| Parse roman numeral
-}
fromRoman : String -> Maybe Int
fromRoman st =
    let
        worker bases acc parser =
            case bases of
                ( tk, value, ( maxReps, drop ) ) :: moreBases ->
                    let
                        ( reps, newParser ) =
                            readN tk maxReps parser
                    in
                    if reps == 0 then
                        worker moreBases acc parser

                    else if reps > maxReps then
                        Nothing

                    else
                        worker (List.drop drop moreBases) (acc + value * reps) newParser

                _ ->
                    if end parser then
                        Just acc

                    else
                        Nothing
    in
    worker conversionSequence 0 (Parser 0 st)
