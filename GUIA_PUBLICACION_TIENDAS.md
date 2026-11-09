# 🚀 Guía Maestra de Publicación en Tiendas: MotoAngleHUD Pro (Google Play & Apple App Store)

Esta guía detalla los pasos y recursos generados para publicar **MotoAngleHUD Pro** (`com.simpleappspg.motoanglehud`) bajo el modelo **Camino 1: App de Pago (100% Pro Desbloqueado, sin paywall ni anuncios)**.

---

## 📦 1. Recursos Listos en el Repositorio

| Recurso | Ubicación | Descripción |
| :--- | :--- | :--- |
| **Application ID / Package** | `com.simpleappspg.motoanglehud` | Identificador único en Android & iOS. |
| **Keystore de Producción** | `android/app/upload-keystore.jks` | Firma criptográfica configurada en `android/key.properties`. |
| **Generador de Ícono 1024x1024** | `generate_icon.py` | Genera `assets/icon/app_icon.png` con diseño Racing Red & Neon Green. |
| **Generador de Store Assets** | `generate_store_assets.py` | Genera `icon_512.png`, `feature_graphic_1024x500.png` y 4 capturas 1080x1920 en `store_assets/`. |
| **Política de Privacidad** | `privacy_policy.html` | Documento HTML listo para alojar en GitHub Pages. |

---

## 🤖 2. Configuración en Google Play Console

1. **Modelo de Monetización (Camino 1 - Paid App):**
   - Selecciona **Aplicación de Pago** en Google Play Console (ej. `$3.99 USD` o `$4.99 USD` pago único).
   - Al no contener anuncios ni compras integradas (In-App Purchases), la declaración de contenido en Play Console es inmediata y transparente para los revisores.
2. **Ficha de Play Store:**
   - **Título:** `MotoAngleHUD Pro: Lean & G-HUD`
   - **Descripción Corta:** `Inclinómetro de moto, fuerza G 2D, HUD espejo parabrisas y reportes PDF.`
   - **Gráficos:** Sube los recursos ubicados en la carpeta `store_assets/`.

---

## 🛠️ 3. Comandos de Verificación y Compilación

```bash
# Regenerar ícono y assets de tienda
python generate_icon.py
dart run flutter_launcher_icons
python generate_store_assets.py

# Ejecutar análisis estático y tests
C:\flutter\bin\flutter.bat analyze
C:\flutter\bin\flutter.bat test

# Compilar Android App Bundle (.aab) de producción
C:\flutter\bin\flutter.bat build appbundle --release
```
