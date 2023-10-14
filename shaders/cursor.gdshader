shader_type spatial;

void fragment(){
	ALBEDO = vec3(0, 1, 1);
	ALPHA = 1.0;
	//Looking from z axis

	//1st UV Row
	if (UV.x <= 0.33 && UV.y <= 0.25){ // Front
		ALPHA = 0.5;
	}
	if (UV.x <= 0.67 && UV.x >= 0.33 && UV.y <= 0.25){ // Right
		ALPHA = 0.5;
	}
	if (UV.x <= 1.0 && UV.x >= 0.67 && UV.y <= 0.25){ // Back
		ALPHA = 0.5;
	}

	//2nd UV Row
	if (UV.x <= 0.33 && UV.y >= 0.5 && UV.y <= 0.75){ // Left
		ALPHA = 0.5;
	}
	if (UV.x <= 0.67 && UV.x >= 0.33 && UV.y >= 0.5 &&  UV.y <= 1.0){ // Top
		ALPHA = 0.5;
	}
}