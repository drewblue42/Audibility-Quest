export function createPlayer() {
    return {
      health: 1,
      maxHealth: 100,
      stamina: 1,
      maxStamina: 3,
      inventory: [],
      textureKey: "kiraIdle",
  
      animations: {
        idle: "kira-idle",
        hit: "kira-hit",
        hurt: "kira-hurt",
        death:"kira-death"
    
      },
  
      scale: 1.9,
    };
  }