# VecDraw by Topz

Initial native Android foundation for an offline vector editor.

- Native Kotlin Android application
- Minimum Android 10 (API 29); designed for Android 11 compatibility
- No INTERNET permission and no runtime network calls
- Dark editor shell with starter Pick, Pen, Rectangle, Ellipse, Undo and Clear tools
- Build: `gradle :app:assembleDebug`

## Update ZIP workflow

Place files in `update.zip` using paths relative to the repository root. The GitHub Actions workflow extracts the ZIP over the checked-out repository and builds the APK. Files not included in the ZIP remain unchanged.

The workflow must be installed in `.github/workflows/unpack.yml` on the default branch once before push-triggered ZIP updates can run.
