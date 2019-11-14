module Route exposing (Route(..), parseUrl, pushUrl)

import Browser.Navigation as Nav
import Ranking exposing (RankingId)
import Url exposing (Url)
import Url.Parser exposing (..)


type Route
    = NotFound
    | Rankings
    | Ranking RankingId
    | NewRanking


parseUrl : Url -> Route
parseUrl url =
    case parse matchRoute url of
        Just route ->
            route

        Nothing ->
            NotFound


matchRoute : Parser (Route -> a) a
matchRoute =
    oneOf
        [ map Rankings top
        , map Rankings (s "posts")
        , map Ranking (s "posts" </> Ranking.idParser)
        , map NewRanking (s "posts" </> s "new")
        ]


pushUrl : Route -> Nav.Key -> Cmd msg
pushUrl route navKey =
    routeToString route
        |> Nav.pushUrl navKey


routeToString : Route -> String
routeToString route =
    case route of
        NotFound ->
            "/not-found"

        Rankings ->
            "/posts"

        Ranking postId ->
            "/posts/" ++ Ranking.idToString postId

        NewRanking ->
            "/posts/new"
