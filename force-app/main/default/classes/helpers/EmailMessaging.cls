public class EmailMessaging {
  public void startReservation(String contactName, String contactEmail, String inventoryName) {
    String emailBody = 'Olá, ' + contactName + '\n\n' +
                      'Seu filme ' + inventoryName + ' foi reservado com sucesso!\n\n' +
                      'Assim que o filme estiver disponível lhe avisaremos. \n\n' +
                      'Agradecemos por escolher nossa locadora de filmes. \n\n' +
                      'Atenciosamente, \n' +
                      'WillFlix Movie Store';

    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();

    email.setToAddresses(new String[]{contactEmail});
    email.setSubject('Reserva - ' + inventoryName);
    email.setPlainTextBody(emailBody);

    Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email});
  }
  
  public void receivedItem(String contactName, String contactEmail, String inventoryName, String resevationName) {
    String emailBody = 'Olá, ' + contactName + '\n\n' +
                      'Seu filme ' + inventoryName + ' chegou! Você tem 24 horas para retirá-lo. \n\n' +
                      'Agradecemos por escolher nossa locadora de filmes. Por favor, visite nossa loja o mais breve possível para retirar sua reserva. \n\n' +
                      'Caso você não possa retirar o filme dentro de 24 horas, pedimos que entre em contato conosco para discutir outras opções. \n\n' +
                      'Atenciosamente, \n' +
                      'WillFlix Movie Store';

    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();

    email.setToAddresses(new String[]{contactEmail});
    email.setSubject('Reserva - ' + resevationName + ' - ' + inventoryName);
    email.setPlainTextBody(emailBody);

    Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email});
  }
}
