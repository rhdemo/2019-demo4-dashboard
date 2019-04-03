const log = require("../utils/log")("datagrid/opt-event");
const OUTGOING_MESSAGE_TYPE = require("../message-types").OUTGOING_MESSAGE_TYPES;
const broadcast = require("../utils/broadcast");

async function optEventHandler(client, changeType, key) {
  const optEvent = await global.optClient.get(key);
  log.debug(key, optEvent);
  if (optEvent) {
    broadcast(OUTGOING_MESSAGE_TYPE.OPT_EVENT, {key, value: JSON.parse(optEvent)}, changeType);
  } else if (changeType === "remove") {
    broadcast(OUTGOING_MESSAGE_TYPE.OPT_EVENT, {key, value: null}, changeType);
  }
}

module.exports = optEventHandler;

