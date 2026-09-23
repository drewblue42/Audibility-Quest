// ToDo add a back button(add issue to github)

import Button from "../ui/Button";
import Phaser from "phaser";
import { titleContent } from "../data/titleContent";

export default class InstructionsScreen extends Phaser.Scene {
  constructor() {
    super({ key: "InstructionsScreen" });
  }

  preload() {
    const castleUrl = new URL(
      "../assets/images/background/castle.png",
      import.meta.url
    ).toString();

    this.load.image("instructionsCastle", castleUrl);
  }

  create() {
    const howTo = titleContent.instructions[0];
    const healthStamina = titleContent.instructions[1];

    // -------------------------
    // BACKGROUND
    // -------------------------

    const bg = this.add
      .image(
        this.cameras.main.centerX,
        this.cameras.main.centerY,
        "instructionsCastle"
      )
      .setOrigin(0.5);

    const scaleX =
      this.cameras.main.width / bg.width;

    const scaleY =
      this.cameras.main.height / bg.height;

    const scale =
      Math.max(scaleX, scaleY);

    bg.setScale(scale);

    // -------------------------
    // OPTIONAL DARK OVERLAY
    // Makes the text easier to read
    // -------------------------

    this.add
      .rectangle(
        0,
        0,
        this.scale.width,
        this.scale.height,
        0x000000,
        0.35
      )
      .setOrigin(0);

    // -------------------------
    // TEXT STYLES
    // -------------------------

    const headingStyle = {
      fontFamily: "Palatino",
      fontSize: "52px",
      color: "#fcc844",
      fontStyle: "bold",
      stroke: "#241600",
      strokeThickness: 6,
      align: "center",
    };

    const bodyStyle = {
      fontFamily: "Palatino",
      fontSize: "28px",
      color: "#fff1a8",
      fontStyle: "bold",
      stroke: "#241600",
      strokeThickness: 4,
      align: "center",
      lineSpacing: 8,
      wordWrap: {
        width: 1000,
        useAdvancedWrap: true,
      },
    };

    // -------------------------
    // HOW TO PLAY
    // -------------------------

    this.add
      .text(
        this.cameras.main.centerX,
        120,
        howTo.heading,
        headingStyle
      )
      .setOrigin(0.5);

    this.add
      .text(
        this.cameras.main.centerX,
        260,
        howTo.body.join("\n\n"),
        bodyStyle
      )
      .setOrigin(0.5);

    // -------------------------
    // HEALTH / STAMINA
    // -------------------------

    this.add
      .text(
        this.cameras.main.centerX,
        460,
        healthStamina.heading,
        headingStyle
      )
      .setOrigin(0.5);

    this.add
      .text(
        this.cameras.main.centerX,
        600,
        healthStamina.body.join("\n\n"),
        bodyStyle
      )
      .setOrigin(0.5);

    // -------------------------
    // BACK BUTTON
    // -------------------------

    new Button(
      this,
      this.cameras.main.centerX,
      820,
      "Back to Title Screen",
      () => {
        this.scene.start("title");
      }
    );
  }
}