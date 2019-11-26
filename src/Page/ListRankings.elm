module Page.ListRankings exposing (Model, Msg, init, update, view)

import Error exposing (buildErrorMessage)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Http
import Json.Decode as Decode
import Ranking exposing (Ranking, RankingId(..), rankingIdToString, rankingsDecoder)
import RemoteData exposing (WebData)
import Route exposing (Route, matchRouteParser)
import Url exposing (Url)
import Url.Parser as Parser exposing ((</>))


type alias Model =
    { rankings : WebData (List Ranking)
    , ranking : Ranking
    , deleteError : Maybe String
    }



-- these Msg types get sent to update e.g. onClick


type Msg
    = FetchRankings
    | RankingsReceived (WebData (List Ranking))
    | DeleteRanking RankingId
    | RankingDeleted (Result Http.Error String)
    | ViewRanking Ranking
    | ViewRankingResult (Result Http.Error String)


init : ( Model, Cmd Msg )
init =
    ( initialModel, fetchRankings )



-- set initial model values here


initialModel : Model
initialModel =
    { rankings = RemoteData.Loading
    , ranking =
        { id = ""
        , active = True
        , name = "Initial"
        , desc = "Initial"
        }
    , deleteError = Nothing
    }


fetchRankings : Cmd Msg
fetchRankings =
    Http.get
        { url = "https://api.jsonbin.io/b/5c36f5422c87fa27306acb52/latest"
        , expect =
            rankingsDecoder
                |> Http.expectJson (RemoteData.fromResult >> RankingsReceived)
        }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        FetchRankings ->
            ( { model | rankings = RemoteData.Loading }, fetchRankings )

        RankingsReceived response ->
            ( { model | rankings = response }, Cmd.none )

        DeleteRanking rankingId ->
            ( model, deleteRanking rankingId )

        RankingDeleted (Ok _) ->
            ( model, fetchRankings )

        RankingDeleted (Err error) ->
            ( { model | deleteError = Just (buildErrorMessage error) }
            , Cmd.none
            )

        ViewRanking ranking ->
            let
                _ =
                    Debug.log "in viewRanking, id" ranking.id
            in
            ( { model | ranking = ranking }, Cmd.none )

        --REVIEW: change these two to viewRanking results not fetchRankings (that was used to get it to work)?
        ViewRankingResult (Ok _) ->
            ( model, fetchRankings )

        ViewRankingResult (Err error) ->
            ( { model | deleteError = Just (buildErrorMessage error) }
            , Cmd.none
            )


deleteRanking : RankingId -> Cmd Msg
deleteRanking rankingId =
    Http.request
        { method = "DELETE"
        , headers = []
        , url = "http://localhost:5019/posts/" ++ "rankingId.id"
        , body = Http.emptyBody
        , expect = Http.expectString RankingDeleted
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
            [ text "Refresh rankings" ]
        , br [] []
        , br [] []
        , a [ href "/posts/new" ]
            [ text "Create new ranking" ]
        , viewRankings model.rankings
        , viewDeleteError model.deleteError
        ]


viewRankings : WebData (List Ranking) -> Html Msg
viewRankings rankings =
    case rankings of
        RemoteData.NotAsked ->
            text ""

        RemoteData.Loading ->
            h3 [] [ text "Loading..." ]

        RemoteData.Success actualRankings ->
            -- let
            --     temp =
            --         List.map .id actualRankings
            --
            --     _ =
            --         Debug.log "actualRankings" temp
            -- in
            div []
                [ h3 [] [ text "Select Ranking" ]
                , table []
                    ([ viewTableHeader ] ++ List.map viewTableBody actualRankings)
                ]

        RemoteData.Failure httpError ->
            viewFetchError (buildErrorMessage httpError)


viewTableHeader : Html Msg
viewTableHeader =
    tr []
        [ th [ hidden True ]
            [ text "ID" ]
        , th [ hidden True ]
            [ text "Active" ]
        , th [ hidden False, align "left" ]
            [ text "Ranking" ]
        , th []
            [ text "Description" ]
        ]


viewTableBody : Ranking -> Html Msg
viewTableBody ranking =
    tr []
        [ td [ hidden True ]
            [ text (boolToString ranking.active) ]
        , td []
            --[ a [ href rankingPath ] [ text ranking.name ] ]
            --[ button [ type_ "button", onClick (DeleteRanking ranking.id) ]
            [ button [ onClick (ViewRanking ranking) ] [ text "Select" ] ]
        , td []
            [ text ranking.desc ]
        , td [ hidden True ]
            --[ button [ type_ "button", onClick (DeleteRanking ranking.id) ]
            [ text "Delete" ]
        ]


boolToString : Bool -> String
boolToString bool =
    case bool of
        True ->
            "True"

        False ->
            "False"


viewFetchError : String -> Html Msg
viewFetchError errorMessage =
    let
        errorHeading =
            "Couldn't fetch rankings at this time."
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
                [ h3 [] [ text "Couldn't delete ranking at this time." ]
                , text ("Error: " ++ error)
                ]

        Nothing ->
            text ""
