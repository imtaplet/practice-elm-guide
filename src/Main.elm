module Main exposing (main)

import Dice exposing (dice)
import AnalogWatch exposing (analogWatch)

import Browser
import Html exposing (..)
import Html.Attributes exposing (width, height, style)
import Html.Events exposing (..)
import Random
import Task
import Time

diceCount = 30

main =
  Browser.element 
    { init = init
    , update = update
    , subscriptions = subscriptions 
    , view = view 
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

init : () -> (Model, Cmd Msg)
init _ =
  ( Time { zone = Time.utc, time = Time.millisToPosix 0 }
  , initTime
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
      init ()
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
    Time _ -> Time.every 1000 Tick
    _ -> Sub.none

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
