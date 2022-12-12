module Pages.BoulderSector exposing (Model, Msg, entry, httpDataRequest, update, view)

import Api
import Config as Cfg
import Data exposing (..)
import Decoder
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.Lazy exposing (lazy)
import Http
import List.Extra
import Markdown
import Route
import Table exposing (defaultCustomizations)
import Types exposing (..)
import Ui.App
import Ui.BoulderMap as Map
import Ui.Color
import Ui.Components as Ui
import Ui.Histogram as Histogram
import Ui.Tab as Tab exposing (Msg(..))


type alias Model =
    { id : SectorId
    , sector : Api.ApiResult Sector
    , selectedFormation : Maybe ElemId
    , tab : Tab.Model
    , map : Map.Model
    , table : Table.State
    , histogram : Histogram.Model
    }


type Msg
    = OnDataReceived (Result Http.Error Sector)
    | OnTabMsg Tab.Msg
    | OnMapMsg Map.Msg
    | OnHistogramMsg Histogram.Msg
    | OnTableUpdate Table.State
    | OnBlockSelect ElemId


get : (Sector -> a) -> a -> Model -> a
get attr default m =
    Result.map attr m.sector |> Result.withDefault default


entry : Cfg.Model -> SectorId -> ( Model, Cmd Msg )
entry cfg id =
    ( { id = id
      , sector = Err Nothing
      , selectedFormation = Nothing
      , tab = Tab.init tabConfig
      , map = Map.init
      , table = Table.initialSort "Nome"
      , histogram = Histogram.init
      }
    , httpDataRequest OnDataReceived cfg id
    )


update : Msg -> Cfg.Model -> Model -> ( Model, Cmd Msg )
update msg _ m =
    let
        return model =
            ( model, Cmd.none )
    in
    case msg of
        OnDataReceived (Ok data) ->
            return { m | sector = Api.resultFromData data }

        OnDataReceived (Err e) ->
            return { m | sector = Api.resultFromError e }

        OnTabMsg msg_ ->
            return { m | tab = Tab.update msg_ m.tab }

        OnMapMsg msg_ ->
            return { m | map = Map.update msg_ m.map }

        OnHistogramMsg msg_ ->
            return { m | histogram = Histogram.update msg_ m.histogram }

        OnTableUpdate state ->
            return { m | table = state }

        OnBlockSelect id ->
            return { m | selectedFormation = Just id }


view : Cfg.Model -> Model -> Html Msg
view _ m =
    let
        ( regionId, _ ) =
            splitSectorId m.id

        ( countryId, _ ) =
            splitRegionId regionId
    in
    Ui.App.appShell <|
        Ui.container
            [ Ui.breadcrumbs
                [ ( Route.country countryId, String.toUpper countryId )
                , ( Route.region regionId, get .regionName (regionSlug regionId) m )
                ]
            , Ui.title "Setor Moco"
            , Ui.tags [ "Facil acesso", "Democratico" ]
            , Tab.view tabConfig m.tab m
            ]


viewBoulders : Model -> Html Msg
viewBoulders m =
    Ui.App.viewLoadingResult m.sector <|
        \sector ->
            let
                blockItem { id, name } =
                    option [ value (elemSlug id) ] [ text name ]

                blockOptions =
                    option [ disabled True, selected True ] [ text "Selecione o bloco" ]
                        :: option [ value "*" ] [ text "Todos" ]
                        :: List.map blockItem sector.boulderFormations

                blockLink =
                    m.selectedFormation
                        |> Maybe.map
                            (\x ->
                                a [ class "btn w-full btn-primary my-4", href (Route.boulderDetail x) ] [ text "Ir para bloco" ]
                            )
                        |> Maybe.withDefault (div [] [])
            in
            div []
                [ Html.map OnMapMsg (Map.view m.map)
                , select [ onInput (OnBlockSelect << elemId m.id), class "select select-bordered w-full mb-4" ] blockOptions
                , Ui.title sector.name
                , Ui.cardList a
                    Ui.Color.Primary
                    (List.map
                        (\( { id }, { name, grade } ) ->
                            ( name ++ " (" ++ grade ++ ")", [ href (Route.boulderDetail id) ] )
                        )
                        (getBoulderProblems m)
                    )
                , blockLink
                ]


viewInfo : Model -> Html Msg
viewInfo m =
    Ui.App.viewLoadingResult m.sector <|
        \sector ->
            let
                problems =
                    getBoulderProblems m

                histData =
                    problems
                        |> List.map (Tuple.second >> .grade)
                        |> List.Extra.frequencies
                        |> List.map (\( x, y ) -> ( x, toFloat y ))
            in
            Ui.sections
                [ ( "Descrição do bloco", [ lazy (Markdown.toHtml []) sector.description ] )
                , ( "Distribuição de graus", [ Html.map OnHistogramMsg (Histogram.view m.histogram histData) ] )
                , ( "Lista de problemas", [ Table.view tableConfig m.table problems ] )
                ]


viewAccess : Model -> Html Msg
viewAccess m =
    Ui.App.viewLoadingResult m.sector <|
        \sector ->
            div []
                [ p [] [ text sector.howToAccess ] ]


tabConfig : Tab.Config Model Msg
tabConfig =
    Tab.Config
        OnTabMsg
        [ ( "Blocos", viewBoulders )
        , ( "Sobre", viewInfo )
        , ( "Acesso", viewAccess )
        ]


tableConfig : Table.Config ( BoulderFormation, BoulderProblem ) Msg
tableConfig =
    Table.customConfig
        { toId = Tuple.second >> .name
        , toMsg = OnTableUpdate
        , columns =
            [ Table.stringColumn "Name" (Tuple.second >> .name)
            , Table.stringColumn "Bloco" (Tuple.first >> .name)
            , Table.stringColumn "Grau" (Tuple.second >> .grade)
            ]
        , customizations = { defaultCustomizations | tableAttrs = [ class "table w-full" ] }
        }


getBoulderProblems : Model -> List ( BoulderFormation, BoulderProblem )
getBoulderProblems m =
    case m.selectedFormation of
        Nothing ->
            Result.map .boulderFormations m.sector
                |> Result.withDefault []
                |> List.map (\x -> List.map (Tuple.pair x) x.problems)
                |> List.concat

        Just id ->
            Result.map .boulderFormations m.sector
                |> Result.withDefault []
                |> List.filter (.id >> (==) id)
                |> List.map (\x -> List.map (Tuple.pair x) x.problems)
                |> List.concat


httpDataRequest : (Result Http.Error Sector -> msg) -> Cfg.Model -> SectorId -> Cmd msg
httpDataRequest msg cfg id =
    Http.get
        { url = Api.boulderSector cfg id
        , expect = Http.expectJson msg Decoder.sector
        }
