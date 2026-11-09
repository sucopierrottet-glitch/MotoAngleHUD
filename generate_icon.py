import math
import os
from PIL import Image, ImageDraw

def create_app_icon(output_path="assets/icon/app_icon.png"):
    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    size = 1024
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    # 1. Obsidian Dark Rounded Squircle Background
    bg_margin = 32
    bg_radius = 220

    gradient_img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    grad_draw = ImageDraw.Draw(gradient_img)

    for y in range(size):
        ratio = y / size
        r = int(11 + (22 - 11) * ratio)
        g = int(15 + (31 - 15) * ratio)
        b = int(25 + (48 - 25) * ratio)
        grad_draw.line([(0, y), (size, y)], fill=(r, g, b, 255))

    mask = Image.new("L", (size, size), 0)
    mask_draw = ImageDraw.Draw(mask)
    mask_draw.rounded_rectangle(
        [bg_margin, bg_margin, size - bg_margin, size - bg_margin],
        radius=bg_radius,
        fill=255,
    )
    img.paste(gradient_img, (0, 0), mask)

    # Neon Green & Racing Red outer rim glow
    draw.rounded_rectangle(
        [bg_margin, bg_margin, size - bg_margin, size - bg_margin],
        radius=bg_radius,
        outline=(239, 68, 68, 120),
        width=6,
    )

    cx, cy = 512, 540
    dial_r = 370

    # 2. Outer Telemetry Bezel Circle
    draw.ellipse(
        [cx - dial_r, cy - dial_r, cx + dial_r, cy + dial_r],
        fill=(15, 23, 42, 255),
        outline=(51, 65, 85, 255),
        width=10,
    )

    # 3. Lean Angle Protractor Arcs (Left = Racing Red #EF4444, Right = Neon Green #00E676)
    arc_box = [cx - 320, cy - 320, cx + 320, cy + 320]
    draw.arc(arc_box, start=205, end=270, fill=(239, 68, 68, 255), width=34)
    draw.arc(arc_box, start=270, end=335, fill=(0, 230, 118, 255), width=34)

    # Degree tick marks along upper arc
    for deg in range(-60, 61, 15):
        rad = math.radians(-90 + deg)
        r_in = 265 if deg % 30 == 0 else 280
        r_out = 305
        x1 = cx + r_in * math.cos(rad)
        y1 = cy + r_in * math.sin(rad)
        x2 = cx + r_out * math.cos(rad)
        y2 = cy + r_out * math.sin(rad)
        draw.line([(x1, y1), (x2, y2)], fill=(226, 232, 240, 220), width=6)

    # 4. Artificial Horizon Line
    draw.line([(cx - 260, cy), (cx + 260, cy)], fill=(56, 189, 248, 160), width=5)

    # 5. Banked Sport Motorcycle Silhouette (-38 deg lean angle)
    lean_rad = math.radians(-38)
    cos_a = math.cos(lean_rad)
    sin_a = math.sin(lean_rad)

    def rot_pt(px, py):
        rx = px * cos_a - py * sin_a
        ry = px * sin_a + py * cos_a
        return (cx + rx, cy + ry)

    # Lean vector needle
    p_top = rot_pt(0, -295)
    p_bot = rot_pt(0, 120)
    draw.line([p_top, p_bot], fill=(0, 230, 118, 255), width=12)

    # Handlebars
    hb_left = rot_pt(-140, -70)
    hb_right = rot_pt(140, -70)
    draw.line([hb_left, hb_right], fill=(248, 250, 252, 255), width=16)

    # Sport Fairing / Windshield Polygon
    fairing = [
        rot_pt(0, -175),
        rot_pt(85, -55),
        rot_pt(55, 40),
        rot_pt(-55, 40),
        rot_pt(-85, -55),
    ]
    draw.polygon(fairing, fill=(239, 68, 68, 255), outline=(255, 255, 255, 255))

    # Rear Tire Profile
    tire_poly = [
        rot_pt(-44, 15),
        rot_pt(44, 15),
        rot_pt(38, 165),
        rot_pt(-38, 165),
    ]
    draw.polygon(tire_poly, fill=(30, 41, 59, 255), outline=(0, 230, 118, 255))

    # Center G-Force Bullseye Hub
    hub_r = 36
    draw.ellipse(
        [cx - hub_r, cy - hub_r, cx + hub_r, cy + hub_r],
        fill=(0, 230, 118, 255),
        outline=(255, 255, 255, 255),
        width=6,
    )

    img.save(output_path, "PNG")
    print(f"Generated MotoAngleHUD icon successfully at {output_path}")

if __name__ == "__main__":
    create_app_icon()
