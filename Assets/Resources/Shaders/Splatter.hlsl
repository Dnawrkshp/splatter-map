// Splatter by Dnawrkshp

//
#include "ClassicNoise3D.hlsl"


// (global) Splatter colors
uniform float4 SplatterColors[4];


// Input
struct SplatterInput {
	float4 map;
	float3 worldPos;
	float4 albedo;
	float3 normal;
	float smoothness;
};

// Output
struct SplatterOutput {
	float4 albedo;
	float3 normal;
	float smoothness;
	float mask;
};

// Bubble sort
void SplatterBubble(inout uint4 order, float4 values) {
	uint old = 0;

	if (values[order[0]] < values[order[1]]) {
		old = order[0];
		order[0] = order[1];
		order[1] = old;
	}

	if (values[order[1]] < values[order[2]]) {
		old = order[1];
		order[1] = order[2];
		order[2] = old;
	}

	if (values[order[2]] < values[order[3]]) {
		old = order[2];
		order[2] = order[3];
		order[3] = old;
	}
}

float SplatterStep(float a, float b) {
	float dif = b - a;
	return saturate(dif / fwidth(dif));
}

SplatterOutput GetSplatter(SplatterInput i) {
	SplatterOutput o;

	o.albedo = i.albedo;
	o.smoothness = i.smoothness;
	o.normal = i.normal;
	o.mask = 0;

	// Unity doesn't initialize vertex colors so they default to white
	// If that's the case then we just render the default
	if (length(i.map) > 1) {
		return o;
	}

	// Get noise for each channel
	float4 vNoise = float4(
		(cnoise(i.worldPos.xyz) + 1) / 2,
		(cnoise(i.worldPos.zyx) + 1) / 2,
		(cnoise(i.worldPos.yzx) + 1) / 2,
		(cnoise(i.worldPos.zxy) + 1) / 2);

	// Sort from strongest to weakest
	uint4 sorted = uint4(0, 1, 2, 3);
	SplatterBubble(sorted, i.map); SplatterBubble(sorted, i.map); SplatterBubble(sorted, i.map); SplatterBubble(sorted, i.map);

	// Use noise to make a more random appearance
	float4 strength = float4(
		SplatterStep(vNoise[0], pow(i.map[0], vNoise[0]*2)),
		SplatterStep(vNoise[1], pow(i.map[1], vNoise[1]*2)),
		SplatterStep(vNoise[2], pow(i.map[2], vNoise[2]*2)),
		SplatterStep(vNoise[3], pow(i.map[3], vNoise[3]*2))
		);

	// Whether there is any splatter or not
	fixed isSplat = max(strength[0], max(strength[1], max(strength[2], strength[3])));

	// Apply weakest to strongest
	o.albedo = lerp(o.albedo, SplatterColors[sorted[3]], strength[sorted[3]]);
	o.albedo = lerp(o.albedo, SplatterColors[sorted[2]], strength[sorted[2]]);
	o.albedo = lerp(o.albedo, SplatterColors[sorted[1]], strength[sorted[1]]);
	o.albedo = lerp(o.albedo, SplatterColors[sorted[0]], strength[sorted[0]]);

	// Lerp other channels
	o.smoothness = lerp(i.smoothness, 1, isSplat);
	o.normal = lerp(i.normal, float3(0, 0, 1), isSplat*0.5);
	o.mask = isSplat;

	return o;
}
