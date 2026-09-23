//restore HP or stamina
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

  create() {
    this.add
      .text(
        this.cameras.main.centerX,
        150,
        "Campsite",
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
        "Choose an action",
        {
          fontSize: "28px",
          color: "#ffffff",
        }
      )
      .setOrigin(0.5);

    new Button(
      this,
      this.cameras.main.centerX,
      380,
      `Restore Health (${this.seeRestoredHealthAmount()} HP)`,
      () => {
        this.restoreHealth();
        RunState.achievements.fortitude = false
        console.log("Fortitude achievements lost!!")
        this.returnToMap();
      }
    );
    new Button(
      this,
      this.cameras.main.centerX,
      600,
      `Keep going without resting`,
      () => {
        this.returnToMap();
      }
    );
    createPlayerStats(this, 30, 30);

    // new Button(
    //   this,
    //   this.cameras.main.centerX,
    //   470,
    //   "Restore Stamina",
    //   () => {
    //     this.restoreStamina();
    //     this.returnToMap();
    //   }
    // );

    // new Button(
    //   this,
    //   this.cameras.main.centerX,
    //   560,
    //   "Leave Camp",
    //   () => {
    //     this.returnToMap();
    //   }
    // );
  }
  seeRestoredHealthAmount() {
    const currentHealth = RunState.player.health;
    const maxHealth = RunState.player.maxHealth;
    const toAddHealth =  Math.ceil((maxHealth-currentHealth)/2);
    return toAddHealth;
  }

  restoreHealth() {
    const currentHealth = RunState.player.health;
    const maxHealth = RunState.player.maxHealth;
    const toAddHealth =  Math.ceil((maxHealth-currentHealth)/2);
    RunState.player.health += toAddHealth;

    console.log("Restore player health here");
  }

  restoreStamina() {
    console.log("Restore player stamina here");
  }

  returnToMap() {
    this.scene.start(this.returnTo, {
      mapId: this.mapId,
      currentNodeId: this.nodeId,
      
    });
  }
}