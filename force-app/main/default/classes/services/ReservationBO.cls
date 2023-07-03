public with sharing class ReservationBO {
  ReservationDAO reservationDAO = new ReservationDAO();
  InventoryItemBO inventoryItemBO = new InventoryItemBO();
  ContactBO contactBO = new ContactBO();
  InventoryBO inventoryBO = new InventoryBO();
  ContactDAO contactDAO = new ContactDAO();
  InventoryDAO inventoryDAO = new InventoryDAO();

  public void handleTriggerBeforeInsert(List<Reservation__c> reservations) {
    Set<Id> contactsIds = new Set<Id>();
    Set<Id> inventoriesIds = new Set<Id>();

    for (Reservation__c reservation : reservations) {
      contactsIds.add(reservation.Contact__c);
      inventoriesIds.add(reservation.Inventory__c);
    }

    List<Contact> contacts = contactDAO.findByIds(contactsIds);
    List<Inventory__c> inventories = inventoryDAO.findByIds(inventoriesIds);

    Map<Id, Contact> contactsMap = ListToMap.changeContact(contacts);
    Map<Id, Inventory__c> inventoriesMap = ListToMap.changeInventory(inventories);

    try {
      this.verifyDuplicateReservation(reservations);
      contactBO.verifyDefaultingStatus(contactsIds);
      InventoryBO.verifyActiveInventory(inventoriesIds);
      inventoryBO.verifyInventoryAvailable(inventoriesIds);

      EmailMessaging emailMessaging = new EmailMessaging();

      for (Reservation__c reservation : reservations) {
        Contact contact = contactsMap.get(reservation.Contact__c);
        Inventory__c inventory = inventoriesMap.get(reservation.Inventory__c);
  
        emailMessaging.startReservation(contact.Name, contact.Email, inventory.Name);
      }

    } catch (Exception e) {
      for (Reservation__c reservation : reservations) {
        reservation.addError(e.getMessage());
      }
    }
  }

  public void verifyDuplicateReservation(List<Reservation__c> reservations) {
    for (Reservation__c reservation : reservations) {
      List<Reservation__c> reservationsList = reservationDAO
        .findByContactAndInventory(reservation.Contact__c, reservation.Inventory__c);

      if (reservationsList.size() > 0) {
        reservation.addError('The Customer already has a reservation for this inventory');
      }
    }
  }

  public void handleTriggerBeforeUpdate(List<Reservation__c> reservations) {
    Set<Id> inventoryItemIds = new Set<Id>();

    for (Reservation__c reservation : reservations) {
      if (reservation.ReservationStatus__c == 'Canceled') {
        inventoryItemIds.add(reservation.InventoryItem__c);
      }
    }

    inventoryItemBO.changeStatusToAvailable(inventoryItemIds);
  }

  public void verifyReservatioPeriod() {
    List<Reservation__c> reservations = reservationDAO.findByAwaitingRent();
    Set<Id> inventoryItemIds = new Set<Id>();

    for (Reservation__c reservation : reservations) {
      inventoryItemIds.add(reservation.InventoryItem__c);

      if (reservation.ReservationStatus__c == 'Awaiting Rent' && reservation.StartAwaitingRent__c.addDays(1) < DateTime.now()) {
        reservation.ReservationStatus__c = 'Canceled';
      }
    }

    inventoryItemBO.changeStatusToAvailable(inventoryItemIds);

    update reservations;
  }
}
