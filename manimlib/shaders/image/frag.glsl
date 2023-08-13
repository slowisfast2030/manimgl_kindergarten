#version 330

uniform sampler2D Texture;

/*
这两个变量是从顶点着色器传递过来的
默认会插值
*/
in vec2 v_im_coords;
in float v_opacity;

out vec4 frag_color;

void main() {
    frag_color = texture(Texture, v_im_coords);
    frag_color.a *= v_opacity;
}