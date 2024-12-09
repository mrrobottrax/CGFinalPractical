# Shader 1: Colour Correction
[Assets/Shaders/LUT.shader](Assets/Shaders/LUT.shader)

Colour correction is acheived by using a look up table. This implementation expands on the examples from class by using a 3D texture for more accurate sampling.

![](docs/tex.png)

The current LUT applied has higher brightness and saturation to make the game look more cartoony.

![](docs/no-lut.png)  
(before)

![](docs/lut.png)  
(after)

# Shader 2: Hologram
[Assets/Shaders/Hologram.shader](Assets/Shaders/Hologram.shader)

The hologram consists of standard half Lambertain shader, rim lighting, and a scrolling texture to control the alpha.

![](docs/holo.png)

Unlike the example in class, this version uses a custom texture for the scrolling lines, allowing for all sorts of visual effects.

This is the texture used currently:

![](Assets/holo.png)

# Shader 3: Rim Light
[Assets/Shaders/Rim.shader](Assets/Shaders/Rim.shader)

This shader uses a rim light to make Mario stand out against the background, and add more definition to his shape.

![](docs/rim.png)

# Shader 4: Star Powerup
[Assets/Shaders/Star.shader](Assets/Shaders/Star.shader)

This shader emulates the effect of Mario favourite powerup by cycling his hue over time.

![](docs/star.png)

This is done by using time as the hue parameter of this function:

![](docs/graph.png)

This function was made by plotting out where the peaks of each colour are when crossfading between the primary colours (with the assumption that they would be saturated later):

(1, 0, 0) at 0  
(1, 1, 0) at 1/6  
(0, 1, 0) at 2/6  
(0, 1, 1) at 3/6  
(0, 0, 1) at 4/6  
(1, 0, 1) at 5/6  
(1, 0, 0) at 1  

# General: Half Lambert

Rather than getting the Lambertian term just by taking the saturated dot product of the normal and light direction, the half Lambertian technique multiplies this term by 0.5, adds 0.5, then applies a power of 2. This results in a softer gradient, which gives more definition to the parts of the shape that face away from the light. I decided to use this because of the cartoonish nature of the game, favouring readability over realism.

![](docs/half-lambert.png)