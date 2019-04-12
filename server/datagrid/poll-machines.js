const axios = require("axios");
const log = require("../utils/log")("datagrid/poll-machines");
const GAME_STATES = require("../models/game-states");
const {OUTGOING_MESSAGE_TYPES} = require("../message-types");
const broadcast = require("../utils/broadcast");
const MAX_HEALTH = 1000000000000000000;

async function pollMachines(interval, alwaysPoll) {
  setInterval(function () {
    const inactiveGameState = (global.game.state === GAME_STATES.LOBBY || global.game.state === GAME_STATES.LOADING);

    if (!alwaysPoll && inactiveGameState) {
      return;
    }

    for (let key in global.machines) {
      refreshMachine(global.machines[key], alwaysPoll);
    }
  }, interval);
}

async function refreshMachine(machine, alwaysBroadcast) {
  try {
    let response = await axios({method: "get", url: machine.url});
    machine.value = response.data;
  } catch (error) {
    log.error(`error occurred in http call get counter for machine ${machine.id}`);
    log.error(error)
  }

  let percent =  Math.floor(machine.value / MAX_HEALTH * 100);
  if (alwaysBroadcast || machine.percent !== percent) {
    machine.percent = percent;
    broadcast(OUTGOING_MESSAGE_TYPES.MACHINE, {id: machine.id, value: machine.value, percent: machine.percent}, "modify");
  }
}

module.exports = pollMachines;
