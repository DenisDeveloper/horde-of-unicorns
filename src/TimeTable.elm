module TimeTable exposing (view)

import Html exposing (Html, div, text)
import Html.Attributes exposing (class)

import Svg as S exposing (Svg, svg)
import Svg.Attributes as SA exposing (width, height, viewBox)

import List as L
import String as Str

import AppModel exposing (Model)
import AppMsg exposing (Msg)

import Util.Time as UT

-- timeRange = L.range 1 31

timeRange =
  [ 29.94977536123669
  , 94.31126510969952
  , 165.56862875978337
  , 234.52736777599355
  , 305.7847314260774
  , 374.74347044228756
  , 446.00083409237146
  , 517.2581977424553
  , 586.2169367586655
  , 657.4743004087493
  , 726.4330394249595
  , 797.6904030750434
  , 868.9477667251272
  , 933.30925647359
  , 1004.5666201236739
  , 1073.5253591398841
  , 1144.782722789968
  , 1213.741461806178
  , 1284.998825456262
  , 1356.2561891063458
  , 1425.214928122556
  , 1496.47229177264
  , 1565.43103078885
  , 1636.688394438934
  , 1707.9457580890178
  ]

title : Float -> Int -> String -> Svg Msg
title x y v =
  S.text_ [ SA.x (Str.fromFloat x)
          , SA.y (Str.fromInt y)]
          [text v]

titles : Int -> List Float -> Svg Msg
titles h xs =
  S.g [SA.class "axis"]
  <| L.indexedMap (\i x -> title x (h - 20) (Str.fromInt i)) xs

-- const s = 1516306657000;
-- const e = 1579378808000;

view : Model -> Html Msg
view model =
  let
    start = 1516306657000
    end = 1579378808000
    charWidth = 7.81
    w = 1396
    conversion = UT.calcConversion 1516306657000 1579378808000 w
    minStep = UT.minimumStep charWidth conversion
    s = UT.setMinimumStep (toFloat (truncate minStep))
    cur = UT.start s start
    _ = Debug.log "elm Scale" s
    _ = Debug.log "elm start" cur
    _ = Debug.log "elm next" (UT.next s end cur)
  in
  div [class "time-table"]
      [ svg [ SA.id "time-table-view"
            , width "100%"
            , height "100%"
            ]
            [(titles (truncate model.viewportHeight) timeRange)]
      ]
