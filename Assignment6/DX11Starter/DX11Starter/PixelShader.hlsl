
// Struct representing the data we expect to receive from earlier pipeline stages
// - Should match the output of our corresponding vertex shader
// - The name of the struct itself is unimportant
// - The variable names don't have to match other shaders (just the semantics)
// - Each variable must have a semantic, which defines its usage
struct VertexToPixel
{
	// Data type
	//  |
	//  |   Name          Semantic
	//  |    |                |
	//  v    v                v
	float4 position		: SV_POSITION;
	float3 normal		: NORMAL;
	float2 uv			: TEXCOORD;
};

struct Light
{
	float4 AmbientColour;
	float4 DiffuseColour;
	float3 Direction;
};


cbuffer externalData : register(b1)
{
	Light light;
	Light OtherLight;
};

float4 LightValue(Light newLight, VertexToPixel input)
{
	input.normal = normalize(input.normal);

	float3 toLight = normalize(newLight.Direction);
	float NdotL = dot(input.normal, -toLight);
	NdotL = saturate(NdotL);

	return newLight.AmbientColour + (newLight.DiffuseColour * NdotL);
}

Texture2D diffuseTexture	: register(t0);
SamplerState basicSampler	: register(s1);


// --------------------------------------------------------
// The entry point (main method) for our pixel shader
// 
// - Input is the data coming down the pipeline (defined by the struct)
// - Output is a single color (float4)
// - Has a special semantic (SV_TARGET), which means 
//    "put the output of this into the current render target"
// - Named "main" because that's the default the shader compiler looks for
// --------------------------------------------------------
float4 main(VertexToPixel input) : SV_TARGET
{

	float4 lighting = LightValue(light, input) + LightValue(OtherLight, input);
	float4 surfaceColour = diffuseTexture.Sample(basicSampler, input.uv);
	return surfaceColour * lighting;

}