// TiPixelReader Example app
// @Kosso 2019 

var tipixelreader = require('com.kosso.tipixelreader');
Ti.API.info("module is => " + tipixelreader);

var win = Ti.UI.createWindow({
	backgroundColor:'white'
});
var label = Ti.UI.createLabel({
	top:20,
	text:'TiPixelReader Example'
});
win.add(label);

var btn_img = Ti.UI.createButton({
    top: 50,
    borderColor: 'white',
    title: 'Get Pixel Data'
});
btn_img.addEventListener('click', function (e) {

	// In this example, images need to be in the root Resources folder. 
    var image_ = 'test_64x32.gif';
    
    var f = Ti.Filesystem.getFile(Ti.Filesystem.resourcesDirectory, image);
    if (!f.exists()) {
        Ti.API.info('Image file does not exist: '+image);
    } else {
        Ti.API.warn('image file OK : ' + f.nativePath);
        var ft = Ti.Filesystem.getFile(Ti.Filesystem.tempDirectory, image);
        if (ft.exists()) {
            ft.deleteFile();
        }
        ft = null;
		// Need to copy image to temp directory (mainly for Android, but will work for iOS too)
        if(f.copy(Ti.Filesystem.tempDirectory + image)){
            Ti.API.info('test file copied to temp dir');
            inspector.getImagePixels(Ti.Filesystem.tempDirectory + image, function (response) {
				
				
				Ti.API.info('response pixel data lines: ', response.lines.length);
				// An array of 'lines'.
				// Each line is an array of uints. 
				// The first entry (0) is the line number. The rest is RGBRGBRGBRGBRGBRGBRGBRGBRGB.. etc. 
                response.lines.forEach(function(line){
                    console.log(line[0], line.length);

                });
				// DONE! 

				// Now this can be sent to an ESP32 powered RGB LED Matrix over BLE, line-by-line...
				// See another test app to follow soon, using Ti.Bluetooth ...

			});
        } else {
            Ti.API.warn('Image file copy failed to : ' + Ti.Filesystem.tempDirectory + image);
        }
    }
});

win.add(btn_img);

win.open();



