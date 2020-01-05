module Job exposing (JobEntity, Job, list)

import Api.Endpoint as Api
import Http
import Json.Decode as D exposing (Decoder, field)


type alias JobEntity =
  { id : Int
  , jobId : Maybe Int
  , workerId : Int
  , jobType : String
  , start : Int
  , finish : Int
  }

type alias Job =
  { x : Maybe Float
  }

jobDecoder : D.Decoder JobEntity
jobDecoder =
  D.map6 JobEntity
    (field "id" D.int)
    (field "jobId" (D.maybe D.int))
    (field "workerId" D.int)
    (field "jobType" D.string)
    (field "start" D.int)
    (field "finish" D.int)

list : (Result Http.Error (List JobEntity) -> msg) -> Cmd msg
list msg =
  Api.get Api.jobs msg (D.list jobDecoder)
