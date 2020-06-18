module AnalogWatch exposing (analogWatch)

import Html exposing (Html)
import Svg exposing (..)
import Svg.Attributes exposing (..)

type alias Hour = Int
type alias Minute = Int
type alias Second = Int
type alias Length = Float 
type alias Denominator = Float 

timeAxis : Length -> Denominator -> Int -> List (Attribute msg)
timeAxis l d t = 
  let
    origin = 50
    angle = 360 / d * (t |> toFloat)
  in
  [ origin + l * sin (angle * pi / 180) |> String.fromFloat |> x2
  , origin - l * cos (angle * pi / 180) |> String.fromFloat |> y2
  ]

hourAxis = timeAxis 30.0 12.0
minuteAxis = timeAxis 40.0 60.0
secondAxis = timeAxis 50.0 60.0

analogWatch : Hour -> Minute -> Second -> Html msg
analogWatch hour minute second =
  svg [ width "100", height "100" ]
    [ circle [ cx "50", cy "50", r "50", stroke "black", fill "#fefefe", strokeWidth "3" ] []
    , line ([ x1 "50", y1 "50", stroke "red", strokeWidth "1" ] 
        ++ secondAxis second) []
    , line ([ x1 "50", y1 "50", stroke "red", strokeWidth "2" ] 
        ++ minuteAxis minute) []
    , line ([ x1 "50", y1 "50", stroke "red", strokeWidth "3" ] 
        ++ hourAxis hour) []
    ]
