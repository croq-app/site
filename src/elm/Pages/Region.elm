module Pages.Region exposing (Model, Msg, entry, update, view)

import Api
import Config as Cfg
import Data exposing (Region)
import Decoder
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import List.Extra
import Route
import Types exposing (..)
import Ui.App
import Ui.Color
import Ui.Components as Ui
import Ui.SectorMap as Map
import Ui.Tab as Tab


type alias Model =
    { id : RegionId
    , region : Api.ApiResult Region
    , tab : Tab.Model
    , map : Map.Model
    , selectedSector : Int
    , selectedAttraction : Int
    , showAttraction : Bool
    }


type Msg
    = OnDataReceived (Result Http.Error Region)
    | OnChangeSelectedSector Int
    | OnChangeSelectedAttraction Int
    | OnShowAttraction Int
    | OnTabMsg Tab.Msg
    | OnMapMsg Map.Msg


entry : Cfg.Model -> RegionId -> ( Model, Cmd Msg )
entry cfg id =
    let
        m =
            { id = id
            , region = Err Nothing
            , tab = Tab.init tabConfig
            , map = Map.init
            , selectedSector = -1
            , selectedAttraction = -1
            , showAttraction = False
            }
    in
    ( m, httpDataRequest cfg id )


update : Msg -> Model -> Model
update msg m =
    case msg of
        OnDataReceived (Ok data) ->
            { m | region = Api.resultFromData data }

        OnDataReceived (Err e) ->
            { m | region = Api.resultFromError e }

        OnTabMsg msg_ ->
            { m | tab = Tab.update msg_ m.tab }

        OnMapMsg msg_ ->
            { m | map = Map.update msg_ m.map }

        OnChangeSelectedSector i ->
            { m | selectedSector = i }

        OnChangeSelectedAttraction i ->
            { m | selectedAttraction = i }

        OnShowAttraction i ->
            { m | showAttraction = i >= 0, selectedAttraction = i }


view : Cfg.Model -> Model -> Html Msg
view _ m =
    let
        ( countryId, _ ) =
            splitRegionId m.id
    in
    Ui.App.appShell <|
        div []
            [ Ui.container
                [ Ui.breadcrumbs [ ( "/" ++ countryId, String.toUpper countryId ) ]
                , Ui.title "Mapa dos setores"
                ]
            , div [ class "max-w-lg mx-auto" ] [ Map.view m.map ]
            , Ui.container [ Tab.view tabConfig m.tab m ]
            ]


viewSectors : Model -> Html Msg
viewSectors m =
    let
        card sector =
            let
                url : String
                url =
                    Route.boulderSector sector.id
            in
            ( sector.name, [ href url ] )
    in
    Ui.App.viewLoadingResult m.region <|
        \{ sectors } ->
            if sectors == [] then
                div [ class "card m-4 p-4 bg-focus" ] [ text "Nenhum setor cadastrado!" ]

            else
                Ui.cardList a Ui.Color.Primary (List.map card sectors)


viewAttractions : Model -> Html Msg
viewAttractions m =
    Ui.App.viewLoadingResult m.region <|
        \{ attractions } ->
            if attractions == [] then
                div [ class "card m-4 p-4 bg-error" ] [ text "Nenhuma atração cadastrada!" ]

            else if m.showAttraction then
                div []
                    [ button [ onClick (OnShowAttraction -1) ] [ text "< back" ]
                    , text
                        (List.Extra.getAt m.selectedAttraction attractions
                            |> Maybe.map (\x -> x.description)
                            |> Maybe.withDefault "internal error"
                        )
                    ]

            else
                Ui.cardList button
                    Ui.Color.Secondary
                    (List.indexedMap
                        (\i a -> ( a.name, [ onClick (OnShowAttraction i) ] ))
                        attractions
                    )


tabConfig : Tab.Config Model Msg
tabConfig =
    Tab.config OnTabMsg [ ( "Setores", viewSectors ), ( "Atrações", viewAttractions ) ]


httpDataRequest : Cfg.Model -> RegionId -> Cmd Msg
httpDataRequest cfg id =
    Http.get
        { url = Api.region cfg id
        , expect = Http.expectJson OnDataReceived Decoder.region
        }
