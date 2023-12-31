// 二维向量点乘
float cross2d(vec2 v, vec2 w){
    return v.x * w.y - w.x * v.y;
}

// Orthogonal matrix to convert to a uv space defined so that
// b0 goes to [0, 0] and b1 goes to [1, 0]
// 从相机坐标系到uv坐标系的转换
// 返回正交矩阵
mat3 get_xy_to_uv(vec2 b0, vec2 b1){
    // 偏移矩阵
    mat3 shift = mat3(
        1.0, 0.0, 0.0,
        0.0, 1.0, 0.0,
        -b0.x, -b0.y, 1.0
    );
    /*
    b0和b1是相机坐标系的点，经过正交变换后，b0变为[0, 0]，b1变为[1, 0]
    那么正交阵对于模长的缩放因子为length(b1 - b0)
    */
    float sf = length(b1 - b0);
    vec2 I = (b1 - b0) / sf;
    vec2 J = vec2(-I.y, I.x);
    // 旋转矩阵
    mat3 rotate = mat3(
        I.x, J.x, 0.0,
        I.y, J.y, 0.0,
        0.0, 0.0, 1.0
    );
    // 最终的变换矩阵 = 1/缩放因子 * 旋转矩阵 * 偏移矩阵
    return (1 / sf) * rotate * shift;
}


// Orthogonal matrix to convert to a uv space defined so that
// b0 goes to [0, 0] and b1 goes to [1, 0]
// 从相机坐标系到uv坐标系的转换
// 返回正交矩阵: 转换到 uv 空间
mat4 get_xyz_to_uv(vec3 b0, vec3 b1, vec3 unit_normal){
    mat4 shift = mat4(
        1, 0, 0, 0,
        0, 1, 0, 0,
        0, 0, 1, 0,
        -b0.x, -b0.y, -b0.z, 1
    );

    float scale_factor = length(b1 - b0);
    vec3 I = (b1 - b0) / scale_factor;
    vec3 K = unit_normal;
    vec3 J = cross(K, I);
    // Transpose (hence inverse) of matrix taking
    // i-hat to I, k-hat to unit_normal, and j-hat to their cross
    mat4 rotate = mat4(
        I.x, J.x, K.x, 0.0,
        I.y, J.y, K.y, 0.0,
        I.z, J.z, K.z, 0.0,
        0.0, 0.0, 0.0, 1.0
    );
    return (1 / scale_factor) * rotate * shift;
}


// Returns 0 for null curve, 1 for linear, 2 for quadratic.
// Populates new_points with bezier control points for the curve,
// which for quadratics will be the same, but for linear and null
// might change.  The idea is to inform the caller of the degree,
// while also passing tangency information in the linear case.
// float get_reduced_control_points(vec3 b0, vec3 b1, vec3 b2, out vec3 new_points[3]){
/*
points[3] 为输入参数
new_points[3] 为输出参数

对于零曲线
    new_points 均为 points[0]
    返回 0
对于单线段
    new_points[0] 为 points[0]
    new_points[1] 为 (points[0] + points[2]) / 2
    new_points[2] 为 points[2]
    返回 1
对于二次贝塞尔曲线
    new_points[i] 分别为 points[i], i = 0, 1, 2
    返回 2
*/
float get_reduced_control_points(in vec3 points[3], out vec3 new_points[3]){
    float length_threshold = 1e-6;
    float angle_threshold = 5e-2;

    vec3 p0 = points[0];
    vec3 p1 = points[1];
    vec3 p2 = points[2];
    vec3 v01 = (p1 - p0);
    vec3 v12 = (p2 - p1);

    float dot_prod = clamp(dot(normalize(v01), normalize(v12)), -1, 1);
    bool aligned = acos(dot_prod) < angle_threshold;
    bool distinct_01 = length(v01) > length_threshold;  // v01 is considered nonzero
    bool distinct_12 = length(v12) > length_threshold;  // v12 is considered nonzero
    int n_uniques = int(distinct_01) + int(distinct_12);

    bool quadratic = (n_uniques == 2) && !aligned;
    bool linear = (n_uniques == 1) || ((n_uniques == 2) && aligned);
    bool constant = (n_uniques == 0);
    if(quadratic){
        new_points[0] = p0;
        new_points[1] = p1;
        new_points[2] = p2;
        return 2.0;
    }else if(linear){
        new_points[0] = p0;
        new_points[1] = (p0 + p2) / 2.0;
        new_points[2] = p2;
        return 1.0;
    }else{
        new_points[0] = p0;
        new_points[1] = p0;
        new_points[2] = p0;
        return 0.0;
    }
}