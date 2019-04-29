shader_type canvas_item;
render_mode blend_disabled;
uniform vec4 blend_color;

void fragment(){
    vec4 color = texture(TEXTURE, UV);
	vec3 gray = vec3(dot(color.rgb, vec3(0.299, 0.587, 0.114)));
	bool test1 = color.r < 0.01 && color.g < 0.61 && color.b < 0.885 && color.a > 0.4;
	bool test2 = color.r < 0.21 && color.g < 0.4 && color.b > 0.1 && color.a > 0.4;
	bool test3 = color.r < 0.47 && color.g < 0.55 && color.b > 0.5 && color.a > 0.4;
	bool test4 = color.r < 0.32 && color.g < 0.345 && color.b > 0.45 && color.a > 0.4;
    // if the pixel has enough red
    if (test1) {
		//color = vec4(coverall_color);  // or color = vec4(0,255.0,0,color.a)
		color = vec4(gray,1.0) * blend_color;
    }
    // otherwise
    else {
        // set its color to blue
        color = color;
    }
    COLOR = color;
}