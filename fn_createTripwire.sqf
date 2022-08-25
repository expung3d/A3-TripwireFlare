if(isNil "ZAM_fnc_flareTripwireDeactivate") then {
	ZAM_fnc_flareTripwireDeactivate = {
		params ["_claymore","_tripwire","_anchor"];
		waitUntil {isNull _claymore || !alive _claymore};
		private _claymorePos = getPos _anchor;
		deleteVehicle _tripwire;
		deleteVehicle _anchor;
		sleep 0.2;
		private _item = nearestObject [_claymorePos,"GroundWeaponHolder"];
		deleteVehicle _item;
	};
};
		
if(isNil "ZAM_fnc_createFlareTripwire") then {
	ZAM_fnc_createFlareTripwire = {
		params ["_object"];
		private _claymorePos = _object modelToWorld [1.42004,0.00195313,0];
		private _projectilePos = _object modelToWorld [1.42004,0.00195313,0.23801];
		_object = [_object] call BIS_fnc_replaceWithSimpleObject;

		private _anchor = "Land_HelipadEmpty_F" createVehicle (position _object);
		_anchor setPosWorld (getPosWorld _object);
		_anchor addEventhandler ["Deleted",{
			params ["_entity"];
			{
				deleteVehicle _x;
			}forEach (attachedObjects _entity);
		}];
		[_object,_anchor] call BIS_fnc_attachToRelative;
		[[[_anchor],allCurators],{
			params ["_objects","_curators"];
			{
				_x addCuratorEditableObjects [_objects,true];
			} foreach _curators;
		}] remoteExec ["Spawn",2];
		
		private _claymore = createMine ["Claymore_F",position _object,[],0];
		_claymore setPos _claymorePos;
		[_claymore,_object,_anchor] spawn ZAM_fnc_flareTripwireDeactivate;

		waitUntil {
			sleep 0.5;
			((nearestObjects [_object,["CAManBase"],1.3]) findIf {alive _x}) != -1
		};

		if(!isNull _object) then {
			hideObjectGlobal _claymore;
			_claymore setPos [0,0,0];
			private _projectile = createVehicle ["F_20mm_White_Infinite",getPos _object,[],0,"none"];
			_projectile setPos _projectilePos;
			[[_projectile,"SN_Flare_Fired_4","say3D"],"bis_fnc_sayMessage"] call bis_fnc_mp;
			private _soundSource = createSoundSource ["SoundFlareLoop_F",getPosATL _projectile,[],0];
			sleep 120;
			deleteVehicle _projectile;
			deleteVehicle _soundSource;
			sleep 120;
			deleteVehicle _claymore;
		};
	};
};
[this] spawn ZAM_fnc_createFlareTripwire;
