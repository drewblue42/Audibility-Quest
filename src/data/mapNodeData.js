// src/data/mapData.js

/**
 * Map data structure
 *
 * id:
 *   Unique identifier for the map.
 *
 * name:
 *   Display name for the map.
 *
 * backgroundKey:
 *   Phaser texture key used for the map background.
 *
 * startingNodeId:
 *   The node where the player begins.
 *
 * nodes:
 *   All nodes available on this map.
 *
 * node.id:
 *   Unique identifier within the map.
 *
 * node.x / node.y:
 *   Position of the node on the map.
 *
 * node.type:
 *   Determines what happens when the player selects the node.
 *   Examples: "fight", "camp", "boss", "treasure".
 *
 * node.isCheckpoint:
 *   Marks a node as a checkpoint.
 *
 * connections:
 *   Defines which nodes are connected.
 */
export const maps = [
    {
      id: "map-1",
      name: "Ancient Ruins",
      backgroundKey: "map",
      startingNodeId: 1,
  
      nodes: [
        {
          id: 1,
          x: 200,
          y: 200,
          type: "fight",
          isCheckpoint: false,
        },
        {
          id: 2,
          x: 200,
          y: 390,
          type: "fight",
          isCheckpoint: false,
        },
        {
          id: 3,
          x: 200,
          y: 650,
          type: "camp",
          isCheckpoint: false,
        },
  
        {
          id: 4,
          x: 320,
          y: 150,
          type: "fight",
          isCheckpoint: false,
        },
        {
          id: 5,
          x: 340,
          y: 340,
          type: "camp",
          isCheckpoint: true,
        },
        {
          id: 6,
          x: 310,
          y: 550,
          type: "fight",
          isCheckpoint: false,
        },
  
        {
          id: 7,
          x: 320,
          y: 210,
          type: "treasure",
          isCheckpoint: false,
        },
        {
          id: 8,
          x: 340,
          y: 380,
          type: "fight",
          isCheckpoint: false,
        },
        {
          id: 9,
          x: 310,
          y: 620,
          type: "boss",
          isCheckpoint: false,
        },
      ],
  
      connections: [
        { from: 1, to: 4 },
        { from: 1, to: 7 },
  
        { from: 2, to: 5 },
        { from: 2, to: 8 },
  
        { from: 3, to: 6 },
        { from: 3, to: 9 },
      ],
    },
  ];

  export function getMapById(mapId) {
    return maps.find((map) => map.id === mapId);
  }