module Pages.BoulderDetail exposing (Model, Msg, entry, update, view)

import Config as Cfg
import Data exposing (BoulderInfo)
import Html exposing (..)
import Html.Attributes exposing (..)
import Route
import Types exposing (..)
import Ui.Accordion as Accordion
import Ui.App
import Ui.Carousel as Carousel
import Ui.Components as Ui


type alias Model =
    { id : ElemId
    , name : String
    , carousel : Carousel.Model
    , accordion : Accordion.State
    , boulderInfo : List BoulderInfo
    }


type Msg
    = OnCarouselMsg Carousel.Msg
    | OnAccordionUpdate Accordion.State


entry : ElemId -> ( Model, Cmd a )
entry id =
    ( { id = id
      , name = "Bloco do fax"
      , carousel = Carousel.init
      , accordion = Accordion.init
      , boulderInfo =
            [ { name = "Boulder Foo", slug = "foo", grade = "V2", block = "fax" }
            , { name = "No Bar", slug = "bar", grade = "V5", block = "fax" }
            , { name = "Blas", slug = "blas", grade = "V10", block = "fax" }
            , { name = "Burp", slug = "burp", grade = "V10", block = "block-2" }
            ]
      }
    , Cmd.none
    )


update : Msg -> Cfg.Model -> Model -> ( Model, Cmd Msg )
update msg _ m =
    let
        return m_ =
            ( m_, Cmd.none )
    in
    case msg of
        OnCarouselMsg msg_ ->
            return { m | carousel = Carousel.update msg_ m.carousel }

        OnAccordionUpdate state ->
            return { m | accordion = state }


view : Cfg.Model -> Model -> Html Msg
view _ m =
    let
        info =
            List.map (\x -> ( m, x )) m.boulderInfo
    in
    Ui.App.appShell <|
        Ui.container
            [ Ui.breadcrumbs [ ( "/br", "BR" ), ( "/br/cocalzinho", "Cocalzinho" ), ( "/br/cocal/b/casa-da-cobra/", "Casa da cobra" ) ]
            , Ui.title "Bloco do Fax"
            , Html.map OnCarouselMsg (Carousel.view m.carousel)
            , Accordion.view accordionConfig m.accordion info
            ]


accordionConfig : Accordion.Config ( Model, BoulderInfo ) Msg
accordionConfig =
    Accordion.config
        { toMsg = OnAccordionUpdate
        , render =
            \( m, info ) ->
                div []
                    [ dl []
                        [ dt [] [ text "Grau:" ]
                        , dd [] [ text info.grade ]
                        , dt [] [ text "Descrição:" ]
                        , dd [] [ text "Boulder description" ]
                        ]
                    , a [ href (Route.boulderProblem (problemId m.id info.slug)), class "btn btn-primary" ] [ text "Ver detalhes" ]
                    ]
        , title = \( _, info ) -> info.name ++ " (" ++ info.grade ++ ")"
        }
