module Asset exposing (Image, dice, src)

import Html exposing (Attribute)
import Html.Attributes as Attr

type Image
  = Image String

dice =
  image "dice.png"

image : String -> Image
image filename =
  Image ("/assets/images/" ++ filename)

src : Image -> Attribute msg
src (Image url) =
  Attr.src url
