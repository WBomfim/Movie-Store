public with sharing class ReservationDAO {
  public List<Reservation__c> findByInventoryId(Id inventoryId) {
    return [
      SELECT
        Id,
        Name,
        Contact__c,
        Inventory__c,
        InventoryItem__c,
        ReservationStatus__c,
        CreatedDate,
        StartAwaitingRent__c
      FROM Reservation__c
      WHERE Inventory__c = :inventoryId
      AND ReservationStatus__c = 'Awaiting Item'
      ORDER BY Name ASC
    ];
  }
  
  public List<Reservation__c> findByAwaitingRent() {
    return [
      SELECT
        Id,
        Name,
        Contact__c,
        Inventory__c,
        InventoryItem__c,
        ReservationStatus__c,
        CreatedDate,
        StartAwaitingRent__c
      FROM Reservation__c
      WHERE ReservationStatus__c = 'Awaiting Rent'
    ];
  }

  public List<Reservation__c> findByContactAndItem(Id contactId, Id itemId) {
    return [
      SELECT
        Id,
        Name,
        Contact__c,
        Inventory__c,
        InventoryItem__c,
        ReservationStatus__c,
        CreatedDate,
        StartAwaitingRent__c
      FROM Reservation__c
      WHERE Contact__c = :contactId
      AND InventoryItem__c = :itemId
      AND ReservationStatus__c = 'Awaiting Rent'
    ];
  }

  public List<Reservation__c> findByContactAndInventory(Id contactId, Id inventoryId) {
    return [
      SELECT
        Id,
        Name,
        Contact__c,
        Inventory__c,
        InventoryItem__c,
        ReservationStatus__c,
        CreatedDate,
        StartAwaitingRent__c
      FROM Reservation__c
      WHERE Contact__c = :contactId
      AND Inventory__c = :inventoryId
      AND ReservationStatus__c IN ('Awaiting Item', 'Awaiting Rent')
    ];
  }
}
