//slay-the-spire style branching map
import Phaser from "phaser";
import Button from "../ui/Button";

//title + instructions

export default class Map extends Phaser.Scene {

    constructor ()
    {
        super({ key: 'map' })
    }

    preload ()
    {
        const skyUrl = new URL("../assets/images/map.jpg", import.meta.url).toString();
        this.load.image("map", skyUrl);
    }

    create () // only valid method to be considered a "scene"
    {
        const bg = this.add.image(0, 0, "map").setOrigin(0);

        const scaleX = this.cameras.main.width / bg.width;
        const scaleY = this.cameras.main.height / bg.height;
        const scale = Math.max(scaleX, scaleY);

        bg.setScale(scale);



        new Button(
            this,
            100,
            250,
            'Fight 1',
            () => {
              this.scene.start('fight');
            }
          );

          new Button(
            this,
            100,
            550,
            'Fight 2',
            () => {
              this.scene.start('fight');
            }
          );

          new Button(
            this,
            100,
            650,
            'Fight 3',
            () => {
              this.scene.start('fight');
            }
          );
    }
    

}