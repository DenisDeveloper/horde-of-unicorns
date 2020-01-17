module AppMsg exposing (Msg(..))

import Browser.Dom as Dom
import Http

import Job exposing (JobEntity, Job)

type Msg
  = GotBoundary (Result Dom.Error Dom.Element)
  | OnPageResize
  | FetchJobs
  | GotJobs (Result Http.Error (List JobEntity))
