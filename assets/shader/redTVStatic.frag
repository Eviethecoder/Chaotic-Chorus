// TV Static Shader with Red Tint, Variable Intensity, and Half Visibility

// Define the precision for floating point numbers
#ifdef GL_ES
precision highp float;
#endif

// Uniforms (variables that remain constant for all vertices of a single primitive)
uniform vec2 resolution; // Resolution of the screen
uniform float time; // Time since the shader started running
uniform float amount; // Intensity of the static effect (0.0 - 1.0)

// Function to generate pseudo-random noise
float random(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

void main() {
    // Calculate the normalized pixel coordinates (from -1 to 1)
    vec2 uv = (2.0 * gl_FragCoord.xy - resolution) / min(resolution.x, resolution.y);
    
    // Generate noise based on pixel position and time
    float noise = random(floor(gl_FragCoord.xy) + time);
    
    // Scale the noise by the amount variable
    noise *= amount;
    
    // Create color variation using noise, with slight red tint
    vec3 staticColor = vec3(0.5 + noise * 0.5, 0.0, 0.0);
    
    // Output the final color with adjusted visibility
    gl_FragColor = vec4(staticColor, 0.5 + noise * 0.5); // Adjusted visibility
}
