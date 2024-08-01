#version 430 core

layout(location = 0) in vec3 a_position;
layout(location = 1) in vec3 a_normal;
layout(location = 2) in vec2 a_texcoord;

layout(std140, binding = 0) uniform u_mat {
    mat4 u_model_mat;
    mat4 u_view_mat;
    mat4 u_projection_mat;
};

layout(std140, binding = 1) uniform u_light {
    vec3 u_light_position;
    mat4 u_light_view_mat;
    mat4 u_light_projection_mat;
};

out vec3 v_world_position;
out vec4 v_light_space_position;
out vec3 v_normal;

void main() {
    vec3 world_position = vec3(u_model_mat * vec4(a_position, 1.0));
    vec4 v_position = u_projection_mat * u_view_mat * vec4(world_position, 1.0);
    v_world_position = world_position;
    v_light_space_position = u_light_projection_mat * u_light_view_mat * vec4(world_position, 1.0);
    v_normal = a_normal;
    gl_Position = v_position;
}