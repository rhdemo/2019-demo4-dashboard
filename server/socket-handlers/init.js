const log = require("../utils/log")("socket-handlers/init");

const {OUTGOING_MESSAGE_TYPES} = require("../message-types");
const send = require("../utils/send");


async function initHandler(ws, messageObj) {
  send(ws, OUTGOING_MESSAGE_TYPES.GAME, global.game);

  for (let prop in global.machines) {
    let {id, value} = global.machines[prop];
    send(ws, OUTGOING_MESSAGE_TYPES.MACHINE, {id, value});
  }

  sendOptEvents(ws);
}

async function sendOptEvents(ws) {
  let clientIterator = await global.optClient.iterator(1);

  let entry = {done: true};

  do {
    entry = await clientIterator.next();
    if (!entry.done) {
      log.debug(entry.key + ' = ' + entry.value + '\n');
      send(ws, {type: OUTGOING_MESSAGE_TYPES.OPT_EVENT, data: {key: entry.key, value: JSON.parse(entry.value)}});
    }

  } while (!entry.done);
}

module.exports = initHandler;
