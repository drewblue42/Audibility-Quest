// src/data/monsters.js

export const MONSTERS = [
    {
      name: "Skeleton Warrior",
      maxHealth: 4,
  
      textureKey: "skeletonIdle",
  
      animations: {
        idle: "skeleton-idle",
        attack: "skeleton-attack",
      },
  
      scale: 6,
    },
  ];

  export function getRandomMonster() {
    const index = Math.floor(Math.random() * MONSTERS.length);
    return MONSTERS[index];
  }