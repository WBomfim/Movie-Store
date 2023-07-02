public with sharing class SeedersToTests {
  public static Id createContactNormalStatus(String firstName, String lastName) {
    Contact contact = new Contact(
      FirstName = firstName,
      LastName = lastName,
      Email = firstName + '@gmail.com',
      ContactStatus__c = 'Normal',
      Phone = '01234567890',
      Address__c = 'Test Address, 444'
    );

    insert contact;
    return contact.Id;
  }

  public static Id createContactDefaultingStatus(String firstName, String lastName) {
    Contact contact = new Contact(
      FirstName = firstName,
      LastName = lastName,
      Email = firstName + '@gmail.com',
      ContactStatus__c = 'Defaulting',
      Phone = '01234567890',
      Address__c = 'Test Address, 444'
    );

    insert contact;
    return contact.Id;
  }

  public static Id createInventory(String name) {
    Inventory__c inventory = new Inventory__c(
      Name = name
    );

    insert inventory;
    return inventory.Id;
  }

  public static Id createInventoryItem(Id inventoryId) {
    InventoryItem__c inventoryItem = new InventoryItem__c(
      Inventory__c = inventoryId
    );

    insert inventoryItem;
    return inventoryItem.Id;
  }

  public static Id createRentInProgress(Id contactId, Id inventoryItemId) {
    Rent__c rent = new Rent__c(
      Contact__c = contactId,
      InventoryItem__c = inventoryItemId,
      CloseDate__c = Date.today().addDays(1)
    );

    insert rent;
    return rent.Id;
  }

  public static Id createRentLate(Id contactId, Id inventoryItemId) {
    Rent__c rent = new Rent__c(
      Contact__c = contactId,
      InventoryItem__c = inventoryItemId,
      ValidationRulesIgnore__c = true,
      CloseDate__c = Date.today().addDays(-1)
    );

    insert rent;
    return rent.Id;
  }
}
