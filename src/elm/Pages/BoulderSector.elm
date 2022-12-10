module Pages.BoulderSector exposing (Model, Msg, entry, update, view)

import Config as Cfg
import Data exposing (..)
import Dict exposing (Dict)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
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
    , name : String
    , description : String
    , access : String
    , boulderInfo : List BoulderInfo
    , blockInfo : Dict Slug BlockInfo
    , selectedBlock : String
    , tab : Tab.Model
    , map : Map.Model
    , table : Table.State
    , histogram : Histogram.Model
    }


type Msg
    = OnTabMsg Tab.Msg
    | OnMapMsg Map.Msg
    | OnHistogramMsg Histogram.Msg
    | OnTableUpdate Table.State
    | OnBlockSelect String


entry : SectorId -> ( Model, Cmd a )
entry id =
    ( { id = id
      , name = "Bloco do fax"
      , description = "Lorem Ipsum Est"
      , boulderInfo =
            [ { name = "Boulder Foo", slug = "foo", grade = "V2", block = "fax" }
            , { name = "No Bar", slug = "bar", grade = "V5", block = "fax" }
            , { name = "Blas", slug = "blas", grade = "V10", block = "fax" }
            , { name = "Burp", slug = "burp", grade = "V10", block = "block-2" }
            ]
      , blockInfo =
            Dict.fromList
                [ ( "fax", { name = "Bloco do Fax", shortName = "Fax" } )
                , ( "block-2", { name = "Bloco 2", shortName = "Bloco 2" } )
                ]
      , selectedBlock = "*"
      , access = "De carro"
      , tab = Tab.init tabConfig
      , map = Map.init
      , histogram = Histogram.init
      , table = Table.initialSort "Nome"
      }
    , Cmd.none
    )


update : Msg -> Cfg.Model -> Model -> ( Model, Cmd Msg )
update msg _ m =
    let
        return model =
            ( model, Cmd.none )
    in
    case msg of
        OnTabMsg msg_ ->
            return { m | tab = Tab.update msg_ m.tab }

        OnMapMsg msg_ ->
            return { m | map = Map.update msg_ m.map }

        OnHistogramMsg msg_ ->
            return { m | histogram = Histogram.update msg_ m.histogram }

        OnTableUpdate state ->
            return { m | table = state }

        OnBlockSelect id ->
            return { m | selectedBlock = id }


view : Cfg.Model -> Model -> Html Msg
view _ m =
    Ui.App.appShell <|
        Ui.container
            [ Ui.breadcrumbs [ ( "br", "BR" ), ( "foo", "Cocalzinho" ) ]
            , Ui.title "Setor Moco"
            , Ui.tags [ "Facil acesso", "Democratico" ]
            , Tab.view tabConfig m.tab m
            ]


viewBoulders : Model -> Html Msg
viewBoulders m =
    let
        blockItem ( id, { name } ) =
            option [ value id ] [ text name ]

        blockOptions =
            option [ disabled True, selected True ] [ text "Selecione o bloco" ]
                :: option [ value "*" ] [ text "Todos" ]
                :: List.map blockItem (Dict.toList m.blockInfo)

        blockLink =
            Route.boulderDetail (elemId m.id m.selectedBlock)
    in
    div []
        [ Html.map OnMapMsg (Map.view m.map)
        , select [ onInput OnBlockSelect, class "select select-bordered w-full mb-4" ] blockOptions
        , Ui.title m.name
        , Ui.cardList a
            Ui.Color.Primary
            (List.map
                (\{ name, slug, grade } ->
                    ( name ++ " (" ++ grade ++ ")", [ href (Route.boulderDetail (elemId m.id slug)) ] )
                )
                (getBoulders m)
            )
        , a [ class "btn w-full btn-primary my-4", href blockLink ] [ text "Ir para bloco" ]
        ]


viewInfo : Model -> Html Msg
viewInfo m =
    let
        data =
            [ ( "VB", 1 )
            , ( "V0", 2 )
            , ( "V1", 2 )
            , ( "V3", 11 )
            , ( "V4", 1 )
            , ( "V5", 4 )
            , ( "V6", 6 )
            , ( "V7", 4 )
            , ( "V8", 5 )
            , ( "V10", 2 )
            ]
    in
    Ui.sections
        [ ( "Descrição do bloco", [ text m.description ] )
        , ( "Distribuição de graus", [ Html.map OnHistogramMsg (Histogram.view m.histogram data) ] )
        , ( "Lista de problemas", [ Table.view tableConfig m.table m.boulderInfo ] )
        ]


viewAccess : Model -> Html Msg
viewAccess m =
    div []
        [ p [] [ text m.access ]
        ]


tabConfig : Tab.Config Model Msg
tabConfig =
    Tab.Config
        OnTabMsg
        [ ( "Blocos", viewBoulders )
        , ( "Sobre", viewInfo )
        , ( "Acesso", viewAccess )
        ]


tableConfig : Table.Config BoulderInfo Msg
tableConfig =
    let
        c =
            defaultCustomizations
    in
    Table.customConfig
        { toId = .slug
        , toMsg = OnTableUpdate
        , columns =
            [ Table.stringColumn "Name" .name
            , Table.stringColumn "Bloco" .block
            , Table.stringColumn "Grau" .grade
            ]
        , customizations = { c | tableAttrs = [ class "table w-full" ] }
        }


getBoulders : Model -> List BoulderInfo
getBoulders m =
    if m.selectedBlock == "*" then
        m.boulderInfo

    else
        List.filter (\info -> info.block == m.selectedBlock) m.boulderInfo
