local t = Def.ActorFrame{}

local newBPS;
local oldBPS;

--[[t[#t+1] = Def.ActorFrame{
	Def.Quad {
	InitCommand=cmd(visible,not BGA;Center;diffuse,color("0.15,0.15,0.15,1");zoomto,SCREEN_WIDTH,SCREEN_HEIGHT);
	}
}



t[#t+1] = LoadActor(THEME:GetPathB("ScreenWithMenuElements","background")) .. {
	--InitCommand=cmd(visible,not BGA;Center;zoomto,SCREEN_WIDTH,SCREEN_HEIGHT);
}; 
]]

-- DECORATIONS ////////////////////////

--TODO: These need to be put in the "pn in ivalues" statement eventually but it would break doubles

-- Left Hex Corner Decoration
t[#t+1] = LoadActor("decoration_corner") .. {
	InitCommand=cmd(visible,(GAMESTATE:IsHumanPlayer(PLAYER_1) or ToEnumShortString(GAMESTATE:GetCurrentStyle():GetStyleType()) == "OnePlayerTwoSides"));
	OnCommand=cmd(horizalign,left;x,SCREEN_LEFT;vertalign,top;y,SCREEN_TOP;zoomy,0.4;zoomx,0.6;diffusealpha,0.3;blend,Blend.Add); 
};

-- Right Hex Corner Decoration
t[#t+1] = LoadActor("decoration_corner") .. {
	InitCommand=cmd(visible,(GAMESTATE:IsHumanPlayer(PLAYER_2) or ToEnumShortString(GAMESTATE:GetCurrentStyle():GetStyleType()) == "OnePlayerTwoSides"));
	OnCommand=cmd(horizalign,left;x,SCREEN_RIGHT;vertalign,top;y,SCREEN_TOP;zoomy,0.4;;zoomx,-0.6;diffusealpha,0.3;blend,Blend.Add); 
};


-- WAVY LINE (thanks AJ) ////////////////////////




--Double
--customtexturerect,0,0,[PixelsToCoverWidth]/[ImageWidth],[PixelsToCoverHeight]/[ImageHeight]
--I said that I was gonna write it down. thx midi


-- METERS ////////////////////////
local style = ToEnumShortString(GAMESTATE:GetCurrentStyle():GetStyleType())


if style == "OnePlayerOneSide" and PREFSMAN:GetPreference("Center1Player") == true then
	t[#t+1] = LoadActor("centered_lifebar",GAMESTATE:GetMasterPlayerNumber())..{
		InitCommand=cmd(xy,SCREEN_CENTER_X,34);
	};
elseif style == "TwoPlayersTwoSides" or style == "OnePlayerOneSide" then
	for pn in ivalues(GAMESTATE:GetHumanPlayers()) do
		
		--The good lifebar
		t[#t+1] = LoadActor("lifebar", pn)..{
			InitCommand=cmd(y,34);
			OnCommand=function(self)
				if pn == PLAYER_1 then
					self:x(SCREEN_WIDTH/4);
					self:horizalign(left);
				else
					self:x(SCREEN_WIDTH*.75);
					self:horizalign(right);
				end;
			end;
		};
	end;
else
	--DANGER double
	t[#t+1] = LoadActor("danger") .. {
		InitCommand=cmd(visible,false;horizalign,center;x,SCREEN_CENTER_X;vertalign,top;y,SCREEN_TOP+16;zoomtowidth,SCREEN_WIDTH-36;zoomy,0.5); 
		OnCommand=cmd(effectclock,"bgm";diffuseshift;effectcolor1,color("#FFFFFFFF");effectcolor2,color("#FFFFFF66"));
			
		HealthStateChangedMessageCommand=function(self,params)
				if params.HealthState == 'HealthState_Dead' then
				self:visible(false);
			end;
		end;
		
		LifeChangedMessageCommand=function(self,params)
			local life = params.LifeMeter:GetLife();
			local style = GAMESTATE:GetCurrentStyle();
			if style:GetStyleType() == "StyleType_OnePlayerTwoSides" then
				if life <= THEME:GetMetric("LifeMeterBar", "DangerThreshold") then
					self:visible(true);
					else
					self:visible(false);
					end;
			end;
		end;
	};


	-- Doubles... And legacy code.
	t[#t+1] = LoadActor("doubles_lifebar", PLAYER_1)..{
		InitCommand=cmd(visible,GAMESTATE:IsHumanPlayer(PLAYER_1);xy,SCREEN_CENTER_X,34);

	}

	--[[t[#t+1] = LoadActor("tip") .. {	
			InitCommand=cmd(visible,GAMESTATE:IsHumanPlayer(PLAYER_1);valign,0.5;y,SCREEN_TOP+41;zoom,0.5;blend,Blend.Add;queuecommand,"Set"); 

			
			LifeChangedMessageCommand=function(self,params)
					if params.Player == PLAYER_1 then	
					local style = GAMESTATE:GetCurrentStyle();		
					local lifeP1 = params.LifeMeter:GetLife();
							
							if lifeP1 <= THEME:GetMetric("LifeMeterBar", "DangerThreshold") then
								self:diffusecolor(1,0.7,0.7,0.7);
								else
								self:diffusecolor(1,1,1,1);
								end
							
								if GAMESTATE:IsHumanPlayer(PLAYER_1)==true then
									if lifeP1==0 then
										self:visible(false);
									else
										self:visible(true);
									end
								end
								
								if style:GetStyleType() == "StyleType_OnePlayerTwoSides" then
									if lifeP1 == 1 then
									self:x((SCREEN_WIDTH-40)*lifeP1+17);

									else

									self:x((SCREEN_WIDTH-40)*lifeP1+20);
								
									end
								else
									self:x((SCREEN_WIDTH/2-26)*lifeP1+20);	
								end;
								
						end;
			end;

	};]]
end

for pn in ivalues(GAMESTATE:GetHumanPlayers()) do
	--NAME
	t[#t+1] = LoadFont("venacti/_venacti_outline 26px bold diffuse") .. {
		InitCommand=cmd(maxwidth,300;y,SCREEN_TOP+14;zoom,0.45;shadowlength,1;uppercase,true);
		OnCommand=function(self)
			if pn == PLAYER_1 then
				self:horizalign(left);
				self:x(SCREEN_LEFT+30);
			else
				self:horizalign(right);
				self:x(SCREEN_RIGHT-30);
			end;
		end;
	
		
		BeginCommand=function(self)
			local profile = PROFILEMAN:GetProfile(pn);
			local name = profile:GetDisplayName();
			
			if GAMESTATE:IsHumanPlayer(pn) == true then
				if name=="" and SCREENMAN:GetTopScreen():GetName() ~= "ScreenDemonstration" then
					self:settext("Player");
				else
					self:settext( name );
				end
			end	
			
		end;
	};
end;

-- Progress bar
t[#t+1] = Def.ActorFrame{

	InitCommand=cmd(y,SCREEN_BOTTOM-20);
	OnCommand=cmd(visible,SCREENMAN:GetTopScreen():GetName() ~= "ScreenDemonstration");
	LoadActor("progressmeter")..{
		InitCommand=cmd(diffusealpha,.8;zoomx,0;horizalign,left;x,SCREEN_CENTER_X-607/2);
		OnCommand=cmd(sleep,math.abs(GAMESTATE:GetCurrentSong():GetFirstBeat());linear,GAMESTATE:GetCurrentSong():GetStepsSeconds();zoomx,1);
	};

	LoadActor("progress-bar")..{
		InitCommand=cmd(x,SCREEN_CENTER_X);
	};

};

--The current stage
--[[t[#t+1] = Def.ActorFrame{
	InitCommand=cmd(y,34;zoom,0.8);
	OnCommand=function(self)
		if style == "OnePlayerOneSide" and PREFSMAN:GetPreference("Center1Player") == true then
			self:x(SCREEN_CENTER_X-210);
		else
			self:x(SCREEN_CENTER_X);
		end;
	end;
	
	LoadActor(THEME:GetPathG("ScreenGameplay", "stage icon"))..{
	};
	
	LoadFont("combo/_handelgothic bt 70px") .. {
		InitCommand=cmd(addy,5;zoom,.5);
		--Text="Hello World";
		OnCommand=function(self)
			self:settextf("%02d",GAMESTATE:GetCurrentStageIndex()+1);
		end;
	};
}]]

			
--[[ MISC ///////////////////////////////////


	gonna save this for later


	HealthStateChangedMessageCommand=function(self,params)
		 local failure = (params.HealthState);
		 if params.PlayerNumber == PLAYER_1 then
			if failure=="HealthState_Dead" then  
				self:visible(false)
			end;
		 end;
    end;
	
	
	
	
	
	
	]]
			

return t
