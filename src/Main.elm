module Main exposing (main)

import Asset exposing (src, dice)

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

diceElement x y = 
  img 
    [ src dice
    , style "object-fit" "none"
    , style "object-position" 
        ((String.fromInt x ++ "px ") 
        ++ (String.fromInt y ++ "px"))
    , width 200
    , height 200
    ] []

diceOf n =
  case n of
    1 -> diceElement 0 0
    2 -> diceElement -200 0
    3 -> diceElement -400 0
    4 -> diceElement 0 -200
    5 -> diceElement -200 -200
    6 -> diceElement -400 -200
    _ -> div [] [ text "error dice" ]

view : Model -> Html Msg
view model =
  div []
    [ button [ onClick Roll ] [ text "Roll" ]
    , diceOf model.diceFace
    ]
