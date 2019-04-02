const infinispan = require("infinispan");
const env = require("env-var");

const log = require("../utils/log")("planner");
const optEventHandler = require("./opt-event");

const DATAGRID_HOST = env.get("DATAGRID_HOST").asString();
const DATAGRID_HOTROD_PORT = env.get("DATAGRID_HOTROD_PORT").asIntPositive();

async function initClient() {
  let client = await infinispan.client({port: DATAGRID_HOTROD_PORT, host: DATAGRID_HOST}, {cacheName: "DispatchEvents"});
  log.info(`Connected to OptaPlanner data`);

  let stats = await client.stats();
  log.debug(stats);

  let listenerId = await client.addListener("create", key => handleDataChange(client,"create", key));
  client.addListener("modify", key => handleDataChange(client,"modify", key), {listenerId});
  client.addListener("remove", key => handleDataChange(client,"remove", key), {listenerId});

  return client;
}

async function handleDataChange(client, changeType, key) {
  log.debug(`OptaPlanner event: ${changeType} ${key}`);
  optEventHandler(client, changeType, key);
}

async function initPlanner() {
  try {
    global.optClient = await initClient();
  } catch (error) {
    log.error(`Error connecting to OptaPlanner data: ${error.message}`);
    log.error(error);
  }
  return global.optClient;
}

module.exports = initPlanner;
