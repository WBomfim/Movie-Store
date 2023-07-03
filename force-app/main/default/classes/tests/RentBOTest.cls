@isTest
public with sharing class RentBOTest {
  @isTest
  public static void testHandleTriggerBeforeInsert() {
    RentBO rentBO = new RentBO();

    Id contactId = SeedersToTests.createContactNormalStatus('Teste', 'Normal');
    Id inventoryId = SeedersToTests.createInventory('Suits');
    Id inventoryItemId = SeedersToTests.createInventoryItem(inventoryId);

    Id rentId = SeedersToTests.createRentInProgress(contactId, inventoryItemId);

    List<Rent__c> rents = [
      SELECT LocationStatus__c, Contact__c, InventoryItem__c FROM Rent__c WHERE Id = :rentId
    ];

    rentBO.handleTriggerBeforeInsert(rents);

    InventoryItem__c inventoryItem = [
      SELECT Status__c FROM InventoryItem__c WHERE Id = :inventoryItemId
    ];

    Assert.areEqual('Rented', inventoryItem.Status__c);

    Id reservationId = SeedersToTests.createReservation(contactId, inventoryId);

    inventoryItem.Status__c = 'Available';
    update inventoryItem;

    rentBO.handleTriggerBeforeInsert(rents);

    inventoryItem = [
      SELECT Status__c FROM InventoryItem__c WHERE Id = :inventoryItemId
    ];

    Reservation__c reservation = [
      SELECT ReservationStatus__c, InventoryItem__c FROM Reservation__c WHERE Id = :reservationId
    ];

    Assert.areEqual('Rented', inventoryItem.Status__c);
    Assert.areEqual('Rented', reservation.ReservationStatus__c);
  }

  @isTest
  public static void testHandleTriggerBeforeUpdate() {
    RentBO rentBO = new RentBO();

    Id contactId = SeedersToTests.createContactNormalStatus('Teste', 'Normal');
    Id inventoryId = SeedersToTests.createInventory('Suits');
    Id inventoryItemId01 = SeedersToTests.createInventoryItem(inventoryId);
    Id inventoryItemId02 = SeedersToTests.createInventoryItem(inventoryId);

    Id rentIdOld = SeedersToTests.createRentInProgress(contactId, inventoryItemId01);
    List<Rent__c> oldRents = [
      SELECT LocationStatus__c, Contact__c, InventoryItem__c FROM Rent__c WHERE Id = :rentIdOld
    ];

    Id rentIdNew = SeedersToTests.createRentLate(contactId, inventoryItemId02);
    List<Rent__c> newRents = [
      SELECT LocationStatus__c, Contact__c, InventoryItem__c, LocationFinished__c FROM Rent__c WHERE Id = :rentIdNew
    ];
    
    rentBO.handleTriggerBeforeUpdate(oldRents, newRents);

    Contact contact = [
      SELECT ContactStatus__c FROM Contact WHERE Id = :contactId
    ];

    Assert.areEqual('Defaulting', contact.ContactStatus__c);

    contact.ContactStatus__c = 'Normal';
    update contact;

    newRents[0].LocationFinished__c = true;
    update newRents;

    newRents = [
      SELECT LocationStatus__c, Contact__c, InventoryItem__c, LocationFinished__c FROM Rent__c WHERE Id = :rentIdNew
    ];

    rentBO.handleTriggerBeforeUpdate(oldRents, newRents);

    contact = [
      SELECT ContactStatus__c FROM Contact WHERE Id = :contactId
    ];

    InventoryItem__c inventoryItem02 = [
      SELECT Status__C FROM InventoryItem__c WHERE Id = :inventoryItemId02
    ];

    Assert.areEqual('Normal', contact.ContactStatus__c);
    Assert.areEqual('Available', inventoryItem02.Status__c);
    
    inventoryItem02.Status__c = 'Rented';
    update inventoryItem02;

    contact.ContactStatus__c = 'Defaulting';
    update contact;

    oldRents[0].ValidationRulesIgnore__c = true;
    oldRents[0].CloseDate__c = Date.today().addDays(-1);
    update oldRents;

    oldRents = [
      SELECT LocationStatus__c, Contact__c, InventoryItem__c, ValidationRulesIgnore__c, CloseDate__c FROM Rent__c WHERE Id = :rentIdOld
    ];

    rentBO.handleTriggerBeforeUpdate(oldRents, newRents);

    contact = [
      SELECT ContactStatus__c FROM Contact WHERE Id = :contactId
    ];

    InventoryItem02 = [
      SELECT Status__C FROM InventoryItem__c WHERE Id = :inventoryItemId02
    ];

    Assert.areEqual('Normal', contact.ContactStatus__c);
    Assert.areEqual('Available', inventoryItem02.Status__c);
  }

  @isTest
  public static void testFindRentLateByContact() {
    RentBO rentBO = new RentBO();

    Id contactId = SeedersToTests.createContactNormalStatus('Teste', 'Normal');
    Id inventoryId = SeedersToTests.createInventory('Suits');
    Id inventoryItemId01 = SeedersToTests.createInventoryItem(inventoryId);
    Id inventoryItemId02 = SeedersToTests.createInventoryItem(inventoryId);

    SeedersToTests.createRentLate(contactId, inventoryItemId01);
    SeedersToTests.createRentLate(contactId, inventoryItemId02);

    Map<Id, Integer> rentLateByContact = rentBO.findRentLateByContact(new Set<Id>{contactId});

    Assert.areEqual(2, rentLateByContact.get(contactId));
  }

  @isTest
  public static void testFindContactsWithOneLateRent() {
    RentBO rentBO = new RentBO();

    Id contactId = SeedersToTests.createContactNormalStatus('Teste', 'Normal');
    Id inventoryId = SeedersToTests.createInventory('Suits');
    Id inventoryItemId = SeedersToTests.createInventoryItem(inventoryId);

    SeedersToTests.createRentLate(contactId, inventoryItemId);

    Set<Id> contacts = rentBO.findContactsWithOneLateRent(new Set<Id>{contactId});

    Assert.areEqual(1, contacts.size());
  }

  @isTest
  public static void testFindContactsWithMoreThanOneLateRent() {
    RentBO rentBO = new RentBO();

    Id contactId = SeedersToTests.createContactNormalStatus('Teste', 'Normal');
    Id inventoryId = SeedersToTests.createInventory('Suits');
    Id inventoryItemId01 = SeedersToTests.createInventoryItem(inventoryId);
    Id inventoryItemId02 = SeedersToTests.createInventoryItem(inventoryId);

    SeedersToTests.createRentLate(contactId, inventoryItemId01);
    SeedersToTests.createRentLate(contactId, inventoryItemId02);

    Set<Id> contacts = rentBO.findContactsWithMoreThanOneLateRent(new Set<Id>{contactId});

    Assert.areEqual(1, contacts.size());
  }
}
