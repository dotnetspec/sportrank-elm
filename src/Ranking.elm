module Ranking exposing (Ranking, RankingId, emptyPostId, idParser, idToString, newPostEncoder, postDecoder, postEncoder, postsDecoder)

import Json.Decode as Decode exposing (Decoder, int, list, string)
import Json.Decode.Pipeline exposing (required)
import Json.Encode as Encode
import Url.Parser exposing (Parser, custom)


type alias Ranking =
    { id : RankingId
    , title : String
    , authorName : String
    , authorUrl : String
    }


type RankingId
    = RankingId Int


postsDecoder : Decoder (List Ranking)
postsDecoder =
    list postDecoder


postDecoder : Decoder Ranking
postDecoder =
    Decode.succeed Ranking
        |> required "id" idDecoder
        |> required "title" string
        |> required "authorName" string
        |> required "authorUrl" string


idDecoder : Decoder RankingId
idDecoder =
    Decode.map RankingId int


idToString : RankingId -> String
idToString (RankingId id) =
    String.fromInt id


idParser : Parser (RankingId -> a) a
idParser =
    custom "POSTID" <|
        \postId ->
            Maybe.map RankingId (String.toInt postId)


postEncoder : Ranking -> Encode.Value
postEncoder post =
    Encode.object
        [ ( "id", encodeId post.id )
        , ( "title", Encode.string post.title )
        , ( "authorName", Encode.string post.authorName )
        , ( "authorUrl", Encode.string post.authorUrl )
        ]


newPostEncoder : Ranking -> Encode.Value
newPostEncoder post =
    Encode.object
        [ ( "title", Encode.string post.title )
        , ( "authorName", Encode.string post.authorName )
        , ( "authorUrl", Encode.string post.authorUrl )
        ]


encodeId : RankingId -> Encode.Value
encodeId (RankingId id) =
    Encode.int id


emptyPost : Ranking
emptyPost =
    { id = emptyPostId
    , title = ""
    , authorName = ""
    , authorUrl = ""
    }


emptyPostId : RankingId
emptyPostId =
    RankingId -1
