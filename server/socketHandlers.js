const log = require("./utils/log")("socket-handlers");

const {INCOMING_MESSAGE_TYPES, OUTGOING_MESSAGE_TYPES} = require("./message-types");

function processSocketMessage(ws, messageStr) {
  let messageObj = JSON.parse(messageStr);

  switch (messageObj.type) {
    case INCOMING_MESSAGE_TYPES.CONNECTION:
      connectionHandler(ws, messageObj);
      break;

    default:
      log.warn("Unhandled Admin Message: ", messageStr);
      break;
  }
}

function connectionHandler(ws, messageObj) {
  const game = global.game;
  ws.send(JSON.stringify({type: OUTGOING_MESSAGE_TYPES.CONFIGURATION, game}));
}

module.exports.processSocketMessage = processSocketMessage;
