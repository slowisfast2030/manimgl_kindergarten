#version 330

/*
uniform vec2 frame_shape;
uniform float anti_alias_width;
uniform vec3 camera_offset;
uniform mat3 camera_rotation;
uniform float is_fixed_in_frame;
uniform float focal_distance;

这些uniform变量会在
get_gl_Position
position_point_into_frame
函数中使用
*/
#INSERT camera_uniform_declarations.glsl

uniform sampler2D Texture;

in vec3 point;
in vec2 im_coords;
in float opacity;

/*
v_im_coords和v_opacity是可变类型的。
它们是顶点着色器的输出变量，在传递到片段着色器之前会被插值。

在顶点着色器中，输出变量默认是可变的，因此不需要显式声明。
*/
out vec2 v_im_coords;
out float v_opacity;

// Analog of import for manim only
#INSERT get_gl_Position.glsl
#INSERT position_point_into_frame.glsl

// 一个猜想：这里的point已经在world space
// 通过position_point_into_frame把point转换到camera space
// 通过get_gl_Position把camera space的point转换到clip space
void main(){
    v_im_coords = im_coords;
    v_opacity = opacity;
    gl_Position = get_gl_Position(position_point_into_frame(point));
}