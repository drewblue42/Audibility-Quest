export function createBoss() {
  return {
  name: "Black Dragon",
  health: 1,
  maxHealth: 1,

  textureKey: "dragonIdle",

  animations: {
    idle: "dragon-idle",
    attack: "dragon-attack",
  },

  scale: 2.5,
};
}