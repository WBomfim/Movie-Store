public class MonitoringToRentStatus implements Schedulable {
  public void execute(SchedulableContext context) {
    ContactBO contactBO = new ContactBO();
    contactBO.changeStatusToDefaultingByLateRent();
  }
} 
