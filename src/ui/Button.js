export default class Button extends Phaser.GameObjects.Text {
  constructor(scene, x, y, text, callback) {
    super(scene, x, y, text, {
      fontSize: '32px',
      fontFamily: 'Arial',
      color: '#ffffff',
      backgroundColor: '#1e90ff',
      padding: { x: 20, y: 10 },
    });

    this._enabled = true;
    this._baseBg = '#1e90ff';
    this._hoverBg = '#63b3ff';
    this._disabledBg = '#777777';

    this.setOrigin(0.5);
    this.setInteractive({ useHandCursor: true });

    this.on('pointerover', () => {
      if (!this._enabled) return;
      this.setStyle({ backgroundColor: this._hoverBg });
    });

    this.on('pointerout', () => {
      if (!this._enabled) return;
      this.setStyle({ backgroundColor: this._baseBg });
    });

    this.on('pointerdown', () => {
      if (!this._enabled) return;
      callback?.();
    });

    scene.add.existing(this);
  }

  disable() {
    this._enabled = false;
    this.disableInteractive();
    return this;
  }

  enable() {
    this._enabled = true;
    this.setInteractive({ useHandCursor: true });
    this.setStyle({ backgroundColor: this._baseBg });
    this.setAlpha(1);
    return this;
  }

  setGreyed(isGrey = true) {
    if (isGrey) {
      this.setStyle({ backgroundColor: this._disabledBg });
      this.setAlpha(0.65);
    } else {
      this.setStyle({ backgroundColor: this._baseBg });
      this.setAlpha(1);
    }
    return this;
  }
}
