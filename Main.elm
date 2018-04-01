import Html exposing (Html, br, button, div, hr, input, label, text, textarea)
import Html.Events exposing (onInput, onClick)
import Html.Attributes exposing (value, rows, cols)

import Task
import Time exposing (Time, inMilliseconds)

import Random exposing (Seed, initialSeed)
import Crypto.Strings exposing (encrypt, decrypt)


type alias Model =
    { message: String
    , key: String
    , encrypted: String
    , seed: Seed
    }


type Msg
    = ChangeMessage String
    | ChangeKey String
    | ChangeEncrypted String
    | TimeResult Time
    | DoEncryption
    | DoDecryption


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        ChangeMessage message ->
            { model | message = message } ! []
        ChangeKey key ->
            { model | key = key } ! []
        ChangeEncrypted encrypted ->
            { model | encrypted = encrypted } ! []
        DoEncryption ->
            let
                result = encrypt model.seed model.key model.message
            in
                case result of
                    Ok (cypherText, seed) ->
                        { model | encrypted = cypherText, seed = seed } ! []
                    Err errorMessage ->
                        model ! []
        DoDecryption ->
            let
                result = decrypt model.key model.encrypted
            in
                case result of
                    Ok plainText ->
                        { model | message = plainText } ! []
                    Err errorMessage ->
                        model ! []
        TimeResult time ->
            let
                ms = floor (inMilliseconds time)
            in
                { model | seed = initialSeed ms } ! []


view : Model -> Html Msg
view model = div []
    [ div []
        [ label [] [ text "Plaintext: " ]
        , input [ onInput ChangeMessage, value model.message ] []
        ]
    , hr [] []
    , div []
        [ label [] [ text "Passphrase: " ]
        , input [ onInput ChangeKey, value model.key ] []
        ]
    , button [ onClick DoEncryption ] [ text "Encrypt" ]
    , button [ onClick DoDecryption ] [ text "Decrypt" ]
    , hr [] []
    , label [] [ text "Encrypted Data: " ], br [] []
    , textarea [ value model.encrypted, onInput ChangeEncrypted, rows 8, cols 60 ] [ ]
    ]


init : (Model, Cmd Msg)
init =
    let
        model =
            { message = "{\"Hello\":\"World\"}"
            , key = "s0m3p455phr453"
            , encrypted = ""
            , seed = initialSeed 0
            }
     in
        model ! [ Task.perform TimeResult Time.now ]


main = Html.program
    { init = init
    , view = view
    , update = update
    , subscriptions = \m -> Sub.none
    }