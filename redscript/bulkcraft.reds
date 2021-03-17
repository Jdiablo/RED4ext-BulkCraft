@addField(UI_CraftingDef)
public let m_CraftingController: wref<IScriptable>;

@addField(CraftingMainGameController)
let m_quantityPickerPopupToken: ref<inkGameNotificationToken>;

@addField(CraftingMainGameController)
let m_selectedRecipe_id : ref<Item_Record>;

@replaceMethod(CraftingMainGameController)
private final func SetupBB() -> Void {
	this.m_craftingDef = GetAllBlackboardDefs().UI_Crafting;
	this.m_craftingBlackboard = this.GetBlackboardSystem().Get(this.m_craftingDef);
	if NotEquals(this.m_craftingBlackboard, null) {
	  this.m_craftingBBID = this.m_craftingBlackboard.RegisterDelayedListenerVariant(this.m_craftingDef.lastItem, this, n"OnCraftingComplete", true);
	};

	this.m_craftingDef.m_CraftingController = this;
	this.m_buttonHintsController.AddButtonHint(n"disassemble_item", "Bulk craft");
}

@replaceMethod(CraftingMainGameController)
private final func RemoveBB() -> Void {
    if NotEquals(this.m_craftingBlackboard, null) {
      this.m_craftingBlackboard.UnregisterDelayedListener(this.m_craftingDef.lastItem, this.m_craftingBBID);
    };
	this.m_craftingDef.m_CraftingController = null;
    this.m_craftingBlackboard = null;
}
  
@replaceMethod(CraftingMainGameController)
protected cb func OnRecipeSelect(previous: ref<inkVirtualCompoundItemController>, next: ref<inkVirtualCompoundItemController>) -> Bool {
    let craftableController: ref<CraftableItemLogicController>;
    let previousCraftableController: ref<CraftableItemLogicController>;
    craftableController = (next as CraftableItemLogicController);
    previousCraftableController = (previous as CraftableItemLogicController);
    if NotEquals(previousCraftableController, null) {
      previousCraftableController.SelectSlot(false);
    };
    craftableController.SelectSlot(true);
    this.UpdateItemPreview(craftableController, true);
	if Equals(this.m_mode, CraftingMode.craft) {
		if Equals(this.m_dryInventoryItemData.CategoryName, "Weapon") || Equals(this.m_dryInventoryItemData.CategoryName, "Clothing") {
			this.m_buttonHintsController.RemoveButtonHint(n"disassemble_item");
		} else {
			this.m_buttonHintsController.AddButtonHint(n"disassemble_item", "Bulk craft");
		};
	};
  }

@replaceMethod(CraftingMainGameController)  
private final func ChangeMode(mode: CraftingMode) -> Void {
	this.m_mode = mode;
	this.SetFilters(false);
	if Equals(this.m_mode, CraftingMode.craft) {
		inkWidgetRef.SetVisible(this.m_filterRoot_Crafting, true);
		inkWidgetRef.SetVisible(this.m_filterRoot_Upgrading, false);
		inkWidgetRef.RegisterToCallback(this.m_sortingButton_Crafting, n"OnRelease", this, n"OnSortingButtonClicked");
		inkWidgetRef.UnregisterFromCallback(this.m_sortingButton_Upgrading, n"OnRelease", this, n"OnSortingButtonClicked");
		inkWidgetRef.SetVisible(this.m_sortingDropdown_Crafting, true);
		inkWidgetRef.SetVisible(this.m_sortingDropdown_Upgrading, false);
	} else {
		inkWidgetRef.SetVisible(this.m_filterRoot_Crafting, false);
		inkWidgetRef.SetVisible(this.m_filterRoot_Upgrading, true);
		inkWidgetRef.UnregisterFromCallback(this.m_sortingButton_Crafting, n"OnRelease", this, n"OnSortingButtonClicked");
		inkWidgetRef.RegisterToCallback(this.m_sortingButton_Upgrading, n"OnRelease", this, n"OnSortingButtonClicked");
		inkWidgetRef.SetVisible(this.m_sortingDropdown_Crafting, false);
		inkWidgetRef.SetVisible(this.m_sortingDropdown_Upgrading, true);
		this.m_buttonHintsController.RemoveButtonHint(n"disassemble_item");
	};
}

@addMethod(CraftingSystem)
private final func CraftFewItems(target: wref<GameObject>, itemRecord: ref<Item_Record>, amount: Int32) -> wref<gameItemData> {
    let ingredientRecords: array<wref<RecipeElement_Record>>;
    let requiredIngredients: array<IngredientData>;
    let tempStat: Float;
    let ingredient: ItemID;
    let transactionSystem: ref<TransactionSystem>;
    let statsSystem: ref<StatsSystem>;
    let j: Int32;
    let i: Int32;
    let craftedItemID: ItemID;
    let itemData: wref<gameItemData>;
    let randF: Float;
    let xpID: TweakDBID;
    let recipeXP: Int32;
    let ingredientQuality: gamedataQuality;
    transactionSystem = GameInstance.GetTransactionSystem(this.GetGameInstance());
    statsSystem = GameInstance.GetStatsSystem(this.GetGameInstance());
    randF = RandF();
    itemRecord.CraftingData().CraftingRecipe(ingredientRecords);
    requiredIngredients = this.GetItemCraftingCost(ingredientRecords);
    i = 0;
    while i < ArraySize(requiredIngredients) {
      ingredient = ItemID.CreateQuery(requiredIngredients[i].id.GetID());
      if RPGManager.IsItemWeapon(ingredient) || RPGManager.IsItemClothing(ingredient) {
        itemData = transactionSystem.GetItemData(target, ingredient);
        this.ClearNonIconicSlots(itemData);
      } else {
        i += 1;
      };
    };
    tempStat = statsSystem.GetStatValue(Cast(target.GetEntityID()), gamedataStatType.CraftingMaterialRetrieveChance);
    i = 0;
    while i < ArraySize(requiredIngredients) {
      ingredient = ItemID.CreateQuery(requiredIngredients[i].id.GetID());
      if RPGManager.IsItemWeapon(ingredient) || RPGManager.IsItemClothing(ingredient) {
        randF = 100.00;
      };
      if randF >= tempStat {
        transactionSystem.RemoveItem(target, ingredient, requiredIngredients[i].quantity * amount);
      };
      ingredientQuality = RPGManager.GetItemQualityFromRecord(TweakDBInterface.GetItemRecord(requiredIngredients[i].id.GetID()));
      if Equals(ingredientQuality, gamedataQuality.Common) {
		xpID = t"Constants.CraftingSystem.commonIngredientXP";
	  };
	  if Equals(ingredientQuality, gamedataQuality.Uncommon) {
		xpID = t"Constants.CraftingSystem.uncommonIngredientXP";
	  };
	  if Equals(ingredientQuality, gamedataQuality.Rare) {
		xpID = t"Constants.CraftingSystem.rareIngredientXP";
	  };
	  if Equals(ingredientQuality, gamedataQuality.Epic) {
		xpID = t"Constants.CraftingSystem.epicIngredientXP";
	  };
	  if Equals(ingredientQuality, gamedataQuality.Legendary) {
		xpID = t"Constants.CraftingSystem.legendaryIngredientXP";
	  };
      recipeXP += TweakDBInterface.GetInt(xpID, 0) * requiredIngredients[i].quantity * amount;
      i += 1;
    };
    craftedItemID = ItemID.FromTDBID(itemRecord.GetID());
    transactionSystem.GiveItem(target, craftedItemID, amount);
    if Equals(itemRecord.ItemType().Type(), gamedataItemType.Prt_Program) {
      this.ProcessProgramCrafting(itemRecord.GetID());
    };
    itemData = transactionSystem.GetItemData(target, craftedItemID);
    this.ProcessCraftingPerksData(target, itemRecord, itemData);
    this.SetItemLevel(itemData);
    this.MarkItemAsCrafted(itemData);
    this.SendItemCraftedDataTrackingRequest(craftedItemID);
    this.ProcessCraftSkill(recipeXP, itemData.GetStatsObjectID());
    return itemData;
}

@addMethod(CraftingSystem)
public final const func MaxCraftableQuantity(itemRecord: ref<Item_Record>) -> Int32 {
	let ingredientRecords: array<wref<RecipeElement_Record>>;
	let required: array<IngredientData>;
	
	itemRecord.CraftingData().CraftingRecipe(ingredientRecords);
    required = this.GetItemCraftingCost(ingredientRecords);
	
    let i: Int32;
	let max: Int32;
	let curMax: Int32;
	max = 5000;
	curMax = 0;
    let currentQuantity: Int32;
    let transactionSystem: ref<TransactionSystem>;
    transactionSystem = GameInstance.GetTransactionSystem(this.GetGameInstance());
    i = 0;
    while i < ArraySize(required) {
      currentQuantity = transactionSystem.GetItemQuantity(this.m_playerCraftBook.GetOwner(), ItemID.CreateQuery(required[i].id.GetID()));
	  if (currentQuantity < required[i].quantity) {
		return 0;
	  };
	  curMax = currentQuantity / required[i].quantity;
      if curMax < max {
		max = curMax;
      };
      i += 1;
    };
    return max;
}

@addMethod(CraftingMainGameController)
private final func OpenQuantityPicker() -> Void {
	if !inkWidgetRef.IsVisible(this.m_craftingRoot) || Equals(this.m_dryInventoryItemData.CategoryName, "Weapon") || Equals(this.m_dryInventoryItemData.CategoryName, "Clothing") {
		return;
	};
	this.m_quantityPickerPopupToken = null;
	this.m_selectedRecipe_id = this.m_selectedRecipe.id;
    let data: ref<QuantityPickerPopupData>;
    data = new QuantityPickerPopupData();
    data.notificationName = n"base\gameplay\gui\widgets\notifications\item_quantity_picker.inkwidget";
    data.isBlocking = true;
    data.useCursor = true;
    data.queueName = n"modal_popup";
	let maxValue: Int32;
	maxValue = this.m_craftingSystem.MaxCraftableQuantity(this.m_selectedRecipe_id);
	if (maxValue < 2) {
		return;
	};
    data.maxValue = maxValue;
    data.gameItemData = this.m_dryInventoryItemData;
    
    this.m_quantityPickerPopupToken = this.ShowGameNotification(data);
    this.m_quantityPickerPopupToken.RegisterListener(this, n"OnQuantityPickerPopupClosed");
    this.m_buttonHintsController.Hide();
}

@addMethod(CraftingMainGameController)
protected cb func OnQuantityPickerPopupClosed(data: ref<inkGameNotificationData>) -> Bool {
	this.m_buttonHintsController.Show();
	let quantityData: ref<QuantityPickerPopupCloseData>;
    this.m_quantityPickerPopupToken = null;
    quantityData = (data as QuantityPickerPopupCloseData);
    if quantityData.choosenQuantity < 1 {
		return false;
	}
	
	this.PlaySound(n"Item", n"OnCraftted");
    this.RefreshUI();
	
	let request: ref<CraftItemRequest>;
	request = new CraftItemRequest();
	request.target = this.m_player;
	request.itemRecord = this.m_selectedRecipe_id;
	request.amount = quantityData.choosenQuantity;
	this.m_craftingSystem.CraftFewItems(this.m_player, this.m_selectedRecipe_id, quantityData.choosenQuantity);
	
    return true;
}