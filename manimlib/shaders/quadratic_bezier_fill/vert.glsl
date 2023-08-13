#version 330

#INSERT camera_uniform_declarations.glsl

in vec3 point;       // 从 manim 传入的顶点坐标（默认世界坐标）
in vec3 unit_normal; // 单位法向量（世界坐标）
in vec4 color;       // 顶点颜色
in float vert_index; // 顶点索引

out vec3 bp;                    // Bezier control point
out vec3 v_global_unit_normal;  // 传给 geom 单位法向量（好奇：为何取名global）
out vec4 v_color;               // 传给 geom 顶点颜色
out float v_vert_index;         // 传给 geom 顶点索引

// Analog of import for manim only
#INSERT position_point_into_frame.glsl

void main(){
    /*
    这里进一步验证了一个猜测: manim传入的顶点坐标原生就是在世界坐标系
    */
    bp = position_point_into_frame(point);
    v_global_unit_normal = rotate_point_into_frame(unit_normal);
    v_color = color;
    v_vert_index = vert_index;
}