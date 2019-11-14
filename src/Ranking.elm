module Ranking exposing (Ranking, RankingId, emptyRankingId, newPostEncoder, rankingDecoder, rankingEncoder, rankingsDecoder)

import Json.Decode as Decode exposing (Decoder, bool, int, list, string)
import Json.Decode.Pipeline exposing (required)
import Json.Encode as Encode
import Url.Parser exposing (Parser, custom)



-- type alias Ranking =
--     { id : RankingId
--     , title : String
--     , authorName : String
--     , authorUrl : String
--     }


type alias Ranking =
    { id : String
    , active : Bool
    , name : String
    , desc : String
    }


type RankingId
    = RankingId String


rankingsDecoder : Decoder (List Ranking)
rankingsDecoder =
    list rankingDecoder



-- rankingDecoder : Decoder Ranking
-- rankingDecoder =
--     Decode.succeed Ranking
--         |> required "id" idDecoder
--         |> required "title" string
--         |> required "authorName" string
--         |> required "authorUrl" string
--this was rankingDecoder


rankingDecoder : Decoder Ranking
rankingDecoder =
    Decode.succeed Ranking
        |> required "RANKINGID" string
        |> required "ACTIVE" bool
        |> required "RANKINGNAME" string
        |> required "RANKINGDESC" string



-- postDecoder : Decoder Post
-- postDecoder =
--     map4 Post
--         (field "RANKINGID" string)
--         (field "ACTIVE" bool)
--         (field "RANKINGNAME" string)
--         (field "RANKINGDESC" string)
-- idDecoder : Decoder RankingId
-- idDecoder =
--     Decode.map RankingId int
-- idToString : RankingId -> String
-- idToString (RankingId id) =
--     String.fromInt id
-- idParser : Parser (RankingId -> a) a
-- idParser =
--     custom "RANKINGID" <|
--         \rankingId ->
--             Maybe.map RankingId (String.toInt rankingId)
-- Original with encodeId
-- rankingEncoder : Ranking -> Encode.Value
-- rankingEncoder post =
--     Encode.object
--         [ ( "id", encodeId post.id )
--         , ( "title", Encode.string post.title )
--         , ( "authorName", Encode.string post.authorName )
--         , ( "authorUrl", Encode.string post.authorUrl )
--         ]


rankingEncoder : Ranking -> Encode.Value
rankingEncoder ranking =
    Encode.object
        [ ( "RANKINGID", Encode.string ranking.id )
        , ( "ACTIVE", Encode.bool ranking.active )
        , ( "RANKINGNAME", Encode.string ranking.name )
        , ( "RANKINGDESC", Encode.string ranking.desc )
        ]


newPostEncoder : Ranking -> Encode.Value
newPostEncoder ranking =
    Encode.object
        [ ( "ACTIVE", Encode.bool ranking.active )
        , ( "RANKINGNAME", Encode.string ranking.name )
        , ( "RANKINGDESC", Encode.string ranking.desc )
        ]



-- encodeId : RankingId -> Encode.Value
-- encodeId (RankingId id) =
--     Encode.int id


emptyRanking : Ranking
emptyRanking =
    { id = ""
    , active = False
    , name = ""
    , desc = ""
    }


emptyRankingId : RankingId
emptyRankingId =
    RankingId "-1"
