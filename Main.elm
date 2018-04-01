import Html exposing (Html, button, div, hr, input, label, text)
import Html.Events exposing (onInput)

type alias Model =
    { message: String
    , key: String
    }

type Msg
    = ChangeMessage String
    | ChangeKey String

update : Msg -> Model -> Model
update msg model =
    case msg of
        ChangeMessage message ->
            { model | message = message }
        ChangeKey key ->
            { model | key = key }

view : Model -> Html Msg
view model = div []
    [ div []
        [ label [] [ text "Message" ]
        , input [ onInput ChangeMessage ] []
        ]
    , div []
        [ label [] [ text "Encryption key" ]
        , input [ onInput ChangeKey ] []
        ]
    , button [] [ text "Encrypt" ]
    , hr [] []
    , text "ENCRYPTED_DATA_GOES_HERE"
    ]

main = Html.beginnerProgram
    { model = Model "" ""
    , view = view
    , update = update
    }