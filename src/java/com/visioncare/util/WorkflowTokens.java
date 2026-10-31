package com.visioncare.util;
import jakarta.servlet.http.*;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.util.UUID;
public final class WorkflowTokens {
 private WorkflowTokens() {}
 public static String ensure(HttpSession session) {
  if(session.getAttribute("workflowCsrf")==null)session.setAttribute("workflowCsrf",UUID.randomUUID().toString());
  return (String)session.getAttribute("workflowCsrf");
 }
 public static boolean valid(HttpServletRequest request) {
  Object token=request.getSession().getAttribute("workflowCsrf");String sent=request.getParameter("csrfToken");
  return token instanceof String && sent!=null && MessageDigest.isEqual(((String)token).getBytes(StandardCharsets.UTF_8),sent.getBytes(StandardCharsets.UTF_8));
 }
 public static String html(String text) {return text==null?"":text.replace("&","&amp;").replace("<","&lt;").replace(">","&gt;").replace("\"","&quot;").replace("'","&#39;");}
}
