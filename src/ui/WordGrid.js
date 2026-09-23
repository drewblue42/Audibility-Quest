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
    this.fontFamily = config.fontFamily ?? "Palatino";
    this.textColor = config.color ?? "#fcc844";

    this.buttonsByCol = Array.from(
      { length: this.cols },
      () => []
    );

    this.selectedByCol = Array.from(
      { length: this.cols },
      () => null
    );

    this.buildGrid();

    scene.add.existing(this);
  }

  buildGrid() {
    const totalWidth =
      this.cols * this.cellWidth;

    const totalHeight =
      this.rows * this.cellHeight;

    // -------------------------
    // ORNATE BORDER IMAGE
    // -------------------------

    const borderPadding = 30;

    const border = this.scene.add
      .image(
        totalWidth / 2,
        totalHeight / 2,
        "wordGridBorder"
      )
      .setOrigin(0.5)
      .setDisplaySize(
        totalWidth + borderPadding * 2 +40,
        totalHeight + borderPadding * 2  +40
      );

    this.add(border);

    // -------------------------
    // DARK GRID BACKGROUND
    // -------------------------

    const tableBg = this.scene.add
      .rectangle(
        0,
        0,
        totalWidth,
        totalHeight,
        0x17130d
      )
      .setOrigin(0)
      .setStrokeStyle(
        3,
        0x8f6b2e
      );

    this.add(tableBg);

    // -------------------------
    // CELLS
    // -------------------------

    for (
      let col = 0;
      col < this.cols;
      col++
    ) {
      const q =
        this.questions[col];

      if (!q) continue;

      const shuffledChoices =
        shuffle(q.choices).slice(
          0,
          this.rows
        );

      for (
        let row = 0;
        row < this.rows;
        row++
      ) {
        const word =
          shuffledChoices[row];

        const isCorrect =
          word === q.correct;

        const cellX =
          col * this.cellWidth;

        const cellY =
          row * this.cellHeight;

        // Dark brown/black cell
        const rect =
          this.scene.add
            .rectangle(
              cellX,
              cellY,
              this.cellWidth,
              this.cellHeight,
              0x211b13
            )
            .setOrigin(0)
            .setStrokeStyle(
              1,
              0x705526
            )
            .setInteractive({
              useHandCursor: true,
            });

        const text =
          this.scene.add
            .text(
              cellX +
                this.cellWidth / 2,
              cellY +
                this.cellHeight / 2,
              word,
              {
                fontSize:
                  this.fontSize,

                fontFamily:
                  this.fontFamily,

                color:
                  this.textColor,

                fontStyle:
                  "bold",

                stroke:
                  "#241600",

                strokeThickness:
                  2,

                align:
                  "center",

                wordWrap: {
                  width:
                    this.cellWidth -
                    10,
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

        // -------------------------
        // HOVER EFFECT
        // -------------------------

        rect.on(
          "pointerover",
          () => {
            if (
              this.selectedByCol[
                col
              ] !== null
            ) {
              return;
            }

            rect.setFillStyle(
              0x3a2d19
            );

            rect.setStrokeStyle(
              2,
              0xd4a947
            );

            text.setColor(
              "#fff1a8"
            );
          }
        );

        rect.on(
          "pointerout",
          () => {
            if (
              this.selectedByCol[
                col
              ] !== null
            ) {
              return;
            }

            rect.setFillStyle(
              0x211b13
            );

            rect.setStrokeStyle(
              1,
              0x705526
            );

            text.setColor(
              this.textColor
            );
          }
        );

        // -------------------------
        // CLICK
        // -------------------------

        rect.on(
          "pointerdown",
          () => {
            this.pickCell(cell);
          }
        );

        text.setInteractive({
          useHandCursor: true,
        });

        text.on(
          "pointerdown",
          () => {
            this.pickCell(cell);
          }
        );

        this.buttonsByCol[
          col
        ].push(cell);

        this.add(rect);
        this.add(text);
      }
    }
  }

  pickCell(cell) {
    if (
      this.selectedByCol[
        cell.col
      ] !== null
    ) {
      return;
    }

    this.selectedByCol[
      cell.col
    ] = cell;

    for (
      const otherCell of
      this.buttonsByCol[
        cell.col
      ]
    ) {
      if (
        otherCell === cell
      ) {
        // Selected cell
        otherCell.rect
          .setFillStyle(
            0x7a5517
          )
          .setStrokeStyle(
            3,
            0xffd45c
          );

        otherCell.text
          .setColor(
            "#ffffff"
          )
          .setScale(1.05);
      } else {
        // Disabled cells
        otherCell.rect
          .setFillStyle(
            0x100d09
          )
          .setStrokeStyle(
            1,
            0x342a1b
          )
          .setAlpha(0.55);

        otherCell.text
          .setColor(
            "#6e675c"
          )
          .setAlpha(0.7);

        otherCell.rect
          .disableInteractive();

        otherCell.text
          .disableInteractive();
      }
    }

    this.onPick?.({
      col: cell.col,
      row: cell.row,
      text: cell.word,
      isCorrect:
        cell.isCorrect,
      btn: cell,
      grid: this,
    });
  }

  allChosen() {
    return this.selectedByCol.every(
      (v) => v !== null
    );
  }

  getChosen() {
    return this.selectedByCol.map(
      (v) => ({
        text: v.word,
        isCorrect:
          v.isCorrect,
      })
    );
  }

  correctCount() {
    return this.selectedByCol.reduce(
      (acc, v) =>
        acc +
        (v?.isCorrect ? 1 : 0),
      0
    );
  }
}