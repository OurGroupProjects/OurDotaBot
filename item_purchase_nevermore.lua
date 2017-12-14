

local tableItemsToBuy = { 
				"item_circlet",
				"item_slippers",
				"item_recipe_wraith_band",
				"item_enchanted_mango",
				"item_enchanted_mango",
				"item_enchanted_mango",
				"item_enchanted_mango",
				"item_enchanted_mango",
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

	if ( npcBot:GetGold() >= GetItemCost( sNextItem ) )
	then
		npcBot:ActionImmediate_PurchaseItem( sNextItem );
		table.remove( tableItemsToBuy, 1 );
	end

end

----------------------------------------------------------------------------------------------------
