import Browser
import Html exposing (..)
import Html.Events exposing (onClick)
import Http
import Dict exposing (Dict)
import Time exposing (..)
import Json.Decode as Decode exposing (Decoder, int, string, float, map, map4, field, list)



-- MODEL


type alias Product =
    { id : Int
    ,  name : String
    ,  body : String
    ,  timestamp : String
    }

type alias Products = 
    {
        products : List Product
    }

type alias Model =
    -- { products : List Product
    { stringProducts : List String
    , products : Maybe Products
    , errorMessage : Maybe String
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( { stringProducts = []
      , products = Nothing
      , errorMessage = Nothing
      }
    , Cmd.none
    )

url : String
url =
    "http://localhost:5000/products"

-- UPDATE

productDecoder : Decoder Product
productDecoder =
    map4 Product
        (field "id" int)
        (field "name" string)
        (field "body" string)
        (field "timestamp" string)

productsDecoder : Decoder Products
productsDecoder =
    map Products
        (field "products" (list productDecoder))

type Msg
    = SendHttpRequest
    | DataReceived (Result Http.Error Products)

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SendHttpRequest ->
            ( model, getProducts )

        DataReceived (Ok products) ->
            ( { model | products =  Just products }, Cmd.none )
        DataReceived (Err httpError) ->
            ( { model
                | errorMessage = Just (buildErrorMessage httpError)
              }
            , Cmd.none
            )

getProducts : Cmd Msg
getProducts =
    Http.get
        { url = url
        , expect = Http.expectJson DataReceived productsDecoder
        }

-- VIEW

view : Model -> Html Msg
view model =
    div []
        [ button [ onClick SendHttpRequest ]
            [ text "Get data from server" ]
        , viewProductsOrError model
        ]


viewProductsOrError : Model -> Html Msg
viewProductsOrError model =
    case model.errorMessage of
        Just message ->
            viewError message

        Nothing ->
            viewProducts model.stringProducts

viewError : String -> Html Msg
viewError errorMessage =
    let
        errorHeading =
            "Couldn't fetch products at this time."
    in
    div []
        [ h3 [] [ text errorHeading ]
        , text ("Error: " ++ errorMessage)
        ]

viewProducts : List String -> Html Msg
viewProducts products =
    div []
        [ h3 [] [ text "Products" ]
        , ul [] (List.map viewProduct products)
        ]

viewProduct : String -> Html Msg
viewProduct product =
    li [] [ text product ]

buildErrorMessage : Http.Error -> String
buildErrorMessage httpError =
    case httpError of
        Http.BadUrl message ->
            message

        Http.Timeout ->
            "Server is taking too long to respond. Please try again later."

        Http.NetworkError ->
            "Unable to reach server."

        Http.BadStatus statusCode ->
            "Request failed with status code: " ++ String.fromInt statusCode

        Http.BadBody message ->
            message

main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }