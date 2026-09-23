//restore HP or stamina
import Phaser from "phaser";
import Button from "../ui/Button";
import { RunState } from "../systems/RunState";
import { createPlayerStats } from "../ui/PlayerStats";
import healingPotion from "url:../assets/images/potions/healingPotion.png";
import speedPotion from "url:../assets/images/potions/speedPotion.png";
import staminaPotion from "url:../assets/images/potions/staminaPotion.png";
import strengthPotion from "url:../assets/images/potions/strengthPotion.png";

export default class PotionShop extends Phaser.Scene {
  constructor() {
    super({ key: "potionshop" });
  }

  init(data) {
    this.nodeId = data.nodeId;
    this.mapId = data.mapId;
    this.returnTo = data.returnTo ?? "nodeMap";
  }
  preload() {
    this.load.image("healingPotion", healingPotion);
    this.load.image("staminaPotion", staminaPotion);
    this.load.image("speedPotion", speedPotion);
    this.load.image("strengthPotion", strengthPotion);

    const potionShopUrl = new URL(
      "../assets/images/background/potionbg.png",
      import.meta.url
    ).toString();

    this.load.image("potion", potionShopUrl);

    const tabUrl = new URL(
      "../assets/ui/tab.png",
      import.meta.url
    ).toString();

    this.load.image("potionTab", tabUrl);
  }

  create() {

    const bg = this.add
      .image(
        this.cameras.main.centerX,
        this.cameras.main.centerY,
        "potion"
      )
      .setOrigin(0.5);

    const scaleX = this.cameras.main.width / bg.width;
    const scaleY = this.cameras.main.height / bg.height;
    const scale = Math.max(scaleX, scaleY);

    bg.setScale(scale);

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

    this.add
      .text(
        this.cameras.main.centerX,
        150,
        "Potion Shop",
        titleStyle
      )
      .setOrigin(0.5);

    this.add
      .text(
        this.cameras.main.centerX,
        260,
        "Choose a potion to take (Warning: will be used immediatly!)",
        uiTextStyle
      )
      .setOrigin(0.5);


    this.createPotionButton(
      260,
      400,
      "healingPotion",
      "Health Potion",
      "Restores 20 health, up to your maximum health.",
      "#fc030b",
      () => {
        this.restoreHealth();
        RunState.achievements.potionMaster = true
        RunState.achievements.fortitude = false
        console.log("Fortitude achievements lost!!")
        console.log("Potion master achieved")
        this.returnToMap();
      }
    );

    this.createPotionButton(
      510,
      400,
      "staminaPotion",
      "Stamina Potion",
      "Restores 1 stamina point, up to your maximum stamina.",
      "#13d102",
      () => {
        this.restoreStamina();
        RunState.achievements.potionMaster = true
        console.log("Potion master achieved")
        this.returnToMap();
      }
    );

    this.createPotionButton(
      760,
      400,
      "speedPotion",
      "Speed Potion",
      "You move two spaces instead of one before fighting the next monster",
      "#0390fc",
      () => {
        this.speedPotion();
        RunState.achievements.potionMaster = true
        console.log("Potion master achieved")
        this.returnToMap();
      }
    );

    this.createPotionButton(
      1010,
      400,
      "strengthPotion",
      "Strength Potion",
      "Your next fight is easier!",
      "#ed8b02",
      () => {
        RunState.achievements.potionMaster = true
        console.log("Potion master achieved")
        this.returnToMap();
      }
    );

    this.descriptionText = this.add
      .text(
        this.cameras.main.centerX,
        650,
        "Hover over a potion to see what it does.",
        {
          ...uiTextStyle,

          backgroundColor: "#17130d",

          padding: {
            x: 20,
            y: 14,
          },

          align: "center",

          wordWrap: {
            width: 700,
          },
        }
      )
      .setOrigin(0.5);
  }

  restoreHealth() {
    const toAddHealth = 20
    RunState.player.health = Math.min(
      RunState.player.health + toAddHealth,
      RunState.player.maxHealth
    );

    console.log("Restore player health here");
  }

  speedPotion() {
    RunState.progress.skipNode = true
    RunState.boss.health += 4
    RunState.boss.maxHealth += 4
    console.log("BOSS HEALTH INCREASED")
    console.log("Current Health of Boss: " + RunState.boss.maxHealth)
  }

  createPotionButton(
    x,
    y,
    imageKey,
    label,
    description,
    hoverColor,
    onClick
  ) {
    // Tab behind potion
    const tab = this.add
      .image(
        x,
        y + 25,
        "potionTab"
      )
      .setOrigin(0.5)
      .setDisplaySize(210, 180);

    const image = this.add
      .image(
        x,
        y - 10,
        imageKey
      )
      .setDisplaySize(80, 80)
      .setInteractive({
        useHandCursor: true,
      });

    const labelText = this.add
      .text(
        x,
        y + 65,
        label,
        {
          fontSize: "20px",
          fontFamily: "Palatino",
          color: "#fcc844",
          fontStyle: "bold",
          stroke: "#241600",
          strokeThickness: 3,
        }
      )
      .setOrigin(0.5);

    image.on(
      "pointerdown",
      onClick
    );

    image.on(
      "pointerover",
      () => {
        image.setDisplaySize(
          90,
          90
        );

        tab.setTint(
          0xdddddd
        );

        labelText.setColor(
          "#fff1a8"
        );

        this.descriptionText.setText(
          description
        );

        this.descriptionText
          .setBackgroundColor(
            hoverColor
          );
      }
    );

    image.on(
      "pointerout",
      () => {
        image.setDisplaySize(
          80,
          80
        );

        tab.clearTint();

        labelText.setColor(
          "#fcc844"
        );

        this.descriptionText.setText(
          "Hover over a potion to see what it does."
        );

        this.descriptionText
          .setBackgroundColor(
            "#17130d"
          );
      }
    );

    return image;
  }

  restoreStamina() {
    RunState.player.stamina = Math.min(
      RunState.player.stamina + 1,
      RunState.player.maxStamina
    );
  }

  returnToMap() {
    this.scene.start(this.returnTo);
  }
}