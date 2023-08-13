#version 330

#INSERT camera_uniform_declarations.glsl

in vec3 point;
in vec3 unit_normal;
in vec4 color;
in float vert_index;

out vec3 bp;  // Bezier control point
out vec3 v_global_unit_normal;
out vec4 v_color;
out float v_vert_index;

// Analog of import for manim only
#INSERT position_point_into_frame.glsl

void main(){
    /*
    从 manim 传入的顶点坐标
    这里进一步验证了一个猜测: manim传入的顶点坐标原生就是在世界坐标系
    */
    bp = position_point_into_frame(point);
    v_global_unit_normal = rotate_point_into_frame(unit_normal);
    v_color = color;
    v_vert_index = vert_index;
}