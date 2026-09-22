// ToDo add a way to remove connections when the player is past the position and the player has no way to travle there
// 

import Phaser from "phaser";
import mapImage from "url:../assets/images/old_map1.jpg";
import { getMapById } from "../data/mapNodeData.js";
import { RunState } from "../systems/RunState.js";
import { createPlayerStats } from "../ui/PlayerStats.js";

const NODE_OFFSET_X = 0;
const NODE_OFFSET_Y = 130;

export default class NodeMap extends Phaser.Scene {
    constructor() {
        super({ key: "nodeMap" });

    }

    init(data) {

        if (data?.mapId) {
            RunState.setCurrentMap(data.mapId);
        }

        this.mapId = RunState.progress.currentMapId;

        const mapData = getMapById(this.mapId);

        if (data?.nodeId) {
            const validNode = mapData.nodes.some(
                node => node.id === data.nodeId
            );

            if (validNode) {
                RunState.setCurrentNode(data.nodeId);
            } else {
                console.warn(`Invalid node ID: ${data.nodeId}`);
            }
        }

        this.nodeId = RunState.progress.currentNodeId;
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

        const reachableNodes = this.getReachableNodes(mapData)
        console.log("reachableNodes: " + reachableNodes)
        this.createBackground(mapData.backgroundKey);
        this.createConnections(mapData);
        this.createNodes(mapData, reachableNodes);
        createPlayerStats(this, 30, 30);


    }

    createBackground(backgroundKey) {
        const bg = this.add
            .image(0, 0, backgroundKey)
            .setOrigin(0);

        const scaleX = this.cameras.main.width / bg.width;
        const scaleY = this.cameras.main.height / bg.height;
        const scale = Math.max(scaleX, scaleY);

        bg.setScale(scale);
        bg.setPosition(-150, 0)
    }

    getReachableNodes(mapData) {
        const currentNode = RunState.progress.currentNodeId

        return mapData.connections
            .filter(connection => connection.from === currentNode)
            .map(connection => connection.to)

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


        graphics.lineStyle(4, 0x000000, 0.2);


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

            graphics.moveTo(
                fromNode.x + NODE_OFFSET_X,
                fromNode.y + NODE_OFFSET_Y
            );

            graphics.lineTo(
                toNode.x + NODE_OFFSET_X,
                toNode.y + NODE_OFFSET_Y
            );
            graphics.strokePath();
        });

        graphics.lineStyle(4, 0x000000, 0.7);

        const visibleConnections = mapData.connections.filter(
            connection => connection.from === RunState.progress.currentNodeId)

        console.log("nodebyID: " + visibleConnections)


        visibleConnections.forEach((connection) => {
            const fromNode = nodeById.get(connection.from);
            const toNode = nodeById.get(connection.to);

            if (!fromNode || !toNode) {
                console.warn(
                    `Invalid connection: ${connection.from} -> ${connection.to}`
                );

                return;
            }

            graphics.beginPath();
            graphics.moveTo(
                fromNode.x + NODE_OFFSET_X,
                fromNode.y + NODE_OFFSET_Y
            );

            graphics.lineTo(
                toNode.x + NODE_OFFSET_X,
                toNode.y + NODE_OFFSET_Y
            );
            graphics.strokePath();
        });
    }

    createNodes(mapData, reachableNodes) {
        mapData.nodes.forEach((node) => {

            const isCurrentNode =
                node.id === RunState.progress.currentNodeId;

            const isReachable =
                reachableNodes.includes(node.id);

            this.createNode(
                node,
                mapData,
                isReachable
            );
        });
    }

    createNode(node, mapData, isAvailable) {
        const isCurrentNode =
            node.id === RunState.progress.currentNodeId;

        const isCompleted =
            RunState.progress.completedNodes.includes(node.id);

        const iconKey = this.getNodeIcon(node);

        const x = node.x + NODE_OFFSET_X;
        const y = node.y + NODE_OFFSET_Y;

        if (node.isCheckpoint) {
            this.add.circle(
                x,
                y,
                30,
                0xffd700,
                0.35
            );
        }
        if (isCurrentNode) {
            this.add.circle(
                x,
                y,
                30,
                0x00ff00,
                0.35
            );
        }

        const icon = this.add
            .image(x, y, iconKey)
            .setDisplaySize(42, 42);
        if (isAvailable) {
            icon.setInteractive({ useHandCursor: true });

            icon.on("pointerdown", () => {
                this.handleNodeSelection(node);
            });

        } else {
            icon.setAlpha(0.3);
        }
        if (isCompleted) {
            this.add.text(
                x + 18,
                y - 25,
                "✓",
                {
                    fontSize: "24px",
                    color: "#00ff00",
                    fontStyle: "bold",
                }
            ).setOrigin(0.5);
        }
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
        switch (node.type) {
            case "fight":
                if (RunState.progress.skipNode === true) {

                    RunState.progress.skipNode = false
                    RunState.setCurrentNode(node.id);
                    RunState.completeNode(node.id);


                    this.scene.start("nodeMap");

                }
                else {
                    RunState.setCurrentNode(node.id);
                    this.cameras.main.shake(300);
                    this.time.delayedCall(300, () => {
                        this.scene.start("fight", {
                            nodeId: node.id,
                            mapId: RunState.progress.currentMapId,
                            returnTo: "nodeMap",
                        });
                    }
                    )
                }
                console.log("CURRENT NODE: "+ RunState.progress.currentNodeId)
                break;

            case "camp":
                RunState.setCurrentNode(node.id);
                this.scene.start("campsite", {
                    nodeId: node.id,
                    mapId: RunState.progress.currentMapId,
                    returnTo: "nodeMap",
                });
                console.log("CURRENT NODE: "+ RunState.progress.currentNodeId)
                RunState.completeNode(node.id);
                break;

            case "treasure":
                RunState.setCurrentNode(node.id);
                this.scene.start("potionshop", {
                    nodeId: node.id,
                    mapId: RunState.progress.currentMapId,
                    returnTo: "nodeMap",
                });
                console.log("CURRENT NODE: "+ RunState.progress.currentNodeId)
                RunState.completeNode(node.id);
                break;

            case "boss":
                RunState.setCurrentNode(node.id);
                this.scene.start("fight", {
                    nodeId: node.id,
                    mapId: RunState.progress.currentMapId,
                    encounterType: "boss",
                    returnTo: "nodeMap",
                });
                console.log("CURRENT NODE: "+ RunState.progress.currentNodeId)
                RunState.completeNode(node.id);
                break;

            default:
                console.warn(`Unknown node type: ${node.type}`);

        };
    }
}