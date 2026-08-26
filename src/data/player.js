export function createPlayer() {
    return {
      health: 10,
      maxHealth: 30,
      stamina: 3,
      maxStamina: 3,
      inventory: [],
      textureKey: "samuraiIdle",
  
      animations: {
        idle: "samurai-idle",
    
      },
  
      scale: 6,
    };
  }