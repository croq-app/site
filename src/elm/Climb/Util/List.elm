module Climb.Util.List exposing (iterate, partitionWhile, repeats)


repeats : List comparable -> List ( comparable, Int )
repeats xs =
    let
        do ys acc =
            case ys of
                a :: rest ->
                    let
                        ( left, right ) =
                            partitionWhile (\x -> x == a) rest
                    in
                    do right (( a, List.length left + 1 ) :: acc)

                [] ->
                    acc
    in
    List.reverse (do xs [])


partitionWhile : (a -> Bool) -> List a -> ( List a, List a )
partitionWhile pred lst =
    let
        do elems left =
            case elems of
                e :: es ->
                    if pred e then
                        do es (e :: left)

                    else
                        ( List.reverse left, elems )

                _ ->
                    ( List.reverse left, elems )
    in
    do lst []


iterate : (a -> a) -> a -> Int -> List a
iterate func x0 n =
    if n == 0 then
        [ x0 ]

    else
        x0 :: iterate func (func x0) (n - 1)
