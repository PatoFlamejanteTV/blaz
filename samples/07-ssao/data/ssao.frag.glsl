#version 430 core

precision highp float;

layout(location = 0) in vec3 v_position;
layout(location = 1) in vec3 v_world_position;
layout(location = 2) in vec3 v_world_normal;
layout(location = 3) in vec3 v_world_tangent;

layout(location = 0) out vec4 o_color;

layout(binding = 1) uniform sampler2D u_sampler_depth;

uint next_random(inout uint rng_state) {
    rng_state = rng_state * 747796405 + 2891336453;
    uint result = ((rng_state >> ((rng_state >> 28) + 4)) ^ rng_state) * 277803737;
    result = (result >> 22) ^ result;
    return result;
}

float random(inout uint rng_state) {
    return next_random(rng_state) / 4294967295.0;
}

vec3 random_unit_vector(inout uint rng_state) {
    float rand1 = random(rng_state);
    float rand2 = random(rng_state);

    float theta = rand1 * 2.0 * 3.14159265358979323846;
    float phi = acos(2.0 * rand2 - 1.0);

    float x = sin(phi) * cos(theta);
    float y = sin(phi) * sin(theta);
    float z = cos(phi);

    return normalize(vec3(x, y, z));
}

vec3 random_unit_vector_on_hemisphere(inout uint rng_state, vec3 normal) {
    vec3 v = random_unit_vector(rng_state);
    if (dot(v, normal) > 0.0) {
        return v;
    } else {
        return -v;
    }
}

void main() {
    uint rng_state = uint(gl_FragCoord.x) * 984894 + uint(gl_FragCoord.y) * 184147;

    vec3 normal = normalize(v_world_normal);
    // vec3 tangent = normalize(v_world_tangent);
    // tangent = normalize(tangent - dot(tangent, normal) * normal);
    // vec3 bitangent = cross(tangent, normal);
    // mat3 tbn_matrix = mat3(tangent, bitangent, normal);

    // vec3 random_direction = random_unit_vector_on_hemisphere(rng_state, normal);
    vec3 random_direction = random_unit_vector(rng_state);
    vec3 new_pos = v_world_position + random_direction;

    float occlusion = 0.0;
    for (int i = 0; i < 10; i++) {
        float depth = gl_FragCoord.z;
        occlusion += new_pos.z > depth ? 1.0 : 0.0;
    }
    occlusion /= 10.0;

    // o_color = vec4(vec3(normal), 1.0);
    // o_color = vec4(vec3(texture(u_sampler_depth, gl_FragCoord.xy).x) / 3.0, 1.0);
    vec2 uv = gl_FragCoord.xy / vec2(textureSize(u_sampler_depth, 0));
    o_color = vec4(uv, 0.0, 1.0);
}