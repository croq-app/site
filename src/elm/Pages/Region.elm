module Pages.Region exposing (Model, Msg, entry, update, view)

import Api
import Config as Cfg
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode as D
import List.Extra
import Route
import Types exposing (..)
import Ui.App
import Ui.Color
import Ui.Components as Ui
import Ui.SectorMap as Map
import Ui.Tab as Tab


type alias Sector =
    ( String, String )


type alias Model =
    { id : String
    , tab : Tab.Model
    , map : Map.Model
    , data : Maybe Data
    , selectedSector : Int -- (-1) if no sector/attraction is selected
    , selectedAttraction : Int
    , showAttraction : Bool
    }


type alias Data =
    { sectors : List Sector
    , attractions : List Attraction
    }


type alias Attraction =
    { title : String
    , description : String
    }


type Msg
    = OnRequestData
    | OnDataReceived (Result Http.Error Data)
    | OnChangeSelectedSector Int
    | OnChangeSelectedAttraction Int
    | OnShowAttraction Int
    | OnTabMsg Tab.Msg
    | OnMapMsg Map.Msg


entry : String -> ( Model, Cmd Msg )
entry url =
    let
        m =
            { id = url
            , data = Nothing
            , tab = Tab.init tabConfig
            , map = Map.init
            , selectedSector = -1
            , selectedAttraction = -1
            , showAttraction = False
            }
    in
    ( m, httpDataRequest url )


update : Msg -> Cfg.Model -> Model -> ( Model, Cmd Msg )
update msg cfg m =
    let
        return model =
            ( model, Cmd.none )
    in
    case msg of
        OnRequestData ->
            ( m, httpDataRequest m.id )

        OnDataReceived (Ok data) ->
            return { m | data = Just data }

        OnDataReceived (Err e) ->
            ( m, Cfg.pushErrorUrl e cfg )

        OnTabMsg msg_ ->
            return { m | tab = Tab.update msg_ m.tab }

        OnMapMsg msg_ ->
            return { m | map = Map.update msg_ m.map }

        OnChangeSelectedSector i ->
            return { m | selectedSector = i }

        OnChangeSelectedAttraction i ->
            return { m | selectedAttraction = i }

        OnShowAttraction i ->
            return { m | showAttraction = True, selectedAttraction = i }



--- VIEW ----------------------------------------------------------------------


view : Cfg.Model -> Model -> Html Msg
view _ m =
    Ui.App.appShell <|
        div []
            [ Ui.container
                [ Ui.breadcrumbs [ ( "/br", "BR" ) ]
                , Ui.title "Mapa dos setores"
                ]
            , Map.view m.map
            , Ui.container [ Tab.view tabConfig m.tab m ]
            ]


viewSectors : Model -> Html Msg
viewSectors m =
    viewLoading m.data <|
        \{ sectors } ->
            if sectors == [] then
                div [ class "card m-4 p-4 bg-focus" ] [ text "Nenhum setor cadastrado!" ]

            else
                Ui.cardList a
                    Ui.Color.Primary
                    (List.map
                        (\( a, id_ ) ->
                            ( a, [ href (Route.boulderSector (sectorId m.id id_)) ] )
                        )
                        sectors
                    )


viewAttractions : Model -> Html Msg
viewAttractions m =
    viewLoading m.data <|
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
                        (\i a -> ( a.title, [ onClick (OnShowAttraction i) ] ))
                        attractions
                    )


viewLoading : Maybe a -> (a -> Html msg) -> Html msg
viewLoading data render =
    case data of
        Just content ->
            render content

        Nothing ->
            div [ class "card m-4 p-4 bg-focus" ] [ text "Carregando..." ]


tabConfig : Tab.Config Model Msg
tabConfig =
    Tab.config OnTabMsg [ ( "Setores", viewSectors ), ( "Atrações", viewAttractions ) ]



--- JSON DECODER --------------------------------------------------------------


dataDecoder : D.Decoder Data
dataDecoder =
    let
        pair =
            D.list D.string
                |> D.andThen toPair

        toPair lst =
            case lst of
                [ a, b ] ->
                    D.succeed ( a, b )

                _ ->
                    D.fail "list must have exactly 2 elements"
    in
    D.map2 Data
        (D.field "sectors" (D.list pair))
        (D.field "attractions" (D.list attractionDecoder))


attractionDecoder : D.Decoder Attraction
attractionDecoder =
    D.map2 Attraction
        (D.field "title" D.string)
        (D.field "description" D.string)


httpDataRequest : RegionId -> Cmd Msg
httpDataRequest id =
    Http.get
        { url = Api.sectorList id
        , expect = Http.expectJson OnDataReceived dataDecoder
        }
