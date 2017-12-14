

local tableItemsToBuy = { 
				"item_circlet",
				"item_slippers",
				"item_recipe_wraith_band",
				"item_flask",
				"item_belt_of_strength",
				"item_belt_of_strength",
				"item_belt_of_strength",
				"item_belt_of_strength",
				"item_belt_of_strength",
				"item_belt_of_strength",
				"item_belt_of_strength",
				"item_belt_of_strength",
			};


----------------------------------------------------------------------------------------------------

function ItemPurchaseThink()

	local npcBot = GetBot();

	
	
	if ( #tableItemsToBuy == 0 )
	then
		npcBot:SetNextItemPurchaseValue( 0 );
		return;
	end

	local sNextItem = tableItemsToBuy[1];

	npcBot:SetNextItemPurchaseValue( GetItemCost( sNextItem ) );
	
	
	local myCourier;
	if (npcBot:GetTeam() == 2) then
		myCourier = GetCourier(2)
	elseif (npcBot:GetTeam() == 3) then
		myCourier = GetCourier(1)
	end
	
	local botTeamName = "Glitch";
	if (npcBot:GetTeam() == 2) then
		botTeamName = "Radi";
	elseif (npcBot:GetTeam() == 3) then
		botTeamName = "Dire"
	end;
	
	if ((npcBot:GetMaxHealth() - npcBot:GetHealth() > 400) and (npcBot:GetGold() >= GetItemCost("item_salve"))) then
		npcBot:ActionImmediate_PurchaseItem("item_salve");
		print(botTeamName .. " buying salve");
		if (npcBot:GetStashValue() + npcBot:GetCourierValue() > 0) then
			print(botTeamName .. " having salve delivered");
			npcBot:ActionImmediate_Courier(myCourier, COURIER_ACTION_TAKE_AND_TRANSFER_ITEMS);
		end;
	elseif ( npcBot:GetGold() >= GetItemCost( sNextItem ) ) then
		print(botTeamName .. " buying next item");
		npcBot:ActionImmediate_PurchaseItem( sNextItem );
		table.remove( tableItemsToBuy, 1 );
		if (npcBot:GetStashValue() + npcBot:GetCourierValue() > 0) then
			print(botTeamName .. " having item delivered");
			npcBot:ActionImmediate_Courier(myCourier, COURIER_ACTION_TAKE_AND_TRANSFER_ITEMS);
		end;
	end

end

----------------------------------------------------------------------------------------------------
