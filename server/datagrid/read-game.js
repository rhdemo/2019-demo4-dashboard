
async function readGame() {
    let gameStr = await global.dataClient.get("game");
    if (gameStr) {
        global.game = JSON.parse(gameStr);
    }
    return global.game;
}


module.exports = readGame;
