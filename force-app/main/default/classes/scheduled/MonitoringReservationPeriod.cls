public class MonitoringReservationPeriod implements Schedulable {
  public void execute(SchedulableContext context) {
    ReservationBO reservationBO = new ReservationBO();

    reservationBO.verifyReservatioPeriod();
  }
}
