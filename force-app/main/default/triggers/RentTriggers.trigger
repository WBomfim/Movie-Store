trigger RentTriggers on Rent__c (before insert, before update) {
  RentBO rentBO = new RentBO();
  
  if (Trigger.isInsert) {
    rentBO.handleTriggerBeforeInsert(Trigger.new);
  } 

  if (Trigger.isUpdate) {
    rentBO.handleTriggerBeforeUpdate(Trigger.old, Trigger.new);
  }
}
