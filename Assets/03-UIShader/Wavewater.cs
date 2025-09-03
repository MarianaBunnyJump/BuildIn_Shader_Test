#region

using UnityEngine;
using UnityEngine.UI;

#endregion

public class Wavewater : MonoBehaviour
{
    [Range(0, 1)] public float progressText = 0.5f;
    public Material mat;
    public Text percent;
    private int _shaderID;

    private void Start()
    {
        _shaderID = Shader.PropertyToID("_Control");
        Debug.Log(_shaderID);
    }

    private void Update()
    {
        mat.SetFloat(_shaderID, progressText);
        percent.text = (progressText * 100).ToString("F1") + "%";
    }
}