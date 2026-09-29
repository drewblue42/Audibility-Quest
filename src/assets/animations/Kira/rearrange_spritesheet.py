from PIL import Image

input_file = "spr_kira_hit_strip86.png"
output_file = "spr_kira_hit_43x2.png"

frame_width = 256
frame_height = 256

columns = 43
rows = 2
total_frames = 86

sheet = Image.open(input_file).convert("RGBA")

new_sheet = Image.new(
    "RGBA",
    (columns * frame_width, rows * frame_height),
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

print("Saved:", output_file)
print("Size:", new_sheet.size)