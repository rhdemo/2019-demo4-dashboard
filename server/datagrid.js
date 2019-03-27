const infinispan = require("infinispan");
const WebSocket = require("ws");
const env = require("env-var");
const log = require("./utils/log")("datagrid");
const {OUTGOING_MESSAGE_TYPES} = require("./message-types");

const DATAGRID_HOST = env.get("DATAGRID_HOTROD_SERVICE_HOST").asString();
const DATAGRID_PORT = env.get("DATAGRID_HOTROD_SERVICE_PORT").asIntPositive();

const DATAGRID_KEYS = {
  GAME: "game",
  LEADERBOARD: "leaderboard"
};


async function initClient() {
  let client = await infinispan.client({port: DATAGRID_PORT, host: DATAGRID_HOST});
  log.info(`Connected to Infinispan dashboard data`);

  let stats = await client.stats();
  log.debug(stats);

  let listenerId = await client.addListener("create", key => handleDataChange(client,"create", key));
  client.addListener("modify", key => handleDataChange(client,"modify", key), {listenerId});
  client.addListener("remove", key => handleDataChange(client,"remove", key), {listenerId});

  return client;
}


async function handleDataChange(client, changeType, key) {
  log.info(`Data change: ${changeType} ${key}`);
  let value;
  // value = await client.get(key);
  // log.info(`value = ${value}`);
  switch (key) {
    case DATAGRID_KEYS.GAME:
      log.info("Game change");
      value = await client.get(key);
      log.debug(`value = ${value}`);
      global.game = JSON.parse(value);
      broadcastGame();
      break;
  }
}

function broadcastGame() {
  const game = global.game;
  broadcastMessage(JSON.stringify({type: OUTGOING_MESSAGE_TYPES.GAME, game}));
}

function broadcastMessage(message) {
  global.socketServer.clients.forEach(function each(client) {
    if (client.readyState === WebSocket.OPEN) {
      client.send(message);
    }
  });
}

async function initData() {
  let dataClient = null;
  try {
    dataClient = await initClient();
    //TODO init data
  } catch (error) {
    log.error(`Error connecting to Infinispan dashboard data: ${error.message}`);
    log.error(error);
  }
  return dataClient;
}

module.exports.initData = initData;
module.exports.DATAGRID_KEYS = DATAGRID_KEYS;
