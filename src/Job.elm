module Job exposing (JobEntity, list)

import Api.Endpoint as Api
import Http
import Json.Decode as D exposing (Decoder)


type alias JobEntity =
  { id : Int
  , jobId : Maybe Int
  , workerId : Int
  , jobType : String
  , start : String
  , finish : String
  }

jobDecoder : D.Decoder JobEntity
jobDecoder =
  D.map6 JobEntity
    (D.field "id" D.int)
    (D.field "jobId" (D.maybe D.int))
    (D.field "workerId" D.int)
    (D.field "jobType" D.string)
    (D.field "start" D.string)
    (D.field "finish" D.string)

list : (Result Http.Error (List JobEntity) -> msg) -> Cmd msg
list msg =
  Api.get Api.jobs msg (D.list jobDecoder)
