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
  { diceFace : Int
  }
  

init : () -> (Model, Cmd Msg)
init _ =
  ( Model 1
  , Cmd.none
  )

type Msg
  = Roll
  | NewFace Int

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Roll ->
      ( model
      , Random.generate NewFace (Random.int 1 6)
      )
    NewFace newFace ->
      ( Model newFace
      , Cmd.none
      )

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none

view : Model -> Html Msg
view model =
  div []
    [ button [ onClick Roll ] [ text "Roll" ]
    , dice model.diceFace
    ]
