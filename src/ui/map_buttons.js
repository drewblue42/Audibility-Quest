// slay-the-spire style branching map
import Phaser from "phaser";
import Button from "../ui/Button";

export default class MapScene extends Phaser.Scene {
  constructor() {
    super({ key: "map" });
    this.nodes = [];
    this.connections = [];
  }

  preload() {
    const skyUrl = new URL("../assets/images/map.jpg", import.meta.url).toString();
    this.load.image("map", skyUrl);
  }

  create() {
    // Background
    // const bg = this.add.image(0, 0, "map").setOrigin(0);

    // const scaleX = this.cameras.main.width / bg.width;
    // const scaleY = this.cameras.main.height / bg.height;
    // bg.setScale(Math.max(scaleX, scaleY));

    // 1) Generate nodes
    this.nodes = generateMapNodes(this, { rows: 7, cols: 4 });

    // 2) Connect nodes
    this.connections = connectMapNodes(this.nodes);

    // 3) Draw connections first (so they appear behind nodes)
    this.drawConnections(this.nodes, this.connections);

    // 4) Render node buttons
    this.renderNodes(this.nodes);
  }

  renderNodes(nodes) {
    nodes.forEach((node) => {
      new Button(this, node.x, node.y, "●", () => this.onNodeSelected(node));
    });
  }

  drawConnections(nodes, connections) {
    // helpful lookup from id -> node
    const nodeById = new Map(nodes.map((n) => [n.id, n]));

    const g = this.add.graphics();
    g.lineStyle(3, 0xffffff, 0.5); // you can tweak later

    connections.forEach((c) => {
      const from = nodeById.get(c.from);
      const to = nodeById.get(c.to);
      if (!from || !to) return;

      g.beginPath();
      g.moveTo(from.x, from.y);
      g.lineTo(to.x, to.y);
      g.strokePath();
    });
  }

  onNodeSelected(node) {
    console.log("Selected node:", node);
    this.scene.start("fight", { node });
  }
}

/** --- Pure helper functions (outside the class) --- */

function generateMapNodes(scene, config = {}) {
  const {
    rows = 6,
    cols = 3,
    startY = 150,
    spacingY = 120,
    spacingX = 200,
    jitterX = 30,
    jitterY = 20,
    fillChance = 0.7,
  } = config;

  const centerX = scene.cameras.main.centerX;
  const startX = centerX - ((cols - 1) * spacingX) / 2;

  const nodes = [];

  for (let row = 0; row < rows; row++) {
    for (let col = 0; col < cols; col++) {
      if (Math.random() > fillChance) continue;

      const x = startX + col * spacingX + Phaser.Math.Between(-jitterX, jitterX);
      const y = startY + row * spacingY + Phaser.Math.Between(-jitterY, jitterY);

      nodes.push({
        id: `${row}-${col}`,
        row,
        col,
        x,
        y,
        type: "combat",
        reachable: row === 0,
      });
    }
  }

  return nodes;
}

function connectMapNodes(nodes) {
  const connections = [];

  nodes.forEach((node) => {
    const nextRow = nodes.filter(
      (n) => n.row === node.row + 1 && Math.abs(n.col - node.col) <= 1
    );

    if (nextRow.length > 0) {
      const target = Phaser.Utils.Array.GetRandom(nextRow);
      connections.push({ from: node.id, to: target.id });
    }
  });

  return connections;
}
