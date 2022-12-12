module Pages.BoulderProblem exposing (Model, Msg, entry, update, view)

{-| Example bare bones page
-}

import Api
import Config as Cfg
import Data exposing (BoulderProblem, Sector)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Lazy exposing (lazy)
import Http
import Markdown
import Pages.BoulderFormation exposing (getFormation)
import Pages.BoulderSector exposing (httpDataRequest)
import Types exposing (..)
import Ui.App
import Ui.Carousel as Carousel
import Ui.Components as Ui


type alias Model =
    { id : ProblemId
    , problem : Api.ApiResult BoulderProblem
    }


type Msg
    = OnDataReceived (Result Http.Error Sector)


entry : Cfg.Model -> ProblemId -> ( Model, Cmd Msg )
entry cfg id =
    ( { id = id
      , problem = Err Nothing
      }
    , httpDataRequest OnDataReceived cfg (getSectorId id)
    )


update : Msg -> Model -> Model
update msg m =
    case msg of
        OnDataReceived (Ok sector) ->
            { m
                | problem =
                    getFormation (getFormationId m.id) sector.boulderFormations
                        |> Maybe.andThen (.problems >> getProblem m.id)
                        |> Maybe.map Api.resultFromData
                        |> Maybe.withDefault (Api.resultFromMsg "Bloco não encontrado")
            }

        OnDataReceived (Err e) ->
            { m | problem = Api.resultFromError e }


view : Cfg.Model -> Model -> Html Msg
view _ m =
    Ui.App.appShell <|
        Ui.App.viewLoadingResult m.problem <|
            \problem ->
                let
                    tags =
                        [ "??", "??", "??" ]
                in
                Ui.container
                    [ Ui.breadcrumbs [ ( "/br", "BR" ), ( "/br/cocalzinho", "Cocalzinho" ), ( "/br/cocal/b/sectors/casa-da-cobra/", "Casa da cobra" ), ( "/br/cocal/b/sectors/casa-da-cobra/fax/", "Bloco do fax" ) ]
                    , Ui.title problem.name
                    , Carousel.view carouselConfig [ "??", "??" ]
                    , Ui.sections
                        [ ( "Bloco", [ text "Bloco do ??" ] )
                        , ( "Descrição/Saída", [ lazy (Markdown.toHtml []) problem.description ] )
                        , ( "Links"
                          , [ ul [ class "list-disc pl-6" ]
                                [ li [] [ a [ href "http://youtube.com/abc" ] [ text "http://youtube.com/??" ] ]
                                , li [] [ a [ href "http://youtube.com/abcd" ] [ text "http://youtube.com/??" ] ]
                                ]
                            ]
                          )
                        , ( "Tags", [ Ui.tags tags ] )
                        ]
                    ]


carouselConfig : Carousel.Config String msg
carouselConfig =
    Carousel.config


getFormationId : ProblemId -> ElemId
getFormationId =
    splitProblemId >> Tuple.first


getProblem : ProblemId -> List BoulderProblem -> Maybe BoulderProblem
getProblem id xs =
    case xs of
        y :: ys ->
            if y.id == id then
                Just y

            else
                getProblem id ys

        [] ->
            Nothing


getSectorId : ProblemId -> SectorId
getSectorId =
    splitProblemId >> Tuple.first >> splitElemId >> Tuple.first
