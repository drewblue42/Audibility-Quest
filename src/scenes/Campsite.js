// restore HP or stamina
import Phaser from "phaser";
import Button from "../ui/Button";
import { RunState } from "../systems/RunState";
import { createPlayerStats } from "../ui/PlayerStats";

export default class Campsite extends Phaser.Scene {
  constructor() {
    super({ key: "campsite" });
  }

  init(data) {
    this.nodeId = data.nodeId;
    this.mapId = data.mapId;
    this.returnTo = data.returnTo ?? "nodeMap";
  }

  preload() {
    const campfireUrl = new URL(
      "../assets/animations/campfire-Sheet.png",
      import.meta.url
    ).toString();

    this.load.spritesheet(
      "campfire",
      campfireUrl,
      {
        // CHANGE THESE if your sprite sheet
        // uses a different frame size
        frameWidth: 36,
        frameHeight: 48,
      }
    );
  }

  create() {
    const width = this.scale.width;
    const height = this.scale.height;

    // -----------------------------
    // TEXT STYLES
    // -----------------------------

    const titleStyle = {
      fontFamily: "Palatino",
      fontSize: "48px",
      color: "#fcc844",
      fontStyle: "bold",
      stroke: "#241600",
      strokeThickness: 5,
    };

    const uiTextStyle = {
      fontFamily: "Palatino",
      fontSize: "26px",
      color: "#fcc844",
      fontStyle: "bold",
      stroke: "#241600",
      strokeThickness: 3,
    };

    // -----------------------------
    // BLACK BACKGROUND
    // -----------------------------

    this.add
      .rectangle(
        0,
        0,
        width,
        height,
        0x000000
      )
      .setOrigin(0)
      .setDepth(0);

    // -----------------------------
    // CAMPFIRE ANIMATION
    // -----------------------------

    if (!this.anims.exists("campfire-burning")) {
      this.anims.create({
        key: "campfire-burning",

        frames:
          this.anims.generateFrameNumbers(
            "campfire",
            {
              start: 0,

              end: 5,
            }
          ),

        frameRate: 8,
        repeat: -1,
      });
    }

    // -----------------------------
    // GLOW BEHIND FIRE
    // -----------------------------

    const glow = this.add
      .circle(
        width / 2,
        height / 2,
        120,
        0xff9d2e,
        0.18
      )
      .setDepth(1);

    const innerGlow = this.add
      .circle(
        width / 2,
        height / 2,
        75,
        0xffd166,
        0.22
      )
      .setDepth(2);

    // Outer glow pulse
    this.tweens.add({
      targets: glow,

      scale: {
        from: 2.9,
        to: 3.3,
      },

      alpha: {
        from: 0.12,
        to: 0.28,
      },

      duration: 900,
      yoyo: true,
      repeat: -1,
      ease: "Sine.easeInOut",
    });

    // Inner glow pulse
    this.tweens.add({
      targets: innerGlow,

      scale: {
        from: 2.85,
        to: 3.15,
      },

      alpha: {
        from: 0.18,
        to: 0.32,
      },

      duration: 650,
      yoyo: true,
      repeat: -1,
      ease: "Sine.easeInOut",
    });

    // -----------------------------
    // FIRE
    // -----------------------------

    const fire = this.add
      .sprite(
        width / 2,
        height / 2,
        "campfire"
      )
      .setScale(3)
      .setDepth(3);

    fire.play("campfire-burning");

    // -----------------------------
    // TITLE
    // -----------------------------

    this.add
      .text(
        width / 2,
        110,
        "Campsite",
        titleStyle
      )
      .setOrigin(0.5)
      .setDepth(10);

    this.add
      .text(
        width / 2,
        185,
        "Rest by the fire or continue your journey.",
        uiTextStyle
      )
      .setOrigin(0.5)
      .setDepth(10);

    // -----------------------------
    // BUTTONS
    // -----------------------------

    new Button(
      this,
      width / 2,
      700,
      `Restore Health (${this.seeRestoredHealthAmount()} HP)`,
      () => {
        this.restoreHealth();

        RunState.achievements.fortitude = false;

        console.log(
          "Fortitude achievements lost!!"
        );

        this.returnToMap();
      },
      4
    )


    new Button(
      this,
      width / 2,
      820,
      "Keep going without resting",
      () => {
        this.returnToMap();
      },
      4
    );

    // -----------------------------
    // PLAYER STATS
    // -----------------------------

    createPlayerStats(
      this,
      30,
      30
    );
  }

  seeRestoredHealthAmount() {
    const currentHealth =
      RunState.player.health;

    const maxHealth =
      RunState.player.maxHealth;

    const toAddHealth =
      Math.ceil(
        (maxHealth - currentHealth) / 2
      );

    return toAddHealth;
  }

  restoreHealth() {
    const currentHealth =
      RunState.player.health;

    const maxHealth =
      RunState.player.maxHealth;

    const toAddHealth =
      Math.ceil(
        (maxHealth - currentHealth) / 2
      );

    RunState.player.health =
      Math.min(
        currentHealth + toAddHealth,
        maxHealth
      );

    console.log(
      "Player health restored"
    );
  }

  restoreStamina() {
    console.log(
      "Restore player stamina here"
    );
  }

  returnToMap() {
    this.scene.start(
      this.returnTo,
      {
        mapId: this.mapId,
        currentNodeId:
          this.nodeId,
      }
    );
  }
}