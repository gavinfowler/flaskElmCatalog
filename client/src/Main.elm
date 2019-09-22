import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput, onClick)
import Http
import Bool.Extra exposing (..)
import Debug exposing (log)
import Json.Decode exposing (list, string)


-- MAIN


main =
  Browser.sandbox { init = init, update = update, view = view }



-- MODEL


type alias Model =
  { name : String
  , body : String
  , gotText : String
  }


init : Model
init =
  Model "" ""



-- UPDATE

getPublicOpinion : Cmd Msg
getPublicOpinion =
  Http.get
    { url = "https://elm-lang.org/assets/public-opinion.txt"
    , expect = Http.expectString GotText
    }

type Msg
  = Name String
  | Body String
  | GotText (Result Http.Error String)
  | SendHttpRequest (Result Http.Error (List String))

postBooks : Cmd Msg
postBooks =
  Http.post
    { url = "https://example.com/books"
    , body = Http.jsonBody
    , expect = Http.expectJson GotBooks (list string)
    }

update : Msg -> Model -> Model
update msg model =
  case msg of
    Name name ->
      { model | name = name }

    Body body ->
      { model | body = body }
    
    getPublicOpinion ->
      { model | gotText = gotText }

-- VIEW

view : Model -> Html Msg
view model =
  div []
    [ div [] [ text "Input form for products" ]
    , viewInput "text" "Name" model.name Name
    , viewInput "body" "Body" model.body Body
    , viewValidation model
    , button [ onClick SendHttpRequest ] [ text "-" ]
    ]


viewInput : String -> String -> String -> (String -> msg) -> Html msg
viewInput t p v toMsg =
  input [ type_ t, placeholder p, value v, onInput toMsg ] []


viewValidation : Model -> Html msg
viewValidation model =
  if nameValidation model.name && bodyValidation model.body then
    div [ style "color" "green" ] [ text "OK" ]
  else
    div [ style "color" "red" ] [ text "Name or Body is not valid" ]


nameValidation : String -> Bool
nameValidation string = 
  if String.length string > 0 && String.length string <= 140 then
    True
  else
    False

bodyValidation : String -> Bool
bodyValidation string = 
  if String.length string > 0 && String.length string <= 140 then
    True
  else
    False