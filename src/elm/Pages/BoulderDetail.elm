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
    , accordion : Accordion.State
    , boulderInfo : List BoulderInfo
    }


type Msg
    = OnAccordionUpdate Accordion.State


entry : ElemId -> ( Model, Cmd a )
entry id =
    ( { id = id
      , name = "Bloco do fax"
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
            [ Ui.breadcrumbs [ ( "/br", "BR" ), ( "/br/cocalzinho/b/sectors/", "Cocalzinho" ), ( "/br/cocal/b/sectors/casa-da-cobra/", "Casa da cobra" ) ]
            , Ui.title "Bloco do Fax"
            , Carousel.view carouselConfig [ "foo", "bar", "baz" ]
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
                    , a [ href (Route.boulderProblem (problemId m.id info.slug)), class "btn glass w-full btn-accent" ] [ text "Ver detalhes" ]
                    ]
        , title = \( _, info ) -> info.name ++ " (" ++ info.grade ++ ")"
        }


carouselConfig : Carousel.Config String msg
carouselConfig =
    Carousel.config
