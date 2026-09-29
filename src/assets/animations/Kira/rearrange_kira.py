from PIL import Image

def rearrange_sprite_sheet(
    input_file,
    output_file,
    total_frames,
    columns,
    frame_width=256,
    frame_height=256
):
    rows = (total_frames + columns - 1) // columns

    sheet = Image.open(input_file).convert("RGBA")

    new_sheet = Image.new(
        "RGBA",
        (
            columns * frame_width,
            rows * frame_height
        ),
        (0, 0, 0, 0)
    )

    for i in range(total_frames):
        source_x = i * frame_width

        frame = sheet.crop((
            source_x,
            0,
            source_x + frame_width,
            frame_height
        ))

        col = i % columns
        row = i // columns

        dest_x = col * frame_width
        dest_y = row * frame_height

        new_sheet.paste(
            frame,
            (dest_x, dest_y),
            frame
        )

    new_sheet.save(output_file)

    print(f"Saved: {output_file}")
    print(f"Size: {new_sheet.size}")


# -------------------------
# HURT - 77 FRAMES
# -------------------------

rearrange_sprite_sheet(
    input_file="spr_kira_hurt_strip77.png",
    output_file="spr_kira_hurt_39x2.png",
    total_frames=77,
    columns=39
)


# -------------------------
# DEATH - 64 FRAMES
# -------------------------

rearrange_sprite_sheet(
    input_file="spr_kira_death_strip64.png",
    output_file="spr_kira_death_32x2.png",
    total_frames=64,
    columns=32
)