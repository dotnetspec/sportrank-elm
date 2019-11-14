module EventListener exposing (Model)

import Browser
import Browser.Events exposing (onClick, onKeyPress)
import Html exposing (..)
import Json.Decode as Decode


type alias Model =
    Int


init : () -> ( Model, Cmd Msg )
init _ =
    ( 0, Cmd.none )


view : Model -> Html Msg
view model =
    div []
        [ text (String.fromInt model) ]


type Msg
    = KeyPressed
    | MouseClick


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        KeyPressed ->
            ( model + 1, Cmd.none )

        MouseClick ->
            ( model + 5, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch
        [ onKeyPress (Decode.succeed KeyPressed)
        , onClick (Decode.succeed MouseClick)
        ]


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
