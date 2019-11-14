module Test.Generated.Main4145329475 exposing (main)

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
    FuzzTests.addTests] ]
        |> Test.concat
        |> Test.Runner.Node.run { runs = Nothing, report = (ConsoleReport UseColor), seed = 165539021247139, processes = 4, paths = ["/home/linuxuser/Documents/dev/elm/project1/tests/FuzzTests.elm"]}