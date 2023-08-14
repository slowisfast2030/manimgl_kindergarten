#version 330

#INSERT camera_uniform_declarations.glsl

/*
这里可以假设我们要绘制的是circle
在manim中，circle是由8段贝塞尔曲线组成的
每段贝塞尔曲线由3个控制点组成
因此，我们需要24个控制点

这里我们需要假设:
我们不仅传入了每个点的坐标，还传入了每个点法向量(可以提前计算出来)、颜色、索引
*/
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
    将point和unit_normal转换到相机坐标系中

    position_point_into_frame和rotate_point_into_frame两个函数区别在于
    后者没有平移操作，当然向量也不需要平移操作
    */
    bp = position_point_into_frame(point);
    v_global_unit_normal = rotate_point_into_frame(unit_normal);
    v_color = color;
    v_vert_index = vert_index;
}

/*
一个简单的思考：
manim中默认的点是在世界坐标系中的

在仅有vertex shader和fragment shader的情况下，我们可以
在vertex shader中完成
世界坐标系 ---> 相机坐标系 ---> 裁剪坐标系

而在有vertex shader, geometry shader, fragment shader的情况下，我们可以
在vertex shader中完成
世界坐标系 ---> 相机坐标系
在geometry shader中完成
相机坐标系 ---> 裁剪坐标系
*/