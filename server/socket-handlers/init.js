const log = require("../utils/log")("socket-handlers/init");

const {OUTGOING_MESSAGE_TYPES} = require("../message-types");
const send = require("../utils/send");


async function initHandler(ws, messageObj) {
  send(ws, OUTGOING_MESSAGE_TYPES.GAME, global.game, "modify");

  for (let prop in global.machines) {
    let {id, value} = global.machines[prop];
    send(ws, OUTGOING_MESSAGE_TYPES.MACHINE, {id, value}, "modify");
  }

  sendOptInit(ws);
}

async function sendOptInit(ws) {
  let optaplannerEvents = [];

  let clientIterator = await global.optClient.iterator(1);

  let entry = {done: true};

  do {
    entry = await clientIterator.next();
    if (!entry.done) {
      optaplannerEvents.push({key: entry.key, value: JSON.parse(entry.value)});
    }

  } while (!entry.done);

  await clientIterator.close();

  log.debug(optaplannerEvents);

  send(ws, OUTGOING_MESSAGE_TYPES.OPT_INIT, optaplannerEvents, "modify");
}

module.exports = initHandler;
