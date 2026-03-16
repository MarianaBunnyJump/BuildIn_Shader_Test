using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class ChangeShow : MonoBehaviour
{
    [SerializeField] private List<GameObject> objs;
    [SerializeField] [Range(0, 20)] private int selectedGo;


    private void SelectShow()
    {
        if (objs == null || objs.Count == 0) return;

        int maxIndex = Mathf.Max(0, objs.Count - 1);
        selectedGo = Mathf.Clamp(selectedGo, 0, maxIndex);

        for (int i = 0; i < objs.Count; i++)
        {
            if (objs[i] != null)
                objs[i].SetActive(i == selectedGo);
        }
    }

#if UNITY_EDITOR
    private void OnValidate()
    {
        SelectShow();
    }
#endif
}