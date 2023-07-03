public with sharing class InventoryItemBO {
  InventoryItemDAO inventoryItemDAO = new InventoryItemDAO();
  ReservationDAO reservationDAO = new ReservationDAO();
  ContactDAO contactDAO = new ContactDAO();
  InventoryBO inventoryBO = new InventoryBO();
  InventoryDAO inventoryDAO = new InventoryDAO();

  public void handleTriggerBeforeUpdate(List<InventoryItem__c> inventoryItems) {
    Set<Id> inventoryIds = new Set<Id>();

    for (InventoryItem__c inventoryItem : inventoryItems) {
      if (inventoryItem.Active__c) {
        inventoryIds.add(inventoryItem.Inventory__c);
      }
    }

    try {
      inventoryBO.verifyActiveInventory(inventoryIds);

      for (InventoryItem__c inventoryItem : inventoryItems) {
        this.handleReservation(inventoryItem);
      }
    } catch (Exception e) {
      for (InventoryItem__c inventoryItem : inventoryItems) {
        inventoryItem.addError(e.getMessage());
      }
    }
  }

  public void handleReservation(InventoryItem__c inventoryItem) {
    if (inventoryItem.Status__c == 'Available' && inventoryItem.Active__c) {
      List<Reservation__c> reservations = reservationDAO.findByInventoryId(inventoryItem.Inventory__c);
    
      if (reservations.size() == 0) return;

      Reservation__c reservationToUpdate = reservations.get(0);

      reservationToUpdate.InventoryItem__c = inventoryItem.Id;
      reservationToUpdate.ReservationStatus__c = 'Awaiting Rent';

      Contact contact = contactDAO.findByIds(new Set<Id>{reservationToUpdate.Contact__c})[0];
      Inventory__c inventory = inventoryDAO.findByIds(new Set<Id>{reservationToUpdate.Inventory__c})[0];

      EmailMessaging emailMessaging = new EmailMessaging();

      emailMessaging.receivedItem(contact.Name, contact.Email, inventory.Name, reservationToUpdate.Name);

      inventoryItem.Status__c = 'Reserved';
      update reservationToUpdate;
    }
  }

  public void changeStatusToRented(Set<Id> inventoryItemsIds) {
    List<InventoryItem__c> inventoryItemsToUpdate = inventoryItemDAO.findByIds(inventoryItemsIds);

    for (InventoryItem__c item : inventoryItemsToUpdate) {
      if (item.Status__c == 'Rented') {
        throw new InventoryItemException(item.Name + ' is already rented');
      }

      If (item.Status__c == 'Reserved') {
        throw new InventoryItemException(item.Name + ' is reserved');
      }

      item.Status__c = 'Rented';
    }

    update inventoryItemsToUpdate;
  }

  public void changeStatusToRentedDirect(Set<Id> inventoryItemsIds) {
    List<InventoryItem__c> inventoryItemsToUpdate = inventoryItemDAO.findByIds(inventoryItemsIds);

    for (InventoryItem__c item : inventoryItemsToUpdate) {
      item.Status__c = 'Rented';
    }

    update inventoryItemsToUpdate;
  }

  public void changeStatusToAvailable(Set<Id> inventoryItemsIds) {
    List<InventoryItem__c> inventoryItemsToUpdate = inventoryItemDAO.findByIds(inventoryItemsIds);

    for (InventoryItem__c item : inventoryItemsToUpdate) {
      item.Status__c = 'Available';
    }

    update inventoryItemsToUpdate;
  }

  public void verifyActiveItems(Set<Id> inventoryItemsIds) {
    List<InventoryItem__c> inventoryItems = inventoryItemDAO.findByIds(inventoryItemsIds);

    for (InventoryItem__c item : inventoryItems) {
      if (!item.Active__c) {
        throw new InventoryItemException(item.Name + ' is not active');
      }
    }
  }
}
