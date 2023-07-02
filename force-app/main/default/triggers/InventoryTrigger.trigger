trigger InventoryTrigger on Inventory__c (before update) {
  InventoryBO inventoryBO = new InventoryBO();

  inventoryBO.handleTriggerBeforeUpdate(Trigger.new);
}
