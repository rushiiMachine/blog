// https://www.shadertoy.com/view/NtsBzB
// https://www.shadertoy.com/view/Nlffzj
// 3D Gradient noise from: https://www.shadertoy.com/view/Xsl3Dl

#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;
uniform float u_time;

vec3 hash(vec3 p) // replace this by something better
{
    p = vec3(dot(p, vec3(127.1, 311.7, 74.7)), dot(p, vec3(269.5, 183.3, 246.1)), dot(p, vec3(113.5, 271.9, 124.6)));

    return -1.0 + 2.0 * fract(sin(p) * 43758.5453123);
}

float noise(in vec3 p) {
    vec3 i = floor(p);
    vec3 f = fract(p);

    vec3 u = f * f * (3.0 - 2.0 * f);

    return mix(mix(mix(dot(hash(i + vec3(0.0, 0.0, 0.0)), f - vec3(0.0, 0.0, 0.0)), dot(hash(i + vec3(1.0, 0.0, 0.0)), f - vec3(1.0, 0.0, 0.0)), u.x), mix(dot(hash(i + vec3(0.0, 1.0, 0.0)), f - vec3(0.0, 1.0, 0.0)), dot(hash(i + vec3(1.0, 1.0, 0.0)), f - vec3(1.0, 1.0, 0.0)), u.x), u.y), mix(mix(dot(hash(i + vec3(0.0, 0.0, 1.0)), f - vec3(0.0, 0.0, 1.0)), dot(hash(i + vec3(1.0, 0.0, 1.0)), f - vec3(1.0, 0.0, 1.0)), u.x), mix(dot(hash(i + vec3(0.0, 1.0, 1.0)), f - vec3(0.0, 1.0, 1.0)), dot(hash(i + vec3(1.0, 1.0, 1.0)), f - vec3(1.0, 1.0, 1.0)), u.x), u.y), u.z);
}

// From Unity's black body Shader Graph node
vec3 Unity_Blackbody_float(float Temperature) {
    vec3 color = vec3(255.0, 255.0, 255.0);
    color.x = 56100000. * pow(Temperature, (-3.0 / 2.0)) + 148.0;
    color.y = 100.04 * log(Temperature) - 623.6;
    if(Temperature > 6500.0)
        color.y = 35200000.0 * pow(Temperature, (-3.0 / 2.0)) + 184.0;
    color.z = 194.18 * log(Temperature) - 1448.6;
    color = clamp(color, 0.0, 255.0) / 255.0;
    if(Temperature < 1000.0)
        color *= Temperature / 1000.0;
    return color;
}

void main() {
    const float stars_threshold = 10.0; // modifies the number of stars that are visible
    const float stars_exposure = 500.0; // modifies the overall strength of the stars

    // Normalized pixel coordinates (from 0 to 1)
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;

    // Offset the map based on noise to add perspective shift
    float uvOffset = noise(vec3(uv, u_time / 5.));
    vec2 uvRemap = (gl_FragCoord.xy + uvOffset) / u_resolution.xy;

    // Stars computation:
    vec3 stars_direction = normalize(vec3(uvRemap * 2.0 - 1.0, 1.0)); // could be view vector for example
    float stars = pow(clamp(noise(stars_direction * 200.0), 0.0, 1.0), stars_threshold) * stars_exposure;

    // Star flickering
    stars *= mix(0.4, 1.4, noise(stars_direction * 100.0 + vec3(u_time / 1.)));

    // Star color by randomized temperature
    float stars_temperature = noise(stars_direction * 150.0) * 0.5 + 0.5;
    vec3 stars_color = Unity_Blackbody_float(mix(1500.0, 65000.0, pow(stars_temperature, 4.0)));

    // Output to screen
    gl_FragColor = vec4(stars_color * stars, stars);
}
