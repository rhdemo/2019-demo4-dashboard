module.exports = function send(ws, type, data, action) {
  ws.send(JSON.stringify({type, data, action}));
};