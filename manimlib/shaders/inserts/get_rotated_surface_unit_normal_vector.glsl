// Assumes the following uniforms exist in the surrounding context:
// uniform vec3 camera_offset;
// uniform mat3 camera_rotation;

/*
从函数的实现来看，du_point和dv_point是在世界坐标系下的点
且和point距离很近

类似于求曲线在point的切线，需要在point附近再取一个点
*/
vec3 get_rotated_surface_unit_normal_vector(vec3 point, vec3 du_point, vec3 dv_point){
    vec3 cp = cross(
        (du_point - point),
        (dv_point - point)
    );
    if(length(cp) == 0){
        // Instead choose a normal to just dv_point - point in the direction of point
        vec3 v2 = dv_point - point;
        cp = cross(cross(v2, point), v2);
    }
    /*
    rotate_point_into_frame函数定义在position_point_into_frame.glsl文件中
    作用是将法向量从世界坐标系转换到相机坐标系
    */
    return normalize(rotate_point_into_frame(cp));
}