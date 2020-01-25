module Util.Time exposing ( ContentWidth
                          , Factor
                          , Milliseconds
                          , Offset
                          , Label
                          , Conversion
                          , calcConversion
                          , displayToMs
                          , msToDisplay
                          , minimumStep
                          , setMinimumStep
                          , label
                          , labelRange
                          , marginRange
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
type alias Current = Milliseconds
type alias Conversion = (Offset, Factor)

type alias Label =
  { x : Int
  , content : String
  }

type Scale
  = Millisecond Int
  | Second Int
  | Minute Int
  | Hour Int
  | Day Int
  | Weekday Int
  | Month Int
  | Year Int


stepYear = 1000 * 60 * 60 * 24 * 30 * 12
stepMonth = 1000 * 60 * 60 * 24 * 30
stepDay = 1000 * 60 * 60 * 24
stepHour = 1000 * 60 * 60
stepMinute = 1000 * 60
stepSecond = 1000
stepMillisecond = 1

characterMinorWidth = 8

zone = T.customZone (3 * 60) []



-- labelRangeHelp cur acc =

labelRange : Start -> End -> Scale -> Conversion -> List Label
labelRange start end s c =
  let
    startValue = roundStart s start
    -- iter : Current -> List Current -> List Current
    iter cur acc =
      let
        x = msToDisplay cur c
        content = label s cur
        val = {x = x, content = content}
      in
      if not <| isEnd cur end
      then iter (next s end cur) (acc ++ [val])
      else acc ++ [val]
  in
  iter startValue [] -- startValue




minimumStep : Float -> Conversion -> Float
minimumStep w c =
  (displayToMs (w * 6) c) - (displayToMs 0 c)

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
toDisplayMonth month =
  case month of
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

-- const displayToMs = (x, conversion) => {
--   return new Date(x / conversion.factor + conversion.offset);
-- };

label : Scale -> Milliseconds -> String
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
  let
    offset = v - T.toMillis zone (T.millisToPosix ms)
  in
  ms + (stepMillisecond * offset)

setSeconds : Int -> Milliseconds -> Milliseconds
setSeconds v ms =
  let
    offset = v - T.toSecond zone (T.millisToPosix ms)
  in
  ms + (stepSecond * offset)

setMinutes : Int -> Milliseconds -> Milliseconds
setMinutes v ms =
  let
    offset = v - T.toMinute zone (T.millisToPosix ms)
  in
  ms + (stepMinute * offset)

setHours : Int -> Milliseconds -> Milliseconds
setHours v ms =
  let
    offset = v - T.toHour zone (T.millisToPosix ms)
  in
  ms + (stepHour * offset)

setDay : Int -> Milliseconds -> Milliseconds
setDay v ms =
  let
    offset = v - T.toDay zone (T.millisToPosix ms)
  in
  ms + (stepDay * offset)

setMonth : Int -> Milliseconds -> Milliseconds
setMonth v ms =
  let
    offset = v - numOfMonth (T.toMonth zone (T.millisToPosix ms))
  in
  ms + (stepMonth * offset) + stepDay

setYear : Int -> Milliseconds -> Milliseconds
setYear v ms =
  let
    offset = v - T.toYear zone (T.millisToPosix ms)
  in
  ms + (stepYear * offset)

marginRange : Start -> End -> (Start, End)
marginRange a b =
  let
    diff = toFloat (b - a)
    startValue = (toFloat a) - diff * 0.05
    endValue = (toFloat b) + diff * 0.05
    -- _ = Debug.log "start value" startValue
    -- _ = Debug.log "end value" (truncate 2)
  in
  (round startValue, round endValue)


displayToMs : Float -> ( Offset, Factor ) -> Float
displayToMs v ( o, f ) =
  v / f + toFloat o

msToDisplay : Milliseconds -> ( Offset, Factor ) -> Int
msToDisplay v ( o, f ) =
  round <| (toFloat v - toFloat o) * f

setMinimumStep : Float -> Scale
setMinimumStep m =
  if stepYear * 1000 > m && stepYear * 500 < m then Year 1000
  else if stepYear * 500 > m && stepYear * 100 < m then Year 500
  else if stepYear * 100 > m && stepYear * 50 < m then Year 100
  else if stepYear * 50 > m && stepYear * 10 < m then Year 50
  else if stepYear * 10 > m && stepYear * 5 < m then Year 10
  else if stepYear * 5 > m && stepYear < m then Year 5
  else if stepYear > m && stepMonth * 3 < m then Year 1
  else if stepMonth * 3 > m && stepMonth < m then Month 3
  else if stepMonth > m && stepDay * 5 < m then Month 1
  else if stepDay * 5 > m && stepDay * 2 < m then Day 5
  else if stepDay * 2 > m && stepDay < m then Day 2
  else if stepDay > m && stepDay / 2 < m then Day 1
  else if stepDay / 2 > m && stepHour * 4 < m then Weekday 1
  else if stepHour * 4 > m && stepHour < m then Hour 4
  else if stepHour > m && stepMinute * 15 < m then Hour 1
  else if stepMinute * 15 > m && stepMinute * 10 < m then Minute 15
  else if stepMinute * 10 > m && stepMinute * 5 < m then Minute 10
  else if stepMinute * 5 > m && stepMinute < m then Minute 5
  else if stepMinute > m && stepSecond * 15 < m then Minute 1
  else if stepSecond * 15 > m && stepSecond * 10 < m then Second 15
  else if stepSecond * 10 > m && stepSecond * 5 < m then Second 10
  else if stepSecond * 5 > m && stepSecond < m then Second 5
  else if stepSecond > m && stepMillisecond * 200 < m then Second 1
  else if stepMillisecond * 200 > m && stepMillisecond * 100 < m then Millisecond 200
  else if stepMillisecond * 100 > m && stepMillisecond * 50 < m then Millisecond 100
  else if stepMillisecond * 50 > m && stepMillisecond * 10 < m then Millisecond 50
  else if stepMillisecond * 10 > m && stepMillisecond * 5 < m then Millisecond 10
  else if stepMillisecond * 5 > m && stepMillisecond < m then Millisecond 5
  else if stepMillisecond > m then Millisecond 1
  else Day 1


roundToMinor : Scale -> Milliseconds -> Milliseconds
roundToMinor s ms =
  let
    t =
      case s of
        Year step ->
          let
            y = T.toYear zone (T.millisToPosix ms)
          in
          setYear (step * floor ((toFloat y) / (toFloat step))) ms
          |> setMonth 0
          |> setDay 1
          |> setHours 0
          |> setMinutes 0
          |> setSeconds 0
          |> setMilliseconds 0
        Month _ ->
          setDay 1 ms
          |> setHours 0
          |> setMinutes 0
          |> setSeconds 0
          |> setMilliseconds 0
        Hour _ ->
          setMinutes 0 ms
          |> setSeconds 0
          |> setMilliseconds 0
        Minute _ ->
          setSeconds 0 ms
          |> setMilliseconds 0
        Second _ -> setMilliseconds 0 ms
        Millisecond _ -> ms
        _ ->
          setHours 0 ms
          |> setMinutes 0
          |> setSeconds 0
          |> setMilliseconds 0
        -- _ -> 1
  in
  case s of
    Millisecond step ->
      if step /= 1 then
        let v = T.toMillis zone (T.millisToPosix t)
        in setMilliseconds (v - (modBy step v)) t
      else t
    Second step ->
      if step /= 1 then
        let v = T.toSecond zone (T.millisToPosix t)
        in setSeconds (v - (modBy step v)) t
      else t
    Minute step ->
      if step /= 1 then
        let v = T.toMinute zone (T.millisToPosix t)
        in setMinutes (v - (modBy step v)) t
      else t
    Hour step ->
      if step /= 1 then
        let v = T.toHour zone (T.millisToPosix t)
        in setHours (v - (modBy step v)) t
      else t
    Weekday step ->
      if step /= 1 then
        let v = T.toDay zone (T.millisToPosix t)
        in setDay (v - (modBy step v)) t
      else t
    Day step ->
      if step /= 1 then
        let v = T.toDay zone (T.millisToPosix t)
        in setDay (v - (modBy step v)) t
      else t
    Month step ->
      if step /= 1 then
        let v = numOfMonth <| T.toMonth zone (T.millisToPosix t)
        in setMonth (v - (modBy step v)) t
      else t
    Year step ->
      if step /= 1 then
        let v = T.toYear zone (T.millisToPosix t)
        in setYear (v - (modBy step v)) t
      else t

roundStart : Scale -> Start -> Milliseconds
roundStart a b = roundToMinor a b

isEnd : Current -> End -> Bool
isEnd a b = a > b

next : Scale -> End -> Current -> Milliseconds
next s end current =
  let
    m = numOfMonth <| T.toMonth zone (T.millisToPosix current)
    -- _ = Debug.log "month" m
    res =
      if m < 6 then
        case s of
          Millisecond step -> current + step
          Second step -> current + step * stepSecond
          Minute step -> current + step * stepMinute
          Hour step ->
            let
              t = current + step * stepHour
              v = T.toHour zone (T.millisToPosix t)
            in setHours (v - (modBy step v)) t
          Weekday step ->
            let v = T.toDay zone (T.millisToPosix current)
            in setDay (v + step) current
          Day step ->
            let v = T.toDay zone (T.millisToPosix current)
            in setDay (v + step) current
          Month step ->
            let
              v = numOfMonth <| T.toMonth zone (T.millisToPosix current)
            in setMonth (v + step) current
          Year step ->
            let v = T.toYear zone (T.millisToPosix current)
            in setYear (v + step) current
      else
        case s of
          Millisecond step -> current + step
          Second step ->
            let v = T.toSecond zone (T.millisToPosix current)
            in setSeconds (v + step) current
          Minute step ->
            let v = T.toMinute zone (T.millisToPosix current)
            in setMinutes (v + step) current
          Hour step ->
            let v = T.toHour zone (T.millisToPosix current)
            in setHours (v + step) current
          Weekday step ->
            let v = T.toDay zone (T.millisToPosix current)
            in setDay (v + step) current
          Day step ->
            let v = T.toDay zone (T.millisToPosix current)
            in setDay (v + step) current
          Month step ->
            let v = numOfMonth <| T.toMonth zone (T.millisToPosix current)
            in setMonth (v + step) current
          Year step ->
            let v = T.toYear zone (T.millisToPosix current)
            in setYear (v + step) current
    r =
      case s of
        Millisecond step ->
          if step /= 1 then
            let v = T.toMillis zone (T.millisToPosix res)
            in if v < step then setMilliseconds 0 res else res
          else res
        Second step ->
          if step /= 1 then
            let v = T.toSecond zone (T.millisToPosix res)
            in if v < step then setSeconds 0 res else res
          else res
        Minute step ->
          if step /= 1 then
            let v = T.toMinute zone (T.millisToPosix res)
            in if v < step then setMinutes 0 res else res
          else res
        Hour step ->
          if step /= 1 then
            let v = T.toHour zone (T.millisToPosix res)
            in if v < step then setHours 0 res else res
          else res
        Weekday step ->
          if step /= 1 then
            let v = T.toDay zone (T.millisToPosix res)
            in if v < step + 1 then setDay 1 res else res
          else res
        Day step ->
          if step /= 1 then
            let v = T.toDay zone (T.millisToPosix res)
            in if v < step + 1 then setDay 1 res else res
          else res
        Month step ->
          if step /= 1 then
            let v = numOfMonth <| T.toMonth zone (T.millisToPosix res)
            in if v < step then setMonth 0 res else 0
          else res
        Year step -> res
  in
  if r == current then end else r
