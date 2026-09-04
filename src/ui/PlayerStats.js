import { RunState } from "../systems/RunState";

export function createPlayerStats(scene, x, y) {
  scene.add.text(
    x,
    y,
    `❤️ ${RunState.player.health}/${RunState.player.maxHealth}`,
    {
      fontSize: "24px",
      color: "#ff4444",
    }
  );

  
  scene.add.text(
    x,
    y + 35,
    `⚡ ${RunState.player.stamina}/${RunState.player.maxStamina}`,
    {
      fontSize: "24px",
      color: "#44cc44",
    }
  );
}