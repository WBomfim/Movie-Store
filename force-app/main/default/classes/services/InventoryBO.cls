public with sharing class InventoryBO {
  InventoryDAO inventoryDAO = new InventoryDAO();
  InventoryItemDAO inventoryItemDAO = new InventoryItemDAO();

  public void handleTriggerBeforeUpdate(List<Inventory__c> inventoryList) {
    Set<Id> inventoryIds = new Set<Id>();
    
    for (Inventory__c inventory : inventoryList) {
      if (!inventory.Active__c) {
        inventoryIds.add(inventory.Id);
      }
    }

    if (!inventoryIds.isEmpty()) {
      this.inactiveItems(inventoryIds);
    }
  }

  public void verifyInventoryAvailable(Set<Id> inventoryIds) {
    List<Inventory__c> inventoryList = inventoryDAO.findByIds(inventoryIds);
    
    for (Inventory__c inventory : inventoryList) {
      if (inventory.InventoryStatus__c == 'Available') {
        throw new InventoryException(inventory.Name + ' have item available');
      }
    }
  }

  public void verifyActiveInventory(Set<Id> inventoryIds) {
    List<Inventory__c> inventoryList = inventoryDAO.findByIds(inventoryIds);
    
    for (Inventory__c inventory : inventoryList) {
      if (!inventory.Active__c) {
        throw new InventoryException(inventory.Name + ' is not active');
      }
    }
  }

  public void inactiveItems(Set<Id> inventoryIds) {
    List<InventoryItem__c> inventoryItemList = inventoryItemDAO.findByInventoryIds(inventoryIds);
    
    for (InventoryItem__c inventoryItem : inventoryItemList) {
      inventoryItem.Active__c = false;
    }
    
    update inventoryItemList;
  }
}
