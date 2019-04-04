const log = require("../utils/log")("datagrid/game");
const OUTGOING_MESSAGE_TYPE = require("../message-types").OUTGOING_MESSAGE_TYPES;
const readGame = require("./read-game");
const broadcast = require("../utils/broadcast");

async function gameHandler(client, changeType, key) {
    log.info("broadcasting game change");
    await readGame();
    broadcast(OUTGOING_MESSAGE_TYPE.GAME, global.game, changeType);
}


module.exports = gameHandler;
