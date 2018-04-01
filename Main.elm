import Html exposing (Html, br, button, div, hr, input, label, text, textarea)
import Html.Events exposing (onInput, onClick)
import Html.Attributes exposing (value, rows, cols)

import Random exposing (Seed, initialSeed)
--import Crypto.Types exposing (Passphrase, Plaintext, Ciphertext)
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
    | DoEncryption
    | DoDecryption

update : Msg -> Model -> Model
update msg model =
    case msg of
        ChangeMessage message ->
            { model | message = message }
        ChangeKey key ->
            { model | key = key }
        ChangeEncrypted encrypted ->
            { model | encrypted = encrypted }
        DoEncryption ->
            let
                result = encrypt model.seed model.key model.message
            in
                case result of
                    Ok (cypherText, seed) ->
                        { model | encrypted = cypherText, seed = seed }
                    Err errorMessage ->
                        model
        DoDecryption ->
            let
                result = decrypt model.key model.encrypted
            in
                case result of
                    Ok plainText ->
                        { model | message = plainText }
                    Err errorMessage ->
                        model

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

main = Html.beginnerProgram
    { model = Model "{\"Hello\":\"World\"}" "s0m3p455phr453" ""  (initialSeed 0)
    , view = view
    , update = update
    }