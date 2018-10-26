using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ClickSplatter : MonoBehaviour
{
    public ComputeShader computeShader;
    public Terrain terrain;

    public float Radius = 5f;

    [Range(0, 3)] public int Channel = 1;

    private ComputeBuffer outColorBuffer;
    private ComputeBuffer vertBuffer;
    private ComputeBuffer normBuffer;
    private int _kernel;
    private Vector3 _e;
    private Texture2D _terrainHeightmap;
    private RenderTexture _terrainSplatter;

    // Use this for initialization
    void Start()
    {
        // Set splatter colors
        Shader.SetGlobalVectorArray("SplatterColors", new Vector4[]
        {
            Color.blue,
            Color.red,
            Color.green,
            Color.magenta
        });

        // Get terrain heightmap
        var heights = terrain.terrainData.GetHeights(0, 0, terrain.terrainData.heightmapResolution, terrain.terrainData.heightmapResolution);
        _terrainHeightmap = new Texture2D(terrain.terrainData.heightmapResolution, terrain.terrainData.heightmapResolution, TextureFormat.RFloat, true, true);

        for (int y = 0; y < _terrainHeightmap.height; y++)
            for (int x = 0; x < _terrainHeightmap.width; x++)
                _terrainHeightmap.SetPixel(y,x, new Color(heights[x, y],0,0,0));

        _terrainHeightmap.Apply();

        // Create terrain splatter texture
        _terrainSplatter = new RenderTexture((int)(_terrainHeightmap.width*1), (int)(_terrainHeightmap.height*1), 24, RenderTextureFormat.ARGB32, RenderTextureReadWrite.Linear);
        _terrainSplatter.enableRandomWrite = true;
        _terrainSplatter.Create();
    }

    // Update is called once per frame
    void Update()
    {
        RaycastHit hit;

        if (Input.GetMouseButtonDown(2))
        {
            Channel++;
            if (Channel > 3)
                Channel = 0;
        }

        if (Input.GetMouseButton(0))
        {
            Ray ray = Camera.main.ScreenPointToRay(Input.mousePosition);

            if (Physics.Raycast(ray, out hit, 1000f))
            {
                _e = hit.point;
                var colliders = Physics.OverlapSphere(hit.point, Radius);

                foreach (var collider in colliders)
                {
                    if (collider is TerrainCollider)
                    {
                        RunShaderTerrain(
                            Matrix4x4.TRS(
                                terrain.transform.position,
                                terrain.transform.rotation,
                                terrain.terrainData.size),
                            hit.point, Channel);

                    }
                    else if (collider.transform != null)
                    {
                        var mf = collider.transform.GetComponent<MeshFilter>();
                        if (mf == null)
                            continue;

                        if (mf.mesh.colors32 == null || mf.mesh.colors32.Length < mf.mesh.vertexCount)
                            mf.mesh.colors32 = new Color32[mf.mesh.vertexCount];

                        RunShader(collider.transform, mf.mesh, hit.point - (ray.direction*0.01f), Channel);
                    }
                }
            }
        }
    }

    void RunShaderTerrain(Matrix4x4 world, Vector3 start, int channel)
    {
        _kernel = computeShader.FindKernel("ComputeTerrainSplatter");

        //
        computeShader.SetMatrix("iL2W", world);
        computeShader.SetInt("iChannel", channel);
        computeShader.SetVector("iStartPos", start);
        computeShader.SetFloat("iRadius", Radius);
        computeShader.SetVector("iTerrainSize", new Vector2(_terrainSplatter.width, _terrainSplatter.height));
        
        // Setup textures
        computeShader.SetTexture(_kernel, "TerrainHeightmap", _terrainHeightmap);
        computeShader.SetTexture(_kernel, "TerrainResult", _terrainSplatter);

        // Dispatch
        computeShader.Dispatch(_kernel, Mathf.CeilToInt(_terrainSplatter.width / 8f), Mathf.CeilToInt(_terrainSplatter.height / 8f), 1);


        // Update terrain material
        MaterialPropertyBlock mpb = new MaterialPropertyBlock();
        terrain.GetSplatMaterialPropertyBlock(mpb);
        mpb.SetTexture("_Splatter", _terrainSplatter);
        terrain.SetSplatMaterialPropertyBlock(mpb);
    }

    void RunShader(Transform t, Mesh mesh, Vector3 start, int channel)
    {
        _kernel = computeShader.FindKernel("ComputeSplatter");

        //
        computeShader.SetMatrix("iL2W", t.localToWorldMatrix);
        computeShader.SetInt("iVertexCount", mesh.vertexCount);
        computeShader.SetInt("iChannel", channel*8);
        computeShader.SetVector("iStartPos", start);
        computeShader.SetFloat("iRadius", Radius);


        // Setup output buffer
        outColorBuffer = new ComputeBuffer(mesh.vertexCount, 4);
        outColorBuffer.SetData(mesh.colors32);
        computeShader.SetBuffer(_kernel, "oColor", outColorBuffer);

        //
        vertBuffer = new ComputeBuffer(mesh.vertexCount, 12);
        vertBuffer.SetData(mesh.vertices);
        computeShader.SetBuffer(_kernel, "iPosition", vertBuffer);

        // 
        normBuffer = new ComputeBuffer(mesh.vertexCount, 12);
        normBuffer.SetData(mesh.normals);
        computeShader.SetBuffer(_kernel, "iNormal", normBuffer);
        
        // Dispatch
        computeShader.Dispatch(_kernel, Mathf.CeilToInt(mesh.vertexCount/8f), Mathf.CeilToInt(mesh.vertexCount / 64f), 1);

        // Get output
        Color32[] data = new Color32[mesh.vertexCount];
        outColorBuffer.GetData(data);
        mesh.colors32 = data;

        // Cleanup
        outColorBuffer.Dispose();
        vertBuffer.Dispose();
        normBuffer.Dispose();
    }
}

 