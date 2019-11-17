module Ranking exposing (Ranking, RankingId(..), emptyRankingId, newPostEncoder, rankingDecoder, rankingEncoder, rankingsDecoder)

import Json.Decode as Decode exposing (Decoder, bool, int, list, string)
import Json.Decode.Pipeline exposing (required)
import Json.Encode as Encode
import Url.Parser exposing (Parser, custom)


type alias Ranking =
    { id : String
    , active : Bool
    , name : String
    , desc : String
    }


type RankingId
    = RankingId String



-- TODO: make an opaque type?
-- rankingIdToString: RankingId -> String
-- rankingIdToString rankingid =
--   rankingid


rankingsDecoder : Decoder (List Ranking)
rankingsDecoder =
    list rankingDecoder


rankingDecoder : Decoder Ranking
rankingDecoder =
    Decode.succeed Ranking
        |> required "RANKINGID" string
        |> required "ACTIVE" bool
        |> required "RANKINGNAME" string
        |> required "RANKINGDESC" string


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
