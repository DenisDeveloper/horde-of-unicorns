module Main exposing (main)

import Browser as B
import Browser.Dom as BD exposing (Viewport, Element, getViewportOf, getViewport, getElement)
import Browser.Events exposing (onAnimationFrameDelta, onResize)
import Html exposing (Html, div)
import Html.Attributes as Attr exposing (width, height, style, class)
import Html.Events exposing (onClick)
import WebGL as GL exposing (Entity, Mesh, Shader)
import Math.Matrix4 as Mat4 exposing (Mat4)
import Math.Vector3 as Vec3 exposing (vec3, Vec3)
import Math.Vector2 as Vec3 exposing (vec2, Vec2)
import Task
import String as Str
import Http
import Job exposing (JobEntity, Job)
import Json.Encode as E
import List as L exposing (map, minimum, maximum)
import Maybe as M

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
  div [class "test", onClick FetchJobs] [
    GL.toHtml
      [ Attr.id viewport
      , width <| truncate model.viewportWidth
      , height <| truncate model.viewportHeight
      , style "display" "block"
      , style "width" "100%"
      , style "height" "800px"
      ]
      [ (grid (800 / 1400)) ]
  ]

type alias Bar =
  { x : Float
  , y : Float
  , w : Float
  , h : Float
  }

bar2 x y w h =
  {x = x, y = y, w = w, h = h}

addBar b xs =
  let
    {x, y, w, h} = b
  in
    (tr1 x y w h) :: (tr2 x y w h) :: xs

bars = []



-- perspective : Float -> Mat4
-- perspective t =
--   Mat4.mul
--     (Mat4.makePerspective 45 1 0.01 100)
--     (Mat4.makeLookAt (vec3 (4 * cos t) 0 (4 * sin t)) (vec3 0 0 0) (vec3 0 1 0))

-- perspective : Float -> Mat4
-- perspective t =
--   Mat4.mul
--     ()

type alias Vertex =
  { position : Vec2
  , color : Vec3
  }

type alias Varying =
  { vColor : Vec3}

grid : Float -> Entity
grid ratio =
  GL.entity
    vertexShader
    fragmentShader
    (makeGrid ratio)
    {perspective = (Mat4.makeOrtho2D 0 1 1 0)}

tr1 x y w h =
  ( ( Vertex (vec2 x y) (vec3 0 0 1) )
  , ( Vertex (vec2 (x + w) y) (vec3 0 0 1) )
  , ( Vertex (vec2 x (y + h)) (vec3 0 0 1) )
  )

tr2 x y w h =
  ( ( Vertex (vec2 x (y + h)) (vec3 0 0 1) )
  , ( Vertex (vec2 (x + w) y) (vec3 0 0 1) )
  , ( Vertex (vec2 (x + w) (y + h)) (vec3 0 0 1) )
  )

makeGrid : Float -> Mesh Vertex
makeGrid ratio =
  let
    _ =
      Debug.log "rect "
    bb = (addBar (bar2 0 0 (1 * ratio) 1) bars)
  in
    GL.triangles bb

type alias Uniforms =
  {perspective : Mat4}

vertexShader : Shader Vertex Uniforms Varying
vertexShader =
  [glsl|
    precision mediump float;
    attribute vec2 position;
    attribute vec3 color;
    uniform mat4 perspective;
    varying vec3 vColor;

    void main () {
      gl_Position = perspective * vec4(position, 0.0, 1.0);
      vColor = color;
    }
  |]

fragmentShader : Shader {} Uniforms Varying
fragmentShader =
  [glsl|
    precision mediump float;
    varying vec3 vColor;

    void main () {
      gl_FragColor = vec4(vColor, 1.0);
    }
  |]
