module Pages.BoulderFormation exposing (Model, Msg, entry, getFormation, getSectorId, update, view)

import Api
import Config as Cfg
import Data exposing (BoulderFormation, BoulderProblem, Sector)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Lazy exposing (lazy)
import Http
import Markdown
import Pages.BoulderSector exposing (httpDataRequest)
import Route
import Types exposing (..)
import Ui.Accordion as Accordion
import Ui.App
import Ui.Carousel as Carousel
import Ui.Components as Ui


type alias Model =
    { id : ElemId
    , formation : Api.ApiResult BoulderFormation
    , accordion : Accordion.State
    }


type Msg
    = OnDataReceived (Result Http.Error Sector)
    | OnAccordionUpdate Accordion.State


entry : Cfg.Model -> ElemId -> ( Model, Cmd Msg )
entry cfg id =
    ( { id = id
      , formation = Err Nothing
      , accordion = Accordion.init
      }
    , httpDataRequest OnDataReceived cfg (getSectorId id)
    )


update : Msg -> Cfg.Model -> Model -> ( Model, Cmd Msg )
update msg _ m =
    let
        return m_ =
            ( m_, Cmd.none )
    in
    case msg of
        OnDataReceived (Ok data) ->
            return
                { m
                    | formation =
                        case getFormation m.id data.boulderFormations of
                            Just formation ->
                                Api.resultFromData formation

                            _ ->
                                Api.resultFromMsg "Bloco não encontrado"
                }

        OnDataReceived (Err e) ->
            return { m | formation = Api.resultFromError e }

        OnAccordionUpdate state ->
            return { m | accordion = state }


getFormation : ElemId -> List BoulderFormation -> Maybe BoulderFormation
getFormation id xs =
    case xs of
        y :: ys ->
            if y.id == id then
                Just y

            else
                getFormation id ys

        [] ->
            Nothing


view : Cfg.Model -> Model -> Html Msg
view _ m =
    let
        info =
            List.map (\x -> ( m, x )) (Result.map .problems m.formation |> Result.withDefault [])
    in
    Ui.App.appShell <|
        Ui.container
            [ Ui.breadcrumbs [ ( "/br", "BR" ), ( "/br/cocalzinho/b/sectors/", "Cocalzinho" ), ( "/br/cocal/b/sectors/casa-da-cobra/", "Casa da cobra" ) ]
            , Ui.title "Bloco do Fax"
            , Carousel.view carouselConfig [ "foo", "bar", "baz" ]
            , Accordion.view accordionConfig m.accordion info
            ]


accordionConfig : Accordion.Config ( Model, BoulderProblem ) Msg
accordionConfig =
    Accordion.config
        { toMsg = OnAccordionUpdate
        , render =
            \( _, problem ) ->
                div []
                    [ dl []
                        [ dt [] [ text "Grau:" ]
                        , dd [] [ text problem.grade ]
                        , dt [] [ text "Descrição:" ]
                        , dd [] [ lazy (Markdown.toHtml []) problem.description ]
                        ]
                    , a [ href (Route.boulderProblem problem.id), class "btn glass w-full btn-accent" ] [ text "Ver detalhes" ]
                    ]
        , title = \( _, info ) -> info.name ++ " (" ++ info.grade ++ ")"
        }


carouselConfig : Carousel.Config String msg
carouselConfig =
    Carousel.config


getSectorId : ElemId -> SectorId
getSectorId =
    splitElemId >> Tuple.first
