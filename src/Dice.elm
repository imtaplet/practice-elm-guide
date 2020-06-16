module Dice exposing (dice)

import Html exposing (Html)
import Svg exposing (..)
import Svg.Attributes exposing (..)


diceCircle : String -> String -> String -> String -> Svg msg
diceCircle x y ra color = circle [ cx x, cy y, r ra, stroke "#515151", strokeWidth "10", fill color ] []
    
diceBorder = rect [ x "20" , y "20" , width "160" , height "160", rx "50", ry "50" ] [ ]

dice : Int -> Html msg

dice n =
  svg 
    [ width "200"
    , height "200"
    , viewBox "0 0 200 200"
    , fill "white"
    , stroke "#515151"
    , strokeWidth "20"
    ]
    (case n of
      1 ->
          [ diceBorder
          , diceCircle "100" "100" "30" "#ff8b8e"
          ]

      2 ->
          [ diceBorder
          , diceCircle "80" "120" "15" "black"
          , diceCircle "120" "80" "15" "black"
          ]
      3 ->
          [ diceBorder
          , diceCircle "70" "70" "15" "black"
          , diceCircle "100" "100" "15" "black"
          , diceCircle "130" "130" "15" "black"
          ]
      4 ->
          [ diceBorder
          , diceCircle "70" "70" "15" "black"
          , diceCircle "130" "70" "15" "black"
          , diceCircle "70" "130" "15" "black"
          , diceCircle "130" "130" "15" "black"
          ]
      5 ->
          [ diceBorder
          , diceCircle "70" "70" "15" "black"
          , diceCircle "130" "70" "15" "black"
          , diceCircle "100" "100" "15" "black"
          , diceCircle "70" "130" "15" "black"
          , diceCircle "130" "130" "15" "black"
          ]
      6 ->
          [ diceBorder
          , diceCircle "70" "70" "15" "black"
          , diceCircle "130" "70" "15" "black"
          , diceCircle "70" "100" "15" "black"
          , diceCircle "70" "130" "15" "black"
          , diceCircle "130" "100" "15" "black"
          , diceCircle "130" "130" "15" "black"
          ]
      _ -> [ text "dice generating error" ]
    )
