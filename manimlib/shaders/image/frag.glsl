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
/*
顶点着色器将point从world space（manim中对象初始化不在object space）到clip space
我们知道clip space的下一步是到screen space

只有到了screen space，才能进行光栅化，才能进行片段着色器的计算
为了映射到 screen space，我们需要设置viewport

def get_raw_fbo_data(self, dtype: str = 'f1') -> bytes:
    '''获取源缓冲数据'''
    # Copy blocks from the fbo_msaa to the drawn fbo using Blit
    pw, ph = (self.pixel_width, self.pixel_height)
    gl.glBindFramebuffer(gl.GL_READ_FRAMEBUFFER, self.fbo_msaa.glo)
    gl.glBindFramebuffer(gl.GL_DRAW_FRAMEBUFFER, self.fbo.glo)
    gl.glBlitFramebuffer(0, 0, pw, ph, 0, 0, pw, ph, gl.GL_COLOR_BUFFER_BIT, gl.GL_LINEAR)
    return self.fbo.read(
        viewport=self.fbo.viewport,
        components=self.n_channels,
        dtype=dtype,
    )

上面的代码就是manim中设置viewport的地方

总结一下流程：
vertex shader -> viewport setting -> space transformation -> rasterization -> fragment shader
(clip space)                         (screen space)
*/