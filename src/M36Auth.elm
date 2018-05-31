module M36Auth exposing (Model, Msg, main, view, update)

import Html exposing (..)

import Bootstrap.CDN as CDN
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Col as Col
import Bootstrap.Grid.Row as Row
import Bootstrap.Button as Button
import Bootstrap.Form.Input as Input
import Bootstrap.Form.InputGroup as InputGroup
import Bootstrap.Utilities.Spacing as Sp
import Bootstrap.Alert as Alert

import JsonValue as JV
import Json.Decode as Json

import WebSocket exposing (listen, send)

type Msg =
    M36Response String

type alias Model =
    { mUser : Maybe User
    , error : Maybe String
    }

type alias User =
    { email : String
    , password : String
    }

init : (Model, Cmd Msg)
init = ({ mUser = Nothing, error = Nothing }, connectDB)

websocketServerURI : String
websocketServerURI = "ws://localhost:8000/ws"

connectDB : Cmd Msg
connectDB =
    send websocketServerURI "connectdb:test"

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        M36Response response ->
            case Json.decodeString JV.decoder response of
                Ok r ->
                    updateFromM36 r model
                Err errorMessage ->
                    ({ model | error = Just errorMessage }, Cmd.none)


updateFromM36 : JV.JsonValue -> Model -> (Model, Cmd Msg)
updateFromM36 response model =
    (model, Cmd.none)

view : Model -> Html Msg
view model =
    Grid.container []
        [ CDN.stylesheet
        , Grid.row [Row.attrs [Sp.mt3]] [
               Grid.col [] [
                    h2 [] [text "M36 Authentication"]
                    ]
               ]
        , Grid.row [Row.attrs [Sp.mt3]] [
            Grid.col [ Col.lg12 ]
            [
             case model.error of
                 Just _ ->
                   Alert.simpleDanger [] [ text "Error talking to the database" ]
                 Nothing ->
                   text ""
            ]
        ]
        , Grid.row [Row.attrs [Sp.mt3]] [
               Grid.col [] [
                   ]
              ]
        ]

subscriptions : Model -> Sub Msg
subscriptions =
    always (listen websocketServerURI M36Response)

main : Program Never Model Msg
main =
  Html.program
    { init = init
    , update = update
    , view = view
    , subscriptions = subscriptions
    }
