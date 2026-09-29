// src/data/monsters.js

export const MONSTERS = [
    {
      name: "Skeleton Warrior",
      maxHealth: 1,
  
      textureKey: "skeletonIdle",
  
      animations: {
        idle: "skeleton-idle",
        attack: "skeleton-attack",
      },
  
      scale: 6,
    },
    {
      name: "Black Knight",
      maxHealth: 1,
  
      textureKey: "blackKnightIdle",
  
      animations: {
        idle: "blackKnight-idle",
        attack: "blackKnight-attack",
      },
  
      scale: 4,
    },
   ];

  export function getRandomMonster() {
    const index = Math.floor(Math.random() * MONSTERS.length);
    return MONSTERS[index];
  }