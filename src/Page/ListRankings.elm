module Page.ListRankings exposing (Model, Msg, init, update, view)

import Error exposing (buildErrorMessage)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Http
import Json.Decode as Decode
import Ranking exposing (Ranking, RankingId, postsDecoder)
import RemoteData exposing (WebData)


type alias Model =
    { posts : WebData (List Ranking)
    , deleteError : Maybe String
    }


type Msg
    = FetchRankings
    | PostsReceived (WebData (List Ranking))
    | DeletePost RankingId
    | PostDeleted (Result Http.Error String)


init : ( Model, Cmd Msg )
init =
    ( initialModel, fetchRankings )


initialModel : Model
initialModel =
    { posts = RemoteData.Loading
    , deleteError = Nothing
    }


fetchRankings : Cmd Msg
fetchRankings =
    Http.get
        { url = "http://localhost:5019/posts/"
        , expect =
            postsDecoder
                |> Http.expectJson (RemoteData.fromResult >> PostsReceived)
        }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        FetchRankings ->
            ( { model | posts = RemoteData.Loading }, fetchRankings )

        PostsReceived response ->
            ( { model | posts = response }, Cmd.none )

        DeletePost postId ->
            ( model, deletePost postId )

        PostDeleted (Ok _) ->
            ( model, fetchRankings )

        PostDeleted (Err error) ->
            ( { model | deleteError = Just (buildErrorMessage error) }
            , Cmd.none
            )


deletePost : RankingId -> Cmd Msg
deletePost postId =
    Http.request
        { method = "DELETE"
        , headers = []
        , url = "http://localhost:5019/posts/" ++ Ranking.idToString postId
        , body = Http.emptyBody
        , expect = Http.expectString PostDeleted
        , timeout = Nothing
        , tracker = Nothing
        }



-- VIEWS


view : Model -> Html Msg
view model =
    div []
        [ span []
            [ text "All Ranking Lists" ]
        , br [] []
        , br [] []
        , button [ onClick FetchRankings ]
            [ text "Refresh posts" ]
        , br [] []
        , br [] []
        , a [ href "/posts/new" ]
            [ text "Create new post" ]
        , viewPosts model.posts
        , viewDeleteError model.deleteError
        ]


viewPosts : WebData (List Ranking) -> Html Msg
viewPosts posts =
    case posts of
        RemoteData.NotAsked ->
            text ""

        RemoteData.Loading ->
            h3 [] [ text "Loading..." ]

        RemoteData.Success actualPosts ->
            div []
                [ h3 [] [ text "Posts" ]
                , table []
                    ([ viewTableHeader ] ++ List.map viewPost actualPosts)
                ]

        RemoteData.Failure httpError ->
            viewFetchError (buildErrorMessage httpError)


viewTableHeader : Html Msg
viewTableHeader =
    tr []
        [ th []
            [ text "ID" ]
        , th []
            [ text "Title" ]
        , th []
            [ text "Author" ]
        ]


viewPost : Ranking -> Html Msg
viewPost post =
    let
        postPath =
            "/posts/" ++ Ranking.idToString post.id
    in
    tr []
        [ td [ hidden True ]
            [ text (Ranking.idToString post.id) ]
        , td []
            [ text post.title ]
        , td []
            [ a [ href post.authorUrl ] [ text post.authorName ] ]
        , td []
            [ a [ href postPath ] [ text "Edit" ] ]
        , td []
            [ button [ type_ "button", onClick (DeletePost post.id) ]
                [ text "Delete" ]
            ]
        ]


viewFetchError : String -> Html Msg
viewFetchError errorMessage =
    let
        errorHeading =
            "Couldn't fetch posts at this time."
    in
    div []
        [ h3 [] [ text errorHeading ]
        , text ("Error: " ++ errorMessage)
        ]


viewDeleteError : Maybe String -> Html msg
viewDeleteError maybeError =
    case maybeError of
        Just error ->
            div []
                [ h3 [] [ text "Couldn't delete post at this time." ]
                , text ("Error: " ++ error)
                ]

        Nothing ->
            text ""
