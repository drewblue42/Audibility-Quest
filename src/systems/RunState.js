import { createPlayer } from "../data/player";

export const RunState = {
    player: createPlayer(),
  
    progress: {
      currentNodeId: 1,
      completedNodes: [],
    },
  
    resetRun() {
      this.player.health = this.player.maxHealth;
      this.player.stamina = this.player.maxStamina;
      this.progress.currentNodeId = 1;
      this.progress.completedNodes = [];
    },
  
    damagePlayer(amount) {
      this.player.health = Math.max(0, this.player.health - amount);
    },
  
    reduceStamina(amount) {
      this.player.stamina = Math.max(0, this.player.stamina - amount);
    },
  
    completeNode(nodeId) {
      if (!this.progress.completedNodes.includes(nodeId)) {
        this.progress.completedNodes.push(nodeId);
      }
    },
  };