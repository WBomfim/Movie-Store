@isTest
public with sharing class WishListBOTest {
  @isTest
  public static void testAddItem() {
    WishListBO.addItem('Test 01', 'João');
    WishListBO.addItem('Test 02', 'Marcio');

    List<WishList__c> wishList = [SELECT Name, ContactName__c FROM WishList__c];

    Assert.areEqual(2, wishList.size(), 'WishList size should be 2');
  }

  @isTest
  public static void testFindAll() {
    WishListBO.addItem('Test 01', 'João');
    WishListBO.addItem('Test 02', 'Marcio');

    List<WishList__c> wishList = WishListBO.findAll();

    Assert.areEqual(2, wishList.size(), 'WishList size should be 2');
  }

  @isTest
  public static void testDeleteItem() {
    WishListBO.addItem('Test 01', 'João');
    WishListBO.addItem('Test 02', 'Marcio');

    List<WishList__c> wishList = WishListBO.findAll();

    WishListBO.deleteItem(wishList[0].Id);

    wishList = WishListBO.findAll();

    Assert.areEqual(1, wishList.size(), 'WishList size should be 1');
  }

  @isTest
  public static void testFindContacts() {
    SeedersToTests.createContactNormalStatus('Test01', 'Normal');
    SeedersToTests.createContactNormalStatus('Test02', 'Normal');

    List<Contact> contacts = WishListBO.findContacts();

    Assert.areEqual(2, contacts.size(), 'Contacts size should be 2');
  }
}