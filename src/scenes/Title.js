import Phaser from "phaser";
import Button from "../ui/Button";
import { titleContent } from "../data/titleContent";

export default class Title extends Phaser.Scene {
  constructor() {
    super({ key: "title" });
  }

  preload() {
    const skyUrl = new URL(
      "../assets/images/background/castle.png",
      import.meta.url
    ).toString();

    const buttonUrl = new URL(
      "../assets/ui/banner.png",
      import.meta.url
    ).toString();

    const musicUrl = new URL(
      "../assets/audio/Road To Camelot.mp3",
      import.meta.url
    ).toString();

    this.load.audio("titleMusic", musicUrl);

    this.load.image("castle", skyUrl);
    this.load.image("Button", buttonUrl);
  }

  create() {
    const bg = this.add
      .image(
        this.cameras.main.centerX,
        this.cameras.main.centerY,
        "castle"
      )
      .setOrigin(0.5);

    const scaleX = this.cameras.main.width / bg.width;
    const scaleY = this.cameras.main.height / bg.height;
    const scale = Math.max(scaleX, scaleY);

    bg.setScale(scale);

    this.titleMusic = this.sound.add("titleMusic", {
      loop: true,
      volume: 0.2,
    });

    this.titleMusic.play();
    this.titleMusic.setSeek(6);

    this.musicOn = false;

this.musicToggle = this.add
  .text(
    this.cameras.main.width - 40,
    30,
    "🔊",
    {
      fontSize: "32px",
    }
  )
  .setOrigin(0.5)
  .setDepth(20)
  .setInteractive({ useHandCursor: true });

this.musicToggle.on("pointerup", () => {
  this.musicOn = !this.musicOn;

  if (this.musicOn) {
    this.titleMusic.setMute(false);
    this.musicToggle.setText("🔊");
  } else {
    this.titleMusic.setMute(true);
    this.musicToggle.setText("🔇");
  }
});

    // Initial birds
    for (let i = 0; i < 20; i++) {
      this.createBird(
        Phaser.Math.Between(-200, 500),
        Phaser.Math.Between(70, 280),
        Phaser.Math.FloatBetween(0.2, 0.5),
        Phaser.Math.Between(16000, 26000)
      );
    }

    // Keep spawning birds
    this.time.addEvent({
      delay: 2000,
      loop: true,
      callback: () => {
        this.createBird(
          -50,
          Phaser.Math.Between(70, 230),
          Phaser.Math.FloatBetween(0.2, 0.5),
          Phaser.Math.Between(16000, 26000)
        );
      },
    });



    this.add
      .text(
        this.cameras.main.centerX + 180,
        120,
        titleContent.gameTitle,
        {
          fontSize: "90px",
          fontFamily: "Palitino",
          color: "#fcc844",
          fontStyle: "bold",
          stroke: "#574312",
          strokeThickness: 10,
        }
      )
      .setOrigin(0.5)
      .setDepth(10);

    new Button(
      this,
      this.cameras.main.centerX + 400,
      400,
      titleContent.startButtonText,
      () => {
        this.titleMusic.stop();
        this.scene.start("nodeMap");
      }
    );

    new Button(
      this,
      this.cameras.main.centerX + 400,
      500,
      titleContent.instructionButtonText,
      () => {
        this.titleMusic.stop();
        this.scene.start("InstructionsScreen");
      }
    );
  }

  createBird(x, y, scale = 1, duration = 10000) {
    const bird = this.add.container(x, y).setDepth(1);

    bird.setScale(scale);

    const leftWing = this.add.graphics();

    leftWing.lineStyle(2, 0x111111, 0.8);
    leftWing.beginPath();
    leftWing.moveTo(0, 0);
    leftWing.lineTo(-10, -8);
    leftWing.lineTo(-20, 0);
    leftWing.strokePath();

    const rightWing = this.add.graphics();

    rightWing.lineStyle(2, 0x111111, 0.8);
    rightWing.beginPath();
    rightWing.moveTo(0, 0);
    rightWing.lineTo(10, -8);
    rightWing.lineTo(20, 0);
    rightWing.strokePath();

    bird.add([leftWing, rightWing]);

    this.startRandomFlapping(
      bird,
      leftWing,
      rightWing
    );


    // Bird flies across screen
    this.tweens.add({
      targets: bird,

      x: this.cameras.main.width + 100,

      y: y + Phaser.Math.Between(-30, 30),

      duration: duration,

      ease: "Linear",

      onComplete: () => {
        bird.destroy();
      },
    });
  }


  startRandomFlapping(bird, leftWing, rightWing) {
    const flapOnce = () => {
      this.tweens.add({
        targets: leftWing,
        angle: {
          from: 25,
          to: -35,
        },
        duration: 180,
        yoyo: true,
        repeat: 1,
        ease: "Sine.easeInOut",
      });

      this.tweens.add({
        targets: rightWing,
        angle: {
          from: -25,
          to: 35,
        },
        duration: 180,
        yoyo: true,
        repeat: 1,
        ease: "Sine.easeInOut",
      });

      // Wait a random amount before flapping again
      this.time.delayedCall(
        Phaser.Math.Between(700, 1800),
        flapOnce
      );
    };

    flapOnce();
  }
}