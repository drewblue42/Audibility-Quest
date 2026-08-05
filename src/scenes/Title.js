import Phaser from "phaser";
import Button from "../ui/Button";
import { titleContent } from "../data/titleContent";

export default class Title extends Phaser.Scene {
  constructor() {
    super({ key: "title" });
  }

  preload() {
    const skyUrl = new URL(
      "../assets/images/slay_spire_intro.jpg",
      import.meta.url
    ).toString();

    this.load.image("sky", skyUrl);
  }

  create() {
    const bg = this.add
      .image(
        this.cameras.main.centerX,
        this.cameras.main.centerY,
        "sky"
      )
      .setOrigin(0.5);

    const scaleX = this.cameras.main.width / bg.width;
    const scaleY = this.cameras.main.height / bg.height;
    const scale = Math.max(scaleX, scaleY);

    bg.setScale(scale);

    this.add
      .text(
        this.cameras.main.centerX,
        140,
        titleContent.gameTitle,
        {
          fontSize: "52px",
          color: "#ffffff",
          fontStyle: "bold",
          stroke: "#000000",
          strokeThickness: 6,
        }
      )
      .setOrigin(0.5);

      new Button(
        this,
        this.cameras.main.centerX,
        620,
        titleContent.startButtonText,
        () => {
          this.scene.start('nodeMap');
        }
      );
      
    new Button(
      this,
      this.cameras.main.centerX,
      680,
      titleContent.instructionButtonText,
      () => {
        this.scene.start("InstructionsScreen");
      }
    );
  }
}