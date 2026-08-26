# Audibility-Quest
Towson University Project: User will travel through a dungeon fighting monsters. To fight monsters, you will respond with words you hear and ignore other sounds. Responding with correct words will hurt monsters and protect you from their attacks. You can run away from monsters if you don’t think you can beat them.


TODO:
- Add back button to instructions (Done)
- 5 sentences/ five rounds per fight (Done)
- Cause a GameOver, do not let the player continue with zero health.
- 


Info:
- noise get higher and higher
- 30+ levels of sound
- Player starts with 100 health, loses 1 health for each incorrect word
during fights. When health reaches 0, screen pops up to say “You
died. Press here to continue” That button refills health to 100 and lets
you continue playing from the spot where you died.
- track amount of deaths
- At the end of the game, short credits roll, followed by a set of stats for
the run (see Credits Screen).

    -Number of player deaths

    -Total damage the player took (ignoring health gained from
            campsites/potions) add a totalDamage Counter to RunState

    -Total number of words identified correctly (Counted based on scoring
            keystrokes, 0 damage means +5 correct words, 1 damage = +4 correct
            words)

    - Highlight completed achievements, but show incomplete ones as well:

    - Immortal: Beat the game without dying

    - Fortitude: Beat the game without gaining back any lost life from campsites/potions

    - Warrior: More than 200 words correct

    - Potion Master: Beat the game after visiting the potion shop
    -

8/24/26
Question:
- What happens if all words are missed, does the player still get to hit??? 
    - They do hit, jsut take maximum damage
- Do we need to keep track of "level" for the players view?
    - Yes
- when they run do they go to the next node or do they redo the same one, but the experimentor goes to an easier test?
    - go to next node, cannot run from the boss, 
- What happens when they run with zero stamina? Do they get a game over or are forced to continue?
    - grey out run button, and are forced to play that round and same for the upcoming levels
- What happens when there is a game over? Game goes straight to the main screen and the whole game is refreshed?
    - Start on node, when they die with full health, but increasing death counter in stats.