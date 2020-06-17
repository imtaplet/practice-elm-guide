module Main exposing (main)

import Dice exposing (dice)

import Browser
import Html exposing (..)
import Html.Attributes exposing (width, height, style)
import Html.Events exposing (..)
import Random

main =
  Browser.element 
    { init = init
    , update = update
    , subscriptions = subscriptions 
    , view = view 
    }

type Model
  = Rolling Int (List Int)
  | Rolled (List Int)

init : () -> (Model, Cmd Msg)
init _ =
  ( Rolled [1, 1]
  , Cmd.none
  )

type alias Spin =
  { one : Int
  , two : Int
  }

type Msg
  = Roll
  | NewFace Spin

diceRandom : Random.Generator Int
diceRandom = Random.weighted (10, 1) [(10, 1), (10, 2), (10, 3), (10, 4), (10, 5), (10, 6)]

spin : Random.Generator Spin
spin = Random.map2 Spin diceRandom diceRandom

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case (model, msg) of
    (_, Roll) ->
      ( Rolling 5 []
      , Random.generate NewFace spin
      )
    (Rolling 1 _, NewFace { one, two }) ->
      ( Rolled [one, two]
      , Random.generate NewFace spin
      )
    (Rolling n _, NewFace { one, two }) ->
      ( Rolling (n - 1) [one, two]
      , Random.generate NewFace spin
      )
    (Rolled _, NewFace { one, two }) ->
      ( Rolled [one, two]
      , Cmd.none
      )

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none

view : Model -> Html Msg
view model =
  div []
    ([ button [ onClick Roll ] [ text "Roll" ] ] 
      ++ diceView model)

diceView : Model -> List (Html msg)
diceView model =
  case model of
    Rolled diceFaces -> List.map dice diceFaces
    Rolling _ diceFaces -> List.map dice diceFaces
