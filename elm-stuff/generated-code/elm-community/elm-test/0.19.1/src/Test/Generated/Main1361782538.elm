module Test.Generated.Main1361782538 exposing (main)

import Example

import Test.Reporter.Reporter exposing (Report(..))
import Console.Text exposing (UseColor(..))
import Test.Runner.Node
import Test

main : Test.Runner.Node.TestProgram
main =
    [     Test.describe "Example" [Example.guardianNames,
    Example.comparisonTests,
    Example.additionTests] ]
        |> Test.concat
        |> Test.Runner.Node.run { runs = Nothing, report = (ConsoleReport UseColor), seed = 74600378282978, processes = 4, paths = ["/home/linuxuser/Documents/dev/elm/project1/tests/Example.elm"]}