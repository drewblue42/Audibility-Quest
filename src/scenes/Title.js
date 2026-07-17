import Phaser from "phaser";
import Button from "../ui/Button";

//title + instructions

export default class Title extends Phaser.Scene {

    constructor ()
    {
        super({ key: 'title' })
        ///////adding configurations to the file
        // super({
        //     key: 'Level1',
        //     physics: {
        //         arcade: {
        //             debug: true,
        //             gravity: { y: 200 }
        //         }
        //     }
        // });
        //////////// Can also be used 
        // super({
        //     key: 'boot',
        //     files: [
        //         { type: 'image', key: 'bar', url: 'loaderBar.png' },
        //         { type: 'image', key: 'bg', url: 'background.png' }
        //     ]
        // });
    }

    preload ()
    {
       
    }

    create () // only valid method to be considered a "scene"
    {
        const bg = this.add.image(0, 0, "sky").setOrigin(0);

        const scaleX = this.cameras.main.width / bg.width;
        const scaleY = this.cameras.main.height / bg.height;
        const scale = Math.max(scaleX, scaleY);

        bg.setScale(scale);



        new Button(
            this,
            512,
            620,
            'Start Game',
            () => {
              this.scene.start('nodeMap');
            }
          );
    }

}