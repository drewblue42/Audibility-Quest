import Phaser from "phaser";
import { RunState } from "../systems/RunState";
import Button from "../ui/Button";

export default class GameOver extends Phaser.Scene {
  constructor() {
    super({ key: "gameOver" });
  }

  create() {
    const centerX = this.cameras.main.centerX;

    this.add
      .text(centerX, 80, "RUN COMPLETE", {
        fontSize: "64px",
        color: "#ffffff",
        fontStyle: "bold",
      })
      .setOrigin(0.5);

    this.add
      .text(centerX, 150, "Your Results", {
        fontSize: "32px",
        color: "#dddddd",
      })
      .setOrigin(0.5);

    // Stats
    this.add.text(
      150,
      230,
      `Deaths: ${RunState.achievements.numDeaths}`,
      {
        fontSize: "26px",
        color: "#ffffff",
      }
    );

    this.add.text(
      150,
      275,
      `Damage Received: ${RunState.achievements.damageReceived}`,
      {
        fontSize: "26px",
        color: "#ffffff",
      }
    );

    this.add.text(
      150,
      320,
      `Words Correct: ${RunState.achievements.wordsCorrect}`,
      {
        fontSize: "26px",
        color: "#ffffff",
      }
    );

    this.add
      .text(centerX, 400, "Achievements", {
        fontSize: "36px",
        color: "#ffd700",
        fontStyle: "bold",
      })
      .setOrigin(0.5);

    const achievements = [
      {
        name: "Immortal",
        unlocked: RunState.achievements.immortal,
        description: "Beat the game without dying.",
      },
      {
        name: "Fortitude",
        unlocked: RunState.achievements.fortitude,
        description: "Beat the game without gaining back any lost life from campsites/potions.",
      },
      {
        name: "Warrior",
        unlocked: RunState.achievements.warrior,
        description: "More than 200 words correct",
      },
      {
        name: "Potion Master",
        unlocked: RunState.achievements.potionMaster,
        description: "Beat the game after visiting the potion shop.",
      },
    ];

    achievements.forEach((achievement, index) => {
      const x = 250 + index * 260;
      const y = 510;

      this.createAchievement(
        x,
        y,
        achievement.name,
        achievement.description,
        achievement.unlocked
      );
    });

    this.descriptionText = this.add
      .text(
        centerX,
        680,
        "Hover over an achievement to see its description.",
        {
          fontSize: "22px",
          color: "#ffffff",
          backgroundColor: "#000000",
          padding: {
            x: 16,
            y: 12,
          },
          wordWrap: {
            width: 700,
          },
          align: "center",
        }
      )
      .setOrigin(0.5);

    new Button(this, centerX, 800, "Play Again", () => {
      RunState.resetRun();
      this.scene.start("nodeMap");
    });
  }

  createAchievement(x, y, name, description, unlocked) {
    const background = this.add
      .rectangle(
        x,
        y,
        210,
        100,
        unlocked ? 0x3a7d44 : 0x333333
      )
      .setStrokeStyle(
        4,
        unlocked ? 0xffd700 : 0x666666
      )
      .setInteractive({ useHandCursor: true });

    const status = unlocked ? "✓" : "🔒";

    this.add
      .text(x, y - 15, `${status} ${name}`, {
        fontSize: "22px",
        color: unlocked ? "#ffffff" : "#888888",
        fontStyle: "bold",
      })
      .setOrigin(0.5);

    this.add
      .text(
        x,
        y + 22,
        unlocked ? "Unlocked" : "Locked",
        {
          fontSize: "16px",
          color: unlocked ? "#ffffff" : "#888888",
        }
      )
      .setOrigin(0.5);

    background.on("pointerover", () => {
      background.setScale(1.08);

      this.descriptionText.setText(
        unlocked
          ? description
          : `LOCKED: ${description}`
      );
    });

    background.on("pointerout", () => {
      background.setScale(1);

      this.descriptionText.setText(
        "Hover over an achievement to see its description."
      );
    });
  }
}