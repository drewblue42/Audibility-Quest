import Phaser from "phaser";

export default class Game extends Phaser.Scene {
    init(){
    this.paddleRightVelocity = new Phaser.Math.Vector2(0,0)
    }
    preload() {

    }

    create() {
        this.input.keyboard.disableGlobalCapture();
        this.ball = this.add.circle(400, 384, 10, 0xff0000, 1)

        this.ball.setOrigin(0.5, 0.5)
        this.physics.add.existing(this.ball)
        this.ball.body.setBounce(1, 1)

        this.ball.body.setCollideWorldBounds(true, 1, 1)

        const angle = Phaser.Math.Between(0,360)
        const vec = this.physics.velocityFromAngle(angle, 200)
        this.ball.body.setVelocity(vec.x, vec.y)

        this.paddleLeft = this.add.rectangle(30, 384, 30, 100, 0xffffff, 1)
        this.physics.add.existing(this.paddleLeft)
        this.paddleLeft.body.setBounce(1, 1)
        this.paddleLeft.body.setImmovable(true)

        this.physics.add.collider(this.paddleLeft, this.ball)

        this.paddleRight = this.add.rectangle(990, 384, 30, 100, 0xffffff, 1)
        this.physics.add.existing(this.paddleRight)
        this.paddleRight.body.setBounce(1, 1)
        this.paddleRight.body.setImmovable(true)

        this.physics.add.collider(this.paddleRight, this.ball)

        this.cursors = this.input.keyboard.createCursorKeys()


    }

    update() {

        /** @type {Phaser.Physics.Arcade.StaticBody} */
        const body = this.paddleLeft.body

        if (this.cursors.up.isDown) {
            this.paddleLeft.y -= 5
            body.updateFromGameObject()
            console.log('up pressed')
        }
        else if (this.cursors.down.isDown) {
            this.paddleLeft.y += 5
            body.updateFromGameObject()
            console.log('down pressed')
        }
        else 
        {
            body.setVelocityY(0)
        }

        const diff = this.ball.y - this.paddleRight.y
        if(Math.abs(diff)< 30){
            return
        }
        const aiSpeed = 5;

        this.paddleRightVelocity.y = Phaser.Math.Clamp(
            diff * 0.05,
            -aiSpeed,
            aiSpeed
        );

        this.paddleRight.y += this.paddleRightVelocity.y 
        this.paddleRight.body.updateFromGameObject()

    }

}