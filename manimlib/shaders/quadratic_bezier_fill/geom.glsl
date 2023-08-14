#version 330

layout (triangles) in; // 输入图元
layout (triangle_strip, max_vertices = 5) out; // 输出图元

uniform float anti_alias_width; // 抗锯齿宽度

// Needed for get_gl_Position
uniform vec2 frame_shape;
uniform float focal_distance;
uniform float is_fixed_in_frame;
// Needed for finalize_color
uniform vec3 light_source_position;
uniform vec3 camera_position;
uniform float reflectiveness;
uniform float gloss;
uniform float shadow;

/*
After the vertex shader stage in graphics programming, 
triangulation refers to the process of converting polygons 
with more than three indices into triangles. 

前面说过，对于拥有24个控制点的circle来说，顶点着色器会输出24个顶点
进入到几何着色器之前，这24个控制点会被分成8个三角形
这里的layout (triangles) in;就是指的这个过程
每一个几何着色器处理的是这8个三角形中的一个
*/
in vec3 bp[3]; // 贝塞尔控制点
in vec3 v_global_unit_normal[3]; // 单位法向量
in vec4 v_color[3]; // 颜色
in float v_vert_index[3]; // 顶点索引

out vec4 color; // 计算后的颜色（光照、阴影等）
out float fill_all; // 是否填充
out float uv_anti_alias_width; // uv坐标下的抗锯齿宽度

out vec3 xyz_coords;
out float orientation;

// uv space is where b0 = (0, 0), b1 = (1, 0), and transform is orthogonal
// 特别解释了uv空间
out vec2 uv_coords;
out vec2 uv_b2;
out float bezier_degree;


// Analog of import for manim only
#INSERT quadratic_bezier_geometry_functions.glsl
#INSERT get_gl_Position.glsl
#INSERT get_unit_normal.glsl
#INSERT finalize_color.glsl


void emit_vertex_wrapper(vec3 point, int index){
    color = finalize_color(
        v_color[index],
        point,
        v_global_unit_normal[index],
        light_source_position,
        camera_position,
        reflectiveness,
        gloss,
        shadow
    );
    // 3b1b好像默认xyz_coords是相机空间
    xyz_coords = point;
    // 映射到裁剪空间
    gl_Position = get_gl_Position(xyz_coords);
    EmitVertex();
}


// 需要注意，这里的bp已经转到了相机坐标系
void emit_simple_triangle(){
    for(int i = 0; i < 3; i++){
        emit_vertex_wrapper(bp[i], i);
    }
    EndPrimitive();
}


void emit_pentagon(vec3[3] points, vec3 normal){
    vec3 p0 = points[0];
    vec3 p1 = points[1];
    vec3 p2 = points[2];
    // Tangent vectors
    vec3 t01 = normalize(p1 - p0);
    vec3 t12 = normalize(p2 - p1);
    // Vectors perpendicular to the curve in the plane of the curve pointing outside the curve
    vec3 p0_perp = cross(t01, normal);
    vec3 p2_perp = cross(t12, normal);

    bool fill_inside = orientation > 0;
    float aaw = anti_alias_width;
    vec3 corners[5];
    if(fill_inside){
        // Note, straight lines will also fall into this case, and since p0_perp and p2_perp
        // will point to the right of the curve, it's just what we want
        corners = vec3[5](
            p0 + aaw * p0_perp,
            p0,
            p1 + 0.5 * aaw * (p0_perp + p2_perp),
            p2,
            p2 + aaw * p2_perp
        );
    }else{
        corners = vec3[5](
            p0,
            p0 - aaw * p0_perp,
            p1,
            p2 - aaw * p2_perp,
            p2
        );
    }

    mat4 xyz_to_uv = get_xyz_to_uv(p0, p1, normal);
    uv_b2 = (xyz_to_uv * vec4(p2, 1)).xy;
    uv_anti_alias_width = anti_alias_width / length(p1 - p0);

    for(int i = 0; i < 5; i++){
        vec3 corner = corners[i];
        uv_coords = (xyz_to_uv * vec4(corner, 1)).xy;
        int j = int(sign(i - 1) + 1);  // Maps i = [0, 1, 2, 3, 4] onto j = [0, 0, 1, 2, 2]
        emit_vertex_wrapper(corner, j);
    }
    EndPrimitive();
}


void main(){
    // If vert indices are sequential, don't fill all
    /*
    这里需要特别注意，传入几何着色器的是三角形图元
    图元的顶点索引若是连续，则是弓形
    不连续，则是三角形
    */
    fill_all = float(
        (v_vert_index[1] - v_vert_index[0]) != 1.0 ||
        (v_vert_index[2] - v_vert_index[1]) != 1.0
    );

    // 图元顶点索引不连续，三角形
    if(fill_all == 1.0){
        emit_simple_triangle();
        return;
    }

    // 图元顶点索引连续，弓形
    vec3 new_bp[3];
    // 三个点的空间位置有3种情况：重合、共线、共面
    bezier_degree = get_reduced_control_points(vec3[3](bp[0], bp[1], bp[2]), new_bp);
    // 假设三点共面，计算单位法向量
    vec3 local_unit_normal = get_unit_normal(new_bp);
    // 这个orientation的几何意义是什么？在三点共面的情况下，两个向量垂直
    orientation = sign(dot(v_global_unit_normal[0], local_unit_normal));

    if(bezier_degree >= 1){
        emit_pentagon(new_bp, local_unit_normal);
    }
    // Don't emit any vertices for bezier_degree 0
}

