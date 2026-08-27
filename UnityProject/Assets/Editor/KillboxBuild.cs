#if UNITY_EDITOR
using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEngine;
using UnityEngine.SceneManagement;

public static class KillboxBuild
{
    public static void BuildAndroid()
    {
        var scene = EditorSceneManager.NewScene(NewSceneSetup.EmptyScene, NewSceneMode.Single);
        var go = new GameObject("KILLBOX BOOT");
        go.AddComponent<KillboxGame>();
        EditorSceneManager.SaveScene(scene, "Assets/Main.unity");
        PlayerSettings.companyName = "KILLBOX";
        PlayerSettings.productName = "KILLBOX";
        PlayerSettings.applicationIdentifier = "com.killbox.game";
        PlayerSettings.defaultScreenOrientation = ScreenOrientation.LandscapeLeft;
        PlayerSettings.allowedAutorotateToPortrait = false;
        PlayerSettings.allowedAutorotateToPortraitUpsideDown = false;
        PlayerSettings.allowedAutorotateToLandscapeRight = true;
        PlayerSettings.allowedAutorotateToLandscapeLeft = true;
        EditorBuildSettings.scenes = new[] { new EditorBuildSettingsScene("Assets/Main.unity", true) };
        BuildPipeline.BuildPlayer(new BuildPlayerOptions { scenes = new[] { "Assets/Main.unity" }, locationPathName = "Build/Killbox.apk", target = BuildTarget.Android, options = BuildOptions.Development });
    }
}
#endif
