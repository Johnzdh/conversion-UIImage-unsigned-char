# Conversion
The type of ARKit camera raw data is `unsigned char*`.

If you want to use the camera data as input to CoreML model, you should convert it to `UIImage*`.

This repository supports following types conversion:

- ARGB
- RGBA
- GRAY 