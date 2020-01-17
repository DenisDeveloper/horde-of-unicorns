module AppModel exposing (Model)

type alias Model =
  { aspectRatio : Float
  , viewportWidth: Float
  , viewportHeight: Float
  , error : List String
  }
