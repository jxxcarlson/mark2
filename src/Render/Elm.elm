module Render.Elm exposing (getRows_, paragraphs, renderElement, renderList, renderString)

import CYUtility
import Dict exposing (Dict)
import Element as E exposing (column, el, paragraph, px, row, spacing, text)
import Element.Background as Background
import Element.Font as Font
import Element.Input as Input
import Html exposing (Html)
import Html.Attributes as HA
import Html.Keyed
import Json.Encode
import List.Extra
import Maybe.Extra
import Parser.Data as Data
import Parser.Driver
import Parser.Element exposing (CYTMsg(..), Element(..))
import Parser.Error as Error
import Parser.Metadata exposing (Metadata)
import Parser.TextCursor
import Render.Types exposing (DisplayMode(..), FRender, RenderArgs, RenderElementDict)
import Render.Utility
import Spreadsheet
import String.Extra
import SvgParser
import Widget.Data



-- import Widget.Simulations
-- STYLE PARAMETERS


textWidth =
    E.width (E.px 200)


format =
    [ Font.size 14 ]



-- TOP-LEVEL RENDERERS


renderString : RenderArgs -> String -> E.Element CYTMsg
renderString renderArgs str =
    Parser.Driver.parseLoop renderArgs.generation renderArgs.blockOffset (Data.init Data.defaultConfig) str
        |> Parser.TextCursor.parseResult
        |> renderList renderArgs


renderList : RenderArgs -> List Element -> E.Element CYTMsg
renderList renderArgs list_ =
    paragraph format (List.map (renderElement renderArgs) list_)


renderElement : RenderArgs -> Element -> E.Element CYTMsg
renderElement renderArgs element =
    case element of
        Text str _ ->
            -- TODO
            el [] (text str)

        Element name args body meta ->
            renderWithDictionary renderArgs name args body meta

        LX list_ _ ->
            paragraph format (List.map (renderElement renderArgs) list_)

        Problem p e _ ->
            E.paragraph format
                [ E.el [ Font.color (E.rgb255 0 0 230) ] (E.text (Error.heading p))
                , E.el [ E.paddingXY 8 0, Font.color (E.rgb255 180 0 0), Font.underline ] (E.text e)
                ]


paragraphs : String -> List String
paragraphs str =
    str
        |> String.split "\n\n"
        |> List.map String.trim


theoremLikeElements =
    [ "theorem", "proposition", "proof", "definition", "example", "problem", "corollary", "lemma" ]


renderWithDictionary renderArgs name args body meta =
    case Dict.get name renderElementDict of
        Nothing ->
            if List.member name theoremLikeElements then
                renderaAsTheoremLikeElement renderArgs name args body meta

            else
                case Dict.get name renderArgs.parserData.macroDict of
                    Just macroForm ->
                        -- TODO: finish expandMacro
                        renderElement renderArgs (expandMacro macroForm body)

                    _ ->
                        renderMissingElement name body

        Just f ->
            f renderArgs name args body meta


expandMacro : Data.MacroForm -> Element -> Element
expandMacro macroForm body =
    --  Element macroForm.name macroForm.args (Text (getText2 body) Nothing) Nothing
    Element macroForm.name macroForm.args body Nothing


renderMissingElement : String -> Element -> E.Element CYTMsg
renderMissingElement name body =
    paragraph []
        [ el [ Font.bold ] (text "[")
        , el [ Font.color blueColor, Font.bold ] (text (name ++ " "))
        , el [ Font.color violetColor ] (text (getText body |> Maybe.withDefault ""))
        , el [ Font.color redColor ] (text " << element misstyped or unimplemented")
        , el [ Font.bold ] (text "]")
        ]



-- RENDERER DICTIONARY


renderElementDict : RenderElementDict CYTMsg
renderElementDict =
    Dict.fromList
        [ ( "Error", error )
        , ( "macro", macro )
        , ( "set", set )
        , ( "set_", set_ )
        , ( "hide", hide )
        , ( "get", get )
        , ( "spreadsheet", spreadsheet )
        , ( "tableofcontents", tableofcontents )
        , ( "bold", bold )
        , ( "strike", strike )
        , ( "underline", underline )
        , ( "b", bold )
        , ( "italic", renderItalic )
        , ( "i", renderItalic )
        , ( "highlight", highlight )
        , ( "highlightRGB", highlightRGB )
        , ( "fontRGB", fontRGB )
        , ( "red", red )
        , ( "blue", blue )
        , ( "violet", violet )
        , ( "medgray", medgray )
        , ( "code", renderCode )
        , ( "c", renderCode )
        , ( "def", defitem )
        , ( "codeblock", codeblock )
        , ( "cb", codeblock )
        , ( "verbatim", verbatim )
        , ( "poetry", poetry )
        , ( "obeylines", obeylines )
        , ( "par", par )
        , ( "title", docTitle )
        , ( "section", section_ )
        , ( "section1", section_ )
        , ( "section2", section_ )
        , ( "section3", section_ )
        , ( "section4", section_ )
        , ( "section5", section_ )
        , ( "section6", section_ )
        , ( "list", list )
        , ( "data", dataTable )
        , ( "item", item )
        , ( "link", link )
        , ( "ilink", ilink )
        , ( "image", image )
        , ( "svg", svg )
        , ( "math", renderMath )
        , ( "m", renderMath )
        , ( "mathblock", renderMathDisplay )
        , ( "mb", renderMathDisplay )
        , ( "center", center )
        , ( "indent", indent )

        -- COMPUTATIONS
        , ( "sum", Widget.Data.sum )
        , ( "average", Widget.Data.average )
        , ( "stdev", Widget.Data.stdev )
        , ( "bargraph", Widget.Data.bargraph )
        , ( "linegraph", Widget.Data.linegraph )
        , ( "scatterplot", Widget.Data.scatterplot )

        -- , ( "gameoflife", Widget.Simulations.gameOfLife )
        ]


getText : Element -> Maybe String
getText element =
    case element of
        LX [ Text content _ ] _ ->
            Just content

        _ ->
            Nothing


getText2 : Element -> String
getText2 element =
    case element of
        LX list_ _ ->
            List.map Render.Utility.extractText list_ |> Maybe.Extra.values |> String.join "\n"

        _ ->
            ""



-- NEW
-- LISTS


listPadding =
    E.paddingEach { left = 18, right = 0, top = 8, bottom = 0 }


indentPadding =
    E.paddingEach { left = 24, right = 0, top = 0, bottom = 0 }


getPrefixSymbol : Int -> Dict String String -> E.Element CYTMsg
getPrefixSymbol k dict =
    case Dict.get "s" dict of
        Just "numbered" ->
            el [ Font.size 12, E.alignTop, E.moveDown 2.2 ] (text (String.fromInt (k + 1) ++ "."))

        Nothing ->
            el [ Font.size 16 ] (text "•")

        Just "bullet" ->
            el [ Font.size 16 ] (text "•")

        Just "none" ->
            E.none

        Just str ->
            el [ Font.size 16 ] (text str)


elementTitle args_ =
    let
        dict =
            CYUtility.keyValueDict args_

        title =
            Dict.get "title" dict
    in
    case title of
        Nothing ->
            E.none

        Just title_ ->
            el [ Font.size titleSize ] (text title_)


titleSize =
    14


macro : FRender CYTMsg
macro renderArgs name args_ body meta =
    E.none



-- BINDINGS


set : FRender CYTMsg
set renderArgs name args_ body meta =
    E.none


set_ : FRender CYTMsg
set_ renderArgs name args_ body meta =
    E.el [ Font.color codeColor ] (text ("set " ++ getText2 body))


hide : FRender CYTMsg
hide renderArgs name args_ body meta =
    E.none


getRow : Element -> String
getRow element =
    case element of
        Element "row" [] (LX [ Text t _ ] _) _ ->
            t

        _ ->
            ""


getRows : Element -> List String
getRows body =
    case body of
        LX list_ _ ->
            List.map getRow list_
                |> List.filter (\s -> s /= "")

        _ ->
            []


getRows_ : Element -> List (List String)
getRows_ body =
    case body of
        LX list_ _ ->
            List.map getRow list_
                |> List.filter (\s -> s /= "")
                |> List.map (String.split ",")
                |> List.map (List.map String.trim)

        _ ->
            [ [] ]


spreadsheet : FRender CYTMsg
spreadsheet renderArgs name args_ body meta =
    let
        -- spreadsheet1 : List (List String)
        spreadsheet1 =
            Render.Utility.getCSV ";" body
                |> Spreadsheet.readFromList
                |> Spreadsheet.eval

        spreadsheet2 : List (List String)
        spreadsheet2 =
            Spreadsheet.printAsList spreadsheet1

        renderItem : String -> E.Element CYTMsg
        renderItem str =
            el [ E.width (E.px 60) ] (el [ E.alignRight ] (text str))

        renderRow : List String -> E.Element CYTMsg
        renderRow items =
            row [ spacing 10 ] (List.map renderItem items)
    in
    E.column [ spacing 8, indentPadding ] (List.map renderRow spreadsheet2)


get : FRender CYTMsg
get renderArgs name args_ body meta_ =
    let
        key =
            getText2 body |> String.trim
    in
    case Dict.get key renderArgs.parserData.bindings of
        Nothing ->
            E.el [ Font.color redColor ] (text ("variable " ++ key ++ " not found"))

        Just value ->
            E.el [] (text value)


tableofcontents : FRender CYTMsg
tableofcontents renderArgs name args_ body meta =
    let
        argDict =
            CYUtility.keyValueDict args_

        renderTocItem =
            case Dict.get "numbered" argDict of
                Just "no" ->
                    renderUnNumberedTocItem

                _ ->
                    renderNumberedTocItem
    in
    E.column [ spacing 8, Render.Utility.htmlAttribute "id" "tableofcontents__" ]
        (el [ Font.bold, Font.size 18 ] (text "Table of contents") :: List.map renderTocItem (List.reverse renderArgs.parserData.tableOfContents))


renderNumberedTocItem : Data.TocEntry -> E.Element CYTMsg
renderNumberedTocItem tocItem =
    E.link [ Font.color linkColor, tocPadding tocItem.level ] { label = text (tocItem.label ++ " " ++ tocItem.name), url = "#" ++ Render.Utility.slug tocItem.name }


renderUnNumberedTocItem : Data.TocEntry -> E.Element CYTMsg
renderUnNumberedTocItem tocItem =
    E.link [ Font.color linkColor, tocPadding tocItem.level ] { label = text tocItem.name, url = "#" ++ Render.Utility.slug tocItem.name }


tocPadding k =
    E.paddingEach { left = k * 10, right = 0, top = 0, bottom = 0 }


list : FRender CYTMsg
list renderArgs name args_ body meta =
    let
        dict =
            CYUtility.keyValueDict args_
    in
    case body of
        LX list_ _ ->
            column [ spacing 4, listPadding ]
                (elementTitle args_ :: List.indexedMap (\k item_ -> renderListItem (getPrefixSymbol k dict) renderArgs item_) (filterOutBlankItems list_))

        _ ->
            el [ Font.color redColor ] (text "Malformed list")


defitem : FRender CYTMsg
defitem renderArgs name args_ body meta =
    let
        itemName =
            CYUtility.entities args_ |> List.head |> Maybe.withDefault "ITEM"
    in
    E.column []
        [ el [ Font.bold, Font.size 14 ] (E.text itemName)
        , E.paragraph [ listPadding ] [ renderElement renderArgs body ]
        ]


dataTable : FRender CYTMsg
dataTable renderArgs name args_ body meta =
    let
        rawData : List (List String)
        rawData =
            Render.Utility.getCSV "," body
                |> List.filter (\row -> row /= [ "" ])

        widths : List Float
        widths =
            Render.Utility.columnWidths 10 0 rawData

        headerRow =
            List.member "header" (CYUtility.entities args_)

        style k =
            if k == 0 && headerRow then
                [ Font.bold, spacing 4 ]

            else
                [ spacing 4 ]

        makeRow : Int -> List Float -> List String -> E.Element CYTMsg
        makeRow k columnWidths cells =
            row (style k) (List.map2 (\w cell -> el [ E.width (E.px (round w)) ] (text cell)) columnWidths cells)
    in
    column [ spacing 8 ]
        (elementTitle args_ :: List.indexedMap (\k -> makeRow k widths) rawData)


filterOutBlankItems : List Element -> List Element
filterOutBlankItems list_ =
    List.filter (\item_ -> not (isBlankItem item_)) list_


isBlankItem : Element -> Bool
isBlankItem el =
    case el of
        Text str _ ->
            String.trim str == ""

        _ ->
            False


renderListItem : E.Element CYTMsg -> RenderArgs -> Element -> E.Element CYTMsg
renderListItem prefixSymbol renderArgs elt =
    case elt of
        Element "item" _ body _ ->
            E.row [ E.spacing 8 ] [ el [ E.alignTop, E.moveDown 2 ] prefixSymbol, renderElement renderArgs elt ]

        Element "list" args body _ ->
            let
                dict =
                    CYUtility.keyValueDict args
            in
            case body of
                LX list_ _ ->
                    column [ spacing 4, listPadding ] (elementTitle args :: List.indexedMap (\k item_ -> renderListItem (getPrefixSymbol k dict) renderArgs item_) (filterOutBlankItems list_))

                _ ->
                    el [ Font.color redColor ] (text "Malformed list")

        _ ->
            E.none


item : FRender CYTMsg
item renderArgs name args_ body meta =
    paragraph [] [ renderElement renderArgs body ]


par : FRender CYTMsg
par renderArgs name args_ body meta =
    E.none


error : FRender CYTMsg
error renderArgs name args_ body meta =
    el [ Font.color violetColor ] (renderElement renderArgs body)



-- ELEMENTARY RENDERERS
-- CODE


renderCode : FRender CYTMsg
renderCode renderArgs _ _ body meta =
    let
        adjustedBody =
            getText body
                |> Maybe.withDefault "(body)"
                |> String.replace "\\[" "["
                |> String.replace "\\]" "]"
                |> (\text -> Text text meta)
    in
    el
        [ Font.family
            [ Font.typeface "Inconsolata"
            , Font.monospace
            ]
        , Font.color codeColor
        ]
        (renderElement renderArgs adjustedBody)


getLXText : Element -> String
getLXText element =
    case element of
        LX list_ _ ->
            List.map (getText >> Maybe.withDefault "") list_ |> String.join "\n"

        _ ->
            ""


poetry : FRender CYTMsg
poetry renderArgs _ _ body meta =
    column
        [ Font.size 14
        , Render.Utility.htmlAttribute "white-space" "pre"
        , indentation
        , spacing 4
        ]
        (List.map text (getLines (getText2 body |> String.trim)))


obeylines : FRender CYTMsg
obeylines renderArgs _ _ body meta =
    column
        [ Font.size 14
        , Render.Utility.htmlAttribute "white-space" "pre"
        , spacing 4
        ]
        (List.map text (getLines (getText2 body |> String.trim)))


codeblock : FRender CYTMsg
codeblock renderArgs _ _ body meta =
    column
        [ Font.family
            [ Font.typeface "Inconsolata"
            , Font.monospace
            ]
        , Font.size 14
        , Font.color codeColor
        , Render.Utility.htmlAttribute "white-space" "pre"

        --, Render.Utility.htmlAttribute "line-height" "1.5"
        , indentation
        , spacing 8
        ]
        (List.map text (getLines (getText2 body |> String.trim)))


verbatim : FRender CYTMsg
verbatim renderArgs _ _ body meta =
    column
        [ Font.family
            [ Font.typeface "Inconsolata"
            , Font.monospace
            ]
        , Render.Utility.htmlAttribute "white-space" "pre"

        -- , Render.Utility.htmlAttribute "line-height" "1.5"
        , indentation
        , spacing 8
        ]
        (List.map text (getLines (getText2 body |> String.trim)))


indentation =
    E.paddingEach { left = 18, right = 0, top = 0, bottom = 0 }


getLines : String -> List String
getLines str =
    let
        nonBreakingSpace =
            String.fromChar '\u{00A0}'
    in
    str
        |> String.lines
        |> List.map
            (\s ->
                if s == "" then
                    nonBreakingSpace

                else
                    String.replace " " nonBreakingSpace s
            )



-- STYLE ELEMENTS
-- NEW


getLabel : Maybe Metadata -> String
getLabel mmeta =
    case mmeta of
        Nothing ->
            ""

        Just meta ->
            meta.label


docTitle : FRender CYTMsg
docTitle renderArgs name args body meta =
    column
        [ Font.size titleFontSize
        , paddingAbove (round <| titleFontSize)
        ]
        [ text <| getLabel meta ++ " " ++ (getText body |> Maybe.withDefault "no section name found") ]


section_ renderArgs name args body meta =
    let
        level =
            String.toFloat (String.replace "section" "" name) |> Maybe.withDefault 1.0

        scaleFactor =
            max (sqrt (1.0 / level)) 0.5

        sectionName =
            getText body |> Maybe.withDefault "no section name found"

        tag =
            Render.Utility.slug sectionName

        argDict =
            CYUtility.keyValueDict args

        labelText =
            case Dict.get "numbered" argDict of
                Nothing ->
                    getLabel meta ++ " " ++ sectionName

                Just "no" ->
                    sectionName

                _ ->
                    getLabel meta ++ " " ++ sectionName
    in
    column
        [ Font.size (round (scaleFactor * toFloat sectionFontSize))
        , paddingAbove (round <| scaleFactor * toFloat sectionFontSize)
        , Render.Utility.htmlAttribute "id" tag
        ]
        -- [ text <| getLabel meta ++ " " ++ sectionName ]
        [ E.link [ Font.size (round (scaleFactor * toFloat sectionFontSize)) ] { label = el [] (text <| labelText), url = "#tableofcontents__" } ]


center : FRender CYTMsg
center renderArgs name args body meta =
    column [ E.centerX ] [ renderElement renderArgs body ]


indent : FRender CYTMsg
indent renderArgs name args body meta =
    column [ indentPadding ] [ renderElement renderArgs body ]


paddingAbove k =
    E.paddingEach { top = k, bottom = 0, left = 0, right = 0 }



-- DIMENSIONS


titleFontSize =
    30


sectionFontSize =
    24


link : FRender CYTMsg
link renderArgs name args body meta =
    case Render.Utility.getArg 0 args of
        Nothing ->
            let
                url_ =
                    getText body |> Maybe.withDefault "missing url"
            in
            E.newTabLink []
                { url = url_
                , label = el [ Font.color linkColor, Font.italic ] (text url_)
                }

        Just labelText ->
            E.newTabLink []
                { url = getText body |> Maybe.withDefault "missing url"
                , label = el [ Font.color linkColor, Font.italic ] (text labelText)
                }


ilink : FRender CYTMsg
ilink renderArgs name args body meta =
    let
        url =
            getText body |> Maybe.withDefault "missing url"
    in
    case Render.Utility.getArg 0 args of
        Nothing ->
            let
                url_ =
                    getText body |> Maybe.withDefault "missing url"
            in
            linkTemplate (CYDocumentLink url) url

        Just labelText ->
            linkTemplate (CYDocumentLink url) labelText


linkTemplate : msg -> String -> E.Element msg
linkTemplate msg label_ =
    E.row [ E.pointer, E.mouseDown [ Background.color (E.rgb 0.9 0.8 1.0) ] ]
        [ Input.button linkStyle
            { onPress = Just msg
            , label = E.el [ E.centerY, Font.size 14, Font.color (E.rgb 0.1 0.0 1.0) ] (E.text label_)
            }
        ]


linkStyle =
    [ Font.color (E.rgb255 0 0 0)
    , E.paddingXY 0 2
    ]


image : FRender CYTMsg
image renderArgs name args body meta =
    let
        dict =
            CYUtility.keyValueDict args

        description =
            Dict.get "caption" dict |> Maybe.withDefault ""

        caption =
            case Dict.get "caption" dict of
                Nothing ->
                    E.none

                Just c ->
                    E.row [ placement, E.width E.fill ] [ el [ E.width E.fill ] (text c) ]

        width =
            case Dict.get "width" dict of
                Nothing ->
                    px displayWidth

                Just w_ ->
                    case String.toInt w_ of
                        Nothing ->
                            px displayWidth

                        Just w ->
                            E.px w

        placement =
            case Dict.get "placement" dict of
                Nothing ->
                    E.centerX

                Just "left" ->
                    E.alignLeft

                Just "right" ->
                    E.alignRight

                Just "center" ->
                    E.centerX

                _ ->
                    E.centerX

        displayWidth =
            renderArgs.parserData.config.displayWidth
    in
    E.column [ spacing 8, E.width (E.px displayWidth), placement ]
        [ E.image [ E.width width, placement ]
            { src = getText body |> Maybe.withDefault "no image url", description = description }
        , caption
        ]


svg : FRender CYTMsg
svg renderArgs _ args body meta =
    case SvgParser.parse (getText2 body) of
        Ok html_ ->
            let
                dict =
                    CYUtility.keyValueDict args

                description =
                    Dict.get "caption" dict |> Maybe.withDefault ""

                caption =
                    case Dict.get "caption" dict of
                        Nothing ->
                            E.none

                        Just c ->
                            E.row [ placement ] [ el [] (text c) ]

                width =
                    case Dict.get "width" dict of
                        Nothing ->
                            px displayWidth

                        Just w_ ->
                            case String.toInt w_ of
                                Nothing ->
                                    px displayWidth

                                Just w ->
                                    E.px w

                placement =
                    case Dict.get "placement" dict of
                        Nothing ->
                            E.centerX

                        Just "left" ->
                            E.alignLeft

                        Just "right" ->
                            E.alignRight

                        Just "center" ->
                            E.centerX

                        _ ->
                            E.centerX

                displayWidth =
                    renderArgs.parserData.config.displayWidth
            in
            E.column [ spacing 8, E.width width, placement ]
                [ E.column [ E.width width, placement, Render.Utility.htmlAttribute "text-align" "cener" ] [ html_ |> E.html ]
                , caption
                ]

        Err _ ->
            E.el [] (E.text "SVG parse error")


bold : FRender CYTMsg
bold renderArgs _ _ body meta =
    el [ Font.bold ] (renderElement renderArgs body)


strike : FRender CYTMsg
strike renderArgs _ _ body meta =
    el [ Font.strike ] (renderElement renderArgs body)


underline : FRender CYTMsg
underline renderArgs _ _ body meta =
    el [ Font.underline ] (renderElement renderArgs body)


renderItalic : FRender CYTMsg
renderItalic renderArgs _ _ body meta =
    el [ Font.italic ] (renderElement renderArgs body)


highlight : FRender CYTMsg
highlight renderArgs _ _ body _ =
    el [ Background.color yellowColor, E.paddingXY 4 2 ] (renderElement renderArgs body)


highlightRGB : FRender CYTMsg
highlightRGB renderArgs _ args body meta =
    let
        r =
            Render.Utility.getInt 0 args

        g =
            Render.Utility.getInt 1 args

        b =
            Render.Utility.getInt 2 args
    in
    el [ Background.color (E.rgb255 r g b), E.paddingXY 4 2 ] (renderElement renderArgs body)


fontRGB : FRender CYTMsg
fontRGB renderArgs name args body meta =
    let
        r =
            Render.Utility.getInt 0 args

        g =
            Render.Utility.getInt 1 args

        b =
            Render.Utility.getInt 2 args
    in
    el [ Font.color (E.rgb255 r g b), E.paddingXY 4 2 ] (renderElement renderArgs body)


red : FRender CYTMsg
red renderArgs name args body meta =
    el [ Font.color (E.rgb255 195 0 0), E.paddingXY 4 2 ] (renderElement renderArgs body)


blue : FRender CYTMsg
blue renderArgs name args body meta =
    el [ Font.color (E.rgb255 0 0 200), E.paddingXY 4 2 ] (renderElement renderArgs body)


violet : FRender CYTMsg
violet renderArgs name args body meta =
    el [ Font.color violetColor, E.paddingXY 4 2 ] (renderElement renderArgs body)


medgray : FRender CYTMsg
medgray renderArgs name args body meta =
    el [ Font.color (E.rgb 0.4 0.4 0.4), E.paddingXY 4 2 ] (renderElement renderArgs body)



-- MATH


renderaAsTheoremLikeElement : FRender CYTMsg
renderaAsTheoremLikeElement renderArgs name args body meta =
    let
        label_ =
            Render.Utility.getArg 0 args

        heading =
            case label_ of
                Nothing ->
                    E.row [] [ el [ Font.bold ] (text <| String.Extra.toSentenceCase name ++ ".") ]

                Just label ->
                    paragraph []
                        [ el [ Font.bold ] (text <| String.Extra.toSentenceCase name)
                        , el [] (text <| " (" ++ label ++ ")")
                        , el [ Font.bold ] (text <| ".")
                        ]
    in
    column [ spacing 3 ]
        [ heading
        , el [] (renderElement renderArgs body)
        ]


renderMathDisplay : FRender CYTMsg
renderMathDisplay rendArgs name args body meta =
    case getText body of
        Just content ->
            mathText rendArgs DisplayMathMode content meta

        Nothing ->
            el [ Font.color redColor ] (text "Error rendering math !!!")


renderMath : FRender CYTMsg
renderMath renderArgs name args body meta =
    case getText body of
        Just content ->
            mathText renderArgs InlineMathMode content meta

        Nothing ->
            el [ Font.color redColor ] (text "Error rendering math !!!")


mathText : RenderArgs -> DisplayMode -> String -> Maybe Metadata -> E.Element CYTMsg
mathText renderArgs displayMode content meta =
    Html.Keyed.node "span"
        []
        [ ( String.fromInt renderArgs.generation, mathText_ displayMode renderArgs.selectedId content meta )
        ]
        |> E.html


mathText_ : DisplayMode -> String -> String -> Maybe Metadata -> Html CYTMsg
mathText_ displayMode selectedId content meta =
    Html.node "math-text"
        -- active meta selectedId  ++
        [ HA.property "display" (Json.Encode.bool (isDisplayMathMode displayMode))
        , HA.property "content" (Json.Encode.string content)

        -- , clicker meta
        -- , HA.id (makeId meta)
        ]
        []


isDisplayMathMode : DisplayMode -> Bool
isDisplayMathMode displayMode =
    case displayMode of
        InlineMathMode ->
            False

        DisplayMathMode ->
            True



-- MATH
-- HELPERS
-- active : SourceMap -> String -> List (Attribute LaTeXMsg)
-- active meta selectedId =
--     let
--         id_ =
--             makeId meta
--     in
--     [ clicker meta, HA.id id_, highlight "#FAA" selectedId id_ ]
-- clicker meta =
--     onClick (SendSourceMap meta)
-- COLORS


linkColor =
    E.rgb 0 0 0.8


blackColor =
    E.rgb 0 0 0


medGray =
    E.rgb 0.4 0.4 0.4


redColor =
    E.rgb 0.7 0 0


blueColor =
    E.rgb 0 0 0.8


darkBlueColor =
    E.rgb 0 0 0.6


yellowColor =
    E.rgb 1.0 1.0 0


violetColor =
    E.rgb 0.4 0 0.8


codeColor =
    -- E.rgb 0.2 0.5 1.0
    E.rgb 0.4 0 0.8
