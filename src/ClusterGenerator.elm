module ClusterGenerator exposing (generate)

import List as L
import Array as A exposing (Array)
import Job exposing (DisplayJob)

type alias Scale = Float
type alias Granularity = Int
type alias TimeWindow = Int
type alias Neighbors = Int

granularity : Granularity
granularity = 2

-- fibIter a b c =
--   case c of
--     0 -> b
--     _ -> fibIter (a + b) a (c - 1)
--
-- fib n =
--   fibIter 1 0 n
log =
  logBase e

getTimeWindow : Scale -> Granularity -> TimeWindow
getTimeWindow s g =
  if s > 0 then
     (^) g <| round <| log (100 / s) / (log <| toFloat g)
  else 0

while : (a -> Bool) -> (a -> a) -> a -> a
while p f v =
  if p v
  then while p f (f v)
  else v

-- addCluster

getClusters : Int -> TimeWindow -> Neighbors -> Array DisplayJob -> Int
getClusters i tw n xs =
  let
    item = A.get i xs
    _ = Debug.log "item" i
    neighbors =
      case item of
        Just v ->
          if (i - 1) >= 0
          then scanToRight v.center tw (scanToLeft v.center tw n <| A.slice 0 i xs) xs
          else scanToRight v.center tw n <| A.slice (i + 1) (A.length xs) xs
        Nothing -> n
    -- num =
    -- _ = Debug.log "nth" f
    _ = Debug.log "neighbors" neighbors
  in
    if neighbors > 1 then neighbors + i
    else (i + 1)


-- loopl j c1 c2 w
scanToLeft : Float -> TimeWindow -> Neighbors -> Array DisplayJob -> Neighbors
scanToLeft c tw n xs =
  let
    -- _ = Debug.log "scaltoleft" c
    scan item acc =
      if c - item.center < (toFloat tw) / 2
      then acc + 1
      else acc
  in
    A.foldr scan n xs

scanToRight : Float -> TimeWindow -> Neighbors -> Array DisplayJob -> Neighbors
scanToRight c tw n xs =
  let
    _ = Debug.log "scanToRight" c
    scan item acc =
      let
        _ = Debug.log "it1" (item.center - c)
        _ = Debug.log "it2" ((toFloat tw) / 2)
      in
        if item.center - c < (toFloat tw) / 2
        then acc + 1
        else acc
  in
    A.foldl scan n xs

generate : Scale -> Array DisplayJob -> Int
generate s xs =
  let
    -- _ = Debug.log "loop" (getTimeWindow s granularity)
    len = A.length xs
    _ = Debug.log "len" len
    -- ghh = (1, 2, 4, 5, 6)
    -- (_, ff) = getClusters
    timeWindow = getTimeWindow s 2
    _ = Debug.log "while"
      (while ((>) len)
        (\i -> getClusters i timeWindow 1 xs) 0)
    -- _ = Debug.log "fact" (fst [1, 2])
    -- maxItems = 1
    -- getClusters i =
    --   if i < len then
    --     getClusters (i + 1)
    --   else i
  in
    0
    -- getClusters 0
