attribute vec2 vert;
attribute vec3 rgb;

uniform vec2 pos;
uniform vec2 scale;
uniform float rotation;
uniform float colorMult;

varying vec4 color;

//converts world coordinates to normalized device coordinates
vec2 toNdc(vec2 world){
	vec2 result=world*vec2(2, 2)/vec2(1280, 720) - vec2(1, 1);
	result.y*=-1.0;
	return result;
}

//rotates a vector around (0, 0)
vec2 turn(vec2 a, float angle){
	float cosine=cos(angle);
	float sine=sin(angle);

	vec2 result=vec2(a.x*cosine-a.y*sine, a.x*sine+a.y*cosine);
	return result;
}

void main(){
	vec2 temp=turn(vert*scale, rotation)+pos;
	gl_Position=vec4(toNdc(temp), 0.0, 1.0);
	color=vec4(rgb*colorMult, 1.0);
}