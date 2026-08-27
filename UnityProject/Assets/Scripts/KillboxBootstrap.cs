using UnityEngine;

public static class KillboxBootstrap
{
    [RuntimeInitializeOnLoadMethod(RuntimeInitializeLoadType.AfterSceneLoad)]
    static void Start()
    {
        if (Object.FindObjectOfType<KillboxGame>() == null)
            new GameObject("KILLBOX GAME").AddComponent<KillboxGame>();
    }
}
