from PIL import Image
import math

FRAME_W = 256
FRAME_H = 256

TOTAL_FRAMES = 86

# Your normalized hit sheet was rebuilt as 16 columns
INPUT_COLUMNS = 16
OUTPUT_COLUMNS = 16

PADDING = 4

INPUT_FILE = "spr_kira_hit_normalized.png"
OUTPUT_FILE = "spr_kira_hit_padded.png"


sheet = Image.open(INPUT_FILE).convert("RGBA")

frames = []

# -------------------------
# EXTRACT FRAMES
# DO NOT RESIZE THEM
# -------------------------

for i in range(TOTAL_FRAMES):
    col = i % INPUT_COLUMNS
    row = i // INPUT_COLUMNS

    x = col * FRAME_W
    y = row * FRAME_H

    frame = sheet.crop((
        x,
        y,
        x + FRAME_W,
        y + FRAME_H
    ))

    frames.append(frame)


# -------------------------
# BUILD PADDED SHEET
# -------------------------

rows = math.ceil(
    TOTAL_FRAMES / OUTPUT_COLUMNS
)

output_width = (
    PADDING
    + OUTPUT_COLUMNS * FRAME_W
    + (OUTPUT_COLUMNS - 1) * PADDING
    + PADDING
)

output_height = (
    PADDING
    + rows * FRAME_H
    + (rows - 1) * PADDING
    + PADDING
)

output_sheet = Image.new(
    "RGBA",
    (output_width, output_height),
    (0, 0, 0, 0)
)


for i, frame in enumerate(frames):
    col = i % OUTPUT_COLUMNS
    row = i // OUTPUT_COLUMNS

    x = (
        PADDING
        + col * (FRAME_W + PADDING)
    )

    y = (
        PADDING
        + row * (FRAME_H + PADDING)
    )

    output_sheet.alpha_composite(
        frame,
        (x, y)
    )


output_sheet.save(
    OUTPUT_FILE
)

print(f"Saved: {OUTPUT_FILE}")
print(f"Size: {output_sheet.size}")
print(f"Frames: {TOTAL_FRAMES}")