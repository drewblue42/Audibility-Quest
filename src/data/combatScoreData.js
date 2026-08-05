// src/data/combatScoreData.js

/**
 * Defines how researcher score input affects combat.
 *
 * input:
 *   The keyboard value entered by the researcher.
 *
 * monsterDamage:
 *   Damage dealt to the monster.
 *
 * playerDamage:
 *   Damage dealt to the player.
 *
 * behavior:
 *   Controls special combat presentation.
 *   Supported values:
 *   - "miss"
 *   - "normal"
 *   - "strong"
 *
 * message:
 *   Text displayed during combat resolution.
 *
 * Add or edit score entries here without changing Fight.js combat rules.
 */
export const COMBAT_SCORE_DATA = [
    {
      input: 0,
      monsterDamage: 0,
      playerDamage: 5,
      behavior: "miss",
      message: "The player attacks, but misses!",
    },
    {
      input: 1,
      monsterDamage: 1,
      playerDamage: 4,
      behavior: "normal",
      message: "The player hits for 1 damage.",
    },
    {
      input: 2,
      monsterDamage: 2,
      playerDamage: 3,
      behavior: "normal",
      message: "The player hits for 2 damage.",
    },
    {
      input: 3,
      monsterDamage: 3,
      playerDamage: 2,
      behavior: "normal",
      message: "The player hits for 3 damage.",
    },
    {
      input: 4,
      monsterDamage: 4,
      playerDamage: 1,
      behavior: "normal",
      message: "The player hits for 4 damage.",
    },
    {
      input: 5,
      monsterDamage: 5,
      playerDamage: 0,
      behavior: "strong",
      message: "Strong hit!",
    },
  ];
  
  /**
   * Returns the combat score entry for a researcher input.
   *
   * Returns null when the input is unsupported.
   */
  export function getCombatScore(input) {
    return (
      COMBAT_SCORE_DATA.find((score) => score.input === input) ?? null
    );
  }
  
  /**
   * Returns all valid researcher input values.
   */
  export function getSupportedScoreInputs() {
    return COMBAT_SCORE_DATA.map((score) => score.input);
  }