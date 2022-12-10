module Route exposing (Route(..), boulderDetail, boulderSector, home, parking, parseUrl, region, routeDetail, routeSector, toHref, boulderProblem)

import Types exposing (..)
import Url exposing (Url)
import Url.Parser as Parser exposing (..)


type Route
    = Home
    | Error RegionId
    | Region Id
    | BoulderSector SectorId
    | BoulderDetail ElemId
    | RouteSector SectorId
    | RouteDetail ElemId
    | BoulderProblem ProblemId
    | Parking SectorId
    | GradeTool
    | GpsTool


matchers : Parser (Route -> a) a
matchers =
    let
        regionId =
            id </> id

        id =
            string

        rmap f =
            map (\x y -> f (x ++ "." ++ y))

        smap f =
            map (\a b id_ -> f (sectorId (a ++ "." ++ b) id_))

        emap f =
            map (\a b id1 id2 -> f (elemId (sectorId (a ++ "." ++ b) id1) id2))

        pmap f =
            map (\a b id1 id2 id3 -> f (problemId (elemId (sectorId (a ++ "." ++ b) id1) id2) id3))
    in
    Parser.oneOf
        [ map Home top

        --- Generic pages
        , map GradeTool (s "tools" </> s "grades")
        , map GpsTool (s "tools" </> s "gps")

        --- URLS associated with specific regions
        , rmap Region regionId
        , smap BoulderSector (regionId </> s "b" </> s "sectors" </> id)
        , emap BoulderDetail (regionId </> s "b" </> s "sectors" </> id </> id)
        , pmap BoulderProblem (regionId </> s "b" </> s "sectors" </> id </> id </> id)
        , smap RouteSector (regionId </> s "r" </> s "sectors" </> id)
        , emap RouteDetail (regionId </> s "r" </> s "sectors" </> id </> id)
        , smap Parking (regionId </> s "p" </> id)
        ]


parseUrl : Url -> Route
parseUrl url =
    case Parser.parse matchers url of
        Just route ->
            route

        Nothing ->
            Error (Url.toString url)


toHref : Route -> String
toHref route =
    let
        reg =
            String.replace "." "/"
    in
    case route of
        Home ->
            "/"

        Region id ->
            "/" ++ reg id ++ "/"

        BoulderSector ( rid, id ) ->
            "/" ++ reg rid ++ "/b/sectors/" ++ id ++ "/"

        BoulderDetail ( ( rid, sec ), id ) ->
            "/" ++ reg rid ++ "/b/sectors/" ++ sec ++ "/" ++ id ++ "/"

        BoulderProblem ( ( ( rid, sec ), elem ), id ) ->
            "/" ++ reg rid ++ "/b/sectors/" ++ sec ++ "/" ++ elem ++ "/" ++ id ++ "/"

        RouteSector ( rid, id ) ->
            "/" ++ reg rid ++ "/r/sectors/" ++ id ++ "/"

        RouteDetail ( ( rid, sec ), id ) ->
            "/" ++ reg rid ++ "/r/sectors/" ++ sec ++ "/" ++ id ++ "/"

        Parking ( rid, id ) ->
            "/" ++ reg rid ++ "/p/" ++ id ++ "/"

        GpsTool ->
            "/tools/gps/"

        GradeTool ->
            "/tools/grades/"

        Error st ->
            "/error/" ++ st


home : String
home =
    toHref Home


region : Id -> String
region id =
    toHref (Region id)


boulderSector : SectorId -> String
boulderSector id =
    toHref (BoulderSector id)


boulderDetail : ElemId -> String
boulderDetail id =
    toHref (BoulderDetail id)


boulderProblem : ProblemId -> String
boulderProblem id =
    toHref (BoulderProblem id)


routeSector : SectorId -> String
routeSector id =
    toHref (RouteSector id)


routeDetail : ElemId -> String
routeDetail id =
    toHref (RouteDetail id)


parking : SectorId -> String
parking id =
    toHref (Parking id)
