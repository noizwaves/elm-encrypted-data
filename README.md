# Elm Encrypted Data

An experiment in encryption with Elm. See it live [here](https://noizwaves-elm-encrypted-data.surge.sh/)

## Installation

With Elm 0.18 installed and this repo cloned, run:

1. `./gradlew build`
1. `./gradlew serve`
1. [Navigate here](http://localhost:8000/ElmEncryptedData.elm) to see the code running

## Deployment

Deployments are made using Surge (`npm install --global surge`)

1. `./gradlew build`
1. `surge build noizwaves-elm-encrypted-data.surge.sh`
