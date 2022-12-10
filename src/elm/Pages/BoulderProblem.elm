module Pages.BoulderProblem exposing (Model, Msg, entry, update, view)

{-| Example bare bones page
-}

import Config as Cfg
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Lazy exposing (lazy)
import Markdown
import Types exposing (..)
import Ui.App
import Ui.Carousel as Carousel
import Ui.Components as Ui


type alias Model =
    { id : ProblemId
    , name : Name
    , description : String
    }


type Msg
    = NoOp


entry : ProblemId -> ( Model, Cmd a )
entry id =
    ( { id = id, name = "Galego enjoado", description = "Lorem Ipsum est" }, Cmd.none )


update : Msg -> Cfg.Model -> Model -> ( Model, Cmd Msg )
update msg _ m =
    let
        return m_ =
            ( m_, Cmd.none )
    in
    case msg of
        NoOp ->
            return m


view _ m =
    let
        tags =
            [ "Foo", "Bar", "Baz" ]
    in
    Ui.App.appShell <|
        Ui.container
            [ Ui.breadcrumbs [ ( "/br", "BR" ), ( "/br/cocalzinho", "Cocalzinho" ), ( "/br/cocal/b/sectors/casa-da-cobra/", "Casa da cobra" ), ( "/br/cocal/b/sectors/casa-da-cobra/fax/", "Bloco do fax" ) ]
            , Ui.title m.name
            , Carousel.view carouselConfig [ "foo", "bar" ]
            , Ui.sections
                [ ( "Bloco", [ text "Bloco do fax" ] )
                , ( "Descrição/Saída", [ lazy (Markdown.toHtml []) m.description ] )
                , ( "Links"
                  , [ ul [ class "list-disc pl-6" ]
                        [ li [] [ a [ href "http://youtube.com/abc" ] [ text "http://youtube.com/abc" ] ]
                        , li [] [ a [ href "http://youtube.com/abcd" ] [ text "http://youtube.com/abcd" ] ]
                        ]
                    ]
                  )
                , ( "Tags", [ Ui.tags tags ] )
                ]
            ]


carouselConfig : Carousel.Config String msg
carouselConfig =
    Carousel.config
