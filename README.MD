Unity Pixel Art Camera
======================
Solves the key issues with pixel art rendering in Unity with no headaches.
1. Displays sprites without distortion
2. Enforces a consistent pixel size
3. Conforms to a pixel grid
4. Retains position stability while camera moves
5. Fills the screen in a predictable way
6. Avoids floating point precision errors

Setup
-----
It’s super easy to get started:

1. Put the PixelArtCamera component anywhere in your scene (I recommend on your camera)
2. Connect the Camera and Canvas in the appropriate fields if they’re not automatically filled in.
3. Set the resolution on the PixelArtCamera component to your preference (and match the Pixels Per Unit to your texture imports, if you haven’t left it on the default ‘100’.)
4. Put a material using the ‘Ocias/Pixel Art Sprite’ shader on your sprites.

That’s it!