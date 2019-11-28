--when we view an individual ranking we call it a 'ladder' to make it easier to differentiate
--between the list of all 'rankings' and code that relates to individual 'ladders'
--this is due, in part, to having followed a template initially


module Page.ViewRanking exposing (Model, Msg, init, update, view)

import Browser.Navigation as Nav
import Error exposing (buildErrorMessage)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Http
import Players exposing (Player, PlayerId(..), emptyPlayer, emptyPlayerId, ladderOfPlayersDecoder, playerDecoder, playerEncoder)
import Ranking exposing (Ranking, RankingId(..), rankingDecoder, rankingEncoder)
import RemoteData exposing (WebData)
import Route


type alias Model =
    { navKey : Nav.Key
    , players : WebData (List Player)
    , saveError : Maybe String
    }



-- { players = RemoteData.Loading
-- , ranking =
--     { id = ""
--     , active = True
--     , name = "Initial"
--     , desc = "Initial"
--     }
-- , deleteError = Nothing
-- }


init : RankingId -> Nav.Key -> ( Model, Cmd Msg )
init postId navKey =
    let
        _ =
            Debug.log "made it to viewRanking" postId
    in
    ( initialModel navKey, fetchPost postId )


initialModel : Nav.Key -> Model
initialModel navKey =
    { navKey = navKey
    , players = RemoteData.Loading
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
    --PostReceived is the Msg handled by update whenever a request is made
    --RemoteData is used throughout the module, including update
    --all the json is sent to the ladderDecoder (in Ladder.elm)
    Http.request
        { body = Http.emptyBody
        , expect =
            ladderOfPlayersDecoder
                |> Http.expectJson (RemoteData.fromResult >> PostReceived)
        , headers = [ headerKey ]
        , method = "GET"
        , timeout = Nothing
        , tracker = Nothing
        , url = "https://api.jsonbin.io/b/" ++ postId ++ "/latest"
        }


type Msg
    = PostReceived (WebData (List Player))



--| UpdateTitle Bool
--| UpdateAuthorName String
--| UpdateAuthorRank String
--| SavePost
--| PostSaved (Result Http.Error Player)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        PostReceived post ->
            let
                _ =
                    Debug.log "list of players" post
            in
            --remove the first record (created on ranking creation with different format)
            ( { model | players = post }, Cmd.none )



-- PostReceived post ->
--     ( { model | players = RemoteData.Loading }, fetchPost )
-- UpdateTitle newTitle ->
--     let
--         updateTitle =
--             RemoteData.map
--                 (\postData ->
--                     { postData | active = newTitle }
--                 )
--                 model.player
--     in
--     ( { model | player = updateTitle }, Cmd.none )
--
-- UpdateAuthorName newName ->
--     let
--         updateAuthorName =
--             RemoteData.map
--                 (\postData ->
--                     { postData | name = newName }
--                 )
--                 model.player
--     in
--     ( { model | player = updateAuthorName }, Cmd.none )
-- UpdateAuthorRank rank ->
--     let
--         updateAuthorRank =
--             RemoteData.map
--                 (\postData ->
--                     { postData | rank = rank }
--                 )
--                 model.player
--     in
--     ( { model | player = UpdateAuthorRank }, Cmd.none )
-- SavePost ->
--     ( model, savePost model.player )
--
-- PostSaved (Ok postData) ->
--     let
--         post =
--             RemoteData.succeed postData
--     in
--     ( { model | player = post, saveError = Nothing }
--     , --Route.pushUrl Route.ViewRanking model.navKey
--       Cmd.none
--     )
--
-- PostSaved (Err error) ->
--     ( { model | saveError = Just (buildErrorMessage error) }
--     , Cmd.none
--     )
-- savePost : WebData Player -> Cmd Msg
-- savePost post =
--     case post of
--         RemoteData.Success postData ->
--             let
--                 postUrl =
--                     "http://localhost:5019/posts/"
--                         ++ String.fromInt postData.id
--             in
--             Http.request
--                 { method = "PATCH"
--                 , headers = []
--                 , url = postUrl
--                 , body = Http.jsonBody (playerEncoder postData)
--                 , expect = Http.expectJson PostSaved playerDecoder
--                 , timeout = Nothing
--                 , tracker = Nothing
--                 }
--
--         _ ->
--             Cmd.none


view : Model -> Html Msg
view model =
    div []
        [ h3 [] [ text "View Ladder" ]
        , viewRanking model.players
        , viewSaveError model.saveError
        ]


viewRanking : WebData (List Player) -> Html Msg
viewRanking post =
    case post of
        RemoteData.NotAsked ->
            text ""

        RemoteData.Loading ->
            h3 [] [ text "Loading Players..." ]

        RemoteData.Success actualPlayers ->
            -- let
            --     temp =
            --         List.map .id actualRankings
            --
            --     _ =
            --         Debug.log "actualRankings" temp
            -- in
            div []
                [ h3 [] [ text "Players" ]
                , table []
                    ([ viewTableHeader ] ++ List.map viewTableBody actualPlayers)
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
            [ text "Name" ]
        , th []
            [ text "Rank" ]
        , th []
            [ text "Current Challenger" ]
        ]


viewTableBody : Player -> Html Msg
viewTableBody player =
    let
        playerpath =
            "player/" ++ String.fromInt player.id
    in
    tr []
        [ td [ hidden True ]
            [ text (boolToString player.active) ]
        , td []
            [ a [ href playerpath ] [ text player.name ] ]

        --[ button [ type_ "button", onClick (DeleteRanking ranking.id) ]
        --[ button [ onClick (ViewRanking ranking) ] [ text "Select" ] ]
        , td []
            [ text (String.fromInt player.rank) ]
        , td []
            [ text player.currentchallengername ]
        , td [ hidden True ]
            [ text "Delete" ]
        ]



--TODO: Refactor to single source for utilities


boolToString : Bool -> String
boolToString bool =
    case bool of
        True ->
            "True"

        False ->
            "False"



-- editForm : List Player -> Html Msg
-- editForm post =
--     Html.form []
--         [ div []
--             [ text "Title"
--             , br [] []
--             , input
--                 [ type_ "text"
--                 , value post.name
--
--                 --, onInput (boolToString UpdateTitle)
--                 ]
--                 []
--             ]
--         , br [] []
--         , div []
--             [ text "Author Name"
--             , br [] []
--             , input
--                 [ type_ "text"
--                 , value post.name
--
--                 --, onInput UpdateAuthorName
--                 ]
--                 []
--             ]
--         , br [] []
--         , div []
--             [ text "Rank"
--             , br [] []
--             , input
--                 [ type_ "text"
--                 , value (String.fromInt post.rank)
--
--                 --, onInput "UpdateAuthorRank"
--                 ]
--                 []
--             ]
--         , br [] []
--         , div []
--             [--button [ type_ "button", onClick SavePost ]
--              --[ text "Submit" ]
--             ]
--         ]


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
