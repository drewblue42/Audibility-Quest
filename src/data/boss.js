export function createBoss() {
  return {
  name: "Black Dragon",
  health: 8,
  maxHealth: 8,

  textureKey: "dragonIdle",

  animations: {
    idle: "dragon-idle",
    attack: "dragon-attack",
  },

  scale: 2.5,
};
}