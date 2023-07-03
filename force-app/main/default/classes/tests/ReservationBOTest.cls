@isTest
public with sharing class ReservationBOTest {
  @isTest
  public static void testHandleTriggerBeforeInsert() {
    ReservationBO reservationBO = new ReservationBO();

    Id contactId01 = SeedersToTests.createContactNormalStatus('Teste01', 'Normal');
    Id contactId02 = SeedersToTests.createContactNormalStatus('Teste02', 'Normal');
    Id inventoryId = SeedersToTests.createInventory('Suits');
    Id inventoryItemId = SeedersToTests.createInventoryItem(inventoryId);

    SeedersToTests.createRentInProgress(contactId01, inventoryItemId);

    Reservation__c reservationByContactNormalStatus = new Reservation__c(
      Contact__c = contactId02,
      Inventory__c = inventoryId
    );

    reservationBO.handleTriggerBeforeInsert(new List<Reservation__c>{ reservationByContactNormalStatus });

    Id reservationId = SeedersToTests.createReservation(contactId02, inventoryId);
    List<Reservation__c> reservations = [
      SELECT Contact__c, Inventory__c FROM Reservation__c WHERE Id = :reservationId
    ];

    reservationBO.handleTriggerBeforeInsert(reservations);

    Assert.isTrue(reservations[0].getErrors().size() > 0, 'The Reservation should have errors');
    Assert.areEqual(
      'The Customer already has a reservation for this inventory',
      reservations[0].getErrors()[0].getMessage(),
      'The error message should be "The Customer already has a reservation for this inventory"'
    );

    Contact contact = [
      SELECT Id, ContactStatus__c FROM Contact WHERE Id = :contactId02
    ];
    contact.ContactStatus__c = 'Defaulting';
    update contact;

    Reservation__c reservationByContactDefaultingStatus = new Reservation__c(
      Contact__c = contactId02,
      Inventory__c = inventoryId
    );

    reservationBO.handleTriggerBeforeInsert(new List<Reservation__c>{ reservationByContactDefaultingStatus });
    
    String errorMessage = reservationByContactDefaultingStatus.getErrors()[0].getMessage();

    Assert.isTrue(errorMessage.contains('is defaulting'), 'The error message should contain "is defaulting"');
  }

  @isTest
  public static void testHandleTriggerBeforeUpdate() {
    ReservationBO reservationBO = new ReservationBO();

    Id contactId01 = SeedersToTests.createContactNormalStatus('Teste01', 'Normal');
    Id contactId02 = SeedersToTests.createContactNormalStatus('Teste02', 'Normal');
    Id inventoryId = SeedersToTests.createInventory('Suits');
    Id inventoryItemId = SeedersToTests.createInventoryItem(inventoryId);

    Id rent = SeedersToTests.createRentInProgress(contactId01, inventoryItemId);
    Id reservation = SeedersToTests.createReservation(contactId02, inventoryId);

    Rent__c rentInProgress = [
      SELECT Id, LocationStatus__c, LocationFinished__c FROM Rent__c WHERE Id = :rent
    ];
    rentInProgress.LocationFinished__c = true;
    update rentInProgress;

    Reservation__c reservationToUpdate = [
      SELECT Id, Contact__c, Inventory__c, InventoryItem__c, ReservationStatus__c FROM Reservation__c WHERE Id = :reservation
    ];
    reservationToUpdate.ReservationStatus__c = 'Canceled';

    reservationBO.handleTriggerBeforeUpdate(new List<Reservation__c>{ reservationToUpdate });

    InventoryItem__c inventoryItem = [
      SELECT Id, Status__c FROM InventoryItem__c WHERE Id = :inventoryItemId
    ];

    Assert.areEqual('Available', inventoryItem.Status__c, 'The InventoryItem should be available');
  }

  @isTest
  public static void testVerifyReservatioPeriod() {
    ReservationBO reservationBO = new ReservationBO();

    Id contactId01 = SeedersToTests.createContactNormalStatus('Teste01', 'Normal');
    Id contactId02 = SeedersToTests.createContactNormalStatus('Teste02', 'Normal');
    Id inventoryId = SeedersToTests.createInventory('Suits');
    Id inventoryItemId = SeedersToTests.createInventoryItem(inventoryId);

    Id rentId = SeedersToTests.createRentInProgress(contactId01, inventoryItemId);
    Id reservationId = SeedersToTests.createReservation(contactId02, inventoryId);

    Rent__c rentInProgress = [
      SELECT Id, LocationStatus__c, LocationFinished__c FROM Rent__c WHERE Id = :rentId
    ];
    rentInProgress.LocationFinished__c = true;
    update rentInProgress;

    Reservation__c reservationToUpdate = [
      SELECT StartAwaitingRent__c, ReservationStatus__c FROM Reservation__c WHERE Id = :reservationId
    ];
    reservationToUpdate.StartAwaitingRent__c = DateTime.now().addDays(-1);
    update reservationToUpdate;

    reservationBO.verifyReservatioPeriod();

    Reservation__c reservationUpdated = [
      SELECT ReservationStatus__c FROM Reservation__c WHERE Id = :reservationId
    ];

    Assert.areEqual('Canceled', reservationUpdated.ReservationStatus__c, 'The Reservation should be canceled');

    InventoryItem__c inventoryItem = [
      SELECT Id, Status__c FROM InventoryItem__c WHERE Id = :inventoryItemId
    ];

    Assert.areEqual('Available', inventoryItem.Status__c, 'The InventoryItem should be available');
  }
}
