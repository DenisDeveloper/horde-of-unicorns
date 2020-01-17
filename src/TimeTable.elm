module TimeTable exposing (view)

import Html exposing (Html, div, text)
import Html.Attributes exposing (class)

import Svg as S exposing (svg, rect, text_)
import Svg.Attributes as SA exposing (width, height, viewBox)

import List as L
import String as Str

import AppModel exposing (Model)
import AppMsg exposing (Msg)

timeRange = L.range 1 31

title : Int -> Int -> String -> S.Svg Msg
title x y v =
  text_ [ SA.x (Str.fromInt x)
        , SA.y (Str.fromInt y)
        ]
        [text v]

titles : Int -> List Int -> List (S.Svg Msg)
titles h =
  L.map (\i -> title (i * 20) (h - 20) (Str.fromInt i))

view : Model -> Html Msg
view model =
  div [class "time-table"]
      [ svg [ SA.id "time-table-view"
            , width "100%"
            , height "100%"
            ]
            <| titles (truncate model.viewportHeight) timeRange
      ]
