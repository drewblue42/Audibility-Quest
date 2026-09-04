export function createPlayer() {
    return {
      health: 40,
      maxHealth: 100,
      stamina: 0,
      maxStamina: 1,
      inventory: [],
      textureKey: "samuraiIdle",
  
      animations: {
        idle: "samurai-idle",
    
      },
  
      scale: 6,
    };
  }