import Html exposing (Html, br, button, div, form, hr, h2, input, label, table, text, tr, td, th, textarea)
import Html.Events exposing (onInput, onClick)
import Html.Attributes exposing (disabled, value, rows, cols, placeholder)

import Task
import Time exposing (Time, inMilliseconds)

import Json.Encode exposing (encode, object, string, list, Value)
import Json.Decode exposing (Decoder, decodeString, map2, field)

import Random exposing (Seed, initialSeed)
import Crypto.Strings exposing (encrypt, decrypt)

type alias Book =
    { title: String
    , author: String
    }

type alias Model =
    { data: List Book
    , addingAuthor: String
    , addingTitle: String
    , message: String
    , key: String
    , encrypted: String
    , seed: Seed
    }


type Msg
    = ChangeMessage String
    | ChangeKey String
    | ChangeEncrypted String
    | ChangeAddingTitle String
    | ChangeAddingAuthor String
    | TimeResult Time
    | AddBook
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
        ChangeAddingTitle title ->
            { model | addingTitle = title } ! []
        ChangeAddingAuthor author ->
            { model | addingAuthor = author } ! []
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
                        let
                            decodeResult = decodeString decodeBooks plainText
                        in
                            case decodeResult of
                                Ok data ->
                                    { model | message = plainText, data = data } ! []
                                Err errMessage ->
                                    { model | message = plainText, data = [] } ! []
                    Err errorMessage ->
                        model ! []
        TimeResult time ->
            let
                ms = floor (inMilliseconds time)
            in
                { model | seed = initialSeed ms } ! []
        AddBook ->
            let
                data = List.append model.data [ Book model.addingTitle model.addingAuthor ]
                message = encode 0 (encodeBooks data)
            in
                { model | data = data, addingTitle = "", addingAuthor = "", message = message } ! []


view : Model -> Html Msg
view model = div []
    [ div []
        [ h2 [] [ text "Business Domain" ]
        , viewBooks model.data
        , viewAddBook model.addingTitle model.addingAuthor
        ]
    , hr [] []
    , h2 [] [ text "Serialization" ]
    , div []
        [ label [] [ text "Plaintext: " ], br [] []
        , textarea [ value model.message, onInput ChangeMessage, rows 8, cols 60 ] []
        ]
    , hr [] []
    , h2 [] [ text "Encryption" ]
    , div []
        [ label [] [ text "Passphrase: " ]
        , input [ onInput ChangeKey, value model.key ] []
        ]
    , button [ onClick DoEncryption ] [ text "Encrypt" ]
    , button [ onClick DoDecryption ] [ text "Decrypt" ]
    , hr [] []
    , h2 [] [ text "Persistence" ]
    , label [] [ text "Encrypted Data: " ], br [] []
    , textarea [ value model.encrypted, onInput ChangeEncrypted, rows 8, cols 60 ] [ ]
    ]

viewBooks : List Book -> Html Msg
viewBooks books =
    let
        header = tr []
            [ th [] [ text "Author" ]
            , th [] [ text "Title" ]
            ]
        viewBookRow = \b -> tr [ ]
            [ td [] [ text b.author ]
            , td [] [ text b.title ]
            ]

        rows = List.map viewBookRow books
    in
        table [] (header :: rows)

viewAddBook : String -> String -> Html Msg
viewAddBook addingTitle addingAuthor =
    let
        disableAdd = (String.isEmpty addingAuthor) || (String.isEmpty addingTitle)
    in
        div []
            [ input [ placeholder "Author", onInput ChangeAddingAuthor, value addingAuthor ] []
            , input [ placeholder "Title", onInput ChangeAddingTitle, value addingTitle ] []
            , button [ onClick AddBook, disabled disableAdd ] [ text "Add Book" ]
            ]


encodeBook : Book -> Value
encodeBook book =
    object
        [ ( "author", string book.author )
        , ( "title", string book.title )
        ]


encodeBooks : List Book -> Value
encodeBooks books =
    list (List.map encodeBook books)


decodeBook : Decoder Book
decodeBook = map2 Book (field "title" Json.Decode.string) (field "author" Json.Decode.string)

decodeBooks : Decoder (List Book)
decodeBooks = Json.Decode.list decodeBook

init : (Model, Cmd Msg)
init =
    let
        books =
            [ Book "Theory of Evolution" "Charles Darwin"
            , Book "Philosophiæ Naturalis Principia Mathematica" "Isaac Newton"
            ]

        message = encode 0 (encodeBooks books)

        model =
            { data = books
            , addingTitle = ""
            , addingAuthor = ""
            , message = message
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