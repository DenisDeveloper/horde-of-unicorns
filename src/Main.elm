module Main exposing (main)

import Browser as B
import Browser.Events exposing (onAnimationFrameDelta)
import Html exposing (Html, div)
import Html.Attributes exposing (width, height, style, class)
import WebGL as GL exposing (Entity, Mesh, Shader)
import Math.Matrix4 as Mat4 exposing (Mat4)
import Math.Vector3 as Vec3 exposing (vec3, Vec3)
import Math.Vector2 as Vec3 exposing (vec2, Vec2)
import Json.Decode exposing (Value)

main : Program () Float Float
main =
  B.element
    { init = \_ -> (0, Cmd.none)
    , update = \elapsed currentTime -> (elapsed + currentTime, Cmd.none)
    , subscriptions = \_ -> onAnimationFrameDelta identity
    , view = view
    }

view : Float -> Html msg
view t =
  div [class "test"] [
    GL.toHtml
      [ width 400
      , height 400
      , style "display" "block"
      ]
      [ bar ]
  ]

perspective : Float -> Mat4
perspective t =
  Mat4.mul
    (Mat4.makePerspective 45 1 0.01 100)
    (Mat4.makeLookAt (vec3 (4 * cos t) 0 (4 * sin t)) (vec3 0 0 0) (vec3 0 1 0))

type alias Vertex =
  { position : Vec2
  , color : Vec3
  }

type alias Varying =
  { vColor : Vec3}

bar : Entity
bar =
  GL.entity
    vertexShader
    fragmentShader
    barMesh
    {}

barMesh : Mesh Vertex
barMesh =
  GL.triangles
    [ ( ( Vertex (vec2 -1 1) (vec3 1 0 0) )
      , ( Vertex (vec2 1 1) (vec3 0 1 0) )
      , ( Vertex (vec2 -1 -1) (vec3 0 0 1) )
      )
    ,
      ( ( Vertex (vec2 -1 -1) (vec3 1 0 0) )
      , ( Vertex (vec2 1 -1) (vec3 0 1 0) )
      , ( Vertex (vec2 1 1) (vec3 0 0 1) )
      )
    ]

type alias Uniforms =
  {perspective : Mat4}

vertexShader : Shader Vertex {} Varying
vertexShader =
  [glsl|
    precision mediump float;
    attribute vec2 position;
    attribute vec3 color;
    varying vec3 vColor;

    void main () {
      gl_Position = vec4(position, 0.0, 1.0);
      vColor = color;
    }
  |]

fragmentShader : Shader {} {} Varying
fragmentShader =
  [glsl|
    precision mediump float;
    varying vec3 vColor;

    void main () {
      gl_FragColor = vec4(vColor, 1.0);
    }
  |]
