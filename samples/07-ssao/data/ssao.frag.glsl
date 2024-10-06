#version 430 core

precision highp float;

layout(location = 0) in vec4 v_view_position;
layout(location = 1) in vec3 v_world_position;
layout(location = 2) in vec3 v_world_normal;
layout(location = 3) in vec3 v_world_tangent;

layout(location = 0) out vec4 o_color;

layout(std140, binding = 0) uniform u_mat {
    mat4 u_model_mat;
    mat4 u_view_mat;
    mat4 u_projection_mat;
};

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

float linearize_depth(float depth) {
    float z_near = 0.1;
    float z_far = 2000.0;
    return (2.0 * z_near) / (z_far + z_near - depth * (z_far - z_near));
}

#define NUM_SAMPLES 64
#define SSAO_BIAS 0.00005
#define SSAO_RADIUS 0.05

void main() {
    uint rng_state = uint(gl_FragCoord.x) * 984894 + uint(gl_FragCoord.y) * 184147;

    vec3 normal = normalize(v_world_normal);

    vec3 view_pos = v_view_position.xyz / v_view_position.w;
    view_pos = view_pos * 0.5 + 0.5;

    float occlusion = 0.0;
    for (int i = 0; i < NUM_SAMPLES; i++) {
        vec3 random_direction = random_unit_vector_on_hemisphere(rng_state, normal);

        vec3 world_space_rand = v_world_position + random_direction * SSAO_RADIUS;

        vec4 view_space_rand_proj = (u_projection_mat * u_view_mat * vec4(world_space_rand, 1.0));
        vec3 view_space_rand = view_space_rand_proj.xyz / view_space_rand_proj.w;
        view_space_rand = view_space_rand * 0.5 + 0.5;

        float sample_depth = texture(u_sampler_depth, view_space_rand.xy).x;

        occlusion += view_pos.z > sample_depth + SSAO_BIAS ? 1.0 : 0.0;
    }
    occlusion /= NUM_SAMPLES;

    o_color = vec4(vec3(1.0 - occlusion), 1.0);
    //     vec3 world_position = vec3(u_model_mat * vec4(a_position, 1.0));
    // v_world_position = world_position;
    // gl_Position = u_projection_mat * u_view_mat * vec4(world_position, 1.0);
    // v_view_position = (u_projection_mat * u_view_mat * vec4(world_position, 1.0));
    // mat3 inv_model = mat3(transpose(inverse(u_model_mat)));
    // v_world_normal = inv_model * a_normal;
    // v_world_tangent = inv_model * a_tangent;

    // vec3 random_direction = random_unit_vector_on_hemisphere(rng_state, normal);

    // vec3 world_pos_rand_dir = v_world_position + random_direction * SSAO_RADIUS;

    // vec4 view_pos_rand_dir_4 = (u_projection_mat * u_view_mat * vec4(world_pos_rand_dir, 1.0));
    // vec3 view_pos_rand_dir = view_pos_rand_dir_4.xyz / view_pos_rand_dir_4.w;
    // view_pos_rand_dir = view_pos_rand_dir * 0.5 + 0.5;

    // // vec2 sample_pos = view_pos.xy;
    // vec2 sample_pos = view_pos_rand_dir.xy;
    // o_color = vec4(vec3(linearize_depth(texture(u_sampler_depth, sample_pos).x) * 100.0), 1.0);
}