public with sharing class InventoryItemDAO {
  public List<InventoryItem__c> findByIds(Set<Id> inventoryItemsIds) {
    return [
      SELECT Id,
      Name,
      Status__c,
      Active__c
      FROM InventoryItem__c
      WHERE Id IN :inventoryItemsIds
    ];
  }

  public List<InventoryItem__c> findByInventoryIds(Set<Id> inventoriesIds) {
    return [
      SELECT Id,
      Name,
      Status__c,
      Active__c
      FROM InventoryItem__c
      WHERE Inventory__c IN :inventoriesIds
    ];
  }
}
