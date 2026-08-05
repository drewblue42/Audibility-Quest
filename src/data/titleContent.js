// src/data/titleContent.js

/**
 * Editable content for the title and instruction screens.
 *
 * Each object in `instructions` becomes one instruction page.
 *
 * heading:
 *   The title shown at the top of the page.
 *
 * body:
 *   A list of paragraphs or instruction lines.
 *
 * Add, remove, or edit instruction objects without changing scene logic.
 */
export const titleContent = {
    gameTitle: "Audibility Quest II",
    startButtonText: "Start Game",
    instructionButtonText: "Instructions",
  
    instructions: [
      {
        heading: "How to Play",
        body: [
          "Select one word from each column.",
          "Wait for the experimenter to enter a score.",
          "Continue until the fight is complete.",
        ],
      },
      {
        heading: "Health and Stamina",
        body: [
          "Incorrect answers may reduce your health.",
          "Running from a fight uses one stamina point.",
          "Campsites can restore resources.",
        ],
      },
    ],
  };