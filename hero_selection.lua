

----------------------------------------------------------------------------------------------------

function Think()
   if ( GetTeam() == TEAM_RADIANT )
   then
      print( "selecting radiant" );
      SelectHero( 5, "npc_dota_hero_lina" );
      SelectHero( 6, "npc_dota_hero_lina" );
      SelectHero( 2, "npc_dota_hero_lina" );
      SelectHero( 3, "npc_dota_hero_lina" );
      SelectHero( 4, "npc_dota_hero_nevermore" );
   elseif ( GetTeam() == TEAM_DIRE )
   then
      print( "selecting dire" );
      SelectHero( 10, "npc_dota_hero_lina" );
      SelectHero( 11, "npc_dota_hero_lina" );
      SelectHero( 7, "npc_dota_hero_lina" );
      SelectHero( 8, "npc_dota_hero_lina" );
      SelectHero( 9, "npc_dota_hero_nevermore" );
   end

end

----------------------------------------------------------------------------------------------------
