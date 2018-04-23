Setup
=====
It’s super easy to get started:

1. Put the PixelArtCamera component anywhere in your scene (I recommend on your camera)
2. Connect the Camera and Canvas in the appropriate fields if they’re not automatically filled in.
3. Set the resolution on the PixelArtCamera component to your preference (and match the Pixels Per Unit to your texture imports, if you haven’t left it on the default ‘100’.)
4. Put a material using the ‘Ocias/Pixel Art Sprite’ shader on your sprites.

That’s it!

FAQs
====
* **Why is my font not displaying correctly?**

  Make sure you configure its import settings for pixel art. Set the asset's font size to the designed value, set the rendering mode to raster, and make sure the text object uses the same font size.

  
* **Why is my world-space canvas not displaying correctly?**

  It may not be matching your game's pixels-per-unit settings. Set the scale of your world-space canvas to (1 / Pixels-per-unit).