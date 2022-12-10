module Data exposing (..)

import Types exposing (..)


type alias BoulderInfo =
    { name : Name
    , slug : Slug
    , grade : Grade
    , block : Slug
    }


type alias BlockInfo =
    { name : String
    , shortName : String
    }


type alias RegionInfo =
    { name : String
    , id : RegionId
    , countryName : String
    , countryId : Id
    }
