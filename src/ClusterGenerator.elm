module ClusterGenerator exposing (generate, updateNth)

import List as L
import Array as A exposing (Array, foldl, indexedMap, slice, length)
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

appendItems : (a -> Bool) -> (a -> a) -> a -> a
appendItems p f v =
  if p v
  then while p f (f v)
  else v
-- addCluster

arr = A.fromList [4, 5, 9, 10, 40, 50, 56]

sdam : Array Float -> Float
sdam xs =
  let mean = foldl (+) 0 xs / (toFloat <| length xs)
  in foldl (\x sum -> sum + (x - mean) ^ 2) 0 xs

sdcm n xs =
  let (left, right) = splitArray n xs
  in (sdam left) + (sdam right)

splitArray n xs =
  (slice 0 n xs, slice n (length xs) xs)

when p f v =
  if p v
  then f v
  else v

gvf xs =
  let
    init = (sdcm 1 xs, 0)
    iter n v =
      let
        (val, idx) = v
        sdcmVal = (sdcm n xs)
        res = if sdcmVal < val
              then (sdcmVal, n)
              else v
      in
        if n < (length xs) - 1
        then iter (n + 1) res
        else Tuple.second v
  in iter 1 init


gvf2 xs =
  let
    init = (sdcm 1 xs, 0)
    iter n v =
      let
        -- (val, idx) = v
        sdcmVal = (sdcm n xs)
        res = (sdcmVal, n) :: v
      in
        if n < (length xs) - 1
        then iter (n + 1) res
        else L.reverse v
  in iter 1 [init]

updateNth : (b -> b) -> Int -> Array b -> Array b
updateNth f n =
  (\i x -> if i == n then f x else x)
  |> indexedMap

gen l xs =
  let
    init = (gvf xs)
    iter n v acc =
      let
        (left, right) = splitArray v xs
        leftGvf = gvf left
        rightGvf = gvf right
        -- splits = A.map (\x -> ) acc
        -- _ = Debug.log "split" (splitArray v xs)
      in
        if (n < l)
        then iter (n + 1) v acc
        -- then iter (n + 1) v
        else acc
  in iter 0 init (A.fromList [init])

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
scanToLeft c tw =
  (\it acc ->
    if c - it.center < (toFloat tw) / 2
    then acc + 1
    else acc)
  |> A.foldr

scanToRight : Float -> TimeWindow -> Neighbors -> Array DisplayJob -> Neighbors
scanToRight c tw n xs =
  let
    scan item acc =
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
    -- _ = Debug.log "len" len
    ggg =L.sort <| L.map Tuple.first (gvf2 arr)
    _ = Debug.log "gvf" (gvf2 arr)
    _ = Debug.log "gvf_" (ggg)
    -- _ = Debug.log "gen" (gen 5 arr)
    -- _ = Debug.log "split" (splitArray 2 arr)
    -- _ = Debug.log "sdam" (sdam arr)
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
