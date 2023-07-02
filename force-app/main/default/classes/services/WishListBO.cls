public with sharing class WishListBO {
  @AuraEnabled
  public static List<WishList__c> findAll() {
    return [
      SELECT Id,
      Name,
      ContactName__c
      FROM WishList__c
    ];
  }

  @AuraEnabled
  public static void addItem(String item, String contactName) {
    insert new WishList__c(Name = item, ContactName__c = contactName);
  }

  @AuraEnabled
  public static void deleteItem(Id itemId) {
    delete new WishList__c(Id = itemId);
  }

  @AuraEnabled
  public static List<Contact> findContacts() {
    return [
      SELECT Id,
      Name
      FROM Contact
      ORDER BY Name
    ];
  }
}
