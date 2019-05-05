shader_type canvas_item;
render_mode blend_disabled;
uniform vec4 blend_color;
uniform float fade_amount = 1;

uniform sampler2D uv_mask_texture : hint_black;

void fragment(){
	vec2 texture_based_mask = vec2(0.0);
    vec4 color = texture(TEXTURE, UV);
	vec3 gray = vec3(dot(color.rgb, vec3(0.299, 0.587, 0.114)));
	bool test0 = color.a < 0.45 && color.a > 0.2;
	bool test1 = color.r < 0.42 && color.g < 0.77 && color.b > 0.81 && color.a > 0.4;
	bool test2 = color.r < 0.36 && color.g < 0.73 && color.b < 0.86 && color.a > 0.4;
	bool test3 = color.r < 0.475 && color.g < 0.80 && color.b > 0.88 && color.a > 0.4;
	bool test4 = color.r < 0.45 && color.g < 0.785 && color.b > 0.84 && color.a > 0.4;
	bool test5 = color.r < 0.5 && color.g < 0.8 && color.b > 0.86 && color.a > 0.4;
	bool test6 = color.r < 0.38 && color.g < 0.74 && color.b > 0.78 && color.a > 0.4;
	// right edge 362.0 left edge 296.0 bottom 215.0
	//bool vert = (pow((FRAGCOORD.x-324.0),2.0)/1089.0) + (pow((FRAGCOORD.y-238.0),2.0)/324.0) == 1.0;
	//bool vert = UV.y > 215.0;
    // if the pixel has enough red
    if ((test0 || test1 || test2 || test3 || test4 || test5 || test6)) {
		//color = vec4(coverall_color);  // or color = vec4(0,255.0,0,color.a)
		color = vec4(gray,1.0) * blend_color;
    }
    // otherwise
    else {
        // set its color to blue
        color = color;
    }
	color.a = (color.a * (1.0-fade_amount) + (texture(uv_mask_texture, UV).a * fade_amount));
    COLOR = color;
}