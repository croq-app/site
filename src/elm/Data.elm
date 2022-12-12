module Data exposing (..)

import Types exposing (..)


type alias Region =
    { id : RegionId
    , country : String
    , name : String
    , location : GeoLoc
    , description : String
    , howToAccess : String
    , attractions : List Attraction
    , sectors : List Sector
    }


type alias Attraction =
    { id : SectorId
    , name : String
    , description : String
    , howToAccess : String
    , location : GeoLoc
    }


type alias Sector =
    { id : SectorId
    , name : String
    , description : String
    , regionName: String
    , howToAccess : String
    , location : GeoLoc
    , isBouldering : Bool
    , routes : List Route
    , boulderFormations : List BoulderFormation
    }


type alias Route =
    { id : ElemId
    , name : Name
    , grade : Grade
    }


type alias BoulderFormation =
    { id : ElemId
    , name : String
    , shortName : String
    , problems: List BoulderProblem
    }


type alias BoulderProblem =
    { id : ProblemId
    , name : Name
    , grade : Grade
    , description : String
    }
