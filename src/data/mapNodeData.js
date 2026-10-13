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
    name: "Basic Map",
    backgroundKey: "map",
    startingNodeId: 0,

    nodes: [
      // Start
      { id: 0, x: 50, y: 300, type: "fight", isCheckpoint: false },

      // First split
      { id: 1, x: 125, y: 235, type: "fight", isCheckpoint: false },
      { id: 2, x: 110, y: 405, type: "fight", isCheckpoint: false },

      // Upper branch
      { id: 3, x: 215, y: 190, type: "fight", isCheckpoint: false },

      { id: 4, x: 350, y: 125, type: "fight", isCheckpoint: false },
      { id: 5, x: 425, y: 130, type: "fight", isCheckpoint: false },
      { id: 6, x: 500, y: 160, type: "fight", isCheckpoint: false },
      { id: 7, x: 575, y: 110, type: "fight", isCheckpoint: false },
      { id: 8, x: 650, y: 145, type: "fight", isCheckpoint: false },
      { id: 9, x: 725, y: 165, type: "fight", isCheckpoint: false },
      { id: 10, x: 800, y: 195, type: "fight", isCheckpoint: false },

      // Upper-middle alternate path
      { id: 11, x: 275, y: 235, type: "fight", isCheckpoint: false },
      { id: 12, x: 350, y: 255, type: "fight", isCheckpoint: false },
      { id: 13, x: 425, y: 290, type: "fight", isCheckpoint: false },
      { id: 14, x: 500, y: 270, type: "fight", isCheckpoint: false },
      { id: 15, x: 575, y: 305, type: "fight", isCheckpoint: false },
      { id: 16, x: 650, y: 235, type: "fight", isCheckpoint: false },

      // Blue colored node -> campsite
      { id: 17, x: 725, y: 235, type: "treasure", isCheckpoint: false },

      // Diamond after blue campsite
      { id: 18, x: 875, y: 130, type: "fight", isCheckpoint: false },
      { id: 19, x: 875, y: 235, type: "fight", isCheckpoint: false },
      { id: 20, x: 950, y: 205, type: "fight", isCheckpoint: false },

      // Upper-right route
      { id: 21, x: 1025, y: 255, type: "fight", isCheckpoint: false },
      { id: 22, x: 1095, y: 300, type: "fight", isCheckpoint: false },
      { id: 23, x: 1165, y: 360, type: "fight", isCheckpoint: false },

      // Middle branch from starting split
      { id: 24, x: 195, y: 345, type: "fight", isCheckpoint: false },
      { id: 25, x: 275, y: 350, type: "fight", isCheckpoint: false },
      { id: 26, x: 350, y: 350, type: "fight", isCheckpoint: false },

      { id: 27, x: 500, y: 415, type: "fight", isCheckpoint: false },
      { id: 28, x: 575, y: 395, type: "fight", isCheckpoint: false },
      { id: 29, x: 650, y: 410, type: "fight", isCheckpoint: false },
      { id: 30, x: 725, y: 365, type: "fight", isCheckpoint: false },
      { id: 31, x: 800, y: 415, type: "fight", isCheckpoint: false },
      { id: 32, x: 875, y: 365, type: "fight", isCheckpoint: false },
      { id: 33, x: 950, y: 330, type: "fight", isCheckpoint: false },
      { id: 34, x: 1025, y: 390, type: "fight", isCheckpoint: false },

      // Lower branch
      { id: 35, x: 195, y: 435, type: "fight", isCheckpoint: false },
      { id: 36, x: 275, y: 500, type: "fight", isCheckpoint: false },
      { id: 37, x: 350, y: 455, type: "fight", isCheckpoint: false },
      { id: 38, x: 425, y: 555, type: "fight", isCheckpoint: false },
      { id: 39, x: 500, y: 525, type: "fight", isCheckpoint: false },
      { id: 40, x: 575, y: 565, type: "fight", isCheckpoint: false },
      { id: 41, x: 650, y: 545, type: "fight", isCheckpoint: false },
      { id: 42, x: 725, y: 530, type: "fight", isCheckpoint: false },
      { id: 43, x: 800, y: 535, type: "fight", isCheckpoint: false },
      { id: 44, x: 875, y: 480, type: "fight", isCheckpoint: false },

      // Green colored node -> campsite
      { id: 45, x: 950, y: 440, type: "camp", isCheckpoint: false },

      // Lower-right diamond
      { id: 46, x: 1025, y: 390, type: "fight", isCheckpoint: false },
      { id: 47, x: 1025, y: 500, type: "fight", isCheckpoint: false },
      { id: 48, x: 1100, y: 455, type: "fight", isCheckpoint: false },

      // Final merge
      { id: 49, x: 1165, y: 405, type: "fight", isCheckpoint: false },

      // Red colored node -> campsite
      { id: 50, x: 1230, y: 395, type: "boss", isCheckpoint: false },
    ],

    connections: [
      // Starting split
      { from: 0, to: 1 },
      { from: 0, to: 2 },

      // Upper split
      { from: 1, to: 3 },

      { from: 3, to: 4 },
      { from: 3, to: 11 },

      // Top path
      { from: 4, to: 5 },
      { from: 5, to: 6 },
      { from: 6, to: 7 },
      { from: 7, to: 8 },
      { from: 8, to: 9 },
      { from: 9, to: 10 },

      // Upper-middle path
      { from: 11, to: 12 },
      { from: 12, to: 13 },
      { from: 13, to: 14 },
      { from: 14, to: 15 },
      { from: 15, to: 16 },
      { from: 16, to: 17 },

      // Blue camp merges back
      { from: 17, to: 10 },

      // Diamond
      { from: 10, to: 18 },
      { from: 10, to: 19 },

      { from: 18, to: 20 },
      { from: 19, to: 20 },

      // Upper-right
      { from: 20, to: 21 },
      { from: 21, to: 22 },
      { from: 22, to: 23 },

      // Middle branch
      { from: 2, to: 24 },
      { from: 24, to: 25 },
      { from: 25, to: 26 },

      { from: 26, to: 27 },
      { from: 27, to: 28 },
      { from: 28, to: 29 },
      { from: 29, to: 30 },
      { from: 30, to: 31 },
      { from: 31, to: 32 },
      { from: 32, to: 33 },
      { from: 33, to: 34 },

      // Middle joins upper route
      { from: 15, to: 30 },

      // Lower path
      { from: 2, to: 35 },
      { from: 35, to: 36 },

      // Middle can branch downward
      { from: 25, to: 37 },

      { from: 36, to: 37 },
      { from: 37, to: 38 },
      { from: 38, to: 39 },
      { from: 39, to: 40 },
      { from: 40, to: 41 },
      { from: 41, to: 42 },
      { from: 42, to: 43 },
      { from: 43, to: 44 },

      // Lower path can reconnect upward
      { from: 42, to: 31 },

      // Green campsite
      { from: 44, to: 45 },

      // Green camp splits
      { from: 45, to: 46 },
      { from: 45, to: 47 },

      // Middle route reaches upper side of diamond
      { from: 34, to: 46 },

      // Diamond rejoins
      { from: 46, to: 49 },
      { from: 47, to: 48 },
      { from: 48, to: 49 },

      // Upper route also merges near end
      { from: 23, to: 49 },

      // Final campsite
      { from: 49, to: 50 },
    ],
  },
];

  export function getMapById(mapId) {
    return maps.find((map) => map.id === mapId);
  }