module Render.Elm exposing (paragraphs, renderElement, renderList, renderString)

import CYUtility
import Dict exposing (Dict)
import Element as E exposing (column, el, paragraph, px, row, spacing, text)
import Element.Background as Background
import Element.Font as Font
import Html exposing (Html)
import Html.Attributes as HA
import Html.Keyed
import Json.Encode
import List.Extra
import Maybe.Extra
import Parser.Data as Data
import Parser.Driver
import Parser.Element exposing (CYTMsg, Element(..))
import Parser.Metadata exposing (Metadata)
import Parser.TextCursor
import Render.Types exposing (DisplayMode(..), FRender, RenderArgs, RenderElementDict)
import Render.Utility
import String.Extra
import Widget.Data



-- import Widget.Simulations
-- STYLE PARAMETERS


textWidth =
    E.width (E.px 200)


format =
    []



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

        --case paragraphs str of
        --    [] ->
        --        E.none
        --
        --    [ str_ ] ->
        --        el [] (text str_)
        --
        --    list_ ->
        --        column [ spacing 12 ] (List.map text list_)
        Element name args body meta ->
            renderWithDictionary renderArgs name args body meta

        LX list_ _ ->
            paragraph format (List.map (renderElement renderArgs) list_)


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
                renderMissingElement name body

        Just f ->
            f renderArgs name args body meta


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
        , ( "bold", renderStrong )
        , ( "b", renderStrong )
        , ( "italic", renderItalic )
        , ( "i", renderItalic )
        , ( "highlight", highlight )
        , ( "highlightRGB", highlightRGB )
        , ( "fontRGB", fontRGB )
        , ( "code", renderCode )
        , ( "codeblock", codeblock )
        , ( "verbatim", verbatim )
        , ( "poetry", poetry )
        , ( "title", docTitle )
        , ( "section", section )
        , ( "section1", section )
        , ( "section2", section2 )
        , ( "section3", section3 )
        , ( "list", list )
        , ( "data", dataTable )
        , ( "item", item )
        , ( "link", link )
        , ( "image", image )
        , ( "math", renderMath )
        , ( "m", renderMath )
        , ( "displaymath", renderMathDisplay )
        , ( "dm", renderMathDisplay )
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


dataTable : FRender CYTMsg
dataTable renderArgs name args_ body meta =
    let
        rawData : List (List String)
        rawData =
            Render.Utility.getCSV body
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
            E.row [ E.spacing 8 ] [ prefixSymbol, renderElement renderArgs elt ]

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
        , Font.size 14
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
        , indentation
        ]
        (List.map text (getLines (getText2 body |> String.trim)))


verbatim : FRender CYTMsg
verbatim renderArgs _ _ body meta =
    column
        [ Font.family
            [ Font.typeface "Inconsolata"
            , Font.monospace
            ]
        , Font.size 14
        , Render.Utility.htmlAttribute "white-space" "pre"
        , Render.Utility.htmlAttribute "line-height" "1.5"
        , indentation
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
    column [ Font.size titleFontSize, paddingAbove (round <| 0.8 * sectionFontSize) ] [ text <| getLabel meta ++ " " ++ (getText body |> Maybe.withDefault "no section name found") ]


section : FRender CYTMsg
section renderArgs name args body meta =
    column [ Font.size sectionFontSize, paddingAbove (round <| 0.8 * sectionFontSize) ] [ text <| getLabel meta ++ " " ++ (getText body |> Maybe.withDefault "no section name found") ]


section2 : FRender CYTMsg
section2 renderArgs name args body meta =
    column [ Font.size section2FontSize, paddingAbove (round <| 0.8 * section2FontSize) ] [ text <| getLabel meta ++ " " ++ (getText body |> Maybe.withDefault "no subsection name found") ]


section3 : FRender CYTMsg
section3 renderArgs name args body meta =
    column [ Font.size section3FontSize, paddingAbove (round <| 0.8 * section3FontSize) ] [ text (getText body |> Maybe.withDefault "no subsubsection name found") ]


center : FRender CYTMsg
center renderArgs name args body meta =
    column [ E.centerX ] [ renderElement renderArgs body ]


indent : FRender CYTMsg
indent renderArgs name args body meta =
    column [ indentPadding ] [ renderElement renderArgs body ]


paddingAbove k =
    E.paddingEach { top = k, bottom = 0, left = 0, right = 0 }


titleFontSize =
    30


sectionFontSize =
    24


section2FontSize =
    18


section3FontSize =
    16


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
                    E.row [ E.centerX ] [ el [ E.width E.fill ] (text c) ]

        width =
            case Dict.get "width" dict of
                Nothing ->
                    E.fill

                Just w_ ->
                    case String.toInt w_ of
                        Nothing ->
                            E.fill

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
    in
    E.column [ spacing 8, placement, E.width (E.px 400) ]
        [ E.image [ E.width width, placement ]
            { src = getText body |> Maybe.withDefault "no image url", description = description }
        , caption
        ]


renderStrong : FRender CYTMsg
renderStrong renderArgs _ _ body meta =
    el [ Font.bold ] (renderElement renderArgs body)


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


redColor =
    E.rgb 0.7 0 0


blueColor =
    E.rgb 0 0 0.8


yellowColor =
    E.rgb 1.0 1.0 0


violetColor =
    E.rgb 0.4 0 0.8


codeColor =
    -- E.rgb 0.2 0.5 1.0
    E.rgb 0.4 0 0.8
