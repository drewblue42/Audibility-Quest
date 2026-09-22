import Phaser from "phaser";
import { WORD_GRID } from "../data/wordGrid";
import GridOfButtons from "../ui/WordGrid";
import Button from "../ui/Button";
import { RunState } from "../systems/RunState";
import { getRandomMonster } from "../data/monsters";
import {
  getCombatScore,
  getSupportedScoreInputs,
} from "../data/combatScoreData.js";


export default class Fight extends Phaser.Scene {
  constructor() {
    super({ key: "fight" });
  }
  preload() {
    const skeletonIdleUrl = new URL(
      "../assets/animations/Skeleton/Idle.png",
      import.meta.url
    ).href;

    const skeletonAttackUrl = new URL(
      "../assets/animations/Skeleton/Attack3.png",
      import.meta.url
    ).href;

    const swordEffectUrl = new URL(
      "../assets/animations/Skeleton/Sword_sprite.png",
      import.meta.url
    ).href;

    const samuraiIdleUrl = new URL(
      "../assets/animations/Hero/Samurai/IDLE.png",
      import.meta.url
    ).href;

    this.load.spritesheet("skeletonIdle", skeletonIdleUrl, {
      frameWidth: 150,
      frameHeight: 150,
    });

    this.load.spritesheet("skeletonAttack", skeletonAttackUrl, {
      frameWidth: 150,
      frameHeight: 150,
    });

    this.load.spritesheet("swordEffect", swordEffectUrl, {
      frameWidth: 92,
      frameHeight: 102,
    });

    this.load.spritesheet("samuraiIdle", samuraiIdleUrl, {
      frameWidth: 96,
      frameHeight: 96,
    })

    const dragonIdleUrl = new URL(
      "../assets/animations/Dragon/ShadowDragon/Animations/Idle_Right/Idle_right.png",
      import.meta.url
    ).href;

    const dragonAttackUrl = new URL(
      "../assets/animations/Dragon/ShadowDragon/Animations/Attack_Right/Attack_right.png",

      import.meta.url
    ).href;

    this.load.spritesheet("dragonIdle", dragonIdleUrl, {
      frameWidth: 1408,
      frameHeight: 792,
    });

    this.load.spritesheet("dragonAttack", dragonAttackUrl, {
      frameWidth: 1408,
      frameHeight: 792,
    });
  }

  create(data) {
    this.returnTo = data?.returnTo ?? "nodeMap";
    this.nodeId = data?.nodeId ?? null;

    this.encounterType = data?.encounterType ?? "normal";

    this.roundReady = false;
    this.fightEnded = false;
    this.grid = null;

    this.showCountdown(() => {
      this.buildFightScene();
      this.setupKeyboardControls();
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

  createAnimations() {
    if (!this.anims.exists("skeleton-idle")) {
      this.anims.create({
        key: "skeleton-idle",
        frames: this.anims.generateFrameNumbers("skeletonIdle", {
          start: 0,
          end: 3,
        }),
        frameRate: 6,
        repeat: -1,
      });
    }

    if (!this.anims.exists("skeleton-attack")) {
      this.anims.create({
        key: "skeleton-attack",
        frames: this.anims.generateFrameNumbers("skeletonAttack", {
          start: 0,
          end: 5,
        }),
        frameRate: 10,
        repeat: 0,
      });
    }

    if (!this.anims.exists("sword-effect")) {
      this.anims.create({
        key: "sword-effect",
        frames: this.anims.generateFrameNumbers("swordEffect", {
          start: 0,
          end: 7,
        }),
        frameRate: 14,
        repeat: 0,
        hideOnComplete: true,
      });
    }

    if (!this.anims.exists("samurai-idle")) {
      this.anims.create({
        key: "samurai-idle",
        frames: this.anims.generateFrameNumbers("samuraiIdle", {
          start: 0,
          end: 9,
        }),
        frameRate: 14,
        repeat: -1,
      });
    }

    if (!this.anims.exists("dragon-idle")) {
      this.anims.create({
        key: "dragon-idle",
        frames: this.anims.generateFrameNumbers("dragonIdle", {
          start: 0,
          end: 9,
        }),
        frameRate: 8,
        repeat: -1,
      });
    }

    if (!this.anims.exists("dragon-attack")) {
      this.anims.create({
        key: "dragon-attack",
        frames: this.anims.generateFrameNumbers("dragonAttack", {
          start: 0,
          end: 9,
        }),
        frameRate: 10,
        repeat: 0,
      });
    }
  }

  buildFightScene() {
    this.createAnimations();

    console.log("ENCOUNTER TYPE:", this.encounterType);

    let monsterTemplate;

    if (this.encounterType === "boss") {
      monsterTemplate = RunState.boss
    } else {
      monsterTemplate = getRandomMonster();
    }

    console.log("MONSTER TEMPLATE:", monsterTemplate);

    this.currentMonster = {
      name: monsterTemplate.name,
    
      health:
        this.encounterType === "boss"
          ? RunState.boss.health
          : monsterTemplate.maxHealth,
    
      maxHealth: monsterTemplate.maxHealth,
    
      textureKey: monsterTemplate.textureKey,
      animations: monsterTemplate.animations,
      scale: monsterTemplate.scale,
    };
    

    this.healthText = this.add.text(
      50,
      40,
      `❤️ ${RunState.player.health}/${RunState.player.maxHealth}`,
      {
        fontSize: "32px",
        color: "#FF0000"
      }
    );

    this.staminaText = this.add.text(
      220,
      40,
      `⚡ ${RunState.player.stamina}/${RunState.player.maxStamina}`,
      {
        fontSize: "32px",
        fontFamily: "italic bold sans-serif",
        color: "#0AC200"
      }
    );

    this.damageText = this.add
      .text(640, 230, "", {
        fontSize: "36px",
      })
      .setOrigin(0.5);
    RunState.player.textureKey
    RunState.player.scale
    RunState.player.animations.idle

    // Player and monster are now higher, leaving room for the word grid below.
    this.player = this.add.sprite(
      220,
      250,
      RunState.player.textureKey
    )
    this.player.setScale(RunState.player.scale);
    this.player.play(RunState.player.animations.idle);

    this.monster = this.add.sprite(
      1050,
      300,
      this.currentMonster.textureKey
    );

    this.monster.setScale(this.currentMonster.scale);
    this.monster.setFlipX(true);
    this.monster.play(this.currentMonster.animations.idle);



    this.hitEffect = this.add
      .sprite(this.monster.x, this.monster.y, "swordEffect", 0)
      .setScale(1.5)
      .setVisible(false);


    this.add.text(185, 455, "Player", {
      fontSize: "20px",
    });

    this.monsterNameText = this.add.text(
      960,
      460,
      this.currentMonster.name,
      {
        fontSize: "20px",
      }
    );

    this.monsterHealthText = this.add.text(
      980,
      20,
      `❤️ ${this.currentMonster.health}/${this.currentMonster.maxHealth}`,
      {
        fontSize: "20px",
        color: "#FF0000"
      }
    );

    this.statusText = this.add.text(
      340,
      520,
      "Choose one word from each column.",
      {
        fontSize: "22px",
      }
    );

    if (this.encounterType === "boss") {
      this.reminderText = this.add.text(
        940,
        720,
        "You cannot run from the boss!",
        {
          fontSize: "18px",
          color: "#ff0000",
        }
      );
    }

    if (this.encounterType !== "boss") {
      this.reminderText = this.add.text(
        50,
        920,
        "Reminder: You can run if you can't hear the words, but running reduces stamina by 1.",
        {
          fontSize: "18px",
        }
      );
    }

    this.notificationText = this.add.text(
      1130,
      700,
      "",
      {
        fontSize: "26px",
        fontStyle: "italic",
        color: "#000000",

        wordWrap: {
          width: 260,
          useAdvancedWrap: true,
        },

        align: "center",
      }
    ).setOrigin(0.5, 0);

    this.buildWordGrid();

    if (this.encounterType !== "boss") {
      this.runBtn = new Button(this, 1120, 860, "Run", () => {
        this.runAway();
      });
    }

    //////////////////////////  Player health bar
    const barX = 100;
    const barY = 500;
    const barWidth = 250;
    const barHeight = 28;

    // dark background
    this.healthBarBackground = this.add
      .rectangle(barX, barY, barWidth, barHeight, 0x222222)
      .setOrigin(0, 0.5);

    // red health
    this.healthBar = this.add
      .rectangle(barX, barY, barWidth, barHeight, 0xcc3333)
      .setOrigin(0, 0.5);

    // text over bar
    this.healthText = this.add
      .text(
        barX + barWidth / 2,
        barY,
        `${RunState.player.health}/${RunState.player.maxHealth}`,
        {
          fontSize: "18px",
          color: "#ffffff",
          fontStyle: "bold",
        }
      )
      .setOrigin(0.5);

      this.add.text(670, 20, `${this.currentMonster.name}`, {
        fontSize: "32px",
      });

    ///////////////////////Enemy Health Bar///////////

    const enemyBarX = 950;
    const enemyBarY = 500;
    const enemyBarWidth = 250;
    const enemyBarHeight = 28;

    // dark background
    this.enemyHealthBarBackground = this.add
      .rectangle(enemyBarX, enemyBarY, enemyBarWidth, enemyBarHeight, 0x222222)
      .setOrigin(0, 0.5);

    // red health
    this.enemyHealthBar = this.add
      .rectangle(enemyBarX, enemyBarY, enemyBarWidth, enemyBarHeight, 0xcc3333)
      .setOrigin(0, 0.5);

    // text over bar
    this.enemyHealthText = this.add
      .text(
        enemyBarX + enemyBarWidth / 2,
        enemyBarY,
        `${this.currentMonster.health}/${this.currentMonster.maxHealth}`,
        {
          fontSize: "18px",
          color: "#ffffff",
          fontStyle: "bold",
        }
      )
      .setOrigin(0.5);

    this.updateEnemyHealthBar()
    this.updateHealthBar()
    // new Button(this, 1180, 835, "Back", () => {
    //   this.scene.start(this.returnTo);
    // });
  }

  playMonsterAttack(damageToPlayer) {
    if (damageToPlayer <= 0) {
      return;
    }

    const originalMonsterX = this.monster.x;

    this.monster.play(this.currentMonster.animations.attack);

    this.tweens.add({
      targets: this.monster,
      x: originalMonsterX - 120,
      duration: 250,
      yoyo: true,
      onComplete: () => {
        this.monster.x = originalMonsterX;
        this.monster.play(this.currentMonster.animations.idle);
      },
    });

    this.time.delayedCall(250, () => {
      this.cameras.main.shake(150, 0.006);

      this.tweens.add({
        targets: this.player,
        alpha: 0.3,
        duration: 100,
        yoyo: true,
        repeat: 2,
        onComplete: () => {
          this.player.alpha = 1;
        },
      });
    });
  }

  buildWordGrid() {
    const questions = buildQuestionsFromResearchGrid();

    this.grid = new GridOfButtons(this, 340, 550, {
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

          const supportedInputs = getSupportedScoreInputs();

          this.statusText.setText(
            `Researcher may now enter: ${supportedInputs.join(", ")}.`
          );
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

      const researcherInput = this.getNumpadNumber(event);

      if (researcherInput === null) {
        this.statusText.setText(
          "Invalid score. Enter a supported researcher score."
        );
        return;
      }

      this.resolveResearcherScore(researcherInput);
    });
  }

  getNumpadNumber(event) {
    const supportedInputs = getSupportedScoreInputs();

    let inputText = null;

    if (event.code?.startsWith("Numpad")) {
      inputText = event.code.replace("Numpad", "");
    } else if (event.code?.startsWith("Digit")) {
      inputText = event.code.replace("Digit", "");
    }

    if (inputText === null || inputText === "") {
      return null;
    }

    const input = Number(inputText);

    if (!supportedInputs.includes(input)) {
      return null;
    }

    return input;
  }

  resolveResearcherScore(researcherInput) {
    if (this.fightEnded) return;

    const score = getCombatScore(researcherInput);

    if (!score) {
      this.statusText.setText(
        `Unsupported researcher score: ${researcherInput}`
      );
      return;
    }

    const damageToMonster = score.monsterDamage;
    const damageToPlayer = score.playerDamage;

    this.roundReady = false;

    RunState.damagePlayer(damageToPlayer);
    this.updateHealthBar();

    this.currentMonster.health = Math.max(
      0,
      this.currentMonster.health - damageToMonster
    );
    
    if (this.encounterType === "boss") {
      RunState.boss.health = this.currentMonster.health;
    }

    this.updateEnemyHealthBar()
    this.healthText.setText(
      `❤️ ${RunState.player.health}/${RunState.player.maxHealth}`
    );

    this.monsterHealthText.setText(
      `HP: ${this.currentMonster.health}/${this.currentMonster.maxHealth}`
    );

    this.damageText.setText(
      `Monster -${damageToMonster}     Player -${damageToPlayer}`
    );

    this.animateAttack(score);

    const playerDefeated = RunState.player.health <= 0;
    const monsterDefeated = this.currentMonster.health <= 0;

    if (playerDefeated && monsterDefeated) {
      this.statusText.setText(
        "Both the player and monster were defeated!"
      );

      this.time.delayedCall(700, () => {
        this.endFight(true);
      });

      return;
    }

    if (playerDefeated) {
      this.statusText.setText("The player was defeated!");

      this.time.delayedCall(700, () => {
        this.playerDefeated();
      });

      return;
    }

    if (monsterDefeated) {
      this.time.delayedCall(700, () => {
        this.endFight(true);
      });

      return;
    }

    this.time.delayedCall(1200, () => {
      if (this.fightEnded) return;

      this.damageText.setText("");
      this.statusText.setText(
        "Choose one word from each column."
      );

      this.resetWordGrid();
    });
  }

  playSwordEffect() {
    this.hitEffect
      .setPosition(this.monster.x, this.monster.y)
      .setVisible(true)
      .play("sword-effect");
  }



  animateAttack(score) {
    const damageToMonster = score.monsterDamage;
    const damageToPlayer = score.playerDamage;

    const originalPlayerX = this.player.x;
    const originalPlayerY = this.player.y;
    const originalMonsterX = this.monster.x;

    this.playMonsterAttack(damageToPlayer);
    this.statusText.setText(score.message);

    switch (score.behavior) {
      case "miss":
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
        break;

      case "strong":
        this.time.delayedCall(350, () => {
          this.playSwordEffect();
        });

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

        break;

      case "normal":
        this.time.delayedCall(350, () => {
          this.playSwordEffect();
        });

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

        break;

      default:
        console.warn(`Unknown combat behavior: ${score.behavior}`);

        this.statusText.setText(
          `Unknown combat behavior: ${score.behavior}`
        );

        break;
    }
  }

  restorePlayerHealth() {
    RunState.player.health = RunState.player.maxHealth;
  }

  playerDefeated() {
    if (this.fightEnded) return;
  
    this.fightEnded = true;
    this.roundReady = false;
  
    if (this.encounterType === "boss") {
      RunState.boss.health =
        Math.ceil(RunState.boss.health / 4) * 4;
  
      RunState.boss.health = Math.min(
        RunState.boss.health,
        RunState.boss.maxHealth
      );
  
      console.log(
        "Boss revived to:",
        RunState.boss.health
      );
    }
  
    if (this.grid) {
      this.grid.destroy();
      this.grid = null;
    }
  
    this.showDeathScreen();
  }

  showDeathScreen() {
    const width = this.scale.width;
    const height = this.scale.height;
    const dripStartY = height / 2 - 60;

    // Black overlay
    this.add
      .rectangle(0, 0, width, height, 0x000000, 1)
      .setOrigin(0)
      .setDepth(1000);

    // Main YOU DIED text
    const deathText = this.add
      .text(width / 2, height / 2 - 80, "YOU DIED", {
        fontSize: "110px",
        color: "#cc0000",
        fontStyle: "bold",
        stroke: "#550000",
        strokeThickness: 8,
      })
      .setOrigin(0.5)
      .setAlpha(0)
      .setDepth(1001);

    // Fake blood drips
    const drip1 = this.add
      .rectangle(
        width / 2 - 140,
        dripStartY,
        8,
        90,
        0xaa0000
      )
      .setOrigin(0.5, 0)
      .setScale(1, 0)
      .setDepth(1001);

    const drip2 = this.add
      .rectangle(
        width / 2,
        dripStartY,
        10,
        130,
        0xaa0000
      )
      .setOrigin(0.5, 0)
      .setScale(1, 0)
      .setDepth(1001);

    const drip3 = this.add
      .rectangle(
        width / 2 + 150,
        dripStartY,
        7,
        70,
        0xaa0000
      )
      .setOrigin(0.5, 0)
      .setScale(1, 0)
      .setDepth(1001);

    // Fade/scale text in
    this.tweens.add({
      targets: deathText,
      alpha: 1,
      scale: {
        from: 0.7,
        to: 1,
      },
      duration: 1000,
      ease: "Back.easeOut",
    });

    // Animate drips downward
    this.tweens.add({
      targets: drip1,
      scaleY: 1,
      duration: 1300,
      delay: 500,
      ease: "Sine.easeIn",
    });

    this.tweens.add({
      targets: drip2,
      scaleY: 1,
      duration: 1600,
      delay: 650,
      ease: "Sine.easeIn",
    });

    this.tweens.add({
      targets: drip3,
      scaleY: 1,
      duration: 1100,
      delay: 800,
      ease: "Sine.easeIn",
    });

    // Continue prompt
    const continueText = this.add
      .text(
        width / 2,
        height / 2 + 180,
        "Press ENTER to continue",
        {
          fontSize: "28px",
          color: "#ffffff",
        }
      )
      .setOrigin(0.5)
      .setAlpha(0)
      .setDepth(1001);

    this.tweens.add({
      targets: continueText,
      alpha: 1,
      duration: 800,
      delay: 1800,
    });

    // Flash the continue text
    this.tweens.add({
      targets: continueText,
      alpha: 0.3,
      duration: 700,
      yoyo: true,
      repeat: -1,
      delay: 2600,
    });

    // Wait for Enter
    this.input.keyboard.once("keydown-ENTER", () => {
      this.restorePlayerHealth();

      this.scene.restart({
        nodeId: this.nodeId,
        mapId: RunState.progress.currentMapId,
        returnTo: this.returnTo,
        encounterType: this.encounterType,
      });
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
    if (RunState.player.stamina != 0) {
      if (this.fightEnded) return;

      this.fightEnded = true;
      this.roundReady = false;

      RunState.completeNode(this.nodeId);

      RunState.reduceStamina(1);

      this.staminaText.setText(
        `Stamina: ${RunState.player.stamina}/${RunState.player.maxStamina}`
      );

      this.statusText.setText("You ran away. Stamina reduced by 1.");

      if (this.grid) {
        this.grid.destroy();
        this.grid = null;
      }

      RunState.boss.health += 4
      RunState.boss.maxHealth += 4
      console.log("BOSS HEALTH INCREASED")
      console.log("Current Health of Boss: " + RunState.boss.maxHealth )

      this.tweens.add({
        targets: this.player,
        x: -100,
        duration: 600,
        onComplete: () => {
          this.scene.start(this.returnTo);
        },
      });
    }
    this.notificationText.setText(

      `You are out of Stamina and must stand your ground!`,
    );
    return;


  }

  updateHealthBar() {
    const healthPercent =
      RunState.player.health / RunState.player.maxHealth;

    this.healthBar.displayWidth =
      250 * healthPercent;

    this.healthText.setText(
      `${RunState.player.health}/${RunState.player.maxHealth}`
    );
  }

  updateEnemyHealthBar() {
    const healthPercent =
      this.currentMonster.health / this.currentMonster.maxHealth;

    this.enemyHealthBar.displayWidth =
      250 * healthPercent;

    this.enemyHealthText.setText(
      `${this.currentMonster.health}/${this.currentMonster.maxHealth}`
    );
  }

  endFight(showMonsterDeath = true) {
    if (this.fightEnded) return;

    this.fightEnded = true;
    this.roundReady = false;
    RunState.completeNode(this.nodeId);

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