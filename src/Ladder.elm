module Ladder exposing (Ladder, LadderId(..), emptyLadder, emptyLadderId, ladderDecoder)

import Json.Decode as Decode exposing (Decoder, bool, int, list, string)
import Json.Decode.Pipeline exposing (required)
import Json.Encode as Encode
import Url.Parser exposing (Parser, custom)


type alias Ladder =
    { datestamp : Int
    , active : Bool
    , currentchallengername : String
    , currentlchallengerid : String
    , address : String
    , rank : Int
    , name : String
    , id : Int
    , currentchallengeraddress : String
    }


type LadderId
    = LadderId Int



-- TODO: make an opaque type?
-- rankingIdToString: RankingId -> String
-- rankingIdToString rankingid =
--   rankingid


ladderDecoder : Decoder (List Ladder)
ladderDecoder =
    list playerDecoder


playerDecoder : Decoder Ladder
playerDecoder =
    Decode.succeed Ranking
        |> required "DATESTAMP" int
        |> required "ACTIVE" bool
        |> required "CURRENTCHALLENGERNAME" string
        |> required "CURRENTCHALLENGERID" int
        |> required "ADDRESS" string
        |> required "RANK" int
        |> required "NAME" string
        |> required "id" int
        |> required "CURRENTCHALLENGERADDRESS" string



-- {
--    "DATESTAMP": 1569839363942,
--    "ACTIVE": true,
--    "CURRENTCHALLENGERNAME": "testuser1",
--    "CURRENTCHALLENGERID": 3,
--    "ADDRESS": "0xD99eB29299CEF8726fc688180B30E634827b3078",
--    "RANK": 1,
--    "NAME": "GanacheAcct2",
--    "id": 2,
--    "CURRENTCHALLENGERADDRESS": "0x48DF2ee04DFE67902B83a670281232867e5dC0Ca"
--  },
-- rankingEncoder : Ranking -> Encode.Value
-- rankingEncoder ranking =
--     Encode.object
--         [ ( "RANKINGID", Encode.string ranking.id )
--         , ( "ACTIVE", Encode.bool ranking.active )
--         , ( "RANKINGNAME", Encode.string ranking.name )
--         , ( "RANKINGDESC", Encode.string ranking.desc )
--         ]
--
--
-- newPostEncoder : Ranking -> Encode.Value
-- newPostEncoder ranking =
--     Encode.object
--         [ ( "ACTIVE", Encode.bool ranking.active )
--         , ( "RANKINGNAME", Encode.string ranking.name )
--         , ( "RANKINGDESC", Encode.string ranking.desc )
--         ]
--
--


emptyLadder : Ladder
emptyLadder =
    { datestamp = 1
    , active = False
    , currentchallengername = ""
    , currentlchallengerid = ""
    , address = ""
    , rank = 0
    , name = ""
    , id = 0
    , currentchallengeraddress = ""
    }


emptyLadderId : LadderId
emptyLadderId =
    LadderId "-1"
