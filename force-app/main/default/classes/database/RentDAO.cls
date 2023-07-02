public with sharing class RentDAO {
  public List<Rent__c> findByContactAndStatus(Set<Id> contactsIds, String status) {
    return [
      SELECT Id,
      Name,
      InventoryItem__c,
      Contact__c
      FROM Rent__c
      WHERE Contact__c IN : contactsIds
      AND LocationStatus__c = :status
    ];
  }

  public List<Rent__c> findAllLateRents() {
    return [
      SELECT Id,
      Name,
      InventoryItem__c,
      Contact__c,
      LocationStatus__c
      FROM Rent__c
      WHERE CloseDate__c < TODAY
      AND LocationFinished__c = false
    ];
  }
}
