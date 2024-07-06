# 🔥 blaz

3D engine with no dependencies, all code is written from scratch

## Building

- [Install CMake >= 3.12](https://cmake.org/download/)
- ```git clone https://github.com/imadr/blaz.git```
- ```cd blaz```
- ```mkdir build && cd build```
- ```cmake ..``` to generate the build files
- ```cmake --build .``` to run the build **or** use the generated visual studio project file/makefile to build<br>You can also use **cmake-gui**

## Samples


| <b>Sample</b>                      |<b>Screenshot</b>                                                                               |
|-----------------------------------------------------|------------------------------------------------------------------------------------------------------------|
| 01-triangle           | <img src="/samples/tests/01-hellotriangle.bmp" width="300"/><br>                       |
| 02-cubes              | <img src="/samples/tests/02-cubes.bmp" width="300"/><br>                               |
| 03-pbr                | <img src="/samples/tests/03-pbr.bmp" width="300"/><br>                                 |
| 04-raymarching        | <img src="/samples/tests/04-raymarching.bmp" width="300"/><br>                         |
| 05-raytracing         | <img src="/samples/tests/05-raytracing.bmp" width="300"/><br>                          |
| 06-physics            | <img src="/samples/tests/06-physics.bmp" width="300"/><br>                             |

## Building for web

- Install [emscripten](https://emscripten.org/)
- ```emsdk_env.bat``` or ```emsdk_env.sh```
- ```mkdir build_wasm && cd build_wasm```
- ```emcmake cmake ..```
- ```cmake --build .```
- To build a specific sample ```cmake --build . --target "01-hellotriangle"```
