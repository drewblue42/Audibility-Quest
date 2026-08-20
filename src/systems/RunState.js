import { createPlayer } from "../data/player";
import { STARTING_MAP_ID, STARTING_NODE_ID } from "../congif/gameConfig.js"



export const RunState = {
  player: createPlayer(),

  progress: {
    currentNodeId: STARTING_NODE_ID,
    currentMapId: STARTING_MAP_ID,
    //completedNodes: [],
  },
// get current node function? and add currentNodeID to config file

  resetRun() {
    createPlayer();
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
  setCurrentNode(nodeId){
    if(!nodeId){
      console.warn("Cannot set an empty Node ID");
      return;
    }
      this.progress.currentNodeId = nodeId
  },

  // completeNode(nodeId) {
  //   if (!this.progress.completedNodes.includes(nodeId)) {
  //     this.progress.completedNodes.push(nodeId);
  //   }
  //   else{
  //     console.error("Already completed")
  //   }
  //   console.log("completed Nodes: " + this.progress.completedNodes)
  // },
};