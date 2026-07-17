import Phaser from "phaser";
import { WORD_GRID } from "../data/wordGrid";
import GridOfButtons from "../ui/WordGrid";
import Button from "../ui/Button";
import { RunState } from "../systems/RunState";
import { getRandomMonster } from "../data/monsters";

export default class Fight extends Phaser.Scene {
  constructor() {
    super({ key: "fight" });
  }

  create(data) {
    this.returnTo = data?.returnTo ?? "nodeMap";
    this.nodeId = data?.nodeId ?? null;

    this.roundReady = false;
    this.fightEnded = false;
    this.grid = null;

    this.showCountdown(() => {
      this.buildFightScene();
      this.setupKeyboardControls();
    });

    this.events.once("shutdown", () => {
      this.input.keyboard?.removeAllListeners("keydown");
    });
  }

  ////////Shows the inital fight screen
  showCountdown(onComplete) {
    const fightCountDown = this.add
      .text(640, 450, "", {
        fontSize: "100px",
      })
      .setOrigin(0.5);

    const words = ["Get", "Ready", "To", "Fight"];
    const wordTiming = 600;

    words.forEach((word, i) => {
      this.time.delayedCall(i * wordTiming, () => {
        fightCountDown.setText(word);
      });
    });

    this.time.delayedCall(wordTiming * words.length, () => {
      fightCountDown.destroy();
      onComplete();
    });
  }


  buildFightScene() {
    this.add.

    this.add.text(50, 30, "Practice Fight", {
      fontSize: "32px",
    });

    const monsterTemplate = getRandomMonster();

    this.currentMonster = {
      name: monsterTemplate.name,
      health: monsterTemplate.maxHealth,
      maxHealth: monsterTemplate.maxHealth,
      color: monsterTemplate.color,
    };

    this.healthText = this.add.text(
      50,
      80,
      `❤️ ${RunState.player.health}/${RunState.player.maxHealth}`,
      {
        fontSize: "28px",
      }
    );

    this.staminaText = this.add.text(
      50,
      120,
      `Stamina: ${RunState.player.stamina}/${RunState.player.maxStamina}`,
      {
        fontSize: "24px",
      }
    );

    this.damageText = this.add
      .text(640, 230, "", {
        fontSize: "36px",
      })
      .setOrigin(0.5);

    // Player and monster are now higher, leaving room for the word grid below.
    this.player = this.add.rectangle(220, 330, 80, 120, 0x4a90e2);

    this.monster = this.add.rectangle(
      1050,
      330,
      100,
      130,
      this.currentMonster.color
    );

    this.add.text(185, 405, "Player", {
      fontSize: "20px",
    });

    this.monsterNameText = this.add.text(
      980,
      405,
      this.currentMonster.name,
      {
        fontSize: "20px",
      }
    );

    this.monsterHealthText = this.add.text(
      980,
      435,
      `HP: ${this.currentMonster.health}/${this.currentMonster.maxHealth}`,
      {
        fontSize: "20px",
      }
    );

    this.statusText = this.add.text(
      805,
      70,
      "Choose one word from each column.",
      {
        fontSize: "22px",
      }
    );
    this.reminderText = this.add.text(
      50,
      900,
      "Reminder: You can run if you can't hear the words, but running reduces stamina by 1.",
      {
        fontSize: "18px",
      }
    );

    this.buildWordGrid();

    this.runBtn = new Button(this, 1080, 835, "Run", () => {
      this.runAway();
    });

    new Button(this, 1180, 835, "Back", () => {
      this.scene.start(this.returnTo);
    });
  }

  buildWordGrid() {
    const questions = buildQuestionsFromResearchGrid();
  
    this.grid = new GridOfButtons(this, 255, 500, {
      cols: WORD_GRID.length,
      rows: WORD_GRID[0].length,
  
      cellWidth: 115,
      cellHeight: 34,
  
      spacingX: 115,
      spacingY: 34,
  
      fontSize: "18px",
  
      questions,
  
      onPick: () => {
        if (this.grid.allChosen()) {
          this.roundReady = true;
          this.statusText.setText("Researcher may now press numpad 0–5.");
        }
      },
    });
  }

  setupKeyboardControls() {
    console.log("Keyboard controls set up");

    this.input.keyboard.on("keydown", (event) => {
      console.log("KEYDOWN:", event.key, event.code);

      if (this.fightEnded) return;

      if (event.code === "Enter" || event.code === "Space") {
        this.endFight(true);
        return;
      }

      if (!this.roundReady) return;

      const num = this.getNumpadNumber(event);

      if (num >= 0 && num <= 5) {
        this.resolveResearcherDamage(num);
      }
    });
  }

  getNumpadNumber(event) {
    const allowed = ["0", "1", "2", "3", "4", "5"];

    if (event.code?.startsWith("Numpad")) {
      const num = event.code.replace("Numpad", "");
      return allowed.includes(num) ? Number(num) : Number.NaN;
    }

    if (event.code?.startsWith("Digit")) {
      const num = event.code.replace("Digit", "");
      return allowed.includes(num) ? Number(num) : Number.NaN;
    }

    return Number.NaN;
  }

  resolveResearcherDamage(monsterDamage) {
    if (this.fightEnded) return;

    const playerDamage = 5 - monsterDamage;

    this.roundReady = false;

    RunState.damagePlayer(playerDamage);

    this.currentMonster.health = Math.max(
      0,
      this.currentMonster.health - monsterDamage
    );

    this.healthText.setText(
      `❤️ ${RunState.player.health}/${RunState.player.maxHealth}`
    );

    this.monsterHealthText.setText(
      `HP: ${this.currentMonster.health}/${this.currentMonster.maxHealth}`
    );

    this.damageText.setText(
      `Monster -${monsterDamage}     Player -${playerDamage}`
    );

    this.animateAttack(monsterDamage);

    if (this.currentMonster.health <= 0) {
      this.time.delayedCall(700, () => {
        this.endFight(true);
      });
      return;
    }

    this.time.delayedCall(1200, () => {
      if (this.fightEnded) return;

      this.damageText.setText("");
      this.statusText.setText("Choose one word from each column.");
      this.resetWordGrid();
    });
  }

  animateAttack(monsterDamage) {
    const originalPlayerX = this.player.x;
    const originalPlayerY = this.player.y;
    const originalMonsterX = this.monster.x;

    if (monsterDamage === 0) {
      this.statusText.setText("The player attacks, but misses!");

      this.tweens.add({
        targets: this.player,
        x: originalPlayerX + 150,
        y: originalPlayerY + 40,
        angle: 25,
        duration: 500,
        yoyo: true,
        onComplete: () => {
          this.player.setAngle(0);
          this.player.x = originalPlayerX;
          this.player.y = originalPlayerY;
        },
      });

      this.cameras.main.shake(200, 0.01);
      return;
    }

    if (monsterDamage === 5) {
      this.statusText.setText("Strong hit!");

      this.tweens.add({
        targets: this.player,
        x: originalPlayerX + 720,
        duration: 500,
        yoyo: true,
        onComplete: () => {
          this.player.x = originalPlayerX;
        },
      });

      this.tweens.add({
        targets: this.monster,
        x: originalMonsterX + 25,
        duration: 200,
        yoyo: true,
        repeat: 3,
        onComplete: () => {
          this.monster.x = originalMonsterX;
        },
      });

      return;
    }

    this.statusText.setText(`The player hits for ${monsterDamage} damage.`);

    this.tweens.add({
      targets: this.player,
      x: originalPlayerX + 620,
      duration: 500,
      yoyo: true,
      onComplete: () => {
        this.player.x = originalPlayerX;
      },
    });

    this.tweens.add({
      targets: this.monster,
      alpha: 0.35,
      duration: 500,
      yoyo: true,
      onComplete: () => {
        this.monster.alpha = 1;
      },
    });
  }

  resetWordGrid() {
    if (this.grid) {
      this.grid.destroy();
      this.grid = null;
    }

    this.roundReady = false;
    this.buildWordGrid();
  }

  runAway() {
    if (this.fightEnded) return;

    this.fightEnded = true;
    this.roundReady = false;

    RunState.reduceStamina(1);

    this.staminaText.setText(
      `Stamina: ${RunState.player.stamina}/${RunState.player.maxStamina}`
    );

    this.statusText.setText("You ran away. Stamina reduced by 1.");

    if (this.grid) {
      this.grid.destroy();
      this.grid = null;
    }

    this.tweens.add({
      targets: this.player,
      x: -100,
      duration: 600,
      onComplete: () => {
        this.scene.start(this.returnTo);
      },
    });
  }

  endFight(showMonsterDeath = true) {
    if (this.fightEnded) return;

    this.fightEnded = true;
    this.roundReady = false;

    this.statusText.setText("Fight ended.");

    if (this.grid) {
      this.grid.destroy();
      this.grid = null;
    }

    if (showMonsterDeath) {
      this.tweens.add({
        targets: this.monster,
        alpha: 0,
        y: this.monster.y + 80,
        duration: 700,
        onComplete: () => {
          this.statusText.setText(`${this.currentMonster.name} disappeared.`);
        },
      });
    }

    this.time.delayedCall(1200, () => {
      this.scene.start(this.returnTo);
    });
  }
}

function buildQuestionsFromResearchGrid() {
  return WORD_GRID.map((columnChoices) => {
    return {
      correct: null,
      choices: columnChoices,
    };
  });
}