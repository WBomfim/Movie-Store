public with sharing class InventoryDAO {
  public List<Inventory__c> findByIds(Set<Id> inventoryIds) {
    return [
      SELECT Id,
      Name,
      InventoryStatus__c,
      Active__c
      FROM Inventory__c
      WHERE Id IN :inventoryIds
    ];
  }
}
