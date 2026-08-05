export function createPlayer() {
    return {
      health: 10,
      maxHealth: 30,
      stamina: 5,
      maxStamina: 5,
      inventory: [],
      textureKey: "samuraiIdle",
  
      animations: {
        idle: "samurai-idle",
    
      },
  
      scale: 6,
    };
  }