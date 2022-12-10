module Pages.BoulderProblem exposing (Model, Msg, entry, update, view)

{-| Example bare bones page
-}

import Config as Cfg
import Html exposing (..)
import Html.Attributes exposing (..)
import Types exposing (..)
import Ui.App
import Ui.Carousel as Carousel
import Ui.Components as Ui


type alias Model =
    { id : ProblemId, carousel : Carousel.Model }


type Msg
    = OnCarouselMsg Carousel.Msg


entry : ProblemId -> ( Model, Cmd a )
entry id =
    ( { id = id, carousel = Carousel.init }, Cmd.none )


update : Msg -> Cfg.Model -> Model -> ( Model, Cmd Msg )
update msg _ m =
    let
        return m_ =
            ( m_, Cmd.none )
    in
    case msg of
        OnCarouselMsg msg_ ->
            return { m | carousel = Carousel.update msg_ m.carousel }


view _ m =
    let
        tags =
            [ "Foo", "Bar", "Baz" ]
    in
    Ui.App.appShell <|
        Ui.container
            [ Ui.breadcrumbs [ ( "/br", "BR" ), ( "/br/cocalzinho", "Cocalzinho" ), ( "/br/cocal/b/sectors/casa-da-cobra/", "Casa da cobra" ), ( "/br/cocal/b/sectors/casa-da-cobra/fax/", "Bloco do fax" ) ]
            , Ui.title "Galego Enjoado"
            , Html.map OnCarouselMsg (Carousel.view m.carousel)
            , Ui.sections
                [ ( "Bloco", [ text "Bloco do fax" ] )
                , ( "Descrição/Saída", [ text "Lorem Ipsum est" ] )
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

