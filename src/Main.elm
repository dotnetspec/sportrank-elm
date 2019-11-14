module Main exposing (main)

import Browser exposing (Document, UrlRequest)
import Browser.Navigation as Nav
import Html exposing (..)
import Page.EditRanking as EditRanking
import Page.ListRankings as ListRankings
import Page.NewRanking as NewRanking
import Route exposing (Route)
import Url exposing (Url)


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


init : () -> Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url navKey =
    let
        model =
            { route = Route.parseUrl url
            , page = NotFoundPage
            , navKey = navKey
            }
    in
    initCurrentPage ( model, Cmd.none )


initCurrentPage : ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
initCurrentPage ( model, existingCmds ) =
    let
        ( currentPage, mappedPageCmds ) =
            case model.route of
                Route.NotFound ->
                    ( NotFoundPage, Cmd.none )

                -- This is routing the posts from the other pages
                Route.Rankings ->
                    let
                        ( pageModel, pageCmds ) =
                            ListRankings.init
                    in
                    ( ListPage pageModel, Cmd.map ListPageMsg pageCmds )

                Route.Ranking rankingId ->
                    let
                        ( pageModel, pageCmd ) =
                            EditRanking.init rankingId model.navKey
                    in
                    ( EditPage pageModel, Cmd.map EditPageMsg pageCmd )

                Route.NewRanking ->
                    let
                        ( pageModel, pageCmd ) =
                            NewRanking.init model.navKey
                    in
                    ( NewPage pageModel, Cmd.map NewPageMsg pageCmd )
    in
    --return curently selected page as model and any relevant commands
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

        ( _, _ ) ->
            ( model, Cmd.none )


type Msg
    = ListPageMsg ListRankings.Msg
    | LinkClicked UrlRequest
    | UrlChanged Url
    | EditPageMsg EditRanking.Msg
    | NewPageMsg NewRanking.Msg
