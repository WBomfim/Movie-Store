public with sharing class ListToMap {
  public static Map<Id, Contact> changeContact(List<Contact> contacts) {
    Map<Id, Contact> mapContact = new Map<Id, Contact>();
    for (Contact contact : contacts) {
      mapContact.put(contact.Id, contact);
    }
    return mapContact;
  }

  public static Map<Id, Inventory__c> changeInventory(List<Inventory__c> inventories) {
    Map<Id, Inventory__c> mapInventory = new Map<Id, Inventory__c>();
    for (Inventory__c inventory : inventories) {
      mapInventory.put(inventory.Id, inventory);
    }
    return mapInventory;
  }
}
