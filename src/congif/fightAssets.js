export function preloadFightAssets(scene) {
    const skeletonIdleUrl = new URL(
        "../assets/animations/Skeleton/Idle.png",
        import.meta.url
      ).href;
  
      const skeletonAttackUrl = new URL(
        "../assets/animations/Skeleton/Attack3.png",
        import.meta.url
      ).href;
  
      const swordEffectUrl = new URL(
        "../assets/animations/Skeleton/Sword_sprite.png",
        import.meta.url
      ).href;
  
      const kiraIdleUrl = new URL(
        "../assets/animations/Kira/spr_kira_idle_strip24.png",
        import.meta.url
      ).href;
  
      const kiraHitUrl = new URL(
        "../assets/animations/Kira/spr_kira_hit_normalized.png",
        import.meta.url
      ).href;
  
      const kiraHurtUrl = new URL(
        "../assets/animations/Kira/spr_kira_hurt_normalized.png",
        import.meta.url
      ).href;
  
      const kiraDeathUrl = new URL(
        "../assets/animations/Kira/spr_kira_death_32x2.png",
        import.meta.url
      ).href;
  
      const blackKnightIdleUrl = new URL(
        "../assets/animations/BlackKnight/hooded knight idle.png",
        import.meta.url
      ).href;
  
      const blackKnightHitUrl = new URL(
        "../assets/animations/BlackKnight/hooded knight attack.png",
        import.meta.url
      ).href;
  
      this.load.spritesheet("blackKnightIdle", blackKnightIdleUrl, {
        frameWidth: 100,
        frameHeight: 100,
      });
  
      this.load.spritesheet("blackKnightAttack", blackKnightHitUrl, {
        frameWidth: 180,
        frameHeight: 100,
      });
  
  
      this.load.spritesheet("skeletonIdle", skeletonIdleUrl, {
        frameWidth: 150,
        frameHeight: 150,
      });
  
      this.load.spritesheet("skeletonAttack", skeletonAttackUrl, {
        frameWidth: 150,
        frameHeight: 150,
      });
  
      this.load.spritesheet("swordEffect", swordEffectUrl, {
        frameWidth: 92,
        frameHeight: 102,
      });
  
      this.load.spritesheet("kiraIdle", kiraIdleUrl, {
        frameWidth: 256,
        frameHeight: 256,
      })
  
      this.load.spritesheet("kiraHit", kiraHitUrl, {
        frameWidth: 256,
        frameHeight: 256,
      })
  
      const dragonIdleUrl = new URL(
        "../assets/animations/Dragon/ShadowDragon/Animations/Idle_Right/Idle_right.png",
        import.meta.url
      ).href;
  
      const dragonAttackUrl = new URL(
        "../assets/animations/Dragon/ShadowDragon/Animations/Attack_Right/Attack_right.png",
  
        import.meta.url
      ).href;
  
      this.load.spritesheet("dragonIdle", dragonIdleUrl, {
        frameWidth: 1408,
        frameHeight: 792,
      });
  
      this.load.spritesheet("dragonAttack", dragonAttackUrl, {
        frameWidth: 1408,
        frameHeight: 792,
      });
  
      const dungeonURL = new URL(
        "../assets/images/background/dungeon.png",
        import.meta.url
      ).toString();
  
      this.load.image("dungeon", dungeonURL);
  
      const dungeonBrickURL = new URL(
        "../assets/images/background/dungeonbrick.png",
        import.meta.url
      ).toString();
  
      this.load.image("dungeonbrick", dungeonBrickURL);
  
      const wordGridBorderUrl = new URL(
        "../assets/ui/wordgridborder.png",
        import.meta.url
      ).toString();
  
      this.load.image("wordGridBorder", wordGridBorderUrl);
  
      const heroHealthBarUrl = new URL(
        "../assets/ui/heroHealthBar.png",
        import.meta.url
      ).toString();
  
      const monsterHealthBarUrl = new URL(
        "../assets/ui/monsterHealthBar.png",
        import.meta.url
      ).toString();
  
      this.load.image("heroHealthBarFrame", heroHealthBarUrl);
      this.load.image("monsterHealthBarFrame", monsterHealthBarUrl);
  
      this.load.spritesheet("kiraHurt", kiraHurtUrl, {
        frameWidth: 256,
        frameHeight: 256,
      });
  
      this.load.spritesheet("kiraDeath", kiraDeathUrl, {
        frameWidth: 256,
        frameHeight: 256,
      });

}