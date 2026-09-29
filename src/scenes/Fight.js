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

    const kiraIdleUrl = new URL(
      "../assets/animations/Kira/spr_kira_idle_strip24.png",
      import.meta.url
    ).href;

    const kiraHitUrl = new URL(
      "../assets/animations/Kira/spr_kira_hit_normalized.png",
      import.meta.url
    ).href;

    const kiraHurtUrl = new URL(
      "../assets/animations/Kira/spr_kira_hurt_normalized.png",
      import.meta.url
    ).href;

    const kiraDeathUrl = new URL(
      "../assets/animations/Kira/spr_kira_death_32x2.png",
      import.meta.url
    ).href;

    const blackKnightIdleUrl = new URL(
      "../assets/animations/BlackKnight/hooded knight idle.png",
      import.meta.url
    ).href;

    const blackKnightHitUrl = new URL(
      "../assets/animations/BlackKnight/hooded knight attack.png",
      import.meta.url
    ).href;

    this.load.spritesheet("blackKnightIdle", blackKnightIdleUrl, {
      frameWidth: 100,
      frameHeight: 100,
    });

    this.load.spritesheet("blackKnightAttack", blackKnightHitUrl, {
      frameWidth: 180,
      frameHeight: 100,
    });


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

    this.load.spritesheet("kiraIdle", kiraIdleUrl, {
      frameWidth: 256,
      frameHeight: 256,
    })

    this.load.spritesheet("kiraHit", kiraHitUrl, {
      frameWidth: 256,
      frameHeight: 256,
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

    const dungeonURL = new URL(
      "../assets/images/background/dungeon.png",
      import.meta.url
    ).toString();

    this.load.image("dungeon", dungeonURL);

    const dungeonBrickURL = new URL(
      "../assets/images/background/dungeonbrick.png",
      import.meta.url
    ).toString();

    this.load.image("dungeonbrick", dungeonBrickURL);

    const wordGridBorderUrl = new URL(
      "../assets/ui/wordgridborder.png",
      import.meta.url
    ).toString();

    this.load.image("wordGridBorder", wordGridBorderUrl);

    const heroHealthBarUrl = new URL(
      "../assets/ui/heroHealthBar.png",
      import.meta.url
    ).toString();

    const monsterHealthBarUrl = new URL(
      "../assets/ui/monsterHealthBar.png",
      import.meta.url
    ).toString();

    this.load.image("heroHealthBarFrame", heroHealthBarUrl);
    this.load.image("monsterHealthBarFrame", monsterHealthBarUrl);

    this.load.spritesheet("kiraHurt", kiraHurtUrl, {
      frameWidth: 256,
      frameHeight: 256,
    });

    this.load.spritesheet("kiraDeath", kiraDeathUrl, {
      frameWidth: 256,
      frameHeight: 256,
    });
  }

  create(data) {

    this.doubleKO = false;

    const bgBrick = this.add
      .image(
        this.cameras.main.centerX,
        this.cameras.main.centerY,
        "dungeonbrick"
      )
      .setOrigin(0.5)
      .setDepth(-20);

    const scaleXX = this.cameras.main.width / bgBrick.width;
    const scaleYY = this.cameras.main.height / bgBrick.height;
    const scale1 = Math.max(scaleXX, scaleYY);

    bgBrick.setScale(scale1);
    const bg = this.add
      .image(
        this.cameras.main.centerX,
        this.cameras.main.centerY - 400,
        "dungeon"
      )
      .setOrigin(0.5)
      .setDepth(-10);


    const scaleX = this.cameras.main.width / bg.width;
    const scaleY = this.cameras.main.height / bg.height;
    const scale = Math.max(scaleX, scaleY);

    bg.setScale(scale);



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
    const width = this.scale.width;
    const height = this.scale.height;

    // Black screen covering everything
    const blackBackground = this.add
      .rectangle(
        0,
        0,
        width,
        height,
        0x000000
      )
      .setOrigin(0)
      .setDepth(1000);

    const fightCountDown = this.add
      .text(
        width / 2,
        height / 2,
        "",
        {
          fontSize: "130px",
          fontFamily: "Palatino",
          color: "#ff0000",
          fontStyle: "bold",
          stroke: "#550000",
          strokeThickness: 10,
        }
      )
      .setOrigin(0.5)
      .setDepth(1001);

    const words = ["GET", "READY", "TO", "FIGHT"];
    const wordTiming = 700;

    words.forEach((word, i) => {
      this.time.delayedCall(i * wordTiming, () => {

        fightCountDown.setText(word);

        fightCountDown
          .setScale(0.5)
          .setAlpha(0);

        this.tweens.add({
          targets: fightCountDown,
          scale: 1,
          alpha: 1,
          duration: 250,
          ease: "Back.easeOut",
        });

        if (word === "FIGHT") {
          fightCountDown.setFontSize("160px");

          this.cameras.main.shake(
            250,
            0.008
          );
        }
      });
    });

    this.time.delayedCall(
      wordTiming * words.length,
      () => {

        // Fade countdown away
        this.tweens.add({
          targets: [
            blackBackground,
            fightCountDown
          ],

          alpha: 0,
          duration: 400,

          onComplete: () => {
            blackBackground.destroy();
            fightCountDown.destroy();

            // NOW build the actual fight
            onComplete();
          },
        });
      }
    );
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

    if (!this.anims.exists("blackKnight-idle")) {
      this.anims.create({
        key: "blackKnight-idle",
        frames: this.anims.generateFrameNumbers("blackKnightIdle", {
          start: 0,
          end: 3,
        }),
        frameRate: 6,
        repeat: -1,
      });
    }

    if (!this.anims.exists("blackKnight-attack")) {
      this.anims.create({
        key: "blackKnight-attack",
        frames: this.anims.generateFrameNumbers("blackKnightAttack", {
          start: 0,
          end: 16,
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

    if (!this.anims.exists("kira-idle")) {
      this.anims.create({
        key: "kira-idle",
        frames: this.anims.generateFrameNumbers("kiraIdle", {
          start: 0,
          end: 23,
        }),
        frameRate: 14,
        repeat: -1,
      });
    }

    if (!this.anims.exists("kira-hit")) {
      this.anims.create({
        key: "kira-hit",
        frames: this.anims.generateFrameNumbers("kiraHit", {
          start: 0,
          end: 48,
        }),
        frameRate: 50,
        repeat: 0,
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

    if (!this.anims.exists("kira-hurt")) {
      this.anims.create({
        key: "kira-hurt",

        frames: this.anims.generateFrameNumbers(
          "kiraHurt",
          {
            start: 0,
            end: 76,
          }
        ),

        frameRate: 50,
        repeat: 0,
      });
    }

    if (!this.anims.exists("kira-death")) {
      this.anims.create({
        key: "kira-death",

        frames: this.anims.generateFrameNumbers(
          "kiraDeath",
          {
            start: 0,
            end: 63,
          }
        ),

        frameRate: 50,
        repeat: 0,
      });
    }

    if (!this.anims.exists("kira-revive")) {
      const reviveFrames =
        this.anims.generateFrameNumbers(
          "kiraDeath",
          {
            start: 0,
            end: 63,
          }
        );

      reviveFrames.reverse();

      this.anims.create({
        key: "kira-revive",

        frames: reviveFrames,

        // 64 frames / 16 fps = 4 seconds
        frameRate: 16,

        repeat: 0,
      });
    }
  }



  buildFightScene() {

    if( RunState.player.health === 0){
      this.playReviveAnimation()
    }
    this.createAnimations();

    const uiTextStyle = {
      fontFamily: "Palatino",
      fontSize: "22px",
      color: "#fcc844",
      fontStyle: "bold",
      stroke: "#241600",
      strokeThickness: 3,
    };

    const smallUiTextStyle = {
      fontFamily: "Palatino",
      fontSize: "18px",
      color: "#fcc844",
      fontStyle: "bold",
      stroke: "#241600",
      strokeThickness: 2,
    };

    const largeUiTextStyle = {
      fontFamily: "Palatino",
      fontSize: "32px",
      color: "#fcc844",
      fontStyle: "bold",
      stroke: "#241600",
      strokeThickness: 4,
    };

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


    const heroHealthStat = this.createStatBox(
      150,
      50,
      240,
      60,
      `❤️ ${RunState.player.health}/${RunState.player.maxHealth}`,
      "#ff4d4d",
      uiTextStyle
    );

    this.heroHealthStatText =
      heroHealthStat.text;

    const heroStaminaStat = this.createStatBox(
      400,
      50,
      220,
      60,
      `⚡ ${RunState.player.stamina}/${RunState.player.maxStamina}`,
      "#6cff5c",
      uiTextStyle
    );

    this.staminaText =
      heroStaminaStat.text;

    this.damageText = this.add
      .text(640, 230, "", {
        ...largeUiTextStyle,
        color: "#ffb347",
      })
      .setOrigin(0.5);
    RunState.player.textureKey
    RunState.player.scale
    RunState.player.animations.idle

    // Player and monster are now higher, leaving room for the word grid below.
    this.player = this.add.sprite(
      220,
      265,
      RunState.player.textureKey
    )

    this.player
      .setScale(RunState.player.scale)
      .setDepth(10);

    this.player.play(
      RunState.player.animations.idle
    );

    this.monster = this.add.sprite(
      1050,
      300,
      this.currentMonster.textureKey
    );
    
    this.monster
      .setScale(this.currentMonster.scale)
      .setFlipX(true)
      .setDepth(-1);

    this.monster.play(
      this.currentMonster.animations.idle
    );



    this.hitEffect = this.add
      .sprite(this.monster.x, this.monster.y, "swordEffect", 0)
      .setScale(1.5)
      .setDepth(15)
      .setVisible(false);


    this.add.text(185, 455, "Player", uiTextStyle);

    this.monsterNameText = this.add.text(
      960,
      460,
      this.currentMonster.name,
      uiTextStyle
    );

    const monsterHealthStat = this.createStatBox(
      1120,
      50,
      250,
      60,
      `❤️ ${this.currentMonster.health}/${this.currentMonster.maxHealth}`,
      "#ff4d4d",
      uiTextStyle
    );

    this.monsterHealthText =
      monsterHealthStat.text;

    this.statusText = this.add.text(
      380,
      500,
      "Choose one word from each column.",
      uiTextStyle
    );

    if (this.encounterType === "boss") {
      this.reminderText = this.add.text(
        940,
        720,
        "You cannot run from the boss!",
        {
          ...smallUiTextStyle,
          color: "#ff0000",
        }
      );
    }

    if (this.encounterType !== "boss") {
      this.reminderText = this.add.text(
        500,
        910,
        "Reminder: You can run if you can't hear the words, but running reduces stamina by 1.",
        smallUiTextStyle

      );
    }

    this.notificationText = this.add
      .text(
        1130,
        700,
        "",
        {
          ...uiTextStyle,

          fontStyle: "italic bold",

          wordWrap: {
            width: 260,
            useAdvancedWrap: true,
          },

          align: "center",
        }
      )
      .setOrigin(0.5, 0);

    this.buildWordGrid();

    if (this.encounterType !== "boss") {
      this.runBtn = new Button(this, 1120, 860, "Run", () => {
        this.runAway();
      });
    }

    //////////////////////////  Player health bar
    ////////////////////////// Player health bar

    const barX = 100;
    const barY = 510;
    const barWidth = 250;
    const barHeight = 28;

    // Decorative frame
    this.add
      .image(
        barX + barWidth / 2,
        barY + 3,
        "heroHealthBarFrame"
      )
      .setDisplaySize(
        barWidth + 50,
        barHeight + 30
      );

    // Dark background inside frame
    this.healthBarBackground = this.add
      .rectangle(
        barX,
        barY,
        barWidth,
        barHeight,
        0x222222
      )
      .setOrigin(0, 0.5);

    // Red health fill
    this.healthBar = this.add
      .rectangle(
        barX,
        barY,
        barWidth,
        barHeight,
        0xcc3333
      )
      .setOrigin(0, 0.5);

    // Health number
    this.healthText = this.add
      .text(
        barX + barWidth / 2,
        barY,
        `${RunState.player.health}/${RunState.player.maxHealth}`,
        {
          ...smallUiTextStyle,
          color: "#ffffff",
        }
      )
      .setOrigin(0.5);

    ///////////////////////Enemy Health Bar///////////
    /////////////////////// Enemy Health Bar

    const enemyBarX = 950;
    const enemyBarY = 510;
    const enemyBarWidth = 250;
    const enemyBarHeight = 28;

    // Decorative frame
    this.add
      .image(
        enemyBarX + (enemyBarWidth / 2),
        enemyBarY,
        "monsterHealthBarFrame"
      )
      .setDisplaySize(
        enemyBarWidth + 100,
        enemyBarHeight + 30
      );

    // Dark background
    this.enemyHealthBarBackground = this.add
      .rectangle(
        enemyBarX,
        enemyBarY,
        enemyBarWidth,
        enemyBarHeight,
        0x222222
      )
      .setOrigin(0, 0.5);

    // Red health fill
    this.enemyHealthBar = this.add
      .rectangle(
        enemyBarX,
        enemyBarY,
        enemyBarWidth,
        enemyBarHeight,
        0xcc3333
      )
      .setOrigin(0, 0.5);

    // Health number
    this.enemyHealthText = this.add
      .text(
        enemyBarX + enemyBarWidth / 2,
        enemyBarY,
        `${this.currentMonster.health}/${this.currentMonster.maxHealth}`,
        {
          ...smallUiTextStyle,
          color: "#ffffff",
        }
      )
      .setOrigin(0.5);

    this.updateEnemyHealthBar()
    this.updateHealthBar()
    // new Button(this, 1180, 835, "Back", () => {
    //   this.scene.start(this.returnTo);
    // });
  }

  createStatBox(
    x,
    y,
    width,
    height,
    text,
    textColor,
    textStyle
  ) {
    const container = this.add.container(x, y);

    // Dark background
    const bg = this.add.graphics();

    bg.fillStyle(0x17130d, 0.9);

    bg.fillRoundedRect(
      -width / 2,
      -height / 2,
      width,
      height,
      10
    );

    // Gold border
    bg.lineStyle(
      3,
      0x8f6b2e,
      1
    );

    bg.strokeRoundedRect(
      -width / 2,
      -height / 2,
      width,
      height,
      10
    );

    const statText = this.add
      .text(
        0,
        0,
        text,
        {
          ...textStyle,
          color: textColor,
        }
      )
      .setOrigin(0.5);

    container.add([
      bg,
      statText
    ]);

    return {
      container,
      text: statText,
    };
  }

  showDamageNumber(target, damage) {
    if (damage <= 0) return;

    // Start around the upper-middle part of the character
    const startX =
      target.x + Phaser.Math.Between(-15, 15);

    const startY =
      target.y - target.displayHeight * 0.25;

    const damageNumber = this.add
      .text(
        startX,
        startY,
        `-${damage}`,
        {
          fontFamily: "Palatino",
          fontSize: "52px",
          fontStyle: "bold",

          color: "#ff3333",

          stroke: "#241600",
          strokeThickness: 7,
        }
      )
      .setOrigin(0.5)
      .setDepth(100)
      .setScale(0.4);

    // -------------------------
    // POP OUT
    // -------------------------

    this.tweens.add({
      targets: damageNumber,

      scale: 1.3,

      y: startY + 40,

      duration: 140,

      ease: "Back.easeOut",

      onComplete: () => {
        // -------------------------
        // FALL + FADE
        // -------------------------

        this.tweens.add({
          targets: damageNumber,

          y: startY + 70,

          alpha: 0,

          scale: 0.9,

          duration: 750,

          ease: "Quad.easeIn",

          onComplete: () => {
            damageNumber.destroy();
          },
        });
      },
    });
  }

  finishCombatRound() {
    this.damageText.setText("");

    this.statusText.setText(
      "Choose one word from each column."
    );

    this.resetWordGrid();
  }

  playMonsterAttack(
    damageToPlayer,
    onImpact = null,
    onComplete = null
  ) {
    if (damageToPlayer <= 0) {
      if (onComplete) {
        onComplete();
      }

      return;
    }

    const originalMonsterX =
      this.monster.x;

    // Move monster close to Kira
    const attackX =
      this.player.x + 220;

    // -------------------------
    // MONSTER ATTACK
    // -------------------------

    this.monster.play(
      this.currentMonster.animations.attack
    );

    this.tweens.add({
      targets: this.monster,

      x: attackX,

      duration: 450,

      ease: "Sine.easeOut",

      onComplete: () => {
        // -------------------------
        // IMPACT
        // -------------------------

        this.cameras.main.shake(
          150,
          0.006
        );

        if (onImpact) {
          onImpact();
        }

        // -------------------------
        // PLAYER DIED
        // -------------------------

        if (
          RunState.player.health <= 0
        ) {
          // Move monster back
          this.tweens.add({
            targets: this.monster,

            x: originalMonsterX,

            duration: 450,

            ease: "Sine.easeInOut",

            onComplete: () => {
              this.monster.play(
                this.currentMonster.animations.idle
              );

              if (onComplete) {
                onComplete();
              }
            },
          });

          return;
        }

        // -------------------------
        // KIRA HURT
        // -------------------------

        this.player.play(
          RunState.player.animations.hurt
        );

        this.player.once(
          "animationcomplete-kira-hurt",
          () => {
            this.player.play(
              RunState.player.animations.idle
            );

            // -------------------------
            // MONSTER RETURNS
            // -------------------------

            this.tweens.add({
              targets: this.monster,

              x: originalMonsterX,

              duration: 450,

              ease: "Sine.easeInOut",

              onComplete: () => {
                this.monster.play(
                  this.currentMonster.animations.idle
                );

                if (onComplete) {
                  onComplete();
                }
              },
            });
          }
        );
      },
    });
  }
  playSimultaneousClash(
    damageToMonster,
    damageToPlayer
  ) {
    const originalPlayerX = this.player.x;
    const originalPlayerY = this.player.y;
  
    const originalMonsterX = this.monster.x;
    const originalMonsterY = this.monster.y;
  
    const centerX =
      this.cameras.main.centerX;
  
    // Leave a little space between them.
    const playerAttackX =
      centerX - 110;
  
    const monsterAttackX =
      centerX + 110;
  
    // Prevent any new input while fighting.
    this.roundReady = false;
  
    this.statusText.setText(
      "Both fighters charge!"
    );
  
    // ==========================================
    // RUSH TO THE CENTER AT THE SAME TIME
    // ==========================================
  
    let arrivals = 0;
  
    const onArrived = () => {
      arrivals += 1;
  
      if (arrivals === 2) {
        startClash();
      }
    };
  
    this.tweens.add({
      targets: this.player,
  
      x: playerAttackX,
  
      duration: 450,
  
      ease: "Sine.easeOut",
  
      onComplete: onArrived,
    });
  
    this.tweens.add({
      targets: this.monster,
  
      x: monsterAttackX,
  
      duration: 450,
  
      ease: "Sine.easeOut",
  
      onComplete: onArrived,
    });
  
  
    // ==========================================
    // BOTH ATTACK
    // ==========================================
  
    const startClash = () => {
      this.statusText.setText(
        "The fighters clash!"
      );
  
      this.player.play(
        RunState.player.animations.hit
      );
  
      this.monster.play(
        this.currentMonster.animations.attack
      );
  
      // ----------------------------------------
      // IMPACT
      // ----------------------------------------
  
      // Tune this depending on where the actual
      // weapon impact occurs in Kira's animation.
      this.time.delayedCall(
        500,
        () => {
          this.cameras.main.shake(
            180,
            0.008
          );
  
          // =====================================
          // BOTH DAMAGE NUMBERS APPEAR TOGETHER
          // =====================================
  
          this.showDamageNumber(
            this.monster,
            damageToMonster
          );
  
          this.showDamageNumber(
            this.player,
            damageToPlayer
          );
  
  
          // =====================================
          // DAMAGE BOTH SIDES AT THE SAME TIME
          // =====================================
  
          this.currentMonster.health =
            Math.max(
              0,
              this.currentMonster.health -
                damageToMonster
            );
  
          RunState.damagePlayer(
            damageToPlayer
          );
  
  
          // Track damage received
          RunState.achievements.damageReceived +=
            damageToPlayer;
  
  
          // Persist boss health
          if (
            this.encounterType === "boss"
          ) {
            RunState.boss.health =
              this.currentMonster.health;
          }
  
  
          // =====================================
          // UPDATE BOTH HEALTH BARS
          // =====================================
  
          this.updateEnemyHealthBar();
          this.updateHealthBar();
  
  
          // =====================================
          // HIT FLASHES
          // =====================================
  
          if (damageToMonster > 0) {
            this.monster.setAlpha(0.45);
  
            this.time.delayedCall(
              120,
              () => {
                this.monster.setAlpha(1);
              }
            );
          }
  
          if (damageToPlayer > 0) {
            this.player.setAlpha(0.55);
  
            this.time.delayedCall(
              120,
              () => {
                this.player.setAlpha(1);
              }
            );
          }
        }
      );
  
  
      // ==========================================
      // WAIT FOR THE CLASH, THEN RETURN
      // ==========================================
  
      this.time.delayedCall(
        1100,
        () => {
          // Put both into idle while retreating.
          this.player.play(
            RunState.player.animations.idle
          );
  
          this.monster.play(
            this.currentMonster.animations.idle
          );
  
          returnToSides();
        }
      );
    };
  
  
    // ==========================================
    // BOTH RETURN AT THE SAME TIME
    // ==========================================
  
    const returnToSides = () => {
      let returned = 0;
  
      const onReturned = () => {
        returned += 1;
  
        if (returned === 2) {
          determineOutcome();
        }
      };
  
      this.tweens.add({
        targets: this.player,
  
        x: originalPlayerX,
        y: originalPlayerY,
  
        duration: 450,
  
        ease: "Sine.easeInOut",
  
        onComplete: onReturned,
      });
  
      this.tweens.add({
        targets: this.monster,
  
        x: originalMonsterX,
        y: originalMonsterY,
  
        duration: 450,
  
        ease: "Sine.easeInOut",
  
        onComplete: onReturned,
      });
    };
  
  
    // ==========================================
    // ONLY NOW DETERMINE WHO DIED
    // ==========================================
  
    const determineOutcome = () => {
      const playerDead =
        RunState.player.health <= 0;
  
      const monsterDead =
        this.currentMonster.health <= 0;
  
  
      // -----------------------------------------
      // DOUBLE KO
      // -----------------------------------------
  
      if (playerDead && monsterDead) {
        this.statusText.setText(
          "Both fighters fall!"
        );
      
        // Remember that the enemy also died
        this.doubleKO = true;
      
        // The node was successfully defeated
        RunState.completeNode(this.nodeId);
      
        this.time.delayedCall(
          500,
          () => {
            this.playerDefeated();
          }
        );
      
        return;
      }
  
  
      // -----------------------------------------
      // PLAYER DIED
      // -----------------------------------------
  
      if (playerDead) {
        this.statusText.setText(
          "The player was defeated!"
        );
  
        this.time.delayedCall(
          500,
          () => {
            this.playerDefeated();
          }
        );
  
        return;
      }
  
  
      // -----------------------------------------
      // MONSTER DIED
      // -----------------------------------------
  
      if (monsterDead) {
        this.statusText.setText(
          `${this.currentMonster.name} was defeated!`
        );
  
        this.time.delayedCall(
          500,
          () => {
            this.endFight(true);
          }
        );
  
        return;
      }
  
  
      // -----------------------------------------
      // BOTH SURVIVED
      // -----------------------------------------
  
      this.statusText.setText(
        "Both fighters return to position."
      );
  
      this.time.delayedCall(
        700,
        () => {
          this.finishCombatRound();
        }
      );
    };
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
      fontFamily: "Palatino",
      color: "#fcc844",

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
  
    const score =
      getCombatScore(researcherInput);
  
    if (!score) {
      this.statusText.setText(
        `Unsupported researcher score: ${researcherInput}`
      );
  
      return;
    }
  
    const damageToMonster =
      score.monsterDamage;
  
    const damageToPlayer =
      score.playerDamage;
  
    // Lock input during combat animation
    this.roundReady = false;
  
  
    // ==========================================
    // TRACK WORDS CORRECT
    // ==========================================
  
    switch (damageToPlayer) {
      case 0:
        RunState.achievements.wordsCorrect +=
          5;
        break;
  
      case 1:
        RunState.achievements.wordsCorrect +=
          4;
        break;
  
      case 2:
        RunState.achievements.wordsCorrect +=
          3;
        break;
  
      case 3:
        RunState.achievements.wordsCorrect +=
          2;
        break;
  
      case 4:
        RunState.achievements.wordsCorrect +=
          1;
        break;
  
      default:
        break;
    }
  
  
    // ==========================================
    // WARRIOR ACHIEVEMENT
    // ==========================================
  
    if (
      RunState.achievements.wordsCorrect >=
      200
    ) {
      RunState.achievements.warrior =
        true;
    }
  
  
    // Clear any old damage text
    this.damageText.setText("");
  
  
    // ==========================================
    // STATUS MESSAGE
    // ==========================================
  
    const monsterPointWord =
      damageToMonster === 1
        ? "point"
        : "points";
  
    const playerPointWord =
      damageToPlayer === 1
        ? "point"
        : "points";
  
    this.statusText.setText(
      `Player deals ${damageToMonster} ${monsterPointWord} while ${this.currentMonster.name} deals ${damageToPlayer} ${playerPointWord}!`
    );
  
  
    // ==========================================
    // SIMULTANEOUS CLASH
    // ==========================================
  
    this.playSimultaneousClash(
      damageToMonster,
      damageToPlayer
    );
  }

  startMonsterTurn(damageToPlayer) {
    const pointWord =
      damageToPlayer === 1
        ? "point"
        : "points";

    // -------------------------
    // NO DAMAGE
    // -------------------------

    if (damageToPlayer <= 0) {
      this.statusText.setText(
        `${this.currentMonster.name} deals no damage!`
      );

      this.time.delayedCall(900, () => {
        this.finishCombatRound();
      });

      return;
    }

    // -------------------------
    // MONSTER DAMAGE MESSAGE
    // -------------------------

    this.statusText.setText(
      `${this.currentMonster.name} deals ${damageToPlayer} ${pointWord} of damage to Player!`
    );

    // -------------------------
    // MONSTER ATTACK
    // -------------------------

    this.playMonsterAttack(
      damageToPlayer,

      // ==========================
      // IMPACT
      // ==========================

      () => {
        // Track damage
        RunState.achievements.damageReceived +=
          damageToPlayer;

        // Apply damage AT IMPACT
        RunState.damagePlayer(
          damageToPlayer
        );

        // Floating -number
        this.showDamageNumber(
          this.player,
          damageToPlayer
        );

        // Update health bar
        this.updateHealthBar();
      },

      // ==========================
      // ATTACK FINISHED
      // ==========================

      () => {
        // Player died
        if (RunState.player.health <= 0) {
          this.statusText.setText(
            "The player was defeated!"
          );

          this.time.delayedCall(
            600,
            () => {
              this.playerDefeated();
            }
          );

          return;
        }

        // Next round
        this.time.delayedCall(
          700,
          () => {
            this.finishCombatRound();
          }
        );
      }
    );
  }

  playSwordEffect() {
    this.hitEffect
      .setPosition(this.monster.x, this.monster.y)
      .setVisible(true)
      .play("sword-effect");
  }

  playPlayerAttack(
    originalPlayerX,
    attackX,
    onImpact = null,
    onAttackComplete = null
  ) {
    this.player.setDepth(10);

    // -------------------------
    // MOVE TO ENEMY
    // -------------------------

    this.tweens.add({
      targets: this.player,

      x: attackX,

      duration: 400,

      ease: "Sine.easeOut",

      onComplete: () => {
        // -------------------------
        // ATTACK ANIMATION
        // -------------------------

        this.player.play("kira-hit");

        // Kira animation is:
        //
        // 86 frames / 50fps
        // ≈ 1.72 seconds
        //
        // About halfway through is a good
        // impact point.

        this.time.delayedCall(
          850,
          () => {
            this.cameras.main.shake(
              100,
              0.004
            );

            if (onImpact) {
              onImpact();
            }
          }
        );

        // -------------------------
        // ATTACK FINISHED
        // -------------------------

        this.player.once(
          "animationcomplete-kira-hit",
          () => {
            this.player.play(
              RunState.player.animations.idle
            );

            // -------------------------
            // MOVE BACK
            // -------------------------

            this.tweens.add({
              targets: this.player,

              x: originalPlayerX,

              duration: 400,

              ease: "Sine.easeInOut",

              onComplete: () => {
                if (onAttackComplete) {
                  onAttackComplete();
                }
              },
            });
          }
        );
      },
    });
  }


  animateAttack(score, onComplete = null) {
    const damageToMonster = score.monsterDamage;
    const damageToPlayer = score.playerDamage;

    const originalPlayerX = this.player.x;
    const originalPlayerY = this.player.y;

    this.playMonsterAttack(damageToPlayer);

    this.statusText.setText(
      score.message
    );

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
            this.player.x =
              originalPlayerX;

            this.player.y =
              originalPlayerY;

            if (onComplete) {
              onComplete();
            }
          },
        });

        this.cameras.main.shake(
          200,
          0.01
        );

        break;

      case "strong":
        this.playPlayerAttack(
          originalPlayerX,
          originalPlayerX + 620,
          onComplete
        );

        this.time.delayedCall(
          900,
          () => {
            //this.playSwordEffect();

            this.cameras.main.shake(
              200,
              0.008
            );
          }
        );

        break;

      case "normal":
        this.playPlayerAttack(
          originalPlayerX,
          originalPlayerX + 620,
          onComplete
        );

        this.time.delayedCall(
          900,
          () => {
            //this.playSwordEffect();

            this.monster.setAlpha(
              0.35
            );

            this.time.delayedCall(
              150,
              () => {
                this.monster.setAlpha(1);
              }
            );
          }
        );

        break;

      default:
        console.warn(
          `Unknown combat behavior: ${score.behavior}`
        );

        this.statusText.setText(
          `Unknown combat behavior: ${score.behavior}`
        );

        if (onComplete) {
          onComplete();
        }

        break;
    }
  }

  restorePlayerHealth() {
    RunState.player.health = RunState.player.maxHealth;
  }

  playerDefeated() {
    if (this.fightEnded) return;

    RunState.achievements.numDeaths += 1;
    RunState.achievements.immortal = false;

    this.fightEnded = true;
    this.roundReady = false;

    if (this.grid) {
      this.grid.destroy();
      this.grid = null;
    }

    if (this.encounterType === "boss") {
      RunState.boss.health =
        Math.ceil(
          RunState.boss.health / 4
        ) * 4;

      RunState.boss.health =
        Math.min(
          RunState.boss.health,
          RunState.boss.maxHealth
        );
    }

    // Stop whatever animation is currently playing
    this.player.stop();

    // Play death animation
    this.player.play(
      RunState.player.animations.death
    );

    // Wait until death animation is completely finished
    this.player.once(
      "animationcomplete-kira-death",
      () => {
        this.showDeathScreen();
      }
    );
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
      this.playReviveAnimation();
    });
  }
  playReviveAnimation() {
    const width = this.scale.width;
    const height = this.scale.height;

    // Clear death screen / old fight visuals
    this.children.removeAll(true);

    // Dark background
    this.add
      .rectangle(0, 0, width, height, 0x000000)
      .setOrigin(0);

    // Recreate player in the middle
    const revivePlayer = this.add
      .sprite(
        width / 2,
        height / 2,
        "kiraDeath",
        63
      )
      .setScale(RunState.player.scale)
      .setAlpha(0.3);

    // Play death animation BACKWARDS
    revivePlayer.play("kira-revive");

    // Once she is standing again,
    // switch to normal idle.
    revivePlayer.once(
      "animationcomplete-kira-revive",
      () => {
        revivePlayer.play(
          RunState.player.animations.idle
        );
      }
    );

    // Light beam
    const lightBeam = this.add
      .rectangle(
        width / 2,
        0,
        220,
        height,
        0xfff4b0,
        0.15
      )
      .setOrigin(0.5, 0);

    // Glow around player
    const glow = this.add
      .circle(
        width / 2,
        height / 2,
        100,
        0xffffcc,
        0.15
      )
      .setScale(0.5);

    // Revive text
    const reviveText = this.add
      .text(
        width / 2,
        height / 2 - 180,
        "REVIVING...",
        {
          fontSize: "48px",
          color: "#fff7b2",
          fontStyle: "bold",
        }
      )
      .setOrigin(0.5);

    // -------------------------
    // HEALTH BAR
    // -------------------------

    const barWidth = 350;
    const barHeight = 32;

    const barX = width / 2 - barWidth / 2;
    const barY = height / 2 + 180;

    // Health bar background
    this.add
      .rectangle(
        barX,
        barY,
        barWidth,
        barHeight,
        0x222222
      )
      .setOrigin(0, 0.5);

    // Red health bar
    const reviveHealthBar = this.add
      .rectangle(
        barX,
        barY,
        barWidth,
        barHeight,
        0xff0000
      )
      .setOrigin(0, 0.5)
      .setScale(0, 1);

    // Health text
    const reviveHealthText = this.add
      .text(
        width / 2,
        barY,
        `0/${RunState.player.maxHealth}`,
        {
          fontSize: "20px",
          color: "#ffffff",
          fontStyle: "bold",
        }
      )
      .setOrigin(0.5);

    // -------------------------
    // REVIVE EFFECTS
    // -------------------------

    // Fade player back in
    this.tweens.add({
      targets: revivePlayer,
      alpha: 1,
      duration: 4000,
      ease: "Sine.easeOut",
    });

    // Pulse glow
    this.tweens.add({
      targets: glow,
      scale: 1.8,
      alpha: 0.5,
      duration: 500,
      yoyo: true,
      repeat: 3,
      ease: "Sine.easeInOut",
    });

    // Flash light beam
    this.tweens.add({
      targets: lightBeam,
      alpha: 0.55,
      duration: 400,
      yoyo: true,
      repeat: 4,
      ease: "Sine.easeInOut",
    });

    // -------------------------
    // HEALTH REFILL
    // -------------------------

    const healthCounter = {
      value: 0,
    };

    // Fill red bar
    this.tweens.add({
      targets: reviveHealthBar,
      scaleX: 1,
      duration: 4000,
      ease: "Sine.easeOut",
    });

    // Count health numbers up
    this.tweens.add({
      targets: healthCounter,
      value: RunState.player.maxHealth,
      duration: 4000,
      ease: "Sine.easeOut",

      onUpdate: () => {
        const health = Math.round(
          healthCounter.value
        );

        reviveHealthText.setText(
          `${health}/${RunState.player.maxHealth}`
        );
      },

      onComplete: () => {
        // Actually restore health
        RunState.player.health =
          RunState.player.maxHealth;

        // Force final visual state
        reviveHealthBar.setScale(1, 1);

        reviveHealthText.setText(
          `${RunState.player.maxHealth}/${RunState.player.maxHealth}`
        );

        reviveText.setText("REVIVED");

        // Final bright flash
        this.cameras.main.flash(
          500,
          255,
          255,
          220
        );

        // Restart the fight
        this.time.delayedCall(1500, () => {
          this.time.delayedCall(
            1500,
            () => {
              // ===================================
              // DOUBLE KO
              // ===================================
          
              if (this.doubleKO) {
                // Boss died too
                if (
                  this.encounterType === "boss" &&
                  this.currentMonster.health <= 0
                ) {
                  this.scene.start("gameOver");
                  return;
                }
          
                // Normal monster died too,
                // so return to the map.
                this.scene.start(
                  this.returnTo,
                  {
                    mapId:
                      RunState.progress.currentMapId,
                    nodeId: this.nodeId,
                  }
                );
          
                return;
              }
          
          
              // ===================================
              // NORMAL PLAYER DEATH
              // ===================================
          
              this.scene.restart({
                nodeId: this.nodeId,
                mapId:
                  RunState.progress.currentMapId,
                returnTo: this.returnTo,
                encounterType:
                  this.encounterType,
              });
            }
          );
        });
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
      console.log("Current Health of Boss: " + RunState.boss.maxHealth)

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
      RunState.player.health /
      RunState.player.maxHealth;

    this.healthBar.displayWidth =
      250 * healthPercent;

    // Number inside health bar
    this.healthText.setText(
      `${RunState.player.health}/${RunState.player.maxHealth}`
    );

    // Number in top stat box
    this.heroHealthStatText.setText(
      `❤️ ${RunState.player.health}/${RunState.player.maxHealth}`
    );
  }

  updateEnemyHealthBar() {
    const healthPercent =
      this.currentMonster.health /
      this.currentMonster.maxHealth;

    this.enemyHealthBar.displayWidth =
      250 * healthPercent;

    this.enemyHealthText.setText(
      `${this.currentMonster.health}/${this.currentMonster.maxHealth}`
    );

    this.monsterHealthText.setText(
      `❤️ ${this.currentMonster.health}/${this.currentMonster.maxHealth}`
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

      if (
        this.encounterType === "boss" &&
        this.currentMonster.health <= 0
      ) {
        this.scene.start("gameOver");
        return;
      }

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