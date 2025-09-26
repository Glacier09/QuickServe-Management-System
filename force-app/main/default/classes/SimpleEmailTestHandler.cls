global class SimpleEmailTestHandler implements Messaging.InboundEmailHandler {
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {

        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();

        // Create a simple Task to prove the code ran
        Task newTask = new Task(
            Subject = 'Email Service Test Successful',
            Description = 'Email received from: ' + email.fromAddress
        );

        insert newTask;

        result.success = true;
        return result;
    }
}