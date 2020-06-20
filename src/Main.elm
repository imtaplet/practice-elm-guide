port module Main exposing (main)

import Json.Encode as E


import Dice exposing (dice)
import AnalogWatch exposing (analogWatch)

import Browser
import Html exposing (..)
import Html.Attributes exposing (attribute, width, height, style)
import Html.Events exposing (..)
import Random
import Task
import Time

port cache : E.Value -> Cmd msg

port interval : (Int -> msg) -> Sub msg

diceCount = 30

main =
  Browser.document 
    { init = init
    , update = update
    , subscriptions = subscriptions 
    , view = viewDocument
    }

type alias TimeAndZone =
  { zone : Time.Zone
  , time : Time.Posix
  }

type Model
  = Rolling Int (List Int)
  | Rolled (List Int)
  | Time TimeAndZone
  | StopTime TimeAndZone

initTime : Cmd Msg
initTime = Task.perform AdjustTimeZone Time.here

init : Int -> (Model, Cmd Msg)
init currentTime =
  ( Time { zone = Time.utc, time = (Time.millisToPosix currentTime) }
  , Cmd.batch 
      [ initTime
      , cache (E.int 42)
      ]
  )

type Msg
  = Roll
  | NewFace (List Int)
  | Tick Time.Posix
  | AdjustTimeZone Time.Zone
  | Stop
  | Start

diceRandom : Random.Generator Int
diceRandom = Random.weighted (10, 1) [(10, 1), (10, 2), (10, 3), (10, 4), (10, 5), (10, 6)]

spin : Int -> Random.Generator (List Int)
spin n = Random.list n diceRandom

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case (model, msg) of
    (Time timeModel, Tick newTime) ->
      ( Time { timeModel | time = newTime }
      , Cmd.none
      )
    (StopTime timeModel, Start) ->
      init 0
    (Time timeModel, AdjustTimeZone newZone) ->
      ( Time { timeModel | zone = newZone }
      , Cmd.none
      )
    (Time timeModel, Stop) ->
      ( StopTime timeModel
      , Cmd.none)
    (_, Roll) ->
      ( Rolling 5 []
      , Random.generate NewFace (spin diceCount)
      )
    (Rolling 1 _, NewFace xs) ->
      ( Rolled xs
      , Random.generate NewFace (spin diceCount)
      )
    (Rolling n _, NewFace xs) ->
      ( Rolling (n - 1) xs
      , Random.generate NewFace (spin diceCount)
      )
    (Rolled _, NewFace xs) ->
      ( Rolled xs
      , Cmd.none
      )
    (m, _) -> (m, Cmd.none)

subscriptions : Model -> Sub Msg
subscriptions model =
  case model of
    Time _ -> interval (Time.millisToPosix >> Tick)
    _ -> Sub.none

viewDocument : Model -> Browser.Document Msg
viewDocument model =
  { title = "This is title."
  , body = 
      [ view model 
      , viewDate "ja" 2020 1
      ]
  }


viewDate : String -> Int -> Int -> Html msg
viewDate lang year month =
  node "intl-date"
    [ attribute "lang" lang
    , attribute "year" (String.fromInt year)
    , attribute "month" (String.fromInt month)
    ]
    []


view : Model -> Html Msg
view model =
  case model of
    StopTime { zone, time } ->
      let
        hour = String.fromInt (Time.toHour zone time)
        minute = String.fromInt (Time.toMinute zone time)
        second = String.fromInt (Time.toSecond zone time)
      in
      div []
        [ h1 [] [ text (hour ++ ":" ++ minute ++ ":" ++ second) ]
        , button [ onClick Start ] [ text "Start" ]
        ]
    Time { zone, time } ->
      let
        hour = String.fromInt (Time.toHour zone time)
        minute = String.fromInt (Time.toMinute zone time)
        second = String.fromInt (Time.toSecond zone time)
      in
      div [ style "margin" "20px" ]
        [ analogWatch (Time.toHour zone time) (Time.toMinute zone time) (Time.toSecond zone time)
        , h1 [] [ text (hour ++ ":" ++ minute ++ ":" ++ second) ]
        , button [ onClick Stop ] [ text "Stop" ]
        ]
    _ ->
      div []
        ([ button [ onClick Roll ] [ text "Roll" ] ] 
          ++ diceView model)

diceView : Model -> List (Html msg)
diceView model =
  case model of
    Rolled diceFaces -> List.map dice diceFaces
    Rolling _ diceFaces -> List.map dice diceFaces
    _ -> []
