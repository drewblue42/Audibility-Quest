import Phaser from "phaser";

export default class Button {
  constructor(
    scene,
    x,
    y,
    label,
    onClick,
    scale = 3
  ) {
    this.background = scene.add
      .image(x, y, "Button")
      .setOrigin(0.5)
      .setScale(scale)
      .setInteractive({ useHandCursor: true });

    this.text = scene.add
      .text(x, y - 10, label, {
        fontSize: "32px",
        fontFamily: "Palatino",
        color: "#fcc844",
        fontStyle: "bold",
        stroke: "#4d4a24",
        strokeThickness: 3,
      })
      .setOrigin(0.5);

    // Gentle banner waving
    scene.tweens.add({
      targets: this.background,
      scaleX: {
        from: scale * 0.98,
        to: scale * 1.02,
      },
      scaleY: {
        from: scale * 1.01,
        to: scale * 0.99,
      },
      angle: {
        from: -0.5,
        to: 0.5,
      },
      duration: 900,
      yoyo: true,
      repeat: -1,
      ease: "Sine.easeInOut",
    });

    this.background.on("pointerover", () => {
      this.background.setTint(0xdddddd);
    });

    this.background.on("pointerout", () => {
      this.background.clearTint();
    });

    this.background.on("pointerdown", () => {
      this.background.setScale(scale * 0.95);
    });

    this.background.on("pointerup", () => {
      this.background.setScale(scale);
      onClick();
    });
  }
}