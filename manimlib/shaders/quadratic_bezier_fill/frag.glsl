#version 330

#INSERT camera_uniform_declarations.glsl

// 一个极其重要的猜测！！！
// 几何着色器的输出是片段着色器的输入，有一些细节需要考虑
// 因为几何着色器可以看到整个图元，比如完整的3个点
// 那么几何着色器的输出可以分为两类
// 第一类：以color和uv_coords为代表
// 几何着色器会计算3个点的color和uv_coords，并传给片段着色器
// 因为光栅化阶段拿到的3个color和uv_coords，那么就会自动自动插值
// 得到每一个像素的color和uv_coords
// 第二类：以uv_b2和bezier_degree为代表
// 对于图元中的每个点，这三个值是一样的
// 所以不论插值与否, 传到片段着色器的时候, 同一个图元内部的
// uv_b2和bezier_degree值是一样的
// 从这种角度来看，上面的两类似乎又统一了
// 举个例子：假设几何着色器输出了3个点
// p1(color1, uv_coords1, uv_b2, bezier_degree)
// p2(color2, uv_coords2, uv_b2, bezier_degree)
// p3(color3, uv_coords3, uv_b2, bezier_degree)
// 这个图元被光栅化器处理后，会对图元内的每一个像素进行插值
// color和uv_coords会随着像素位置变化而变化
// uv_b2和bezier_degree不随像素位置变化而变化

// vertex shader --> geometry shader --> rasterizer --> fragment shader
// 顶点着色器只能看到每个点, 片段着色器只能看到每个像素
// 几何着色器和光栅化器都能看到整个图元

// 这里引入几何着色器有两个目的
// 目的一(次要): 将部分图元顶点数由3个变成5个
// 目的二(主要): 因为几何着色器可以看见整个图元，我们需要针对每个图元做些计算并将计算结果传给光栅化器和片段着色器
// 有些变量在图元范围内应该保持不变，比如uv_b2，不同的图元之间可以变化
// 这种功能只能由几何着色器实现(顶点着色器看不见整个图元)

// 片段着色器中每个像素的属性是由图元的几个顶点的属性插值得到的
// 当图元的每个顶点的某个属性一样的时候，那么这个属性对于图元内每个像素都是不变的
// 比如图元1， bezier_degree = 1; 图元2， bezier_degree = 2
// 实现图元范围内的属性不变必须引入几何着色器

in vec4 color;
in float fill_all;  // Either 0 or 1
in float uv_anti_alias_width;

in vec3 xyz_coords;
in float orientation;

in vec2 uv_coords; 
in vec2 uv_b2;
in float bezier_degree;

out vec4 frag_color;

// Needed for quadratic_bezier_distance insertion below
float modify_distance_for_endpoints(vec2 p, float dist, float t){
    return dist;
}

#INSERT quadratic_bezier_distance.glsl


float sdf(){
    if(bezier_degree < 2){
        return abs(uv_coords[1]);
    }
    float u2 = uv_b2.x;
    float v2 = uv_b2.y;
    // For really flat curves, just take the distance to x-axis
    if(abs(v2 / u2) < 0.1 * uv_anti_alias_width){
        return abs(uv_coords[1]);
    }
    // For flat-ish curves, take the curve
    else if(abs(v2 / u2) < 0.5 * uv_anti_alias_width){
        /*
        通过这个函数的调用，可以猜测出:
        uv_coords: 当前像素点的uv坐标
        uv_b2: 贝塞尔曲线的第三个控制点（前两个固定在(0,0)和(0,1)，所以曲线的形状完全由uv_b2决定）
        */
        return min_dist_to_curve(uv_coords, uv_b2, bezier_degree);
    }
    // I know, I don't love this amount of arbitrary-seeming branching either,
    // but a number of strange dimples and bugs pop up otherwise.

    // This converts uv_coords to yet another space where the bezier points sit on
    // (0, 0), (1/2, 0) and (1, 1), so that the curve can be expressed implicityly
    // as y = x^2.
    mat2 to_simple_space = mat2(
        v2, 0,
        2 - u2, 4 * v2
    );
    vec2 p = to_simple_space * uv_coords;
    // Sign takes care of whether we should be filling the inside or outside of curve.
    float sgn = orientation * sign(v2);
    float Fp = (p.x * p.x - p.y);
    if(sgn * Fp < 0){
        return 0.0;
    }else{
        return min_dist_to_curve(uv_coords, uv_b2, bezier_degree);
    }
}


void main() {
    if (color.a == 0) discard;
    frag_color = color;
    if (fill_all == 1.0) return;
    /*
    sdf(): uv空间下的当前像素点uv_coords到贝塞尔曲线的距离
    uv_anti_alias_width: uv空间下的抗锯齿宽度
    */
    frag_color.a *= smoothstep(1, 0, sdf() / uv_anti_alias_width);
}
