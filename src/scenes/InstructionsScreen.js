import Phaser from "phaser";
var platforms;
import { titleContent } from "../data/titleContent";

export default class InstructionsScreen extends Phaser.Scene {
    constructor() {
        super({ key: "InstructionsScreen" });
    }
    preload() {
        const skyUrl = new URL("../assets/images/slay_spire_intro.jpg", import.meta.url).toString();
        this.load.image("sky", skyUrl);
    }
    create() {
        const howTo = titleContent.instructions[0]
        const healthStamina = titleContent.instructions[1]

        this.add
            .text(
                this.cameras.main.centerX,
                140,
                howTo.heading,
                {
                    fontSize: "52px",
                    color: "#ffffff",
                    fontStyle: "bold",
                    stroke: "#000000",
                    strokeThickness: 6,
                }
            )
            .setOrigin(0.5);

            this.add
            .text(
                this.cameras.main.centerX,
                280,
                howTo.body.join("\n\n"),
                {
                    fontSize: "32px",
                    color: "#ffffff",
                    stroke: "#000000",
                    strokeThickness: 6,
                }
            )
            .setOrigin(0.5);

            this.add
            .text(
                this.cameras.main.centerX,
                450,
                healthStamina.heading,
                {
                    fontSize: "52px",
                    color: "#ffffff",
                    fontStyle: "bold",
                    stroke: "#000000",
                    strokeThickness: 6,
                }
            )
            .setOrigin(0.5);

            this.add
            .text(
                this.cameras.main.centerX,
                590,
                healthStamina.body.join("\n\n"),
                {
                    fontSize: "32px",
                    color: "#ffffff",
                    stroke: "#000000",
                    strokeThickness: 6,
                }
            )
            .setOrigin(0.5);


    }
}