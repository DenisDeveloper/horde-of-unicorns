module Main exposing (main)

import Browser as B
import Browser.Dom as Dom exposing (Viewport, Element, getViewportOf, getViewport, getElement)
import Browser.Events exposing (onAnimationFrameDelta, onResize)
import Html as H exposing (Html, div, text)
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

import AppModel exposing (Model)
import AppMsg exposing (Msg(..))

import ClusterGenerator as Cluster

import TimeTable as TT
import Util.Time exposing (foo)

viewport = "time-table-view"

type alias HttpError = Http.Error
type alias DomError = Dom.Error

type Error
  = HttpError
  | DomError

-- errorHandler : error -> String
-- errorHandler e =
--   case e of

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
    _ = Debug.log "main" "render"
    h = foo
  in
    B.element
      { init = \_ -> (initModel, getBoundary)
      , update = update
      , subscriptions = subscriptions
      , view = view
      }

subscriptions : Model -> Sub Msg
subscriptions _ = Sub.none
  -- onResize (\_ _ -> OnPageResize)

getWidth = .width << .element

viewportWidth : Result Dom.Error Element -> Float
viewportWidth v =
  case v of
    Err err -> 0
    Ok value ->  getWidth value

getHeight = .height << .element

viewportHeight : Result Dom.Error Element -> Float
viewportHeight v =
  case v of
    Err err -> 0
    Ok value -> getHeight value -- .height <| .element value

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
      let
        _ = Debug.log "fetch jobs" "!"
      in
      (model, Cmd.none)
      -- (model, Job.list GotJobs)
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
  div [Attr.id "root", onClick FetchJobs]
  [ H.main_ []
    [ TT.view model ]
  ]
