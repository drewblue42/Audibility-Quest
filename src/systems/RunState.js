import { createPlayer } from "../data/player";
import { STARTING_MAP_ID, STARTING_NODE_ID } from "../congif/gameConfig.js"
import { createBoss } from "../data/boss.js";


export const RunState = {
  player: createPlayer(),

  progress: {
    currentNodeId: STARTING_NODE_ID,
    currentMapId: STARTING_MAP_ID,
    completedNodes: [],
    skipNode: false
  },
  achievements:{
    numDeaths: 0, //implemented
    damageReceived: 0, //implemented
    wordsCorrect: 190, //implemented
    immortal: true, //implemented
    fortitude: true, //implemented
    warrior: false, //implemented
    potionMaster: false //implemented
  },

  boss: createBoss(),
  

  resetRun() {
    this.player = createPlayer();
    this.boss = createBoss();
    this.progress.currentMapId = STARTING_MAP_ID;
    this.progress.currentNodeId = STARTING_NODE_ID;
    this.progress.completedNodes = [];
  },

  damagePlayer(amount) {
    this.player.health = Math.max(0, this.player.health - amount);
  },

  reduceStamina(amount) {
    this.player.stamina = Math.max(0, this.player.stamina - amount);
  },

  setCurrentMap(mapId) {
    if (!mapId) {
      console.warn("Cannot set an empty map ID");
      return;
  }
    this.progress.currentMapId = mapId;
  },
  setCurrentNode(nodeId) {
    if (nodeId === null || nodeId === undefined) {
        console.warn("Cannot set an empty Node ID");
        return;
    }

    this.progress.currentNodeId = nodeId;
},

  completeNode(nodeId) {
    if (!this.progress.completedNodes.includes(nodeId)) {
      this.progress.completedNodes.push(nodeId);
    }
    console.log("completed Nodes: " + this.progress.completedNodes)
  },
};