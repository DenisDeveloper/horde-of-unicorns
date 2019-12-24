module Api.Endpoint exposing (Endpoint, request, jobs, get)

import Http
import Url.Builder exposing (QueryParameter)
import Json.Decode as D exposing (Decoder)

type Endpoint
  = Endpoint String

request :
  { body : Http.Body
  , expect : Http.Expect msg
  , headers : List Http.Header
  , method : String
  , timeout : Maybe Float
  , url : Endpoint
  , tracker : Maybe String
  }
  -> Cmd msg
request options =
  Http.request
    { body = options.body
    , expect = options.expect
    , headers = options.headers
    , method = options.method
    , timeout = options.timeout
    , url = unwrap options.url
    , tracker = options.tracker
    }

unwrap : Endpoint -> String
unwrap (Endpoint str) = str

url : List String -> List QueryParameter -> Endpoint
url paths queryParams =
  Url.Builder.crossOrigin "http://localhost:4200"
    paths
    queryParams
    |> Endpoint

get : Endpoint -> (Result Http.Error a -> msg) -> Decoder a -> Cmd msg
get endpointUrl msg decoder =
  request
    { method = "GET"
    , url = endpointUrl
    , expect = Http.expectJson msg decoder
    , headers = []
    , body = Http.emptyBody
    , timeout = Nothing
    , tracker = Nothing
    }

jobs : Endpoint
jobs = url ["jobs.json"] []
