
# TiPixelReader Module

## Description

Titanium iOS and Android modules for reading a local image and getting the RGB values of each pixel.



Data is returned in a callback containing an array of 'lines'. 

Each 'line' is an array of uints, where the first (0) item is the line number and the rest are the RGBRGBRGBRGB.. etc values for the pixels on that line. 



(This data is then used by another app to send this data to an RGB LED Matrix using the `ti.bluetooth` module to an ESP32-powered device attached to the Matrix)



See example app.js. 

Or TiPixelReaderApp in neighbouring folder in this repo. 

## Author

@Kosso 

## License

MIT


