module Util.Time exposing ( ContentWidth
                          , Factor
                          , Milliseconds
                          , Offset
                          , Label
                          , Conversion
                          , calcConversion
                          , screenToTime
                          , timeToScreen
                          , minTimeStep
                          , label
                          , foo
                          )

import Time as T exposing (Posix)

import List as L
import String as Str

type alias ContentWidth = Float
type alias Offset = Int
type alias Factor = Float
type alias Milliseconds = Int
type alias Start = Milliseconds
type alias End = Milliseconds
type alias Interval = Milliseconds
type alias Current = Milliseconds
type alias Conversion = (Offset, Factor)

type alias Label =
  { x : Int
  , content : String
  }

type TimeStep
  = Millisecond Int
  | Second Int
  | Minute Int
  | Hour Int
  | Day Int
  | Weekday Int
  | Month Int
  | Year Int


year = 1000 * 60 * 60 * 24 * 30 * 12
month = 1000 * 60 * 60 * 24 * 30
day = 1000 * 60 * 60 * 24
hour = 1000 * 60 * 60
minute = 1000 * 60
second = 1000
millisecond = 1

zone = T.customZone (3 * 60) []

testRange =
  let
    startVal = 1580270841000 -- 1325376000000
    endVal = 1895890499000 -- 1325793600000
    w = 3180 -- 1580
    c = calcConversion startVal endVal w
    mt = minTimeStep 7 c
    step = calcStep mt
    _ = Debug.log "step" step
    i = interval startVal endVal
    res = axisRange step i startVal
    r = L.indexedMap (\idx v -> v idx) res
  in
    L.map displayTime r

minTimeStep : Float -> Conversion -> Milliseconds
minTimeStep cw c = screenToTime (cw * 6) c - Tuple.first c

foo = Debug.log "hi" testRange

toLabel c ms =
  (timeToScreen ms c, displayHour ms)

axisRange : TimeStep -> Interval -> Start -> List (Int -> Int)
axisRange s i ms =
  case s of
    Year step ->
      let k = round <| toFloat i / toFloat (year * step)
      in L.repeat k (\x -> ms + year * (step * x))
    Month step ->
      let k = round <| toFloat i / toFloat (month * step)
      in L.repeat k (\x -> ms + month * (step * x))
    Day step ->
      let k = round <| toFloat i / toFloat (day * step)
      in L.repeat k (\x -> ms + day * (step * x))
    Hour step ->
      let k = round <| toFloat i / toFloat (hour * step)
      in L.repeat k (\x -> ms + hour * (step * x))
    Minute step ->
      let k = round <| toFloat i / toFloat (minute * step)
      in L.repeat k (\x -> ms + minute * (step * x))
    Second step ->
      let k = round <| toFloat i / toFloat (second * step)
      in L.repeat k (\x -> ms + second * (step * x))
    Millisecond step ->
      let k = round <| toFloat i / toFloat (millisecond * step)
      in L.repeat k (\x -> ms + millisecond * (step * x))
    _ -> []
    
displayHour ms =
  Str.fromInt (T.toHour zone (T.millisToPosix ms))
  ++ ":" ++
  Str.fromInt (T.toMinute zone (T.millisToPosix ms))

displayTime ms =
    Str.fromInt (T.toYear zone (T.millisToPosix ms))
    ++ ":" ++
    toDisplayMonth (T.toMonth zone (T.millisToPosix ms))
    ++ ":" ++
    Str.fromInt (T.toDay zone (T.millisToPosix ms))
    ++ ":" ++
    Str.fromInt (T.toHour zone (T.millisToPosix ms))
    ++ ":" ++
    Str.fromInt (T.toMinute zone (T.millisToPosix ms))
    ++ ":" ++
    Str.fromInt (T.toSecond zone (T.millisToPosix ms))


interval : Start -> End -> Interval
interval start end =
  end - start

calcStep : Milliseconds -> TimeStep
calcStep v =
    if v > year * 40
    then
      let step = round <| toFloat v / toFloat year
      in Year step
    else if year > v && month < v
    then
      let step = round <| toFloat v / toFloat month
      in Month step
    else if month > v && day < v
    then
      let step = round <| toFloat v / toFloat day
      in Day step
    else if day > v && hour < v
    then
      let step = round <| toFloat v / toFloat hour
      in Hour step
    else if hour > v && minute < v
    then
      let step = round <| toFloat v / toFloat minute
      in Minute step
    else if minute > v && second < v
    then
      let step = round <| toFloat v / toFloat second
      in Second step
    else if second > v && millisecond < v
    then
      let step = round <| toFloat v / toFloat millisecond
      in Millisecond step
    else Second 10


calcConversion : Start -> End -> ContentWidth -> Conversion
calcConversion start end w =
  ( start, w / toFloat (end - start) )

numOfMonth : T.Month -> Int
numOfMonth m =
  case m of
    T.Jan -> 0
    T.Feb -> 1
    T.Mar -> 2
    T.Apr -> 3
    T.May -> 4
    T.Jun -> 5
    T.Jul -> 6
    T.Aug -> 7
    T.Sep -> 8
    T.Oct -> 9
    T.Nov -> 10
    T.Dec -> 11

toDisplayWeekday : T.Weekday -> String
toDisplayWeekday weekday =
  case weekday of
    T.Mon -> "пн"
    T.Tue -> "вт"
    T.Wed -> "ср"
    T.Thu -> "чт"
    T.Fri -> "пт"
    T.Sat -> "сб"
    T.Sun -> "вс"

toDisplayMonth : T.Month -> String
toDisplayMonth m =
  case m of
    T.Jan -> "янв"
    T.Feb -> "фев"
    T.Mar -> "мар"
    T.Apr -> "апр"
    T.May -> "май"
    T.Jun -> "июн"
    T.Jul -> "июл"
    T.Aug -> "авг"
    T.Sep -> "сен"
    T.Oct -> "окт"
    T.Nov -> "ноя"
    T.Dec -> "дек"


label : TimeStep -> Milliseconds -> String
label s t =
  case s of
    Millisecond _ -> Str.fromInt <| T.toMillis zone (T.millisToPosix t)
    Second _ -> Str.fromInt <| T.toSecond zone (T.millisToPosix t)
    Minute _ ->
      let
        h = Str.fromInt <| T.toHour zone (T.millisToPosix t)
        m = Str.fromInt <| T.toMinute zone (T.millisToPosix t)
      in
      (Str.padLeft 2 '0' h) ++ ":" ++ (Str.padLeft 2 '0' m)
    Hour _ ->
      let
        h = Str.fromInt <| T.toHour zone (T.millisToPosix t)
        m = Str.fromInt <| T.toMinute zone (T.millisToPosix t)
      in
      (Str.padLeft 2 '0' h) ++ ":" ++ (Str.padLeft 2 '0' m)
    Weekday _ ->
      let
        w = T.toWeekday zone (T.millisToPosix t)
        d = Str.fromInt <| T.toDay zone (T.millisToPosix t)
      in
      toDisplayWeekday w ++ " " ++ d
    Day _ -> Str.fromInt <| T.toDay zone (T.millisToPosix t)
    Month _ -> toDisplayMonth <| T.toMonth zone (T.millisToPosix t)
    Year _ -> Str.fromInt <| T.toYear zone (T.millisToPosix t)

setMilliseconds : Int -> Milliseconds -> Milliseconds
setMilliseconds v ms =
  let offset = v - T.toMillis zone (T.millisToPosix ms)
  in ms + (millisecond * offset)

setSeconds : Int -> Milliseconds -> Milliseconds
setSeconds v ms =
  let offset = v - T.toSecond zone (T.millisToPosix ms)
  in ms + (second * offset)

setMinutes : Int -> Milliseconds -> Milliseconds
setMinutes v ms =
  let offset = v - T.toMinute zone (T.millisToPosix ms)
  in ms + (minute * offset)

setHours : Int -> Milliseconds -> Milliseconds
setHours v ms =
  let offset = v - T.toHour zone (T.millisToPosix ms)
  in ms + (hour * offset)

setDay : Int -> Milliseconds -> Milliseconds
setDay v ms =
  let offset = v - T.toDay zone (T.millisToPosix ms)
  in ms + (day * offset)

setMonth : Int -> Milliseconds -> Milliseconds
setMonth v ms =
  let offset = v - numOfMonth (T.toMonth zone (T.millisToPosix ms))
  in ms + (month * offset) + day

setYear : Int -> Milliseconds -> Milliseconds
setYear v ms =
  let offset = v - T.toYear zone (T.millisToPosix ms)
  in ms + (year * offset)

screenToTime : Float -> ( Offset, Factor ) -> Milliseconds
screenToTime v ( o, f ) = round <| v / f + toFloat o

timeToScreen : Milliseconds -> ( Offset, Factor ) -> Int
timeToScreen v ( o, f ) = round <| (toFloat v - toFloat o) * f

