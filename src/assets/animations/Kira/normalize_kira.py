from PIL import Image
import math
import os

FRAME_W = 256
FRAME_H = 256

# How tall Kira should visually be inside each frame
TARGET_HEIGHT = 190

def normalize_frame(frame):
    frame = frame.convert("RGBA")

    # Get alpha channel
    alpha = frame.getchannel("A")

    # Find visible pixel bounds
    bbox = alpha.getbbox()

    if bbox is None:
        return frame

    left, top, right, bottom = bbox

    char = frame.crop((left, top, right, bottom))

    char_w = char.width
    char_h = char.height

    if char_h == 0:
        return frame

    # Scale based on desired height
    scale = TARGET_HEIGHT / char_h

    new_w = max(1, int(char_w * scale))
    new_h = max(1, int(char_h * scale))

    char = char.resize(
        (new_w, new_h),
        Image.Resampling.LANCZOS
    )

    # Create clean 256x256 frame
    output = Image.new(
        "RGBA",
        (FRAME_W, FRAME_H),
        (0, 0, 0, 0)
    )

    # Center horizontally
    x = (FRAME_W - new_w) // 2

    # Bottom align
    # Leaves a little floor padding
    bottom_padding = 15
    y = FRAME_H - new_h - bottom_padding

    output.alpha_composite(
        char,
        (x, y)
    )

    return output


def normalize_sheet(
    input_file,
    output_file,
    total_frames,
    input_columns,
    output_columns=16
):
    sheet = Image.open(input_file).convert("RGBA")

    frames = []

    for i in range(total_frames):
        col = i % input_columns
        row = i // input_columns

        x = col * FRAME_W
        y = row * FRAME_H

        frame = sheet.crop((
            x,
            y,
            x + FRAME_W,
            y + FRAME_H
        ))

        normalized = normalize_frame(frame)

        frames.append(normalized)

    output_rows = math.ceil(
        total_frames / output_columns
    )

    output_sheet = Image.new(
        "RGBA",
        (
            output_columns * FRAME_W,
            output_rows * FRAME_H
        ),
        (0, 0, 0, 0)
    )

    for i, frame in enumerate(frames):
        col = i % output_columns
        row = i // output_columns

        x = col * FRAME_W
        y = row * FRAME_H

        output_sheet.alpha_composite(
            frame,
            (x, y)
        )

    output_sheet.save(output_file)

    print(
        f"Saved {output_file} "
        f"{output_sheet.size}"
    )


# -------------------------
# IDLE
# Original strip = 24 across
# -------------------------

normalize_sheet(
    "spr_kira_idle_strip24.png",
    "spr_kira_idle_normalized.png",
    total_frames=24,
    input_columns=24
)


# -------------------------
# HIT
# Your repacked version = 43x2
# -------------------------

normalize_sheet(
    "spr_kira_hit_43x2.png",
    "spr_kira_hit_normalized.png",
    total_frames=86,
    input_columns=43
)


# -------------------------
# HURT
# 39x2
# -------------------------

normalize_sheet(
    "spr_kira_hurt_39x2.png",
    "spr_kira_hurt_normalized.png",
    total_frames=77,
    input_columns=39
)


# -------------------------
# DEATH
# 32x2
# -------------------------

normalize_sheet(
    "spr_kira_death_32x2.png",
    "spr_kira_death_normalized.png",
    total_frames=64,
    input_columns=32
)