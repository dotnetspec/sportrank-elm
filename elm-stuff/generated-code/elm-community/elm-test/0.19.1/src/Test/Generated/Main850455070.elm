module Test.Generated.Main850455070 exposing (main)

import Example
import FuzzTests

import Test.Reporter.Reporter exposing (Report(..))
import Console.Text exposing (UseColor(..))
import Test.Runner.Node
import Test

main : Test.Runner.Node.TestProgram
main =
    [     Test.describe "Example" [Example.guardianNames,
    Example.comparisonTests,
    Example.additionTests],     Test.describe "FuzzTests" [FuzzTests.addOneTests,
    FuzzTests.addTests,
    FuzzTests.flipTests] ]
        |> Test.concat
        |> Test.Runner.Node.run { runs = Nothing, report = (ConsoleReport UseColor), seed = 101446144050798, processes = 4, paths = ["/home/linuxuser/Documents/dev/elm/project1/tests/FuzzTests.elm"]}