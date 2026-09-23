export function createPlayer() {
    return {
      health: 5,
      maxHealth: 100,
      stamina: 1,
      maxStamina: 3,
      inventory: [],
      textureKey: "samuraiIdle",
  
      animations: {
        idle: "samurai-idle",
    
      },
  
      scale: 6,
    };
  }