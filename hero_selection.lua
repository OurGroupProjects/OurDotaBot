

----------------------------------------------------------------------------------------------------

function Think()
	for i = 1, 11 do
		if (GameTime() > 12) then
			if (i == 4 or i == 9) then
				SelectHero(i, "npc_dota_hero_nevermore");
			else
				SelectHero(i, "npc_dota_hero_lina");
			end
		end
	end
	--[[
   if ( GetTeam() == TEAM_RADIANT )
   then
      print( "selecting radiant" );
      SelectHero( 2, "npc_dota_hero_lina" );
      SelectHero( 3, "npc_dota_hero_lina" );
      SelectHero( 4, "npc_dota_hero_lina" ); -- SelectHero( 4, "npc_dota_hero_nevermore" );
      SelectHero( 5, "npc_dota_hero_lina" );
      SelectHero( 6, "npc_dota_hero_lina" );
   elseif ( GetTeam() == TEAM_DIRE )
   then
      print( "selecting dire" );
      SelectHero( 7, "npc_dota_hero_lina" );
      SelectHero( 8, "npc_dota_hero_lina" );
      SelectHero( 9, "npc_dota_hero_nevermore" ); --SelectHero( 9, "npc_dota_hero_nevermore" );
      SelectHero( 10, "npc_dota_hero_lina" );
      SelectHero( 11, "npc_dota_hero_lina" );
   end --]]

end

----------------------------------------------------------------------------------------------------
