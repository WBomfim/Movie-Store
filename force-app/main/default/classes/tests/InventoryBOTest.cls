@isTest
public with sharing class InventoryBOTest {
  @isTest
  public static void testHandleTriggerBeforeUpdate() {
    InventoryBO inventoryBO = new InventoryBO();

    Id inventoryId = SeedersToTests.createInventory('Suits');
    Id inventoryItemId01 = SeedersToTests.createInventoryItem(inventoryId);
    Id inventoryItemId02 = SeedersToTests.createInventoryItem(inventoryId);

    Inventory__c inventory = [SELECT Id, Name, Active__c FROM Inventory__c WHERE Id = :inventoryId];

    inventoryBO.handleTriggerBeforeUpdate(new List<Inventory__c>{ inventory });

    List<InventoryItem__c> inventoryItemsActive = [SELECT Id, Name, Active__c FROM InventoryItem__c WHERE Inventory__c = :inventoryId];
    For (InventoryItem__c inventoryItem : inventoryItemsActive) {
      Assert.isTrue(inventoryItem.Active__c, 'InventoryItem should be active');
    }

    inventory.Active__c = false;
    update inventory;

    inventoryBO.handleTriggerBeforeUpdate(new List<Inventory__c>{ inventory });

    List<InventoryItem__c> inventoryItemsInactive = [SELECT Id, Name, Active__c FROM InventoryItem__c WHERE Inventory__c = :inventoryId];
    For (InventoryItem__c inventoryItem : inventoryItemsInactive) {
      Assert.isFalse(inventoryItem.Active__c, 'InventoryItem should be inactive');
    }
  }

  @isTest
  public static void testVerifyInventoryAvailable() {
    InventoryBO inventoryBO = new InventoryBO();
    InventoryException error;

    Id inventoryId01 = SeedersToTests.createInventory('Suits');
    Id inventoryItem01 = SeedersToTests.createInventoryItem(inventoryId01);
    InventoryItem__c inventoryItem = [SELECT Id, Name, Active__c FROM InventoryItem__c WHERE Id = :inventoryItem01];
    inventoryItem.Status__c = 'Rented';
    update inventoryItem;

    Id inventoryId02 = SeedersToTests.createInventory('O Poço');
    Id inventoryItem02 = SeedersToTests.createInventoryItem(inventoryId02);

    Test.startTest();
    try {
      inventoryBO.verifyInventoryAvailable(new Set<Id>{ inventoryId01, inventoryId02 });
    } catch (InventoryException e) {
      error = e;
    }
    Test.stopTest();

    Assert.areNotEqual(null, error, 'Should throw an error');
    Assert.areEqual('O Poço have item available', error.getMessage(), 'Should throw an error');
  }

  @isTest
  public static void testVerifyActiveInventory() {
    InventoryBO inventoryBO = new InventoryBO();
    InventoryException error;

    Id inventoryId01 = SeedersToTests.createInventory('Suits');
    Id inventoryId02 = SeedersToTests.createInventory('O Poço');

    Inventory__c inventory = [SELECT Id, Name, Active__c FROM Inventory__c WHERE Id = :inventoryId01];
    inventory.Active__c = false;
    update inventory;

    Test.startTest();
    try {
      inventoryBO.verifyActiveInventory(new Set<Id>{ inventoryId01, inventoryId02 });
    } catch (InventoryException e) {
      error = e;
    }

    Assert.areNotEqual(null, error, 'Should throw an error');
    Assert.areEqual('Suits is not active', error.getMessage(), 'Should throw an error');
  }
}