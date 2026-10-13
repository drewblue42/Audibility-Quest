export function createBoss() {
  return {
  name: "Black Dragon",
  health: 4,
  maxHealth: 4,

  textureKey: "dragonIdle",

  animations: {
    idle: "dragon-idle",
    attack: "dragon-attack",
  },

  scale: 2.5,
};
}