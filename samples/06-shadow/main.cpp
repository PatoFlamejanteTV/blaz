#include "error.h"
#include "game.h"
#include "logger.h"
#include "mesh.h"

using namespace blaz;

int main() {
    Window window;
    Error err = window.init("06-shadow");
    if (err) {
        logger.error(err);
        return 1;
    }

    Renderer renderer;
    err = renderer.init(&window);
    if (err) {
        logger.error(err);
        return 1;
    }

    Scene scene;
    init_scene(&scene);

    Game game;
    game.m_window = &window;
    game.m_renderer = &renderer;
    game.m_scene = &scene;
    err = game.load_game("data/game.cfg");
    if (err) {
        logger.error(err);
    }

    make_cube(&renderer.m_meshes["cube_mesh"]);
    make_plane(&renderer.m_meshes["plane_mesh"]);

    renderer.create_uniform_buffer(UniformBuffer{
        .m_name = "u_light",
        .m_uniforms =
            {
                Uniform{
                    .m_name = "u_light_position",
                    .m_type = UNIFORM_VEC3,
                },
                Uniform{
                    .m_name = "u_light_rotation",
                    .m_type = UNIFORM_VEC4,
                },
            },
        .m_should_reload = true,
    });

    str node = renderer.m_cameras["light_camera"].m_node;
    renderer.set_uniform_buffer_data("u_light", "u_light_position", scene.m_nodes[node].m_position);
    renderer.set_uniform_buffer_data("u_light", "u_light_rotation", scene.m_nodes[node].m_rotation);

    game.main_camera->m_orbit_pan_sensitivity = 0.005f;

    window.m_mouse_click_callback = [&game](Vec2I mouse_position, ButtonState left_button,
                                            ButtonState right_button) {
        if (left_button == ButtonState::PRESSED) {
            game.main_camera->m_mouse_left_pressed = true;
        } else if (left_button == ButtonState::RELEASED) {
            game.main_camera->m_mouse_left_pressed = false;
        }

        if (right_button == ButtonState::PRESSED) {
            game.main_camera->m_mouse_right_pressed = true;
        } else if (right_button == ButtonState::RELEASED) {
            game.main_camera->m_mouse_right_pressed = false;
        }
    };

    window.m_mouse_move_raw_callback = [&game](Vec2I delta) {
        game.main_camera->orbit_mouse_move(delta);
    };

    window.m_mouse_wheel_callback = [&game](i16 delta) {
        game.main_camera->orbit_mouse_wheel(delta);
    };

    game.m_main_loop = [&game]() {
        if (game.m_window->event_loop()) {
            game.m_renderer->update();

            return true;
        }
        return false;
    };

    game.run();

    return 0;
}