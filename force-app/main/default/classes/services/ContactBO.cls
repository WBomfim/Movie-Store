public with sharing class ContactBO {
  ContactDAO contactDAO = new ContactDAO();
  RentDAO rentDAO = new RentDAO();
  RentBO rentBO = new RentBO();

  public void verifyDefaultingStatus(Set<Id> contactsIds) {
    List<Contact> contacts = contactDAO.findByIds(contactsIds);

    for(Contact contact : contacts) {
      if(contact.ContactStatus__c == 'Defaulting') {
        throw new ContactException(contact.Name + ' is defaulting');
      }
    }
  }

  public void changeStatusToNormal(Set<Id> contactsIds) {
    List<Contact> contacts = contactDAO.findByIds(contactsIds);
    Set<Id> contactsWithOneLateRent = rentBO.findContactsWithOneLateRent(contactsIds);

    for(Contact contact : contacts) {
      if(contactsWithOneLateRent.contains(contact.Id)) {
        contact.ContactStatus__c = 'Defaulting';
      } else {
        contact.ContactStatus__c = 'Normal';
      }
    }

    update contacts;
  }

  public void changeStatusToNormal(Set<Id> contactsIds, Boolean isMoreThanOneLateRent) {
    List<Contact> contacts = contactDAO.findByIds(contactsIds);
    Set<Id> contactsWithMoreThanOneLateRent = rentBO.findContactsWithMoreThanOneLateRent(contactsIds);

    for(Contact contact : contacts) {
      if(contactsWithMoreThanOneLateRent.contains(contact.Id)) {
        contact.ContactStatus__c = 'Defaulting';
      } else {
        contact.ContactStatus__c = 'Normal';
      }
    }

    update contacts;
  }

  public void changeStatusToDefaulting(Set<Id> contactsIds) {
    List<Contact> contacts = contactDAO.findByIds(contactsIds);
    
    for(Contact contact : contacts) {
      contact.ContactStatus__c = 'Defaulting';
    }

    update contacts;
  }

  public void changeStatusToDefaultingByLateRent() {
    List<Rent__c> rents = rentDAO.findAllLateRents();
    Set<Id> contactsIds = new Set<Id>();

    for(Rent__c rent : rents) {
      contactsIds.add(rent.Contact__c);
    }

    this.changeStatusToDefaulting(contactsIds);
  }
}
