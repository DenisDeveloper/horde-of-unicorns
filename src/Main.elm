module Main exposing (main)

import Browser as B
import Browser.Dom as BD exposing (Viewport, Element, getViewportOf, getViewport, getElement)
import Browser.Events exposing (onAnimationFrameDelta, onResize)
import Html exposing (Html, div, text)
import Html.Attributes as Attr exposing (width, height, style, class)
import Html.Events exposing (onClick)
import Task
import String as Str
import Http
import Job exposing (JobEntity, Job)
import Json.Encode as E
import List as L exposing (map, minimum, maximum)
import Maybe as M
import Array as A

import ClusterGenerator as Cluster

viewport = "viewport"

type alias HttpError = Http.Error
type alias DomError = BD.Error

type Error
  = HttpError
  | DomError

type Msg
  = GotBoundary (Result BD.Error Element)
  | OnPageResize
  | FetchJobs
  | GotJobs (Result Http.Error (List JobEntity))

type alias Model =
  { aspectRatio : Float
  , viewportWidth: Float
  , viewportHeight: Float
  , error : List String
  }

-- errorHandler : error -> String
-- errorHandler e =
--   case e of

mock =
  [ { start = 0, end = 9, content = "item 0", center = 4.5 }
  , { start = 10, end = 7, content = "item 1", center = 8.5 }
  , { start = 16, end = 9, content = "item 2", center = 12.5 }
  , { start = 18, end = 6, content = "item 3", center = 12 }
  , { start = 52, end = 2, content = "item 4", center = 27 }
  , { start = 50, end = 6, content = "item 5", center = 28 }
  , { start = 66, end = 4, content = "item 6", center = 35 }
  ]

getBoundary =
  Task.attempt GotBoundary <| getElement viewport

initModel : Model
initModel =
    { aspectRatio = 0.0
    , viewportWidth = 0.0
    , viewportHeight = 0.0
    , error = []
    }

main : Program () Model Msg
main =
  let
    _ = Debug.log "clusters" (Cluster.generate 2 <| A.fromList mock)
  in
    B.element
      { init = \_ -> (initModel, getBoundary)
      , update = update
      , subscriptions = subscriptions
      , view = view
      }

subscriptions : Model -> Sub Msg
subscriptions _ =
  onResize (\_ _ -> OnPageResize)

viewportWidth : Result BD.Error Element -> Float
viewportWidth v =
  case v of
    Err err -> 0
    Ok value ->  .width <| .element value

viewportHeight : Result BD.Error Element -> Float
viewportHeight v =
  case v of
    Err err -> 0
    Ok value ->  .height <| .element value

aspectRatio : Float -> Float -> Float
aspectRatio w h =
  (min w h) / (max w h)


minJob : List JobEntity -> Maybe Int
minJob =
  minimum << map .start

maxJob : List JobEntity -> Maybe Int
maxJob =
  maximum << map .finish

prepare : List JobEntity -> Maybe Float -> List Job
prepare xs ratio=
  let
    f v = { x = M.map (\r -> (toFloat v.start) * r) ratio }
  in
    map f xs

normalize =
  M.map ((/) 1) << M.map toFloat

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    OnPageResize ->
      (model, getBoundary)
    FetchJobs ->
      (model, Job.list GotJobs)
    GotJobs result ->
      case result of
        Ok xs ->
          let
            start = minJob xs
            end = maxJob xs
            timeRange = M.map2 (-) end start
            ratio = normalize timeRange
            j = prepare xs ratio
              -- f = M.map ((/) model.viewportWidth) <| M.map toFloat timeRange
            _ = Debug.log "j" j
            -- _ = Debug.log "time range " timeRange
            -- _ = Debug.log "ratio " ratio
          in
            (model, Cmd.none)
        Err err -> (model, Cmd.none)
    GotBoundary v ->
      let
        w = viewportWidth v
        h = viewportHeight v
      in
        ( { model |
            viewportWidth = w
          , viewportHeight = h
          , aspectRatio = aspectRatio w h
          }
        ,
          Cmd.none
        )

view : Model -> Html Msg
view model =
  div [class "test", onClick FetchJobs] [ text "2" ]
