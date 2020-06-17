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

type alias Model =
  { diceFaces : List Int
  }
  

init : () -> (Model, Cmd Msg)
init _ =
  ( Model [1, 1]
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
diceRandom = Random.weighted (50, 1) [(50, 1), (10, 2), (10, 3), (10, 4), (10, 5), (10, 6)]

spin : Random.Generator Spin
spin = Random.map2 Spin diceRandom diceRandom

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Roll ->
      ( model
      , Random.generate NewFace spin
      )
    NewFace { one, two } ->
      ( Model [one, two]
      , Cmd.none
      )

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none

view : Model -> Html Msg
view model =
  div []
    ([ button [ onClick Roll ] [ text "Roll" ] ] 
      ++ (List.map dice model.diceFaces))
