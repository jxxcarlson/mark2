module CaYaTeX exposing (CaYaTeXMsg, Data, init, render, renderToLaTeX, update)

import Element as E
import Parser.Data
import Parser.Document
import Parser.Element
import Render.Elm
import Render.LaTeX
import Render.Types as Types


type alias Data =
    { content : String, generation : Int }


type alias CaYaTeXMsg =
    Parser.Element.Mark2Msg


init : Int -> String -> Data
init generation text =
    { content = text, generation = generation }


update : Int -> String -> Data -> Data
update generation text _ =
    init generation text


render : String -> Data -> List (E.Element Parser.Element.Mark2Msg)
render id data =
    Parser.Document.runloop data.generation (String.lines data.content)
        |> Parser.Document.toParsed
        |> List.map (Render.Elm.renderList (initState data.generation))


renderToLaTeX : String -> String
renderToLaTeX =
    Render.LaTeX.render


initState : Int -> Types.RenderArgs
initState k =
    { generation = k
    , blockOffset = 0
    , selectedId = ""
    , width = 300
    , parserData = Parser.Data.init Parser.Data.defaultConfig
    }
