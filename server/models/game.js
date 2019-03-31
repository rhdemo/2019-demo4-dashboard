const uuidv4 = require('uuid/v4');

class Game {
  constructor() {
    this.id = uuidv4();

    this.state = "lobby";

    this.motions = {
      shake: false,
      circle: false,
      x: false,
      roll: false,
      fever: false,
      floss: false,
    };

    this.scoring = {
      shake: 1,
      circle: 5,
      x: 5,
      roll: 10,
      fever: 20,
      floss: 100,
    };

    this.damagePercent =  {
      "machine-1": 100,
      "machine-2": 100,
      "machine-3": 100,
      "machine-4": 100,
      "machine-5": 100,
      "machine-6": 100,
      "machine-7": 100,
      "machine-8": 100,
      "machine-9": 100,
      "machine-10": 100
    }
  }
}

module.exports = Game;
