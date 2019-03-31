const WebSocket = require("ws");
const log = require("../utils/log")("broadcast");

function broadcast(type, data) {
  // log.debug("broadcast", type, data);
  const msg = JSON.stringify({type, data});

  if (global.socketServer.clients) {
    global.socketServer.clients.forEach(client => {
      if (client.readyState === WebSocket.OPEN) {
        client.send(msg);
      }
    });
  }
}

module.exports = broadcast;
