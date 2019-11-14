module SimpleStuffTests exposing (simpleTests)

import Expect exposing (Expectation)
import Fuzz exposing (..)
import SimpleStuff exposing (..)
import Test exposing (..)

simpleTests =
    describe "Simple Stuff Tests"
        [ test "Text is Hello there" <|
            \_ ->
                main
                    |> Expect.equal "Hello there"
        -- , test "output is 1 when the input is 0" <|
        --     \_ ->
        --         inverter 1
        --             |> Expect.equal 0
        ]
