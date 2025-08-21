from PIL import Image, ImageDraw, ImageFont
import os

def create_wellminder_icon():
    # Create a 512x512 image with transparency
    size = 512
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Create gradient-like background
    # Green gradient colors
    colors = [
        (76, 175, 80),    # Main green
        (69, 160, 73),    # Slightly darker
        (56, 142, 60),    # Darker green
    ]
    
    # Draw circular background with gradient effect
    center = size // 2
    radius = size // 2 - 20
    
    # Draw multiple circles for gradient effect
    for i, color in enumerate(colors):
        r = radius - i * 15
        if r > 0:
            draw.ellipse([center - r, center - r, center + r, center + r], 
                        fill=color + (255,))
    
    # Try to load a font, fallback to default
    try:
        # Try system fonts
        font_large = ImageFont.truetype("arial.ttf", 180)
        font_small = ImageFont.truetype("arial.ttf", 60)
    except:
        try:
            font_large = ImageFont.truetype("segoeui.ttf", 180)
            font_small = ImageFont.truetype("segoeui.ttf", 60)
        except:
            # Fallback to default font
            font_large = ImageFont.load_default()
            font_small = ImageFont.load_default()
    
    # Draw the "W" letter
    text_w = "W"
    bbox_w = draw.textbbox((0, 0), text_w, font=font_large)
    text_width_w = bbox_w[2] - bbox_w[0]
    text_height_w = bbox_w[3] - bbox_w[1]
    
    x_w = (size - text_width_w) // 2
    y_w = (size - text_height_w) // 2 - 30
    
    # Add text shadow
    draw.text((x_w + 3, y_w + 3), text_w, font=font_large, fill=(0, 0, 0, 100))
    # Main text
    draw.text((x_w, y_w), text_w, font=font_large, fill=(255, 255, 255, 255))
    
    # Draw the "M" letter (smaller, below)
    text_m = "M"
    bbox_m = draw.textbbox((0, 0), text_m, font=font_small)
    text_width_m = bbox_m[2] - bbox_m[0]
    
    x_m = (size - text_width_m) // 2
    y_m = y_w + text_height_w + 10
    
    # Add text shadow for M
    draw.text((x_m + 2, y_m + 2), text_m, font=font_small, fill=(0, 0, 0, 100))
    # Main text for M
    draw.text((x_m, y_m), text_m, font=font_small, fill=(255, 255, 255, 255))
    
    # Add a subtle border/ring
    draw.ellipse([10, 10, size-10, size-10], outline=(255, 255, 255, 50), width=4)
    
    return img

def main():
    # Create the icon
    icon = create_wellminder_icon()
    
    # Save the icon
    output_path = "app_icon.png"
    icon.save(output_path, "PNG")
    print(f"Icon saved as {output_path}")
    
    # Create smaller versions for different platforms
    sizes = [16, 32, 48, 64, 128, 256]
    for size in sizes:
        resized = icon.resize((size, size), Image.Resampling.LANCZOS)
        resized.save(f"app_icon_{size}.png", "PNG")
        print(f"Icon {size}x{size} saved")

if __name__ == "__main__":
    main()
