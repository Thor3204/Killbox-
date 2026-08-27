using UnityEngine;
using UnityEngine.UI;

public class KillboxGameCore : MonoBehaviour
{
    [Header("KILLBOX prototype - game only")]
    public int maxPlayers = 100;
    public float preparationSeconds = 30f;
    public float huntSeconds = 30f;

    private GameObject player;
    private Camera gameCamera;
    private float timer;
    private int alive = 25;
    private Text hud;
    private bool hunt;

    [RuntimeInitializeOnLoadMethod(RuntimeInitializeLoadType.AfterSceneLoad)]
    static void StartGame()
    {
        var root = new GameObject("KILLBOX_GAME");
        root.AddComponent<KillboxGameCore>();
    }

    void Start()
    {
        Application.targetFrameRate = 60;
        Screen.orientation = ScreenOrientation.LandscapeLeft;
        BuildWorld();
        BuildPlayer();
        BuildHUD();
        timer = preparationSeconds;
    }

    void Update()
    {
        if (player == null) return;
        MovePlayer();
        FollowCamera();
        timer -= Time.deltaTime;
        if (timer <= 0f)
        {
            hunt = !hunt;
            timer = hunt ? huntSeconds : preparationSeconds;
        }
        if (hud != null)
            hud.text = $"KILLBOX   •   {(hunt ? "CAZA" : "PREPARACIÓN")}   •   {Mathf.CeilToInt(timer):00}\nVIVOS  {alive}/100     HP 100     ⚔ ATAQUE     ⚡ HABILIDAD";
    }

    void BuildWorld()
    {
        RenderSettings.ambientLight = new Color(0.42f,0.45f,0.5f);
        var ground = GameObject.CreatePrimitive(PrimitiveType.Plane);
        ground.name = "NovaCity_Ground"; ground.transform.localScale = Vector3.one * 8f;
        ground.GetComponent<Renderer>().material.color = new Color(.12f,.14f,.16f);
        for (int i=0;i<26;i++)
        {
            var b=GameObject.CreatePrimitive(PrimitiveType.Cube);
            b.name="CityBlock"; b.transform.position=new Vector3(Random.Range(-32,32),Random.Range(2,5),Random.Range(-32,32));
            b.transform.localScale=new Vector3(Random.Range(3,7),Random.Range(4,10),Random.Range(3,7));
            b.GetComponent<Renderer>().material.color=new Color(.22f,.25f,.29f);
        }
        var lightObj=new GameObject("CityLight"); var light=lightObj.AddComponent<Light>(); light.type=LightType.Directional; light.intensity=1.1f; light.transform.rotation=Quaternion.Euler(48,-35,0);
    }

    void BuildPlayer()
    {
        player=GameObject.CreatePrimitive(PrimitiveType.Capsule); player.name="Player"; player.transform.position=new Vector3(0,1,0); player.transform.localScale=new Vector3(.7f,1f,.7f);
        player.GetComponent<Renderer>().material.color=new Color(.15f,.55f,.95f);
        gameCamera=new GameObject("KillboxCamera").AddComponent<Camera>();
        gameCamera.fieldOfView=62f; gameCamera.transform.position=new Vector3(0,5,-7); gameCamera.transform.LookAt(player.transform.position+Vector3.up);
    }

    void MovePlayer()
    {
        float x=Input.GetAxisRaw("Horizontal"), z=Input.GetAxisRaw("Vertical");
        Vector3 d=new Vector3(x,0,z).normalized;
        if(d.sqrMagnitude>.01f){ player.transform.position += d*6f*Time.deltaTime; player.transform.forward=Vector3.Slerp(player.transform.forward,d,12f*Time.deltaTime); }
    }

    void FollowCamera()
    {
        Vector3 target=player.transform.position+Vector3.up*1.2f;
        Vector3 desired=player.transform.position-player.transform.forward*7f+Vector3.up*4.2f;
        gameCamera.transform.position=Vector3.Lerp(gameCamera.transform.position,desired,8f*Time.deltaTime); gameCamera.transform.LookAt(target);
    }

    void BuildHUD()
    {
        var canvas=new GameObject("GameHUD"); canvas.AddComponent<Canvas>().renderMode=RenderMode.ScreenSpaceOverlay; canvas.AddComponent<CanvasScaler>().uiScaleMode=CanvasScaler.ScaleMode.ScaleWithScreenSize; canvas.GetComponent<CanvasScaler>().referenceResolution=new Vector2(1280,720);
        hud=new GameObject("HUDText").AddComponent<Text>(); hud.transform.SetParent(canvas.transform,false); hud.font=Resources.GetBuiltinResource<Font>("Arial.ttf"); hud.fontSize=30; hud.color=Color.white; hud.alignment=TextAnchor.UpperLeft;
        var rt=hud.rectTransform; rt.anchorMin=new Vector2(0,1); rt.anchorMax=new Vector2(1,1); rt.pivot=new Vector2(.5f,1); rt.sizeDelta=new Vector2(-50,100); rt.anchoredPosition=new Vector2(0,-25);
    }
}
