from PIL import Image, ImageDraw, ImageFont
import os

SIZE = 256

img = Image.new('RGBA', (SIZE, SIZE), (0, 0, 0, 0))
draw = ImageDraw.Draw(img)

# Gradient background: terracotta -> sage
for y in range(SIZE):
    ratio = y / SIZE
    r = int(0xC7 + (0x4A - 0xC7) * ratio)
    g = int(0x5B + (0x7C - 0x5B) * ratio)
    b = int(0x33 + (0x6F - 0x33) * ratio)
    draw.line([(0, y), (SIZE, y)], fill=(r, g, b, 255))

# Rounded rectangle mask
mask = Image.new('L', (SIZE, SIZE), 0)
mask_draw = ImageDraw.Draw(mask)
corner_radius = 48
mask_draw.rounded_rectangle([0, 0, SIZE, SIZE], radius=corner_radius, fill=255)
img.putalpha(mask)

# White "Pp" text
try:
    # Try system fonts, fallback to default
    font_large = ImageFont.truetype("arialbd.ttf", 140)
    font_small = ImageFont.truetype("arialbd.ttf", 80)
except:
    font_large = ImageFont.load_default()
    font_small = ImageFont.load_default()

# Draw main "P"
text = "P"
bbox = draw.textbbox((0, 0), text, font=font_large)
text_w = bbox[2] - bbox[0]
text_h = bbox[3] - bbox[1]
x = (SIZE - text_w) // 2 - 10
y = (SIZE - text_h) // 2 - 25

# Subtle shadow
shadow_offset = 4
draw.text((x + shadow_offset, y + shadow_offset), text, font=font_large, fill=(0, 0, 0, 60))
draw.text((x, y), text, font=font_large, fill=(255, 255, 255, 255))

# Small "p"
text_small = "p"
bbox_s = draw.textbbox((0, 0), text_small, font=font_small)
text_sw = bbox_s[2] - bbox_s[0]
text_sh = bbox_s[3] - bbox_s[1]
xs = x + text_w - text_sw // 2 + 8
ys = y + text_h - text_sh + 10

draw.text((xs + shadow_offset, ys + shadow_offset), text_small, font=font_small, fill=(0, 0, 0, 60))
draw.text((xs, ys), text_small, font=font_small, fill=(255, 255, 255, 230))

# Save PNG preview
png_path = os.path.join(os.path.dirname(__file__), 'app_icon_preview.png')
img.save(png_path)

# Save ICO with multiple sizes
ico_path = os.path.join(
    os.path.dirname(__file__),
    '..', 'windows', 'runner', 'resources', 'app_icon.ico'
)

sizes = [16, 32, 48, 64, 128, 256]
ico_images = []
for s in sizes:
    resized = img.resize((s, s), Image.Resampling.LANCZOS)
    # Ensure no transparency issues at small sizes
    if s <= 48:
        # Add 1px padding for crispness at small sizes
        padded = Image.new('RGBA', (s, s), (0, 0, 0, 0))
        padded.paste(resized, (0, 0), resized)
        ico_images.append(padded)
    else:
        ico_images.append(resized)

img.save(ico_path, format='ICO', sizes=[(s, s) for s in sizes])
print(f"Saved ICO: {ico_path}")
print(f"Saved PNG preview: {png_path}")
