// src/ui/WordGrid.js

function shuffle(arr) {
  const a = [...arr];

  for (let i = a.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [a[i], a[j]] = [a[j], a[i]];
  }

  return a;
}

export default class GridOfButtons extends Phaser.GameObjects.Container {
  constructor(scene, x, y, config) {
    super(scene, x, y);

    this.scene = scene;

    this.cols = config.cols;
    this.rows = config.rows;
    this.questions = config.questions;
    this.onPick = config.onPick;

    this.cellWidth = config.cellWidth ?? 105;
    this.cellHeight = config.cellHeight ?? 44;
    this.fontSize = config.fontSize ?? "18px";

    this.buttonsByCol = Array.from({ length: this.cols }, () => []);
    this.selectedByCol = Array.from({ length: this.cols }, () => null);

    this.buildGrid();

    scene.add.existing(this);
  }

  buildGrid() {
    const totalWidth = this.cols * this.cellWidth;
    const totalHeight = this.rows * this.cellHeight;

    // Outer table background/border
    const tableBg = this.scene.add
      .rectangle(0, 0, totalWidth, totalHeight, 0xe6e6e6)
      .setOrigin(0)
      .setStrokeStyle(2, 0x000000);

    this.add(tableBg);

    for (let col = 0; col < this.cols; col++) {
      const q = this.questions[col];
      if (!q) continue;

      const shuffledChoices = shuffle(q.choices).slice(0, this.rows);

      for (let row = 0; row < this.rows; row++) {
        const word = shuffledChoices[row];
        const isCorrect = word === q.correct;

        const cellX = col * this.cellWidth;
        const cellY = row * this.cellHeight;

        const rect = this.scene.add
          .rectangle(cellX, cellY, this.cellWidth, this.cellHeight, 0xe6e6e6)
          .setOrigin(0)
          .setStrokeStyle(1, 0x000000)
          .setInteractive({ useHandCursor: true });

        const text = this.scene.add
          .text(
            cellX + this.cellWidth / 2,
            cellY + this.cellHeight / 2,
            word,
            {
              fontSize: this.fontSize,
              color: "#000000",
              align: "center",
              wordWrap: {
                width: this.cellWidth - 8,
              },
            }
          )
          .setOrigin(0.5);

        const cell = {
          col,
          row,
          word,
          isCorrect,
          rect,
          text,
        };

        rect.on("pointerdown", () => {
          this.pickCell(cell);
        });

        text.setInteractive({ useHandCursor: true });
        text.on("pointerdown", () => {
          this.pickCell(cell);
        });

        this.buttonsByCol[col].push(cell);

        this.add(rect);
        this.add(text);
      }
    }
  }

  pickCell(cell) {
    if (this.selectedByCol[cell.col] !== null) return;

    this.selectedByCol[cell.col] = cell;

    for (const otherCell of this.buttonsByCol[cell.col]) {
      if (otherCell === cell) {
        otherCell.rect.setFillStyle(0x1e90ff);
        otherCell.text.setColor("#ffffff");
      } else {
        otherCell.rect.setFillStyle(0x999999);
        otherCell.text.setColor("#dddddd");
        otherCell.rect.disableInteractive();
        otherCell.text.disableInteractive();
      }
    }

    this.onPick?.({
      col: cell.col,
      row: cell.row,
      text: cell.word,
      isCorrect: cell.isCorrect,
      btn: cell,
      grid: this,
    });
  }

  allChosen() {
    return this.selectedByCol.every((v) => v !== null);
  }

  getChosen() {
    return this.selectedByCol.map((v) => ({
      text: v.word,
      isCorrect: v.isCorrect,
    }));
  }

  correctCount() {
    return this.selectedByCol.reduce(
      (acc, v) => acc + (v?.isCorrect ? 1 : 0),
      0
    );
  }
}