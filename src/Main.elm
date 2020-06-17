module Main exposing (main)

import Dice exposing (dice)

import Browser
import Html exposing (..)
import Html.Attributes exposing (width, height, style)
import Html.Events exposing (..)
import Random

diceCount = 3

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
  ( Rolled (List.repeat diceCount 1)
  , Cmd.none
  )

type Msg
  = Roll
  | NewFace (List Int)

diceRandom : Random.Generator Int
diceRandom = Random.weighted (10, 1) [(10, 1), (10, 2), (10, 3), (10, 4), (10, 5), (10, 6)]

spin : Int -> Random.Generator (List Int)
spin n = Random.list n diceRandom

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case (model, msg) of
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
