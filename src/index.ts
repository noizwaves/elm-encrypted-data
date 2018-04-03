require('./index.html');

const Elm = require('./ElmEncryptedData.elm');
const mountNode = document.getElementById('main');

const app = Elm.Main.embed(mountNode);

app.ports.downloadFile.subscribe((cypherText: string) => {
    location.href = 'data:application/octet-stream,' + encodeURIComponent(cypherText);
});