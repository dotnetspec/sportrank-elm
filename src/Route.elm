module Route exposing (Route(..), matchRouteParser, parseUrl, pushUrl)

import Browser.Navigation as Nav
import Ranking exposing (RankingId(..), rankingIdToString)
import Url exposing (Url)
import Url.Parser exposing (..)


type Route
    = NotFound
    | ListAll
      --| Ranking String
    | NewRanking String
    | ViewRanking String


parseUrl : Url -> Route
parseUrl url =
    let
        _ =
            Debug.log "url in parseUrl " url
    in
    case parse matchRouteParser url of
        Just route ->
            let
                _ =
                    Debug.log "route" route
            in
            route

        Nothing ->
            NotFound



--"5d8f5d00de0ab12e3d91df6e"
-- tells us if user is on one of the routes
-- it's a parser that will (hopefully) give us a route.
-- Map the routes if we manage to match the url successfully
-- tell matchRouteParser what the structure of the url will look like


matchRouteParser : Parser (Route -> a) a
matchRouteParser =
    let
        temp =
            "hello"

        _ =
            Debug.log "in matchRouteParser" temp
    in
    oneOf
        [ map ListAll top
        , map ViewRanking (s "ranking" </> Url.Parser.string)

        --, map NewRanking (s "posts")
        ]


pushUrl : Route -> Nav.Key -> Cmd msg
pushUrl route navKey =
    let
        _ =
            Debug.log "route in pushUrl" route
    in
    routeToString route
        |> Nav.pushUrl navKey


routeToString : Route -> String
routeToString route =
    let
        _ =
            Debug.log "route in routeToString" route
    in
    case route of
        NotFound ->
            "/not-found"

        ListAll ->
            "/"

        -- this is now ViewRanking - delete?
        -- Ranking postId ->
        --     "/posts/" ++ "postId"
        NewRanking postId ->
            "/posts/new"

        ViewRanking postId ->
            "/" ++ postId
