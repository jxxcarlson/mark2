module Render.Utility exposing
    ( captionElement
    , extractText
    , getArg_
    , getCSV
    , getColumn
    , getInt
    , getPoints
    , getPrecisionWithDefault
    , htmlAttribute
    , makePair
    )

import Dict exposing (Dict)
import Element as E
import Element.Font as Font
import Html.Attributes
import List.Extra
import Maybe.Extra
import Parser.Element exposing (Element(..), Mark2Msg)
import Utility


htmlAttribute : String -> String -> E.Attribute msg
htmlAttribute key value =
    E.htmlAttribute (Html.Attributes.attribute key value)


getPrecisionWithDefault : Int -> List String -> Int
getPrecisionWithDefault default args =
    getPrecision args |> Maybe.withDefault default


getPrecision : List String -> Maybe Int
getPrecision args =
    let
        dict =
            Utility.keyValueDict args
    in
    Dict.get "precision" dict |> Maybe.andThen String.toInt


makePair : List Float -> Maybe ( Float, Float )
makePair ns =
    case ns of
        [ x, y ] ->
            Just ( x, y )

        _ ->
            Nothing


getPoints : Dict String String -> Element -> List ( Float, Float )
getPoints dict body =
    let
        toInt_ : Int -> String -> Int
        toInt_ default str =
            String.toInt str |> Maybe.withDefault default

        ( col1, col2 ) =
            case ( Dict.get "col1" dict, Dict.get "col2" dict ) of
                ( Just i, Just j ) ->
                    ( toInt_ 0 i - 1, toInt_ 1 j - 1 )

                _ ->
                    ( 0, 1 )

        xcutoff =
            Dict.get "xcutoff" dict |> Maybe.andThen String.toFloat

        ycutoff =
            Dict.get "ycutoff" dict |> Maybe.andThen String.toFloat

        rawData : List (List String)
        rawData =
            getCSV body

        getDataColumns : Int -> Int -> List (List String) -> List (List (Maybe String))
        getDataColumns i j data =
            List.map (\column -> [ List.Extra.getAt i column, List.Extra.getAt j column ]) rawData

        xfilter points_ =
            case xcutoff of
                Just xcutoffValue ->
                    List.filter (\( x, y ) -> x < xcutoffValue) points_

                _ ->
                    points_

        yfilter points_ =
            case ycutoff of
                Just ycutoffValue ->
                    List.filter (\( x, y ) -> y < ycutoffValue) points_

                _ ->
                    points_
    in
    body
        |> getCSV
        |> getDataColumns col1 col2
        |> List.map Maybe.Extra.values
        |> List.map (List.map String.toFloat)
        |> List.map Maybe.Extra.values
        |> List.map makePair
        |> Maybe.Extra.values
        |> xfilter
        |> yfilter


getCSV : Element -> List (List String)
getCSV element =
    case element of
        LX list_ _ ->
            case List.map extractText list_ of
                [ Just data ] ->
                    data
                        |> String.split "\n"
                        |> List.map (String.split ",")
                        |> List.map (List.map String.trim)

                _ ->
                    [ [] ]

        _ ->
            [ [] ]


extractText : Element -> Maybe String
extractText element =
    case element of
        Text content _ ->
            Just content

        _ ->
            Nothing


getColumn : Dict String String -> Element -> List Float
getColumn dict body =
    let
        toInt_ : Int -> String -> Int
        toInt_ default str =
            String.toInt str |> Maybe.withDefault default

        col =
            case Dict.get "column" dict of
                Just i ->
                    toInt_ 0 i - 1

                _ ->
                    0

        cutoff =
            Dict.get "cutoff" dict |> Maybe.andThen String.toFloat

        rawData : List (List String)
        rawData =
            getCSV body

        getDataColumn : Int -> List (List String) -> List (Maybe String)
        getDataColumn i data =
            List.map (\column -> List.Extra.getAt i column) rawData

        filter data_ =
            case cutoff of
                Just cutoffValue ->
                    List.filter (\x -> x < cutoffValue) data_

                _ ->
                    data_
    in
    body
        |> getCSV
        |> getDataColumn col
        |> Maybe.Extra.values
        |> List.map String.toFloat
        |> Maybe.Extra.values
        |> filter


captionElement dict =
    case Dict.get "caption" dict of
        Just caption ->
            E.paragraph [ Font.bold ] [ E.text caption ]

        Nothing ->
            E.none


getInt : Int -> List String -> Int
getInt k stringList =
    List.Extra.getAt k stringList
        |> Maybe.andThen String.toInt
        |> Maybe.withDefault 0


getArg_ : Int -> List String -> Maybe String
getArg_ k stringList =
    List.Extra.getAt k stringList


getArg : Int -> String -> List String -> String
getArg k default stringList =
    List.Extra.getAt k stringList |> Maybe.withDefault default
