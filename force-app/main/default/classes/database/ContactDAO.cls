public with sharing class ContactDAO {
  public List<Contact> findByIds(Set<Id> ids) {
    return [
      SELECT Id,
      Name,
      Email,
      Address__c,
      ContactStatus__c
      FROM Contact 
      WHERE Id IN :ids
    ];
  }
}
