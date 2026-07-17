import Phaser from "phaser";
import Boot from "./scenes/Boot";
import Title from "./scenes/Title";
import Fight from "./scenes/Fight";
import MapScene from "./scenes/Map";
import NodeMap from "./scenes/NodeMap";

const config = {
  width: 1280,
  height: 950,
  scale: {
    mode: Phaser.Scale.FIT,
    autoCenter: Phaser.Scale.CENTER_BOTH,
  },
  mode: Phaser.Scale.FIT,
  autoCenter: Phaser.Scale.CENTER_BOTH,
  type: Phaser.AUTO,
  backgroundColor: "#909191",
  physics: { default: "arcade", arcade: { gravity: { y: 0 } } },
  scene: [Boot, Title, Fight, NodeMap, MapScene,], // boot will auto-start first
};

new Phaser.Game(config);