import Phaser from "phaser";
import mapImage from "url:../assets/images/old_map1.jpg";
import { getMapById } from "../data/mapNodeData.js";


export default class NodeMap extends Phaser.Scene {
    constructor() {
        super({ key: "nodeMap" });

        this.mapId = "map-1";
    }

    init(data) {
        this.mapId = data.mapId ?? "map-1";
    }

    preload() {
        this.load.image("map", mapImage);

        const fightIconUrl = new URL(
            "../assets/images/hell.png",
            import.meta.url
        ).toString();

        const campIconUrl = new URL(
            "../assets/images/travel.png",
            import.meta.url
        ).toString();

        const treasureIconUrl = new URL(
            "../assets/images/treasure-chest.png",
            import.meta.url
        ).toString();

        const bossIconUrl = new URL(
            "../assets/images/skull.png",
            import.meta.url
        ).toString();

        this.load.image("fightIcon", fightIconUrl);
        this.load.image("campIcon", campIconUrl);
        this.load.image("treasureIcon", treasureIconUrl);
        this.load.image("bossIcon", bossIconUrl);
    }

    create() {
        const mapData = getMapById(this.mapId);

        if (!mapData) {
            console.error(`Map not found: ${this.mapId}`);
            return;
        }
        this.createBackground(mapData.backgroundKey);
        this.createConnections(mapData);
        this.createNodes(mapData);
    }

    createBackground(backgroundKey) {
        const bg = this.add
            .image(0, 0, backgroundKey)
            .setOrigin(0);

        const scaleX = this.cameras.main.width / bg.width;
        const scaleY = this.cameras.main.height / bg.height;
        const scale = Math.max(scaleX, scaleY);

        bg.setScale(scale);
    }

    getNodeIcon(node) {
        switch (node.type) {
            case "camp":
                return "campIcon";

            case "boss":
                return "bossIcon";

            case "treasure":
                return "treasureIcon";

            case "fight":
            default:
                return "fightIcon";
        }
    }

    createConnections(mapData) {
        const graphics = this.add.graphics();

        graphics.lineStyle(4, 0x000000, 0.7);

        const nodeById = new Map(
            mapData.nodes.map((node) => [node.id, node])
        );

        mapData.connections.forEach((connection) => {
            const fromNode = nodeById.get(connection.from);
            const toNode = nodeById.get(connection.to);

            if (!fromNode || !toNode) {
                console.warn(
                    `Invalid connection: ${connection.from} -> ${connection.to}`
                );

                return;
            }

            graphics.beginPath();
            graphics.moveTo(fromNode.x, fromNode.y);
            graphics.lineTo(toNode.x, toNode.y);
            graphics.strokePath();
        });
    }

    createNodes(mapData) {
        mapData.nodes.forEach((node) => {
            this.createNode(node, mapData);
        });
    }

    createNode(node, mapData) {
        const isStartingNode =
            node.id === mapData.startingNodeId;

        const iconKey = this.getNodeIcon(node);

        if (node.isCheckpoint) {
            this.add.circle(
                node.x,
                node.y,
                30,
                0xffd700,
                0.35
            );
        }

        // if (isStartingNode) {
        //     this.add.circle(
        //         node.x,
        //         node.y,
        //         35,
        //         0x00ff00,
        //         0.25
        //     );
        // }

        const icon = this.add
            .image(node.x, node.y, iconKey)
            .setDisplaySize(42, 42)
            .setInteractive({ useHandCursor: true });

        icon.on("pointerdown", () => {
            this.handleNodeSelection(node);
        });
    }

    getNodeColor(node) {
        if (node.isCheckpoint) {
            return 0xffd700;
        }

        switch (node.type) {
            case "camp":
                return 0x2e8b57;

            case "boss":
                return 0x800080;

            case "treasure":
                return 0xffa500;

            case "fight":
            default:
                return 0xe60f00;
        }
    }

    getNodeLabel(node) {
        switch (node.type) {
            case "camp":
                return `Camp ${node.id}`;

            case "boss":
                return `Boss ${node.id}`;

            case "treasure":
                return `Treasure ${node.id}`;

            case "fight":
            default:
                return `Level ${node.id}`;
        }
    }

    handleNodeSelection(node) {
        this.cameras.main.shake(300);

        this.time.delayedCall(300, () => {
            switch (node.type) {
                case "fight":
                    this.scene.start("fight", {
                        nodeId: node.id,
                        mapId: this.mapId,
                        returnTo: "nodeMap",
                    });
                    break;

                case "camp":
                    this.scene.start("campsite", {
                        nodeId: node.id,
                        mapId: this.mapId,
                        returnTo: "nodeMap",
                    });
                    break;

                case "treasure":
                    this.scene.start("treasure", {
                        nodeId: node.id,
                        mapId: this.mapId,
                        returnTo: "nodeMap",
                    });
                    break;

                case "boss":
                    this.scene.start("fight", {
                        nodeId: node.id,
                        mapId: this.mapId,
                        encounterType: "boss",
                        returnTo: "nodeMap",
                    });
                    break;

                default:
                    console.warn(`Unknown node type: ${node.type}`);
            }
        });
    }
}