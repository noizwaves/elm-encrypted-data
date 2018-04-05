require('./index.html');

const Elm = require('./ElmEncryptedData.elm');
const mountNode = document.getElementById('main');

const app = Elm.Main.embed(mountNode);

app.ports.fileSelected.subscribe((id: string) => {
    const node = document.getElementById(id) as HTMLInputElement;
    if (node === null) {
        return;
    }

    const file = node.files[0];
    const reader = new FileReader();

    reader.onload = (event) => {
        const content = (<any> event.target).result;
        app.ports.fileContentRead.send(content);
    };

    reader.readAsText(file);
});