@isTest
public with sharing class ContactBOTest {
  @isTest 
  public static void testVerifyDefaultingStatus() {
    Id newContactId = SeedersToTests.createContactDefaultingStatus('Test', 'Defaulting');

    Set<Id> contactIds = new Set<Id>{newContactId};

    ContactException error;

    Test.startTest();
    try {
      ContactBO contactBO = new ContactBO();
      contactBO.verifyDefaultingStatus(contactIds);
    } catch (ContactException e) {
      error = e;
    }
    Test.stopTest();

    Assert.areNotEqual(null, error, 'Error should not be null');
    Assert.areEqual('Test Defaulting is defaulting', error.getMessage(), 'Error message should be "Test is defaulting"');    
  }

  @isTest
  public static void testChangeStatusToNormalWithOneParam() {
    ContactBO contactBO = new ContactBO();

    Id contactId = SeedersToTests.createContactDefaultingStatus('Test', 'Defaulting');
    Id inventoryId = SeedersToTests.createInventory('Suits');
    Id inventoryItemId = SeedersToTests.createInventoryItem(inventoryId);

    contactBO.changeStatusToNormal(new Set<Id>{contactId});
    Contact contactNormalStatus = [SELECT ContactStatus__c FROM Contact WHERE Id = :contactId];

    Assert.areEqual('Normal', contactNormalStatus.ContactStatus__c, 'Contact status should be Normal');

    SeedersToTests.createRentLate(contactId, inventoryItemId);

    contactBO.changeStatusToNormal(new Set<Id>{contactId});
    Contact contactDefaultingStatus = [SELECT ContactStatus__c FROM Contact WHERE Id = :contactId];

    Assert.areEqual('Defaulting', contactDefaultingStatus.ContactStatus__c, 'Contact status should be Defaulting');
  }

  @isTest
  public static void testChangeStatusToNormalWithTwoParams() {
    ContactBO contactBO = new ContactBO();

    Id contactId = SeedersToTests.createContactDefaultingStatus('Test', 'Defaulting');
    Id inventoryId = SeedersToTests.createInventory('Suits');
    Id inventoryItemId01 = SeedersToTests.createInventoryItem(inventoryId);
    Id inventoryItemId02 = SeedersToTests.createInventoryItem(inventoryId);
    
    contactBO.changeStatusToNormal(new Set<Id>{contactId}, true);
    Contact contactNormalStatusNotRent = [SELECT ContactStatus__c FROM Contact WHERE Id = :contactId];
    Assert.areEqual('Normal', contactNormalStatusNotRent.ContactStatus__c, 'Contact status should be Normal');

    SeedersToTests.createRentLate(contactId, inventoryItemId01);

    contactBO.changeStatusToNormal(new Set<Id>{contactId}, true);
    Contact contactNormalStatus = [SELECT ContactStatus__c FROM Contact WHERE Id = :contactId];
    Assert.areEqual('Normal', contactNormalStatus.ContactStatus__c, 'Contact status should be Normal');

    SeedersToTests.createRentLate(contactId, inventoryItemId02);

    contactBO.changeStatusToNormal(new Set<Id>{contactId}, true);
    Contact contactDefaultingStatus = [SELECT ContactStatus__c FROM Contact WHERE Id = :contactId];
    Assert.areEqual('Defaulting', contactDefaultingStatus.ContactStatus__c, 'Contact status should be Defaulting');
  }

  @isTest
  public static void testChangeStatusToDefaulting() {
    ContactBO contactBO = new ContactBO();

    Id contactId = SeedersToTests.createContactNormalStatus('Test', 'Normal');

    contactBO.changeStatusToDefaulting(new Set<Id>{contactId});

    Contact contactDefaultingStatus = [SELECT ContactStatus__c FROM Contact WHERE Id = :contactId];

    Assert.areEqual('Defaulting', contactDefaultingStatus.ContactStatus__c, 'Contact status should be Defaulting');
  }

  @isTest
  public static void testChangeStatusToDefaultingByLateRent() {
    ContactBO contactBO = new ContactBO();

    Id contactId = SeedersToTests.createContactNormalStatus('Test', 'Normal');
    Id inventoryId = SeedersToTests.createInventory('Suits');
    Id inventoryItemId01 = SeedersToTests.createInventoryItem(inventoryId);

    contactBO.changeStatusToDefaultingByLateRent();

    Contact contactNormalStatus = [SELECT ContactStatus__c FROM Contact WHERE Id = :contactId];
    Assert.areEqual('Normal', contactNormalStatus.ContactStatus__c, 'Contact status should be Normal');

    SeedersToTests.createRentLate(contactId, inventoryItemId01);

    contactBO.changeStatusToDefaultingByLateRent();

    Contact contactDefaultingStatus = [SELECT ContactStatus__c FROM Contact WHERE Id = :contactId];
    Assert.areEqual('Defaulting', contactDefaultingStatus.ContactStatus__c, 'Contact status should be Defaulting');
  }
}
