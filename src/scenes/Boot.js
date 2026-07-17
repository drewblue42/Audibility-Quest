import Phaser from "phaser";


//preload global assets, set up save data
export default class Boot extends Phaser.Scene {
    constructor() {
      super({ key: 'boot' })
    }


    preload ()
    {
        const skyUrl = new URL("../assets/images/slay_spire_intro.jpg", import.meta.url).toString();
        this.load.image("sky", skyUrl);
        
    }

    create () // only valid method to be considered a "scene"
    {
        this.scene.start('title')
    }

  }