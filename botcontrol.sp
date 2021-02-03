methodmap Bot < StringMap {
	public Bot() {
		return view_as<Bot>(new StringMap());
	}
	
	public void init(){
		float vel[3];
		float pos[3];
		float view[3];
		
		this.SetValue("clientID", -1);
		this.SetValue("playerID", -1);
		this.SetValue("teamID", -1);
		this.SetArray("vel", vel, 3);
		this.SetArray("pos", pos, 3);
		this.SetArray("view", view, 3);
		this.SetString("name", "Unknown");
		this.SetValue("duck", 0);
		this.SetValue("walk", 0);
		this.SetValue("fFlags", 0);
		this.SetValue("health", 100);
		this.SetValue("armor", 100);
		this.SetValue("helmet", 0);
		this.SetValue("defuser", 0);
		this.SetValue("lifeState", 0);
		this.SetString("currWeapon", "");
		this.SetValue("weapon_count", 0);
	}
	
	public void SetClientID(int clientID) {
		this.SetValue("clientID", clientID);
	}
	
	public int GetClientID() {
		int clientID;
		this.GetValue("clientID", clientID);
		return clientID;
	}	
	
	public int GivePlayerItem2(int client, const char[] chItem)
	{	
		//int entity = GivePlayerItem(iClient, chItem);
		//CSWeaponID id = CS_AliasToWeaponID(chItem);
		//int iDef = CS_WeaponIDToItemDefIndex(id);
		
		//SetEntProp(entity, Prop_Send, "m_iItemDefinitionIndex", iDef);
		
		int team = GetClientTeam(client);
		SetEntProp(client, Prop_Send, "m_iTeamNum", team == 3 ? 2 : 3);
		int weapon = GivePlayerItem(client, chItem);
		SetEntProp(client, Prop_Send, "m_iTeamNum", team);
		return weapon;
	} 
	
	public void SetTick(JSONArray teams, int[] tbots_valid, int[] ctbots_valid){
		int clientID;
		int playerID;
		int teamID;
		
		this.GetValue("clientID", clientID);
		this.GetValue("playerID", playerID);
		this.GetValue("teamID", teamID);

		if(clientID > 0){  
			//1=Spec
			//2=Terrorist
			//3=CT

			if(teamID == -1){
				teamID = GetClientTeam(clientID);
				this.SetValue("teamID", teamID);
			}
			
			if(teamID > 1){
				if(playerID == -1){
					for(int i=0;i<5;i++){
						if(teamID == 2 && tbots_valid[i] == 0){
							tbots_valid[i] = 1;
							playerID = i;
							this.SetValue("playerID", playerID);
							break;
						}
						if(teamID == 3 && ctbots_valid[i] == 0){
							ctbots_valid[i] = 1;
							playerID = i;
							this.SetValue("playerID", playerID);
							break;
						}
					}
				}
				
				if(teamID == 2){
					teamID = 1;
				} else if (teamID == 3){
					teamID = 0;
				}
				
				if(playerID != -1){
					JSONObject team = view_as<JSONObject>(teams.Get(teamID));
					JSONArray players = view_as<JSONArray>(team.Get("players"));
					int playerCount = players.Length;
					if(playerCount > playerID){
						JSONObject player = view_as<JSONObject>(players.Get(playerID));
						
						char name[32];
						player.GetString("name", name, 32);
						
						int fFlags = player.GetInt("fFlags");
						int health = player.GetInt("health");
						int armor = player.GetInt("armor");
						bool helmet = player.GetBool("hasHelmet");
						bool defuser = player.GetBool("hasDefuser");
						int lifeState = player.GetInt("lifeState");
						
						char currWeapon[32];
						player.GetString("currWeapon", currWeapon, 32);
						
						JSONArray weaponsJSON = view_as<JSONArray>(player.Get("weapons"));
						
						int weapon_count = weaponsJSON.Length;
						
						char weapons[10][32];
						
						for(int i=0; i<weapon_count; i++){
							weaponsJSON.GetString(i, weapons[i], 32);
							
						}
						
						
						float vel[3];
						float pos[3];
						float view[3];
						
						JSONObject velJSON = view_as<JSONObject>(player.Get("vel"));
						
						vel[0] = velJSON.GetFloat("x");
						vel[1] = velJSON.GetFloat("y");
						vel[2] = velJSON.GetFloat("z");
						
						JSONObject posJSON = view_as<JSONObject>(player.Get("position"));
						
						pos[0] = posJSON.GetFloat("x");
						pos[1] = posJSON.GetFloat("y");
						pos[2] = posJSON.GetFloat("z");
						
						JSONObject viewJSON = view_as<JSONObject>(player.Get("view"));
						
						view[0] = viewJSON.GetFloat("pitch");
						view[1] = viewJSON.GetFloat("yaw");
						
						this.SetString("name", name);
						this.SetArray("vel",vel, 3);
						this.SetArray("pos",pos, 3);
						this.SetArray("view",view, 3);
						this.SetValue("fFlags", fFlags);
						this.SetValue("health", health);
						this.SetValue("armor", armor);
						this.SetValue("helmet", helmet);
						this.SetValue("defuser", defuser);
						this.SetValue("lifeState", lifeState);
						this.SetString("currWeapon", currWeapon);
						this.SetValue("weapon_count", weapon_count);
						
						for(int i=0;i<weapon_count;i++){
							char intBuf[2];
							IntToString(i, intBuf, 2);
							char buf[10] = "weapons";
							StrCat(buf, 10, intBuf);
							this.SetString(buf, weapons[i]);
						}
						
						delete viewJSON;
						delete velJSON; 
						delete posJSON;
						delete player; 
						delete weaponsJSON;
					}
					delete team;
					delete players; 
				}
			}
		}
	}
	
	public void ApplyTick(){
		int clientID;
		float vel[3];
		float pos[3];
		float view[3];
		char name[32];
		char currName[32];
		char currWeapon[32];
		int fFlags;
		int health;
		int armor;
		bool helmet;
		bool defuser;
		int lifeState;
		int weapon_count;
		
		this.GetString("name", name, 32);
		this.GetValue("clientID", clientID);
		this.GetArray("vel", vel, 3);
		this.GetArray("pos", pos, 3);
		this.GetArray("view", view, 3);
		this.GetValue("fFlags", fFlags);
		this.GetValue("armor", armor);
		this.GetValue("health", health);
		this.GetValue("helmet", helmet);
		this.GetValue("defuser", defuser);
		this.GetValue("lifeState", lifeState);
		this.GetValue("weapon_count", weapon_count);
		this.GetString("currWeapon", currWeapon, 32);
		
		if(clientID > 0){
			GetClientName(clientID, currName, 32);
			
			if(StrContains(currName,name) == -1){
				SetClientName(clientID, name);
			}
	
			char weapons[10][32];
			for(int i=0;i<weapon_count;i++){
				char intBuf[2];
				IntToString(i, intBuf, 2);
				char buf[10] = "weapons";
				StrCat(buf, 10, intBuf);
				this.GetString(buf, weapons[i],32);
			}
			
			
			int size = GetEntPropArraySize(clientID, Prop_Send, "m_hMyWeapons");
			int keepWeapons[10];
			for (int i = 0; i < size; i++) 
			{ 
				int item = GetEntPropEnt(clientID, Prop_Send, "m_hMyWeapons", i); 
			
				if (item != -1) {
					char classname[64];
					classname = "weapon_";
					char buf[32];
					int iDef = GetEntProp(item, Prop_Send, "m_iItemDefinitionIndex");
					CSWeaponID wID = CS_ItemDefIndexToID(iDef);
					CS_WeaponIDToAlias(wID, buf, sizeof(buf));
					
					StrCat(classname, 64, buf);
					
					int removeWeapon = 1;
					
					for(int j=0;j<weapon_count;j++){
						//PrintToServer("%s: Own %s - need %s",name, classname, weapons[j]);
						if (StrContains(classname,weapons[j]) != -1)
						{
							//PrintToServer("keep  %s", weapons[j]);
							keepWeapons[j] = 1;
							removeWeapon = 0;
						}
					}			
					
					if(removeWeapon == 1){
						if(StrContains(classname,"knife") == -1){
							//PrintToServer("%s: remove %s",name, classname);
							RemovePlayerItem(clientID, item);
							RemoveEdict(item);	
						}
					}
				} 
			}  
			
			for(int i=0;i<weapon_count;i++){
				if(keepWeapons[i] == 0){
					if(StrContains(weapons[i],"knife") == -1){
						//PrintToServer("%s: give %s",name, weapons[i]);
						this.GivePlayerItem2(clientID, weapons[i]);
					}
				}
			}
						
			
			if(lifeState != 0 && IsPlayerAlive(clientID)){
				ForcePlayerSuicide(clientID);
			} else if(lifeState == 0 && !IsPlayerAlive(clientID)) {
				CS_RespawnPlayer(clientID);
			}
						
			int hasHelmet = 0;
			GetEntProp(clientID, Prop_Send, "m_bHasHelmet", hasHelmet);	
			
			if(helmet){
				SetEntProp(clientID, Prop_Send, "m_bHasHelmet", 1);
			} else {
				SetEntProp(clientID, Prop_Send, "m_bHasHelmet", 0);
			}
			
			if(defuser){
				SetEntProp(clientID, Prop_Send, "m_bHasDefuser", 1);
			} else {
				SetEntProp(clientID, Prop_Send, "m_bHasDefuser", 0);
			}
		

			SetEntityHealth(clientID, health);
			SetEntProp(clientID, Prop_Data, "m_ArmorValue", armor);
			SetEntProp(clientID, Prop_Data, "m_fFlags", fFlags);
			SetEntPropVector(clientID, Prop_Data, "m_vecVelocity", vel);
			SetEntPropVector(clientID, Prop_Data, "m_vecOrigin", pos);
			TeleportEntity(clientID, NULL_VECTOR, view, NULL_VECTOR);
		}
			
	}	
	

}