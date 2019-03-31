const {OUTGOING_MESSAGE_TYPES} = require("../message-types");
const send = require("../utils/send");


async function initHandler(ws, messageObj) {
  send(ws, OUTGOING_MESSAGE_TYPES.GAME, global.game);

  for (let prop in global.machines) {
    let {id, value} = global.machines[prop];
    send(ws, OUTGOING_MESSAGE_TYPES.MACHINE, {id, value});
  }

}

module.exports = initHandler;
