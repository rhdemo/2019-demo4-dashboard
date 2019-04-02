const log = require("../utils/log")("utils/send");
const WebSocket = require("ws");

const gdComUtils = require('@gd-com/utils');


module.exports = function gdSend(ws, type, data) {
  let jsonMessage = JSON.stringify({type: type, data});
  // log.debug(`sending gd message to single client: ${jsonMessage}`);

  let gdBuffer = new gdComUtils.GdBuffer();
  gdBuffer.putString(jsonMessage);
  let msg = gdBuffer.getBuffer();

  ws.send(msg);
};