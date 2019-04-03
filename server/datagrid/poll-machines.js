const axios = require("axios");
const log = require("../utils/log")("datagrid/poll-machines");
const GAME_STATES = require("../models/game-states");
const {OUTGOING_MESSAGE_TYPES} = require("../message-types");
const broadcast = require("../utils/broadcast");


function pollMachines(interval, alwaysPoll) {
  setInterval(function () {
    if (!alwaysPoll && global.game.state !== GAME_STATES.ACTIVE) {
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
    if (alwaysBroadcast || machine.value !== response.data) {
      machine.value = response.data;
      broadcast(OUTGOING_MESSAGE_TYPES.MACHINE, {id: machine.id, value: machine.value});
    }
  } catch (error) {
    log.error(`error occurred in http call get counter for machine ${machine.id}`);
    log.error(error)
  }
}


module.exports = pollMachines;
