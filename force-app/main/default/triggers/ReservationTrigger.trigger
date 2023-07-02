trigger ReservationTrigger on Reservation__c (before insert, before update) {
  ReservationBO reservationBO = new ReservationBO();

  if (Trigger.isInsert) {
    reservationBO.handleTriggerBeforeInsert(Trigger.new);
  } 
  
  if (Trigger.isUpdate) {
    reservationBO.handleTriggerBeforeUpdate(Trigger.new);
  }
}
