public with sharing class RentBO {
  RentDAO rentDAO = new RentDAO();
  ReservationDAO reservationDAO = new ReservationDAO();
  InventoryItemBO inventoryItemBO = new InventoryItemBO();

  public void handleTriggerBeforeInsert(List<Rent__c> rents) {
    ContactBO contactBO = new ContactBO();
    
    Map<Id, Id> contactsIdsAndInventoryItemsIds = new Map<Id, Id>();

    for (Rent__c rent : rents) {
      contactsIdsAndInventoryItemsIds.put(rent.Contact__c, rent.InventoryItem__c);
    }

    try {
      inventoryItemBO.verifyActiveItems(new Set<Id>(contactsIdsAndInventoryItemsIds.values()));
      contactBO.verifyDefaultingStatus(contactsIdsAndInventoryItemsIds.keySet());
      this.handleReservationToRented(contactsIdsAndInventoryItemsIds);
    } catch (Exception e) {
      for (Rent__c rent : rents) {
        rent.addError(e.getMessage());
      }
    }
  }

  public void handleReservationToRented(Map<Id, Id> contactsIdsAndInventoryItemsIds) {
    for (Id contactId : contactsIdsAndInventoryItemsIds.keySet()) {
      List<Reservation__c> reservations = reservationDAO.findByContactAndItem(
        contactId, contactsIdsAndInventoryItemsIds.get(contactId)
      );

      if (reservations.isEmpty()) {
        inventoryItemBO.changeStatusToRented(new Set<Id>{contactsIdsAndInventoryItemsIds.get(contactId)});
      } else {
        reservations[0].ReservationStatus__c = 'Rented';
        update reservations;
        inventoryItemBO.changeStatusToRentedDirect(new Set<Id>{contactsIdsAndInventoryItemsIds.get(contactId)});
      }
    }
  }

  public void handleTriggerBeforeUpdate(List<Rent__c> oldRents, List<Rent__c> newRents) {
    ContactBO contactBO = new ContactBO();
    InventoryItemBO inventoryItemBO = new InventoryItemBO();

    Set<Id> contactsIdsToDefaulting = new Set<Id>();
    Set<Id> contactsIdsNormalFinished = new Set<Id>();
    Set<Id> contactsIdsLateFininished = new Set<Id>();
    Set<Id> inventoryItemsIdsFinished = new Set<Id>();

    for (Integer i = 0; i < newRents.size(); i++) {
      if (newRents[i].LocationStatus__c == 'Late') {
        contactsIdsToDefaulting.add(newRents[i].Contact__c);
      }
      
      if (oldRents[i].LocationStatus__c == 'inProgress' && newRents[i].LocationStatus__c == 'Finished') {
        contactsIdsNormalFinished.add(newRents[i].Contact__c);
        inventoryItemsIdsFinished.add(newRents[i].InventoryItem__c);
      }

      if (oldRents[i].LocationStatus__c == 'Late' && newRents[i].LocationStatus__c == 'Finished') {
        contactsIdsLateFininished.add(newRents[i].Contact__c);
        inventoryItemsIdsFinished.add(newRents[i].InventoryItem__c);
      }
    }

    if (!contactsIdsToDefaulting.isEmpty()) {
      contactBO.changeStatusToDefaulting(contactsIdsToDefaulting);
    }

    if (!contactsIdsNormalFinished.isEmpty()) {
      inventoryItemBO.changeStatusToAvailable(inventoryItemsIdsFinished);
      contactBO.changeStatusToNormal(contactsIdsNormalFinished);
    }

    if (!contactsIdsLateFininished.isEmpty()) {
      inventoryItemBO.changeStatusToAvailable(inventoryItemsIdsFinished);
      contactBO.changeStatusToNormal(contactsIdsLateFininished, true);
    }
  }
  
  public Map<Id, Integer> findRentLateByContact(Set<Id> contactsIds) {
    List<Rent__c> rents = rentDAO.findByContactAndStatus(contactsIds, 'Late');
    Map<Id, Integer> rentsPerContact = new Map<Id, Integer>();

    for (Rent__c rent : rents) {
      if (rentsPerContact.containsKey(rent.Contact__c)) {
        rentsPerContact.put(rent.Contact__c, rentsPerContact.get(rent.Contact__c) + 1);
      } else {
        rentsPerContact.put(rent.Contact__c, 1);
      }
    }

    return rentsPerContact;
  }

  public Set<Id> findContactsWithOneLateRent(Set<Id> contactsIds) {
    Map<Id, Integer> rentsPerContact = findRentLateByContact(contactsIds);
    Set<Id> contactIds = new Set<Id>();

    for (Id contactId : rentsPerContact.keySet()) {
      if (rentsPerContact.get(contactId) >= 1) {
        contactIds.add(contactId);
      }
    }

    return contactIds;
  }

  public Set<Id> findContactsWithMoreThanOneLateRent(Set<Id> contactsIds) {
    Map<Id, Integer> rentsPerContact = findRentLateByContact(contactsIds);
    Set<Id> contactIds = new Set<Id>();

    for (Id contactId : rentsPerContact.keySet()) {
      if (rentsPerContact.get(contactId) > 1) {
        contactIds.add(contactId);
      }
    }

    return contactIds;
  }
}
