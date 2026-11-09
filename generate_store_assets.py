import os
from PIL import Image, ImageDraw, ImageFont

def generate_store_assets():
    out_dir = "store_assets"
    os.makedirs(out_dir, exist_ok=True)

    font_bold_path = "C:/Windows/Fonts/segoeuib.ttf"
    font_reg_path = "C:/Windows/Fonts/segoeui.ttf"

    # 1. ICON 512x512
    base_icon_path = "assets/icon/app_icon.png"
    if os.path.exists(base_icon_path):
        base_icon = Image.open(base_icon_path).convert("RGBA")
        icon_512 = base_icon.resize((512, 512), Image.Resampling.LANCZOS)
        icon_512.save(os.path.join(out_dir, "icon_512.png"), "PNG")
        print("Generated icon_512.png")

    # 2. FEATURE GRAPHIC 1024x500
    w_feat, h_feat = 1024, 500
    feat_img = Image.new("RGBA", (w_feat, h_feat), (11, 15, 25, 255))
    feat_draw = ImageDraw.Draw(feat_img)

    for x in range(w_feat):
        ratio = x / w_feat
        r = int(11 + (22 - 11) * ratio)
        g = int(15 + (31 - 15) * ratio)
        b = int(25 + (48 - 25) * ratio)
        feat_draw.line([(x, 0), (x, h_feat)], fill=(r, g, b, 255))

    if os.path.exists(base_icon_path):
        icon_for_feat = Image.open(base_icon_path).convert("RGBA").resize((320, 320), Image.Resampling.LANCZOS)
        feat_img.paste(icon_for_feat, (85, 90), icon_for_feat)

    f_badge = ImageFont.truetype(font_bold_path, 16)
    f_title = ImageFont.truetype(font_bold_path, 46)
    f_sub = ImageFont.truetype(font_reg_path, 21)
    f_tag = ImageFont.truetype(font_bold_path, 14)

    tx = 445
    feat_draw.rounded_rectangle([tx, 92, tx + 390, 128], radius=18, fill=(239, 68, 68, 45), outline=(239, 68, 68, 220), width=2)
    feat_draw.text((tx + 16, 100), "TELEMETRÍA & HUD PARA MOTOCICLETA", font=f_badge, fill=(0, 230, 118, 255))

    feat_draw.text((tx, 145), "MOTOANGLE HUD PRO", font=f_title, fill=(248, 250, 252, 255))
    feat_draw.text((tx, 210), "Inclinómetro con Retención de Picos • Fuerza G 2D", font=f_sub, fill=(203, 213, 225, 255))
    feat_draw.text((tx, 242), "Modo Espejo Parabrisas & Cronómetro 0-100 km/h", font=f_sub, fill=(148, 163, 184, 255))

    tags = ["LEAN ANGLE 65°", "2D G-FORCE BALL", "WINDSHIELD HUD", "PDF FIRMADO", "100% OFFLINE"]
    chip_x, chip_y = tx, 305
    for t in tags:
        bbox = f_tag.getbbox(t)
        tw = bbox[2] - bbox[0] + 24
        feat_draw.rounded_rectangle([chip_x, chip_y, chip_x + tw, chip_y + 32], radius=8, fill=(22, 31, 48, 255), outline=(0, 230, 118, 160), width=1)
        feat_draw.text((chip_x + 12, chip_y + 7), t, font=f_tag, fill=(248, 250, 252, 255))
        chip_x += tw + 10
        if chip_x > 930:
            chip_x = tx
            chip_y += 42

    feat_img.save(os.path.join(out_dir, "feature_graphic_1024x500.png"), "PNG")
    print("Generated feature_graphic_1024x500.png")

    # 3. 4 PHONE MOCKUP SCREENSHOTS (1080x1920)
    def create_screenshot(filename, tag, title, sub, accent_rgb):
        w, h = 1080, 1920
        img = Image.new("RGBA", (w, h), (11, 15, 25, 255))
        draw = ImageDraw.Draw(img)

        f_top_tag = ImageFont.truetype(font_bold_path, 28)
        f_top_title = ImageFont.truetype(font_bold_path, 60)
        f_top_sub = ImageFont.truetype(font_reg_path, 32)
        f_val = ImageFont.truetype(font_bold_path, 86)

        draw.text((70, 90), tag.upper(), font=f_top_tag, fill=accent_rgb)
        draw.text((70, 138), title, font=f_top_title, fill=(248, 250, 252, 255))
        draw.text((70, 220), sub, font=f_top_sub, fill=(148, 163, 184, 255))

        p_left, p_top, p_right, p_bottom = 80, 310, 1000, 1840
        draw.rounded_rectangle([p_left, p_top, p_right, p_bottom], radius=54, fill=(22, 31, 48, 255), outline=accent_rgb, width=4)

        cx = (p_left + p_right) // 2
        draw.ellipse([cx - 210, p_top + 160, cx + 210, p_top + 580], fill=(11, 15, 25, 255), outline=(0, 230, 118, 255), width=8)
        draw.text((cx - 125, p_top + 315), "48.5°", font=f_val, fill=accent_rgb)
        draw.text((cx - 170, p_top + 650), "PEAK L: 51.2°  |  PEAK R: 47.8°", font=f_top_sub, fill=(248, 250, 252, 255))
        draw.text((cx - 150, p_top + 730), "G-FORCE: 1.33 G  |  0-100: 3.15s", font=f_top_sub, fill=(0, 230, 118, 255))

        img.save(os.path.join(out_dir, filename), "PNG")
        print(f"Generated {filename}")

    create_screenshot("1_cockpit_lean_angle.png", "Telemetría en Vivo", "Ángulo de Inclinación", "Dial de alta precisión con retención de picos Izq/Der", (239, 68, 68, 255))
    create_screenshot("2_g_force_bullseye.png", "Física Inercial SAE", "Esfera de Fuerza G 2D", "Monitoreo simultáneo de frenado y aceleración lateral", (0, 230, 118, 255))
    create_screenshot("3_hud_parabrisas.png", "Proyección Nocturna", "Modo HUD Parabrisas", "Inversión horizontal X:-1 y cronómetro 0-100 km/h", (56, 189, 248, 255))
    create_screenshot("4_reporte_pdf_firmado.png", "Certificación TrackDay", "Reportes PDF Firmados", "Exportación instantánea con firma digital del piloto", (255, 214, 0, 255))

if __name__ == "__main__":
    generate_store_assets()
