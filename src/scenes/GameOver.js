import Phaser from "phaser";
import { RunState } from "../systems/RunState";
import Button from "../ui/Button";

export default class GameOver extends Phaser.Scene {
  constructor() {
    super({ key: "gameOver" });
  }

  preload() {
    const gameOverUrl = new URL(
      "../assets/images/background/treasureroom.png",
      import.meta.url
    ).toString();

    this.load.image("treasure", gameOverUrl);
  }

  create() {
    const width = this.scale.width;
    const height = this.scale.height;
    const centerX = this.cameras.main.centerX;

    // -------------------------
    // BACKGROUND
    // -------------------------

    const bg = this.add
      .image(
        centerX,
        this.cameras.main.centerY,
        "treasure"
      )
      .setOrigin(0.5);

    const scaleX =
      width / bg.width;

    const scaleY =
      height / bg.height;

    const scale =
      Math.max(scaleX, scaleY);

    bg.setScale(scale);

    // Dark overlay so text is readable
    this.add
      .rectangle(
        0,
        0,
        width,
        height,
        0x000000,
        0.45
      )
      .setOrigin(0);

    // -------------------------
    // TEXT STYLES
    // -------------------------

    const titleStyle = {
      fontFamily: "Palatino",
      fontSize: "64px",
      color: "#fcc844",
      fontStyle: "bold",
      stroke: "#241600",
      strokeThickness: 7,
      align: "center",
    };

    const headingStyle = {
      fontFamily: "Palatino",
      fontSize: "36px",
      color: "#fcc844",
      fontStyle: "bold",
      stroke: "#241600",
      strokeThickness: 4,
      align: "center",
    };

    const bodyStyle = {
      fontFamily: "Palatino",
      fontSize: "24px",
      color: "#fff1a8",
      fontStyle: "bold",
      stroke: "#241600",
      strokeThickness: 3,
    };

    const smallStyle = {
      fontFamily: "Palatino",
      fontSize: "18px",
      color: "#fff1a8",
      fontStyle: "bold",
      stroke: "#241600",
      strokeThickness: 2,
    };

    // -------------------------
    // TITLE
    // -------------------------

    this.add
      .text(
        centerX,
        80,
        "RUN COMPLETE",
        titleStyle
      )
      .setOrigin(0.5);

    this.add
      .text(
        centerX,
        145,
        "Your Results",
        headingStyle
      )
      .setOrigin(0.5);

    // -------------------------
    // STATS PANEL
    // -------------------------

    const statPanelX = centerX;
    const statPanelY = 275;
    const statPanelWidth = 620;
    const statPanelHeight = 150;

    const statsPanel = this.add.graphics();

    statsPanel.fillStyle(
      0x17130d,
      0.9
    );

    statsPanel.fillRoundedRect(
      statPanelX - statPanelWidth / 2,
      statPanelY - statPanelHeight / 2,
      statPanelWidth,
      statPanelHeight,
      14
    );

    statsPanel.lineStyle(
      3,
      0x8f6b2e,
      1
    );

    statsPanel.strokeRoundedRect(
      statPanelX - statPanelWidth / 2,
      statPanelY - statPanelHeight / 2,
      statPanelWidth,
      statPanelHeight,
      14
    );

    this.add
      .text(
        centerX - 250,
        215,
        `Deaths: ${RunState.achievements.numDeaths}`,
        bodyStyle
      );

    this.add
      .text(
        centerX - 250,
        260,
        `Damage Received: ${RunState.achievements.damageReceived}`,
        bodyStyle
      );

    this.add
      .text(
        centerX - 250,
        305,
        `Words Correct: ${RunState.achievements.wordsCorrect}`,
        bodyStyle
      );

    // -------------------------
    // ACHIEVEMENTS TITLE
    // -------------------------

    this.add
      .text(
        centerX,
        400,
        "Achievements",
        headingStyle
      )
      .setOrigin(0.5);

    // -------------------------
    // ACHIEVEMENTS
    // -------------------------

    const achievements = [
      {
        name: "Immortal",
        unlocked:
          RunState.achievements.immortal,

        description:
          "Beat the game without dying.",
      },
      {
        name: "Fortitude",
        unlocked:
          RunState.achievements.fortitude,

        description:
          "Beat the game without gaining back any lost life from campsites/potions.",
      },
      {
        name: "Warrior",
        unlocked:
          RunState.achievements.warrior,

        description:
          "More than 200 words correct.",
      },
      {
        name: "Potion Master",
        unlocked:
          RunState.achievements.potionMaster,

        description:
          "Beat the game after visiting the potion shop.",
      },
    ];

    achievements.forEach(
      (achievement, index) => {
        const x =
          250 + index * 260;

        const y = 510;

        this.createAchievement(
          x,
          y,
          achievement.name,
          achievement.description,
          achievement.unlocked,
          smallStyle
        );
      }
    );

    // -------------------------
    // DESCRIPTION PANEL
    // -------------------------

    this.descriptionText = this.add
      .text(
        centerX,
        680,
        "Hover over an achievement to see its description.",
        {
          ...bodyStyle,

          backgroundColor:
            "#17130d",

          padding: {
            x: 20,
            y: 14,
          },

          wordWrap: {
            width: 750,
            useAdvancedWrap: true,
          },

          align: "center",
        }
      )
      .setOrigin(0.5);

    // -------------------------
    // PLAY AGAIN BUTTON
    // -------------------------

    new Button(
      this,
      centerX,
      820,
      "Play Again",
      () => {
        RunState.resetRun();
        this.scene.start("nodeMap");
      }
    );
  }

  createAchievement(
    x,
    y,
    name,
    description,
    unlocked,
    textStyle
  ) {
    // -------------------------
    // CARD BACKGROUND
    // -------------------------

    const background =
      this.add.graphics();

    const fillColor =
      unlocked
        ? 0x2b2416
        : 0x151515;

    const borderColor =
      unlocked
        ? 0xc89b3c
        : 0x555555;

    background.fillStyle(
      fillColor,
      0.95
    );

    background.fillRoundedRect(
      x - 105,
      y - 50,
      210,
      100,
      12
    );

    background.lineStyle(
      3,
      borderColor,
      1
    );

    background.strokeRoundedRect(
      x - 105,
      y - 50,
      210,
      100,
      12
    );

    // Invisible hit area
    const hitArea = this.add
      .rectangle(
        x,
        y,
        210,
        100,
        0xffffff,
        0
      )
      .setInteractive({
        useHandCursor: true,
      });

    const status =
      unlocked
        ? "✓"
        : "🔒";

    const titleText =
      this.add
        .text(
          x,
          y - 15,
          `${status} ${name}`,
          {
            ...textStyle,

            fontSize: "22px",

            color: unlocked
              ? "#fcc844"
              : "#777777",
          }
        )
        .setOrigin(0.5);

    const unlockText =
      this.add
        .text(
          x,
          y + 22,
          unlocked
            ? "Unlocked"
            : "Locked",
          {
            ...textStyle,

            fontSize: "16px",

            color: unlocked
              ? "#fff1a8"
              : "#666666",
          }
        )
        .setOrigin(0.5);

    hitArea.on(
      "pointerover",
      () => {
        titleText.setScale(1.08);
        unlockText.setScale(1.08);

        this.descriptionText.setText(
          unlocked
            ? description
            : `LOCKED: ${description}`
        );
      }
    );

    hitArea.on(
      "pointerout",
      () => {
        titleText.setScale(1);
        unlockText.setScale(1);

        this.descriptionText.setText(
          "Hover over an achievement to see its description."
        );
      }
    );
  }
}