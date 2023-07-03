@isTest
public with sharing class InventoryItemBOTest {
  @isTest
  public static void testHandleTriggerBeforeUpdate() {
    InventoryItemBO inventoryItemBO = new InventoryItemBO();

    Id contactId = SeedersToTests.createContactNormalStatus('Teste', 'Normal');
    Id inventoryId = SeedersToTests.createInventory('Suits');
    Id inventoryItemId = SeedersToTests.createInventoryItem(inventoryId);

    List<InventoryItem__c> inventoryItems = [
      SELECT Id, Status__c, Active__c, Inventory__c FROM InventoryItem__c WHERE Id = :inventoryItemId
    ];

    inventoryItemBO.handleTriggerBeforeUpdate(inventoryItems);

    Assert.areEqual('Available', inventoryItems[0].Status__c, 'Status should be Available');

    inventoryItems[0].Status__c = 'Rented';
    update inventoryItems;

    Id reservationId = SeedersToTests.createReservation(contactId, inventoryId);

    inventoryItems[0].Status__c = 'Available';

    inventoryItemBO.handleTriggerBeforeUpdate(inventoryItems);

    Reservation__c reservation = [
      SELECT Id, ReservationStatus__c FROM Reservation__c WHERE Id = :reservationId
    ];

    Assert.areEqual('Awaiting Rent', reservation.ReservationStatus__c, 'Reservation status should be Await Rent');
    Assert.areEqual('Reserved', inventoryItems[0].Status__c, 'Status should be Reserved');

    Inventory__c inventory = [
      SELECT Id, Active__c FROM Inventory__c WHERE Id = :inventoryId
    ];
    inventory.Active__c = false;
    update inventory;

    inventoryItems[0].Status__c = 'Available';

    inventoryItemBO.handleTriggerBeforeUpdate(inventoryItems);

    String errorMessage = inventoryItems[0].getErrors()[0].getMessage();

    Assert.areEqual('Suits is not active', errorMessage, 'Status should be Unavailable');
  }

  @isTest
  public static void testChangeStatusToRented() {
    InventoryItemBO inventoryItemBO = new InventoryItemBO();

    Id inventoryId = SeedersToTests.createInventory('Suits');
    Id inventoryItemId = SeedersToTests.createInventoryItem(inventoryId);

    inventoryItemBO.changeStatusToRented(new Set<Id>{inventoryItemId});

    InventoryItem__c inventoryItem = [
      SELECT Id, Status__c FROM InventoryItem__c WHERE Id = :inventoryItemId
    ];

    Assert.areEqual('Rented', inventoryItem.Status__c, 'Status should be Rented');

    InventoryItemException error;

    try {
      inventoryItemBO.changeStatusToRented(new Set<Id>{inventoryItemId});
    } catch (InventoryItemException e) {
      error = e;
    }

    Assert.isNotNull(error, 'Should throw error');
    Assert.isTrue(error.getMessage().contains('is already rented'), 'Message should be is already rented');

    error = null;
    inventoryItem.Status__c = 'Reserved';
    update inventoryItem;

    try {
      inventoryItemBO.changeStatusToRented(new Set<Id>{inventoryItemId});
    } catch (InventoryItemException e) {
      error = e;
    }

    Assert.isNotNull(error, 'Should throw error');
    Assert.isTrue(error.getMessage().contains('is reserved'), 'Message should be is reserved');
  }

  @isTest
  public static void testChangeStatusToRentedDirect() {
    InventoryItemBO inventoryItemBO = new InventoryItemBO();

    Id inventoryId = SeedersToTests.createInventory('Suits');
    Id inventoryItemId = SeedersToTests.createInventoryItem(inventoryId);

    inventoryItemBO.changeStatusToRentedDirect(new Set<Id>{inventoryItemId});

    InventoryItem__c inventoryItem = [
      SELECT Id, Status__c FROM InventoryItem__c WHERE Id = :inventoryItemId
    ];

    Assert.areEqual('Rented', inventoryItem.Status__c, 'Status should be Rented');
  }

  @isTest
  public static void testChangeStatusToAvailable() {
    InventoryItemBO inventoryItemBO = new InventoryItemBO();

    Id inventoryId = SeedersToTests.createInventory('Suits');
    Id inventoryItemId = SeedersToTests.createInventoryItem(inventoryId);

    InventoryItem__c inventoryItem = [
      SELECT Id, Status__c FROM InventoryItem__c WHERE Id = :inventoryItemId
    ];
    inventoryItem.Status__c = 'Rented';
    update inventoryItem;

    Assert.areEqual('Rented', inventoryItem.Status__c, 'Status should be Rented');

    inventoryItemBO.changeStatusToAvailable(new Set<Id>{inventoryItemId});

    inventoryItem = [
      SELECT Id, Status__c FROM InventoryItem__c WHERE Id = :inventoryItemId
    ];

    Assert.areEqual('Available', inventoryItem.Status__c, 'Status should be Available');
  }

  @isTest
  public static void testVerifyActiveItems() {
    InventoryItemBO inventoryItemBO = new InventoryItemBO();

    Id inventoryId = SeedersToTests.createInventory('Suits');
    Id inventoryItemId = SeedersToTests.createInventoryItem(inventoryId);

    InventoryItem__c inventoryItem = [
      SELECT Id, Active__c FROM InventoryItem__c WHERE Id = :inventoryItemId
    ];
    inventoryItem.Active__c = false;
    update inventoryItem;

    InventoryItemException error;

    try {
      inventoryItemBO.verifyActiveItems(new Set<Id>{inventoryItemId});
    } catch (InventoryItemException e) {
      error = e;
    }

    Assert.isNotNull(error, 'Should throw error');
    Assert.isTrue(error.getMessage().contains('is not active'), 'Message should be is not active');
  }
}
