module Main exposing (main)

import Browser
import Browser.Navigation as Nav
import Config as Cfg
import Html exposing (Html, div, text)
import Json.Encode exposing (Value)
import Pages.BoulderDetail as BoulderDetail
import Pages.BoulderProblem as BoulderProblem
import Pages.BoulderSector as BoulderSector
import Pages.GpsTool as GpsTool
import Pages.GradeTool as GradeTool
import Pages.Home as Home
import Pages.Parking as Parking
import Pages.Region as Region
import Pages.RouteDetail as RouteDetail
import Pages.RouteSector as RouteSector
import Route exposing (Route(..), parseUrl)
import Types exposing (..)
import Url exposing (Url)


type Page
    = HomePage Home.Model
    | ParkingPage Parking.Model
    | RegionPage Region.Model
    | BoulderSectorPage BoulderSector.Model
    | BoulderDetailPage BoulderDetail.Model
    | BoulderProblemPage BoulderProblem.Model
    | RouteSectorPage RouteSector.Model
    | RouteDetailPage RouteDetail.Model
    | GpsToolPage GpsTool.Model
    | GradeToolPage GradeTool.Model
    | ErrorPage RegionId


type alias Model =
    { page : Page
    , cfg : Cfg.Model
    }


type Msg
    = OnPushUrl String
    | OnUrlChange Url
    | OnUrlRequest Browser.UrlRequest
    | OnConfigMsg Cfg.Msg
    | OnHomeMsg Home.Msg
    | OnRegionMsg Region.Msg
    | OnBoulderSectorMsg BoulderSector.Msg
    | OnBoulderDetailMsg BoulderDetail.Msg
    | OnBoulderProblemMsg BoulderProblem.Msg
    | OnRouteSectorMsg RouteSector.Msg
    | OnRouteDetailMsg RouteDetail.Msg
    | OnParkingMsg Parking.Msg
    | OnGpsToolMsg GpsTool.Msg
    | OnGradeToolMsg GradeTool.Msg
    | NoOp


pageFromRoute : Route -> Cfg.Model -> ( Model, Cmd Msg )
pageFromRoute r cfg =
    let
        page wrap msg ( m, cmd ) =
            ( { page = wrap m, cfg = cfg }, Cmd.map msg cmd )
    in
    case r of
        Home ->
            page HomePage OnHomeMsg (Home.entry cfg)

        Region id ->
            page RegionPage OnRegionMsg (Region.entry id)

        BoulderSector req ->
            page BoulderSectorPage OnBoulderSectorMsg (BoulderSector.entry req)

        BoulderDetail req ->
            page BoulderDetailPage OnBoulderDetailMsg (BoulderDetail.entry req)

        BoulderProblem req ->
            page BoulderProblemPage OnBoulderProblemMsg (BoulderProblem.entry req)

        RouteSector req ->
            page RouteSectorPage OnRouteSectorMsg (RouteSector.entry req)

        RouteDetail req ->
            page RouteDetailPage OnRouteDetailMsg (RouteDetail.entry req)

        Parking req ->
            page ParkingPage OnParkingMsg (Parking.entry req)

        GpsTool ->
            page GpsToolPage OnGpsToolMsg GpsTool.entry

        GradeTool ->
            page GradeToolPage OnGradeToolMsg GradeTool.entry

        Error msg ->
            page ErrorPage (\_ -> NoOp) ( msg, Cmd.none )



-- _ ->
--     ( { page = ErrorPage "not implemented", cfg = cfg }, Cmd.none )


init : Cfg.Model -> Model
init cfg =
    Tuple.first <| pageFromRoute Home cfg


view : Model -> Html Msg
view model =
    case model.page of
        HomePage m ->
            Html.map OnHomeMsg (Home.view m)

        RegionPage m ->
            Html.map OnRegionMsg (Region.view model.cfg m)

        BoulderSectorPage m ->
            Html.map OnBoulderSectorMsg (BoulderSector.view model.cfg m)

        BoulderDetailPage m ->
            Html.map OnBoulderDetailMsg (BoulderDetail.view model.cfg m)

        BoulderProblemPage m ->
            Html.map OnBoulderProblemMsg (BoulderProblem.view model.cfg m)

        RouteSectorPage m ->
            Html.map OnRouteSectorMsg (RouteSector.view model.cfg m)

        RouteDetailPage m ->
            Html.map OnRouteDetailMsg (RouteDetail.view model.cfg m)

        ParkingPage m ->
            Html.map OnParkingMsg (Parking.view m)

        GpsToolPage m ->
            Html.map OnGpsToolMsg (GpsTool.view m)

        GradeToolPage m ->
            Html.map OnGradeToolMsg (GradeTool.view m)

        ErrorPage st ->
            div [] [ text ("ERROR :" ++ st) ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg_ m_ =
    let
        cfg =
            m_.cfg

        page m1 p m2 cmd =
            ( { m_ | page = m1 p }, Cmd.map m2 cmd )
    in
    case ( msg_, m_.page ) of
        -- Routing and generic navigation
        ( OnPushUrl st, _ ) ->
            ( m_, Cfg.pushUrl st cfg )

        ( OnUrlRequest (Browser.Internal url), _ ) ->
            update (OnPushUrl (Url.toString url)) m_

        ( OnUrlRequest (Browser.External url), _ ) ->
            ( m_, Nav.load url )

        ( OnUrlChange url, _ ) ->
            pageFromRoute (parseUrl url) cfg

        -- Redirect to appropriate sub-model
        ( OnHomeMsg msg, HomePage m ) ->
            let
                ( new, cmd ) =
                    Home.update msg m
            in
            page HomePage new OnHomeMsg cmd

        ( OnRegionMsg msg, RegionPage m ) ->
            let
                ( new, cmd ) =
                    Region.update msg cfg m
            in
            page RegionPage new OnRegionMsg cmd

        ( OnBoulderSectorMsg msg, BoulderSectorPage m ) ->
            let
                ( new, cmd ) =
                    BoulderSector.update msg cfg m
            in
            page BoulderSectorPage new OnBoulderSectorMsg cmd

        ( OnBoulderDetailMsg msg, BoulderDetailPage m ) ->
            let
                ( new, cmd ) =
                    BoulderDetail.update msg cfg m
            in
            page BoulderDetailPage new OnBoulderDetailMsg cmd

        ( OnRouteSectorMsg msg, RouteSectorPage m ) ->
            let
                ( new, cmd ) =
                    RouteSector.update msg cfg m
            in
            page RouteSectorPage new OnRouteSectorMsg cmd

        ( OnRouteDetailMsg msg, RouteDetailPage m ) ->
            let
                ( new, cmd ) =
                    RouteDetail.update msg cfg m
            in
            page RouteDetailPage new OnRouteDetailMsg cmd

        ( OnGpsToolMsg msg, GpsToolPage m ) ->
            let
                ( new, cmd ) =
                    GpsTool.update msg m
            in
            page GpsToolPage new OnGpsToolMsg cmd

        ( OnGradeToolMsg msg, GradeToolPage m ) ->
            let
                ( new, cmd ) =
                    GradeTool.update msg m
            in
            page GradeToolPage new OnGradeToolMsg cmd

        -- Internal state and other global tasks
        ( OnConfigMsg msg, _ ) ->
            let
                ( cfg_, cmd ) =
                    Cfg.update msg cfg
            in
            ( { m_ | cfg = cfg_ }, Cmd.map OnConfigMsg cmd )

        ( NoOp, _ ) ->
            ( m_, Cmd.none )

        _ ->
            ( m_, Cmd.none )


main : Program Value Model Msg
main =
    let
        initFn _ url key =
            update (OnUrlChange url) (init (Cfg.init key))
    in
    Browser.application
        { init = initFn
        , update = update
        , subscriptions = \_ -> Sub.batch []
        , onUrlRequest = OnUrlRequest
        , onUrlChange = OnUrlChange
        , view = \m -> Browser.Document "Croq.app" [ view m ]
        }
