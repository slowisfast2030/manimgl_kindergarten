// Assumes the following uniforms exist in the surrounding context:
// uniform float is_fixed_in_frame;
// uniform vec3 camera_offset;
// uniform mat3 camera_rotation;

/*
将一个点从世界空间转换到相机空间
将点减去相机偏移量并将其旋转到相机方向

相机偏移量是相机在世界空间中的位置
*/
vec3 rotate_point_into_frame(vec3 point){
    if(bool(is_fixed_in_frame)){
        return point;
    }
    return camera_rotation * point;
}


vec3 position_point_into_frame(vec3 point){
    if(bool(is_fixed_in_frame)){
        return point;
    }
    return rotate_point_into_frame(point - camera_offset);
}
