#include <sourcemod>
#include <cstrike>
#include <sdktools>
#include <ripext> 
#include "botcontrol.sp"
#include "constants.sp"

#pragma semicolon 1
#pragma newdecls required

#define PLUGIN_VERSION "0.00"

HTTPClient httpClient; 
Bot bots[10];

int tbot_valid[5];
int ctbot_valid[5];

int tick = 10;
bool running = false;


public Plugin myinfo = 
{
	name = "DemoPlayback",
	author = "Logo",
	description = "Replays Demos",
	version = PLUGIN_VERSION,
	url = "logochris.de/demo"
};

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	// No need for the old GetGameFolderName setup.
	EngineVersion g_engineversion = GetEngineVersion();
	if (g_engineversion != Engine_CSGO)
	{
		SetFailState("This plugin was made for use with Counter-Strike: Global Offensive only.");
	}
} 

public void OnPluginStart()
{
	/**
	 * @note For the love of god, please stop using FCVAR_PLUGIN.
	 * Console.inc even explains this above the entry for the FCVAR_PLUGIN define.
	 * "No logic using this flag ever existed in a released game. It only ever appeared in the first hl2sdk."
	 */
	PrintToServer("Plugin Started");
	
	httpClient = new HTTPClient(SERVERURL);
	CreateConVar("sm_dp_version", PLUGIN_VERSION, "Demoplayback plugin version ConVar. Please don't change me!", FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	RegConsoleCmd("sm_dp_tick", SetTick, "Set Current Tick");
	RegConsoleCmd("sm_dp_run", ToggleRun, "Starts/Pauses the playback");
	RegConsoleCmd("sm_dp_init", SetupBots, "Initializes Bots");
	RegConsoleCmd("sm_dp_next", NextTick, "Executes next Tick");
	
	httpClient.Get("demo/10", OnNextTick); 	
	
	for(int i=0;i<10;i++){
		bots[i] = new Bot();
		bots[i].init();
	}
	
}

public Action ToggleRun(int client, int args){
	if(args < 1 || args > 1) {
		ReplyToCommand(client, "[SM] Usage: sm_dp_run 1/0");
		return Plugin_Handled;
	}
	
	char arg[32];
	GetCmdArg(1, arg, sizeof(arg));
	running = view_as<bool>(StringToInt(arg));
	
	return Plugin_Handled;
}

public Action SetTick(int client, int args){
	if(args < 1 || args > 1) {
		ReplyToCommand(client, "[SM] current tick %d", tick);
		return Plugin_Handled;
	}
	
	char arg[32];
	GetCmdArg(1, arg, sizeof(arg));
	tick = StringToInt(arg);
	
	return Plugin_Handled;
}

public Action SetupBots(int client, int args){

	for (int i=1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && GetClientTeam(i) > 1 && IsFakeClient(i))
		{	
			bool found = false;
			for(int j=0;j<10;j++){
				int id = bots[j].GetClientID();
				if(id == -1){
					bots[j].SetClientID(i);
					PrintToServer("New Bot with clientID: %d added", i);
					found = true;
					break;
				}
			}
			if(!found){
				PrintToServer("No Bot for clientID: %d found", i);
			}
		}
	}

	
	return Plugin_Handled;
}

public Action NextTick(int client, int args){
	
	GetNextTick();
	
	for(int i=0;i<10;i++){
		bots[i].ApplyTick();
	}
	
	return Plugin_Handled;
}

void OnNextTick(HTTPResponse response, any value)
{		
	if (response.Status != HTTPStatus_OK) {
		PrintToServer("HTTP Failed");
		return;
	}

	// Indicate that the response is a JSON object
	JSONObject data = view_as<JSONObject>(response.Data);
	JSONArray teams = view_as<JSONArray>(data.Get("teams"));
	

	for(int i=0;i<10;i++){
		bots[i].SetTick(teams, tbot_valid, ctbot_valid);
	}
	
	
	delete data; 
	delete teams;
	
	tick += 1;
}

public void OnGameFrame() {

	if(running){
		GetNextTick();
		
		//PrintToServer("NextTick");
		//bots[0].ApplyTick();
		
		for(int i=0;i<10;i++){
			bots[i].ApplyTick();
		}
	}
	
}

void GetNextTick() {
	char getPath[100] = "demo/";
	char tickStr[95];
	IntToString(tick, tickStr, sizeof(tickStr));
	StrCat(getPath, sizeof(getPath), tickStr);
	
	httpClient.Get(getPath, OnNextTick);
	tick += 1;
}