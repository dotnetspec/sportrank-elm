module Page.ViewRanking exposing (Model, Msg, init, update, view)

import Browser.Navigation as Nav
import Error exposing (buildErrorMessage)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Http
import Ranking exposing (Ranking, RankingId(..), rankingDecoder, rankingEncoder)
import RemoteData exposing (WebData)
import Route


type alias Model =
    { navKey : Nav.Key
    , ranking : WebData Ranking
    , saveError : Maybe String
    }


init : RankingId -> Nav.Key -> ( Model, Cmd Msg )
init postId navKey =
    let
        _ =
            Debug.log "made it to viewRanking"
    in
    ( initialModel navKey, fetchPost postId )


initialModel : Nav.Key -> Model
initialModel navKey =
    { navKey = navKey
    , ranking = RemoteData.Loading
    , saveError = Nothing
    }


fetchPost : RankingId -> Cmd Msg
fetchPost (RankingId postId) =
    -- Http.get
    --     { url = "https://api.jsonbin.io/b/" ++ postId ++ "/latest"
    --     , expect =
    --         rankingDecoder
    --             |> Http.expectJson (RemoteData.fromResult >> PostReceived)
    --     }
    let
        _ =
            Debug.log "rankingid in fetchPost" postId

        headerKey =
            Http.header
                "secret-key"
                "$2a$10$HIPT9LxAWxYFTW.aaMUoEeIo2N903ebCEbVqB3/HEOwiBsxY3fk2i"
    in
    Http.request
        { body = Http.emptyBody
        , expect =
            rankingDecoder
                |> Http.expectJson (RemoteData.fromResult >> PostReceived)
        , headers = [ headerKey ]
        , method = "GET"
        , timeout = Nothing
        , tracker = Nothing
        , url = "https://api.jsonbin.io/b/" ++ postId ++ "/latest"
        }


type Msg
    = PostReceived (WebData Ranking)
    | UpdateTitle Bool
    | UpdateAuthorName String
    | UpdateAuthorUrl String
    | SavePost
    | PostSaved (Result Http.Error Ranking)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        PostReceived post ->
            ( { model | ranking = post }, Cmd.none )

        UpdateTitle newTitle ->
            let
                updateTitle =
                    RemoteData.map
                        (\postData ->
                            { postData | active = newTitle }
                        )
                        model.ranking
            in
            ( { model | ranking = updateTitle }, Cmd.none )

        UpdateAuthorName newName ->
            let
                updateAuthorName =
                    RemoteData.map
                        (\postData ->
                            { postData | name = newName }
                        )
                        model.ranking
            in
            ( { model | ranking = updateAuthorName }, Cmd.none )

        UpdateAuthorUrl newUrl ->
            let
                updateAuthorUrl =
                    RemoteData.map
                        (\postData ->
                            { postData | desc = newUrl }
                        )
                        model.ranking
            in
            ( { model | ranking = updateAuthorUrl }, Cmd.none )

        SavePost ->
            ( model, savePost model.ranking )

        PostSaved (Ok postData) ->
            let
                post =
                    RemoteData.succeed postData
            in
            ( { model | ranking = post, saveError = Nothing }
            , --Route.pushUrl Route.ViewRanking model.navKey
              Cmd.none
            )

        PostSaved (Err error) ->
            ( { model | saveError = Just (buildErrorMessage error) }
            , Cmd.none
            )


savePost : WebData Ranking -> Cmd Msg
savePost post =
    case post of
        RemoteData.Success postData ->
            let
                postUrl =
                    "http://localhost:5019/posts/"
                        ++ "Ranking.idToString"
                        ++ postData.id
            in
            Http.request
                { method = "PATCH"
                , headers = []
                , url = postUrl
                , body = Http.jsonBody (rankingEncoder postData)
                , expect = Http.expectJson PostSaved rankingDecoder
                , timeout = Nothing
                , tracker = Nothing
                }

        _ ->
            Cmd.none


view : Model -> Html Msg
view model =
    div []
        [ h3 [] [ text "View Ranking" ]
        , viewRanking model.ranking
        , viewSaveError model.saveError
        ]


viewRanking : WebData Ranking -> Html Msg
viewRanking post =
    case post of
        RemoteData.NotAsked ->
            text ""

        RemoteData.Loading ->
            h3 [] [ text "Loading Ranking..." ]

        RemoteData.Success postData ->
            editForm postData

        RemoteData.Failure httpError ->
            viewFetchError (buildErrorMessage httpError)


editForm : Ranking -> Html Msg
editForm post =
    Html.form []
        [ div []
            [ text "Title"
            , br [] []
            , input
                [ type_ "text"
                , value post.name

                --, onInput (boolToString UpdateTitle)
                ]
                []
            ]
        , br [] []
        , div []
            [ text "Author Name"
            , br [] []
            , input
                [ type_ "text"
                , value post.name
                , onInput UpdateAuthorName
                ]
                []
            ]
        , br [] []
        , div []
            [ text "Author URL"
            , br [] []
            , input
                [ type_ "text"
                , value post.desc
                , onInput UpdateAuthorUrl
                ]
                []
            ]
        , br [] []
        , div []
            [ button [ type_ "button", onClick SavePost ]
                [ text "Submit" ]
            ]
        ]


viewFetchError : String -> Html Msg
viewFetchError errorMessage =
    let
        errorHeading =
            "Couldn't fetch post at this time."
    in
    div []
        [ h3 [] [ text errorHeading ]
        , text ("Error: " ++ errorMessage)
        ]


viewSaveError : Maybe String -> Html msg
viewSaveError maybeError =
    case maybeError of
        Just error ->
            div []
                [ h3 [] [ text "Couldn't save post at this time." ]
                , text ("Error: " ++ error)
                ]

        Nothing ->
            text ""
