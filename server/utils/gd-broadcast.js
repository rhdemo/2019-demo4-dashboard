const log = require("../utils/log")("utils/broadcast");
const WebSocket = require("ws");

const gdComUtils = require('@gd-com/utils');


module.exports = function gdBroadcast(type, data, action) {
  if (global.socketServer.clients) {
    let jsonMessage = JSON.stringify({type: type, data, action});
    // log.debug(`sending gd message to clients: ${jsonMessage}`);

    let gdBuffer = new gdComUtils.GdBuffer();
    gdBuffer.putString(jsonMessage);
    let msg = gdBuffer.getBuffer();

    global.socketServer.clients.forEach(function each(client) {
      if (client.readyState === WebSocket.OPEN) {
        client.send(msg);
      }
    });
  }
};