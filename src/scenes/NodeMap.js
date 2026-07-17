//slay-the-spire style branching map
import Phaser from "phaser";
import Button from "../ui/Button";
import mapImage from "url:../assets/images/old_map1.jpg";

//title + instructions

export default class NodeMap extends Phaser.Scene {

    constructor ()
    {
        super({ key: 'nodeMap' })
    }

    preload ()
    {
        this.load.image("map", mapImage);
    }

    create () // only valid method to be considered a "scene"
    {
        const bg = this.add.image(0, 0, "map").setOrigin(0);

        const scaleX = this.cameras.main.width / bg.width;
        const scaleY = this.cameras.main.height / bg.height;
        const scale = Math.max(scaleX, scaleY);

        bg.setScale(scale);

        const nodes = [
            //first column
            {id: 1, x:200, y:200},
            {id: 4, x:320, y:150},
            {id: 7, x:320, y:210},

            //second column
            {id: 2, x:200, y:390},
            {id: 5, x:340, y:340},
            {id: 8, x:340, y:380},

            //third column
            {id: 3, x:200, y:650},
            {id: 6, x:310, y:550},
            {id: 9, x:310, y:620}

        ]
        const edges = [
            {from: 1, to: 4},
            {from: 2, to: 5},
            {from: 3, to: 6},
            {from: 1, to: 7},
            {from: 2, to: 8},
            {from: 3, to: 9},
        ]

        const g = this.add.graphics()
        g.lineStyle(4, 0x000000, 0.7)

        const nodeById = new Map(nodes.map(n => [n.id, n]))

        edges.forEach( e  => {
            const a = nodeById.get(e.from)
            const b = nodeById.get(e.to)

            if(!a || !b) return

            g.beginPath()
            g.moveTo(a.x, a.y)
            g.lineTo(b.x, b.y)
            g.strokePath()
        })

        nodes.forEach((n) => {
            const dot = this.add.circle(n.x, n.y, 14, 0xE60f00, 1);
            dot.setStrokeStyle(2,  0x000000 )
            dot.setInteractive({ useHandCursor: true});

            this.add.text(n.x + 18, n.y - 12, ("Level: " +String(n.id)), {
                fontSize: "18px",
                color: "#000000",
              });

            dot.on('pointerdown', () => {
                this.cameras.main.shake(300);

                this.time.delayedCall(300, () => {
                    this.scene.start('fight', { nodeId: n.id, returnTo: 'nodeMap' });
                });
        });
        })
            
        


    }

    

}