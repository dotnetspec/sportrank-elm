module Main exposing (main)

import Browser exposing (Document, UrlRequest)
import Browser.Navigation as Nav
import Html exposing (..)
import Page.EditRanking as EditRanking
import Page.ListRankings as ListRankings
import Page.NewRanking as NewRanking
import Page.ViewRanking as ViewRanking
import Ranking exposing (..)
import Route exposing (Route, matchRouteParser)
import Url exposing (Url)
import Url.Parser as Parser exposing ((</>))


main : Program () Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        , onUrlRequest = LinkClicked
        , onUrlChange = UrlChanged
        }


type alias Model =
    { route : Route
    , page : Page
    , navKey : Nav.Key
    }


type Page
    = NotFoundPage
    | ListPage ListRankings.Model
    | EditPage EditRanking.Model
    | NewPage NewRanking.Model
    | ViewPage ViewRanking.Model


init : () -> Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url navKey =
    let
        _ =
            Debug.log "url" url

        parsedUrl =
            Parser.parse matchRouteParser url

        _ =
            Debug.log "parsed url" parsedUrl

        parts =
            Debug.log "parts" (String.split "/" url.path)

        rankingid =
            case
                List.reverse parts |> List.head
            of
                Nothing ->
                    Nothing

                Just rnkid ->
                    Just (RankingId rnkid)

        _ =
            Debug.log "rankingid" rankingid

        model =
            { route = Route.parseUrl url
            , page = NotFoundPage
            , navKey = navKey
            }
    in
    initCurrentPage ( model, Cmd.none )


initCurrentPage : ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
initCurrentPage ( model, existingCmds ) =
    -- the 'let' at this level will enable the assignment of each of the
    -- different page models (currentPage) and their assoc commands (mappedPageCmds)
    let
        ( currentPage, mappedPageCmds ) =
            case model.route of
                Route.NotFound ->
                    ( NotFoundPage, Cmd.none )

                -- This is routing the posts from the other pages
                Route.ListRankings ->
                    -- the 'let' at this sub level actually assigns the relevant pageModel
                    -- the 'in' just returns the (Model, Cmd Msg) as per the annotation
                    let
                        ( pageModel, pageCmds ) =
                            ListRankings.init
                    in
                    ( ListPage pageModel, Cmd.map ListPageMsg pageCmds )

                Route.Ranking rankingId ->
                    let
                        ( pageModel, pageCmd ) =
                            EditRanking.init (RankingId rankingId) model.navKey
                    in
                    ( EditPage pageModel, Cmd.map EditPageMsg pageCmd )

                Route.NewRanking rankingId ->
                    let
                        ( pageModel, pageCmd ) =
                            NewRanking.init model.navKey
                    in
                    ( NewPage pageModel, Cmd.map NewPageMsg pageCmd )

                Route.ViewRanking rankingId ->
                    let
                        ( pageModel, pageCmd ) =
                            ViewRanking.init (RankingId rankingId) model.navKey
                    in
                    ( ViewPage pageModel, Cmd.map ViewPageMsg pageCmd )
    in
    --return curently selected page as model and any relevant commands
    -- as per annotation
    ( { model | page = currentPage }
    , Cmd.batch [ existingCmds, mappedPageCmds ]
    )



-- Whenever the main model is changed,
-- the Elm runtime will automatically call the view function in Main to get the view code for the new current page


view : Model -> Document Msg
view model =
    { title = "SportRank"
    , body = [ currentView model ]
    }


currentView : Model -> Html Msg
currentView model =
    case model.page of
        NotFoundPage ->
            notFoundView

        ListPage pageModel ->
            ListRankings.view pageModel
                |> Html.map ListPageMsg

        EditPage pageModel ->
            EditRanking.view pageModel
                |> Html.map EditPageMsg

        NewPage pageModel ->
            NewRanking.view pageModel
                |> Html.map NewPageMsg

        ViewPage pageModel ->
            ViewRanking.view pageModel
                |> Html.map ViewPageMsg


notFoundView : Html msg
notFoundView =
    h3 [] [ text "Oops! The page you requested was not found!" ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model.page ) of
        ( ListPageMsg subMsg, ListPage pageModel ) ->
            let
                ( updatedPageModel, updatedCmd ) =
                    ListRankings.update subMsg pageModel
            in
            ( { model | page = ListPage updatedPageModel }
            , Cmd.map ListPageMsg updatedCmd
            )

        --Clicking a link produces a ClickLink message (that will update model) that carries a UrlRequest value.
        ( LinkClicked urlRequest, _ ) ->
            case urlRequest of
                Browser.Internal url ->
                    ( model
                    , Nav.pushUrl model.navKey (Url.toString url)
                    )

                Browser.External url ->
                    ( model
                    , Nav.load url
                    )

        --When the URL actually changes, update receives a ChangeUrl message with the new URL
        --We apply Route.parseUrl (which uses matchRouteParser) to that URL and store the route in the model.
        ( UrlChanged url, _ ) ->
            let
                newRoute =
                    Route.parseUrl url
            in
            ( { model | route = newRoute }, Cmd.none )
                |> initCurrentPage

        ( EditPageMsg subMsg, EditPage pageModel ) ->
            let
                ( updatedPageModel, updatedCmd ) =
                    EditRanking.update subMsg pageModel
            in
            ( { model | page = EditPage updatedPageModel }
            , Cmd.map EditPageMsg updatedCmd
            )

        ( NewPageMsg subMsg, NewPage pageModel ) ->
            let
                ( updatedPageModel, updatedCmd ) =
                    NewRanking.update subMsg pageModel
            in
            ( { model | page = NewPage updatedPageModel }
            , Cmd.map NewPageMsg updatedCmd
            )

        ( ViewPageMsg subMsg, ViewPage pageModel ) ->
            let
                ( updatedPageModel, updatedCmd ) =
                    ViewRanking.update subMsg pageModel
            in
            ( { model | page = ViewPage updatedPageModel }
            , Cmd.map ViewPageMsg updatedCmd
            )

        ( _, _ ) ->
            ( model, Cmd.none )


type Msg
    = ListPageMsg ListRankings.Msg
    | LinkClicked UrlRequest
    | UrlChanged Url
    | EditPageMsg EditRanking.Msg
    | NewPageMsg NewRanking.Msg
    | ViewPageMsg ViewRanking.Msg
