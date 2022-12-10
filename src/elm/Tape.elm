module Tape exposing
    ( Tape
    , create, fromList, fromListOrDefault, singleton, repeat, range
    , read, write, left, right, advance, rewind
    , map, indexedMap, foldr, foldl, reduce, toList
    , all, any, length, maximum, member, minimum, product, reverse, sum
    )

{-| A linear structure with a cursor pointing to some specific element. Tapes cannot be empty.

@docs Tape


# Create

@docs create, fromList, fromListOrDefault, singleton, repeat, range


# Tape operators

@docs read, write, left, right, advance, rewind


# Transforms

@docs map, indexedMap, foldr, foldl, reduce, toList

-}


{-| Base iterator type
-}
type Tape a
    = Tape (List a) a (List a)



--------------------------------------------------------------------------------
-- CREATE
--------------------------------------------------------------------------------


{-| Create a tape from the left, head, and right parts.

The tape is conceptually equivalent to the list `left ++ [head] ++ right`
and has a cursor that points to the tape head.

-}
create : List a -> a -> List a -> Tape a
create xs y zs =
    Tape (List.reverse xs) y zs


{-| Try to create tape from List. Empty lists return Nothing.
-}
fromList : List a -> Maybe (Tape a)
fromList xs =
    case xs of
        x :: ys ->
            Just (Tape [] x ys)

        _ ->
            Nothing


{-| Create a tape from List or a singleton tape with the given default value.
-}
fromListOrDefault : a -> List a -> Tape a
fromListOrDefault x xs =
    case xs of
        y :: ys ->
            Tape [] y ys

        _ ->
            singleton x


{-| Create a tape with only one element
-}
singleton : a -> Tape a
singleton a =
    Tape [] a []


{-| Create a tape with n copies of a value.

Empty tapes or negative n are ignored.

-}
repeat : Int -> a -> Tape a
repeat n x =
    Tape [] x (List.repeat (n - 1) x)


{-| Create a tape of numbers, every element increasing by one. You give the lowest and highest number that should be in the tape.
-}
range : Int -> Int -> Tape Int
range a b =
    if b > a then
        Tape [] a (List.range (a + 1) b)

    else
        singleton a



--------------------------------------------------------------------------------
-- TAPE OPERATIONS
--------------------------------------------------------------------------------


{-| Read element on the current position.
-}
read : Tape a -> a
read (Tape _ x _) =
    x


{-| Write element to the tape's current position.
-}
write : a -> Tape a -> Tape a
write y (Tape xs _ zs) =
    Tape xs y zs


{-| Move head a single position to the left
-}
left : Tape a -> Tape a
left (Tape xs y zs) =
    case xs of
        [] ->
            Tape xs y zs

        w :: ws ->
            Tape ws w (y :: zs)


{-| Move head a single position to the right
-}
right : Tape a -> Tape a
right (Tape xs y zs) =
    case zs of
        [] ->
            Tape xs y zs

        w :: ws ->
            Tape (y :: xs) w ws


{-| Rewind tape so the head points to the first element
-}
rewind : Tape a -> Tape a
rewind (Tape xs y zs) =
    case xs of
        [] ->
            Tape xs y zs

        w :: ws ->
            rewind (Tape ws w (y :: zs))


{-| Advance tape so the head points to the last element
-}
advance : Tape a -> Tape a
advance (Tape xs y zs) =
    case zs of
        [] ->
            Tape xs y zs

        w :: ws ->
            advance (Tape (y :: xs) w ws)



--------------------------------------------------------------------------------
-- TRANSFORM
--------------------------------------------------------------------------------


{-| Apply a function to every element of a tape.
-}
map : (a -> b) -> Tape a -> Tape b
map f (Tape xs y zs) =
    Tape (List.map f xs) (f y) (List.map f zs)


{-| Same as map but the function is also applied to the index of each element.

The head has an index of zero and the left hand side of the tape is indexed with
negative numbers.

-}
indexedMap : (Int -> a -> b) -> Tape a -> Tape b
indexedMap f (Tape xs y zs) =
    let
        f1 n x =
            f -(n + 1) x

        f2 n x =
            f (n + 1) x
    in
    Tape (List.indexedMap f1 xs) (f 0 y) (List.indexedMap f2 zs)


{-| Reduce a tape from the left.

It has the same effect as reducing the equivalent list.

-}
foldl : (a -> b -> b) -> b -> Tape a -> b
foldl f acc (Tape xs y zs) =
    List.foldl f (List.foldr f acc xs) (y :: zs)


{-| Reduce a tape from the right.

It has the same effect as reducing the equivalent list.

-}
foldr : (a -> b -> b) -> b -> Tape a -> b
foldr f acc (Tape xs y zs) =
    List.foldl f (List.foldr f acc zs) (y :: xs)


{-| Reduce tape applying binary operator.

Similar to a fold, but it does not require an initial accumulator.

-}
reduce : (a -> a -> a) -> Tape a -> a
reduce op (Tape xs y zs) =
    List.foldl op (List.foldr op y zs) xs


{-| Converts tape to list
-}
toList : Tape a -> List a
toList (Tape xs y zs) =
    List.reverse xs ++ (y :: zs)



--------------------------------------------------------------------------------
-- UTILITIES
--------------------------------------------------------------------------------


{-| Determine the length of a tape.
-}
length : Tape a -> Int
length (Tape xs _ ys) =
    List.length xs + List.length ys + 1


{-| Reverse a list.
-}
reverse : Tape a -> Tape a
reverse (Tape xs y zs) =
    Tape zs y xs


{-| Figure out whether a tape contains a value.
-}
member : a -> Tape a -> Bool
member a (Tape xs y zs) =
    a == y || List.member a xs || List.member a zs


{-| Determine if all elements satisfy some test.
-}
all : (a -> Bool) -> Tape a -> Bool
all pred (Tape xs y zs) =
    pred y && List.all pred xs && List.all pred zs


{-| Determine if any elements satisfy some test.
-}
any : (a -> Bool) -> Tape a -> Bool
any pred (Tape xs y zs) =
    pred y || List.any pred xs || List.any pred zs


{-| Find the maximum element in a non-empty list.
-}
maximum : Tape comparable -> comparable
maximum =
    reduce max


{-| Find the minimum element in a non-empty list.
-}
minimum : Tape comparable -> comparable
minimum =
    reduce min


{-| Get the sum of the list elements.
-}
sum : Tape number -> number
sum =
    reduce (+)


{-| Get the product of the list elements.
-}
product : Tape number -> number
product =
    reduce (*)
