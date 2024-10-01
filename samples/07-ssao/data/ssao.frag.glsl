#version 430 core

precision highp float;

layout(location = 0) in vec4 v_view_position;
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

#define NUM_SAMPLES 10
#define SSAO_BIAS 0.00005
#define SSAO_RADIUS 0.01

void main() {
    uint rng_state = uint(gl_FragCoord.x) * 984894 + uint(gl_FragCoord.y) * 184147;

    vec3 normal = normalize(v_world_normal);

    vec3 view_pos = v_view_position.xyz / v_view_position.w;
    view_pos = view_pos * 0.5 + 0.5;

    float occlusion = 0.0;
    for (int i = 0; i < NUM_SAMPLES; i++) {
        vec3 random_direction = random_unit_vector_on_hemisphere(rng_state, normal);

        vec3 sample_pos = view_pos + random_direction * SSAO_RADIUS;

        float sample_depth = texture(u_sampler_depth, sample_pos.xy).x;

        occlusion += view_pos.z > sample_depth + SSAO_BIAS ? 1.0 : 0.0;
    }
    occlusion /= NUM_SAMPLES;

    o_color = vec4(vec3(1.0 - occlusion), 1.0);
}