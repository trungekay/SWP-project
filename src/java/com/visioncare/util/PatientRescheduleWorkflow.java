package com.visioncare.util;

import com.visioncare.dao.PatientRescheduleDAO;

/** Notify only after the move commits. SMTP failure cannot undo the patient's new slot. */
public final class PatientRescheduleWorkflow {
    @FunctionalInterface public interface Sender {
        void send(PatientRescheduleDAO.Change change)throws Exception;
    }
    public record Outcome(boolean moved,Exception emailError) {}
    private PatientRescheduleWorkflow() {}

    public static Outcome move(PatientRescheduleDAO dao,int appointment,int account,int target,Sender sender)throws Exception {
        PatientRescheduleDAO.Change change=dao.moveWithDetails(appointment,account,target);
        if(change==null)return new Outcome(false,null);
        try {sender.send(change);return new Outcome(true,null);}
        catch(Exception e){return new Outcome(true,e);}
    }
}
