module.exports = function send(ws, type, data) {
  ws.send(JSON.stringify({type, data}));
};