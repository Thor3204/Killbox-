using UnityEngine;

public class KillboxMatchRuntime : MonoBehaviour
{
    GameObject player; Camera cam; float nextBot;
    [RuntimeInitializeOnLoadMethod(RuntimeInitializeLoadType.AfterSceneLoad)]
    static void Boot(){ var g=new GameObject("KILLBOX MATCH RUNTIME"); g.AddComponent<KillboxMatchRuntime>(); }
    void Update(){
        if(player==null) player=GameObject.Find("Player");
        if(player==null) return;
        if(cam==null) cam=GameObject.Find("ThirdPersonCamera")?.GetComponent<Camera>();
        float x=Input.GetAxisRaw("Horizontal"), z=Input.GetAxisRaw("Vertical");
        Vector3 dir=new Vector3(x,0,z).normalized;
        if(dir.sqrMagnitude>.01f){player.transform.position+=dir*5f*Time.deltaTime;player.transform.forward=Vector3.Slerp(player.transform.forward,dir,12f*Time.deltaTime);}
        if(cam!=null){Vector3 target=player.transform.position+new Vector3(0,1.5f,0);cam.transform.position=Vector3.Lerp(cam.transform.position,target-player.transform.forward*7f+Vector3.up*4f,8f*Time.deltaTime);cam.transform.LookAt(target);}
        if(Time.time>nextBot){nextBot=Time.time+2f;SpawnBot();}
    }
    void SpawnBot(){
        if(GameObject.FindGameObjectsWithTag("Bot").Length>=12)return;
        var b=GameObject.CreatePrimitive(PrimitiveType.Capsule);b.name="Bot";b.tag="Bot";b.transform.position=new Vector3(Random.Range(-30,30),1,Random.Range(-30,30));b.GetComponent<Renderer>().material.color=new Color(.95f,.25f,.25f);
    }
}
