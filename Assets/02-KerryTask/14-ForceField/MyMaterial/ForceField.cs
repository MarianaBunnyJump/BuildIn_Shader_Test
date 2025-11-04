using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode()]
public class ForceField : MonoBehaviour
{
    public ParticleSystem particleSystem;

    public string triggerTag = "ForceField";
    public float clicksPerSecond = 0.1f;
    public int AffectorAmount = 20;

    private ParticleSystem.Particle[] particles;
    private Vector4[] positions;
    private float[] sizes;

    private float clickTimer = 0.1f;

    //鼠标点击的射线检测只有在运行时候才会发生！！！！！
    void DoRayCast()
    {
        RaycastHit hitInfo;
        Ray ray = Camera.main.ScreenPointToRay(Input.mousePosition);

        if (Physics.Raycast(ray, out hitInfo))
        {
            if (hitInfo.transform.CompareTag(triggerTag))
            {
                particleSystem.transform.position = hitInfo.point;
                particleSystem.Emit(1);
            }
        }
    }

    void Update()
    {
        clickTimer += Time.deltaTime;
        if (Input.GetMouseButton(0))
        {
            Debug.Log("点击了鼠标");
            if (clickTimer > clicksPerSecond)
            {
                clickTimer = 0.0f;
                DoRayCast();
            }
        }


        var psmain = particleSystem.main;
        psmain.maxParticles = AffectorAmount;
        particles = new ParticleSystem.Particle[AffectorAmount];
        positions = new Vector4[AffectorAmount];
        sizes = new float[AffectorAmount];
        particleSystem.GetParticles(particles);
        for (int i = 0; i < AffectorAmount; i++)
        {
            positions[i] = particles[i].position;
            sizes[i] = particles[i].GetCurrentSize(particleSystem);
        }

        Shader.SetGlobalVectorArray("HitPosition", positions);
        Shader.SetGlobalFloatArray("HitSize", sizes);
        Shader.SetGlobalFloat("AffectorAmount", AffectorAmount);
    }
}