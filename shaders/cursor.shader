shader_type spatial;

void fragment() {
	ALBEDO = vec3(0, 1, 1);
	ALPHA = 1.0;
//	EMISSION = vec3(0, 1, 1);
	
	if(UV.y < 0.25){
	ALBEDO = vec3(0, 1, 1);
	ALPHA = 0.5;
	}
	if(UV.y > 0.5 && UV.y < 0.75){
	ALBEDO = vec3(0, 1, 1);
	ALPHA = 0.5;
	}
	if(UV.x < 0.69 && UV.x > 0.333 && UV.g > 0.5 && UV.y > 0.75){
	ALBEDO = vec3(0, 1, 1);
	ALPHA = 0.5;
	}
}

