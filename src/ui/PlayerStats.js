import { RunState } from "../systems/RunState";

export function createPlayerStats(scene, x, y) {
  const boxWidth = 220;
  const boxHeight = 55;
  const gap = 12;

  const textStyle = {
    fontFamily: "Palatino",
    fontSize: "22px",
    fontStyle: "bold",
    stroke: "#241600",
    strokeThickness: 3,
  };

  // -------------------------
  // HEALTH BOX
  // -------------------------

  const healthBox = scene.add.graphics();

  healthBox.fillStyle(0x17130d, 0.9);

  healthBox.fillRoundedRect(
    x,
    y,
    boxWidth,
    boxHeight,
    10
  );

  healthBox.lineStyle(
    3,
    0x8f6b2e,
    1
  );

  healthBox.strokeRoundedRect(
    x,
    y,
    boxWidth,
    boxHeight,
    10
  );

  const healthText = scene.add
    .text(
      x + boxWidth / 2,
      y + boxHeight / 2,
      `❤️ ${RunState.player.health}/${RunState.player.maxHealth}`,
      {
        ...textStyle,
        color: "#ff4d4d",
      }
    )
    .setOrigin(0.5);

  // -------------------------
  // STAMINA BOX
  // -------------------------

  const staminaY =
    y + boxHeight + gap;

  const staminaBox = scene.add.graphics();

  staminaBox.fillStyle(
    0x17130d,
    0.9
  );

  staminaBox.fillRoundedRect(
    x,
    staminaY,
    boxWidth,
    boxHeight,
    10
  );

  staminaBox.lineStyle(
    3,
    0x8f6b2e,
    1
  );

  staminaBox.strokeRoundedRect(
    x,
    staminaY,
    boxWidth,
    boxHeight,
    10
  );

  const staminaText = scene.add
    .text(
      x + boxWidth / 2,
      staminaY + boxHeight / 2,
      `⚡ ${RunState.player.stamina}/${RunState.player.maxStamina}`,
      {
        ...textStyle,
        color: "#6cff5c",
      }
    )
    .setOrigin(0.5);

  return {
    healthText,
    staminaText,
    healthBox,
    staminaBox,
  };
}