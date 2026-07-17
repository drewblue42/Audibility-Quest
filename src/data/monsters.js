// src/data/monsters.js

export const MONSTERS = [
    {
      name: "Dummy Goblin",
      maxHealth: 12,
      color: 0xb94a48,
    },
    {
      name: "Training Slime",
      maxHealth: 16,
      color: 0x4caf50,
    },
    {
      name: "Wooden Beast",
      maxHealth: 20,
      color: 0x8b5a2b,
    },
  ];
  
  export function getRandomMonster() {
    const index = Math.floor(Math.random() * MONSTERS.length);
    return MONSTERS[index];
  }