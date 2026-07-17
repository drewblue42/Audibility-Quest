import Phaser from "phaser";
var platforms;
export default class TitleScreen extends Phaser.Scene
{
    preload()
    {
        const skyUrl = new URL("../assets/images/slay_spire_intro.jpg", import.meta.url).toString();
        this.load.image("sky", skyUrl);
    }
    create()
    {
        const img = this.add.image(
            this.scale.width / 2,
            this.scale.height / 2,
            "sky"
          );
        
          const scaleX = this.scale.width / img.width;
          const scaleY = this.scale.height / img.height;
          const scale = Math.max(scaleX, scaleY);
        
          img.setScale(scale);

          platforms = this.physics.add.staticGroup();

          platforms.create(600, 400, 'ground');
          platforms.create(50, 250, 'ground');
          platforms.create(750, 220, 'ground');

    }
}