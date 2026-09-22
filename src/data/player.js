export function createPlayer() {
    return {
      health: 5,
      maxHealth: 100,
      stamina: 2,
      maxStamina: 1,
      inventory: [],
      textureKey: "samuraiIdle",
  
      animations: {
        idle: "samurai-idle",
    
      },
  
      scale: 6,
    };
  }