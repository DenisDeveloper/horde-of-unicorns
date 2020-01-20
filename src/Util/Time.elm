module Util.Time exposing ( ContentWidth
                          , Factor
                          , Milliseconds
                          , Offset
                          , calcConversion
                          , screenToTime
                          , timeToScreen
                          )

import Time as T exposing (Posix)

type alias ContentWidth = Float
type alias Offset = Int
type alias Factor = Float
type alias Milliseconds = Int

type Scale
  = Milliseconds
  | Second
  | Minute
  | Hour
  | Day
  | Weekday
  | Month
  | Year


-- const characterMinorWidth = 8;
--
-- const minimumStep =
--   screenToTime(characterMinorWidth * 6, c) - screenToTime(0, c);

-- const SCALE = {
--   MILLISECOND: 1,
--   SECOND: 2,
--   MINUTE: 3,
--   HOUR: 4,
--   DAY: 5,
--   WEEKDAY: 6,
--   MONTH: 7,
--   YEAR: 8
-- };

characterMinorWidth = 8

minimumStep : Float -> (Offset, Factor) -> Float
minimumStep w c =
  (screenToTime (w * 6) c) - (screenToTime 0 c)

calcConversion : Milliseconds -> Milliseconds -> ContentWidth -> ( Offset, Factor )
calcConversion a b w =
  ( a, w / toFloat (b - a) )

-- const screenToTime = (x, conversion) => {
--   return new Date(x / conversion.factor + conversion.offset);
-- };

screenToTime : Float -> ( Offset, Factor ) -> Float
screenToTime v ( o, f ) =
  v / f + toFloat o

timeToScreen : Milliseconds -> ( Offset, Factor ) -> Int
timeToScreen v ( o, f ) =
  (v - o) * truncate f


-- setMinimumStep m =
--   let
--     scale = Day
--     step = 1
--     stepYear = 1000 * 60 * 60 * 24 * 30 * 12
--     stepMonth = 1000 * 60 * 60 * 24 * 30
--     stepDay = 1000 * 60 * 60 * 24
--     stepHour = 1000 * 60 * 60
--     stepMinute = 1000 * 60
--     stepSecond = 1000
--     stepMillisecond = 1
--   in
--   if stepYear * 1000 > m
--   then
--     scale = SCALE.YEAR;
--     step = 1000;
--   }
--   if (stepYear * 500 > minimumStep) {
--     scale = SCALE.YEAR;
--     step = 500;
--   }
--   if (stepYear * 100 > minimumStep) {
--     scale = SCALE.YEAR;
--     step = 100;
--   }
--   if (stepYear * 50 > minimumStep) {
--     scale = SCALE.YEAR;
--     step = 50;
--   }
--   if (stepYear * 10 > minimumStep) {
--     scale = SCALE.YEAR;
--     step = 10;
--   }
--   if (stepYear * 5 > minimumStep) {
--     scale = SCALE.YEAR;
--     step = 5;
--   }
--   if (stepYear > minimumStep) {
--     scale = SCALE.YEAR;
--     step = 1;
--   }
--   if (stepMonth * 3 > minimumStep) {
--     scale = SCALE.MONTH;
--     step = 3;
--   }
--   if (stepMonth > minimumStep) {
--     scale = SCALE.MONTH;
--     step = 1;
--   }
--   if (stepDay * 5 > minimumStep) {
--     scale = SCALE.DAY;
--     step = 5;
--   }
--   if (stepDay * 2 > minimumStep) {
--     scale = SCALE.DAY;
--     step = 2;
--   }
--   if (stepDay > minimumStep) {
--     scale = SCALE.DAY;
--     step = 1;
--   }
--   if (stepDay / 2 > minimumStep) {
--     scale = SCALE.WEEKDAY;
--     step = 1;
--   }
--   if (stepHour * 4 > minimumStep) {
--     scale = SCALE.HOUR;
--     step = 4;
--   }
--   if (stepHour > minimumStep) {
--     scale = SCALE.HOUR;
--     step = 1;
--   }
--   if (stepMinute * 15 > minimumStep) {
--     scale = SCALE.MINUTE;
--     step = 15;
--   }
--   if (stepMinute * 10 > minimumStep) {
--     scale = SCALE.MINUTE;
--     step = 10;
--   }
--   if (stepMinute * 5 > minimumStep) {
--     scale = SCALE.MINUTE;
--     step = 5;
--   }
--   if (stepMinute > minimumStep) {
--     scale = SCALE.MINUTE;
--     step = 1;
--   }
--   if (stepSecond * 15 > minimumStep) {
--     scale = SCALE.SECOND;
--     step = 15;
--   }
--   if (stepSecond * 10 > minimumStep) {
--     scale = SCALE.SECOND;
--     step = 10;
--   }
--   if (stepSecond * 5 > minimumStep) {
--     scale = SCALE.SECOND;
--     step = 5;
--   }
--   if (stepSecond > minimumStep) {
--     scale = SCALE.SECOND;
--     step = 1;
--   }
--   if (stepMillisecond * 200 > minimumStep) {
--     scale = SCALE.MILLISECOND;
--     step = 200;
--   }
--   if (stepMillisecond * 100 > minimumStep) {
--     scale = SCALE.MILLISECOND;
--     step = 100;
--   }
--   if (stepMillisecond * 50 > minimumStep) {
--     scale = SCALE.MILLISECOND;
--     step = 50;
--   }
--   if (stepMillisecond * 10 > minimumStep) {
--     scale = SCALE.MILLISECOND;
--     step = 10;
--   }
--   if (stepMillisecond * 5 > minimumStep) {
--     scale = SCALE.MILLISECOND;
--     step = 5;
--   }
--   if (stepMillisecond > minimumStep) {
--     scale = SCALE.MILLISECOND;
--     step = 1;
--   }
--   return { scale, step };
