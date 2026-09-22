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
  }

  create() {
    this.add
      .text(
        this.cameras.main.centerX,
        150,
        "Potion Shop",
        {
          fontSize: "48px",
          color: "#ffffff",
        }
      )
      .setOrigin(0.5);

    this.add
      .text(
        this.cameras.main.centerX,
        260,
        "Choose a potion to take (Warning: will be used immediatly!)",
        {
          fontSize: "28px",
          color: "#ffffff",
        }
      )
      .setOrigin(0.5);


      this.createPotionButton(
        200,
        400,
        "healingPotion",
        "Health Potion",
        "Restores 20 health, up to your maximum health.",
        "#fc030b",
        () => {
          this.restoreHealth();
          this.returnToMap();
        }
      );
      
      this.createPotionButton(
        450,
        400,
        "staminaPotion",
        "Stamina Potion",
        "Restores 1 stamina point, up to your maximum stamina.",
        "#13d102",
        () => {
          this.restoreStamina();
          this.returnToMap();
        }
      );
      
      this.createPotionButton(
        700,
        400,
        "speedPotion",
        "Speed Potion",
        "You move two spaces instead of one before fighting the next monster",
        "#0390fc",
        () => {
          this.speedPotion();
          this.returnToMap();
        }
      );
      
      this.createPotionButton(
        950,
        400,
        "strengthPotion",
        "Strength Potion",
        "Your next fight is easier!",
        "#ed8b02",
        () => {
          this.strengthPotion();
          this.returnToMap();
        }
      );

    this.descriptionText = this.add
      .text(
        this.cameras.main.centerX,
        600,
        "Hover over a potion to see what it does.",
        {
          fontSize: "22px",
          color: "#ffffff",
          backgroundColor: "#000000" ,
          padding: {
            x: 16,
            y: 12,
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
    RunState.player.health += toAddHealth;

    console.log("Restore player health here");
  }

  speedPotion(){
    RunState.progress.skipNode = true
    RunState.boss.health += 4
    RunState.boss.maxHealth += 4
    console.log("BOSS HEALTH INCREASED")
    console.log("Current Health of Boss: " + RunState.boss.maxHealth )
  }

  createPotionButton(x, y, imageKey, label, description, hoverColor, onClick) {
    const image = this.add
      .image(x, y, imageKey)
      .setDisplaySize(80, 80)
      .setInteractive({ useHandCursor: true });
  
    this.add
      .text(x, y + 60, label, {
        fontSize: "20px",
        color: "#ffffff",
      })
      .setOrigin(0.5);
  
    image.on("pointerdown", onClick);
  
    image.on("pointerover", () => {
      image.setDisplaySize(90, 90);
      
      this.descriptionText.setText(description);
      this.descriptionText.setBackgroundColor(hoverColor)
    });
  
    image.on("pointerout", () => {
      image.setDisplaySize(80, 80);
  
      this.descriptionText.setText(
        "Hover over a potion to see what it does."
      );
      this.descriptionText.setBackgroundColor("#000000");
    });
  
    return image;
  }

  restoreStamina() {
    RunState.player.stamina += 1;
  }

  returnToMap() {
    this.scene.start(this.returnTo);
  }
}