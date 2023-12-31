#version 330

/*
uniform vec2 frame_shape;         // 帧大小
uniform float anti_alias_width;   // 抗锯齿宽度
uniform vec3 camera_offset;       // 相机偏移量
uniform mat3 camera_rotation;     // 相机旋转矩阵
uniform float is_fixed_in_frame;  // 是否固定在场景中
uniform float focal_distance;     // 焦距

cam_coords = vec3(0, 0, focal_distance);
在相机坐标系中，相机的坐标

这些uniform变量会在
get_gl_Position
position_point_into_frame
函数中使用

这些uniform变量定义在camera.py文件中的Camera类中
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
/*
get_gl_Position函数将点从相机空间转换为裁剪空间。
*/
#INSERT get_gl_Position.glsl
/*
position_point_into_frame函数将点从世界空间转换为相机空间。
*/
#INSERT position_point_into_frame.glsl

void main(){
    v_im_coords = im_coords;
    v_opacity = opacity;
    /*
    gl_Position in the vertex shader is typically expected to be in clip space, 
    which ranges from -1 to 1 in all three dimensions.
    ???
    */
    gl_Position = get_gl_Position(position_point_into_frame(point));
}

/*
#version 330 core

layout(location = 0) in vec3 inPosition; // Input vertex position in object space

uniform mat4 modelViewProjection; // Combined model, view, and projection matrix

void main()
{
    // Transform the vertex position to clip space
    gl_Position = modelViewProjection * vec4(inPosition, 1.0);
}
*/