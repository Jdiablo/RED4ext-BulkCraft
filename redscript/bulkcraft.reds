@addField(CraftingMainGameController)
let m_quantityPickerPopupToken: ref<inkGameNotificationToken>;

@addField(CraftingMainGameController)
let m_selectedRecipe_id : ref<Item_Record>;

@addMethod(CraftingMainGameController)
private final func OpenQuantityPicker() -> Void {
	this.m_selectedRecipe_id = this.m_selectedRecipe.id;
    let data: ref<QuantityPickerPopupData>;
    data = new QuantityPickerPopupData();
    data.notificationName = n"base\gameplay\gui\widgets\notifications\item_quantity_picker.inkwidget";
    data.isBlocking = true;
    data.useCursor = true;
    data.queueName = n"modal_popup";
    data.maxValue = 5;
    data.gameItemData = this.m_dryInventoryItemData;
    
    this.m_quantityPickerPopupToken = this.ShowGameNotification(data);
    this.m_quantityPickerPopupToken.RegisterListener(this, n"OnQuantityPickerPopupClosed");
    this.m_buttonHintsController.Hide();
}

@addMethod(CraftingMainGameController)
protected cb func OnQuantityPickerPopupClosed(data: ref<inkGameNotificationData>) -> Bool {
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
	this.m_craftingSystem.QueueRequest(request);
    return true;
}