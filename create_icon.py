from PIL import Image, ImageDraw, ImageFont
import os

# Create a 1024x1024 red icon with white text
size = 1024
img = Image.new('RGBA', (size, size), color=(204, 26, 26, 255))  # Canadian red
draw = ImageDraw.Draw(img)

# Draw white text "PM" (PriceMate)
try:
    # Try to use a system font
    font_size = 400
    font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", font_size)
except:
    # Fallback to default font
    font = ImageFont.load_default()

# Calculate text position
text = "PM"
bbox = draw.textbbox((0, 0), text, font=font)
text_width = bbox[2] - bbox[0]
text_height = bbox[3] - bbox[1]
position = ((size - text_width) / 2, (size - text_height) / 2 - 50)

# Draw the text
draw.text(position, text, fill="white", font=font)

# Save the icon
output_path = "PriceMateCanada/Assets.xcassets/AppIcon.appiconset/AppIcon.png"
img.save(output_path, "PNG")
print(f"Icon created at: {output_path}")
