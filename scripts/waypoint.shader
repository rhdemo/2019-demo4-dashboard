shader_type canvas_item;
render_mode blend_disabled;
uniform vec4 blend_color;

void fragment(){
    vec4 color = texture(TEXTURE, UV);
	vec3 gray = vec3(dot(color.rgb, vec3(0.299, 0.587, 0.114)));
	bool test0 = color.a < 0.45 && color.a > 0.2;
	bool test1 = color.r < 0.42 && color.g < 0.77 && color.b > 0.81 && color.a > 0.4;
	bool test2 = color.r < 0.36 && color.g < 0.73 && color.b < 0.86 && color.a > 0.4;
	bool test3 = color.r < 0.475 && color.g < 0.80 && color.b > 0.88 && color.a > 0.4;
	bool test4 = color.r < 0.45 && color.g < 0.785 && color.b > 0.84 && color.a > 0.4;
	bool test5 = color.r < 0.5 && color.g < 0.8 && color.b > 0.86 && color.a > 0.4;
	bool test6 = color.r < 0.38 && color.g < 0.74 && color.b > 0.78 && color.a > 0.4;
    // if the pixel has enough red
    if (test0 || test1 || test2 || test3 || test4 || test5 || test6) {
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