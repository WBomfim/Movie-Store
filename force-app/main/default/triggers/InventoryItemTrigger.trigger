trigger InventoryItemTrigger on InventoryItem__c (before update) {
  InventoryItemBO inventoryItemBO = new InventoryItemBO();

  inventoryItemBO.handleTriggerBeforeUpdate(Trigger.new);
}
