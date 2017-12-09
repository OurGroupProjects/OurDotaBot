

----------------------------------------------------------------------------------------------------

function Think()
   if ( GetTeam() == TEAM_RADIANT )
   then
      print( "selecting radiant" );
      SelectHero( 2, "npc_dota_hero_nevermore" );
      SelectHero( 3, "npc_dota_hero_lion" );
      SelectHero( 4, "npc_dota_hero_lion" );
      SelectHero( 5, "npc_dota_hero_lion" );
      SelectHero( 6, "npc_dota_hero_lion" );
   elseif ( GetTeam() == TEAM_DIRE )
   then
      print( "selecting dire" );
      SelectHero( 7, "npc_dota_hero_nevermore" );
      SelectHero( 8, "npc_dota_hero_lion" );
      SelectHero( 9, "npc_dota_hero_lion" );
      SelectHero( 10, "npc_dota_hero_lion" );
      SelectHero( 11, "npc_dota_hero_lion" );
   end

end

----------------------------------------------------------------------------------------------------
