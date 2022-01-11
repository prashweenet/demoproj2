/*
 *                  IFS Research & Development
 *
 * This program is protected by copyright law and by international
 * conventions. All licensing, renting, lending or copying (including
 * for private use), and all other use of the program, which is not
 * expressively permitted by IFS Research & Development (IFS), is a
 * violation of the rights of IFS. Such violations will be reported to the
 * appropriate authorities.
 *
 * VIOLATIONS OF ANY COPYRIGHT IS PUNISHABLE BY LAW AND CAN LEAD
 * TO UP TO TWO YEARS OF IMPRISONMENT AND LIABILITY TO PAY DAMAGES.
 */

import ifs.fnd.base.IfsException;
import ifs.fnd.connect.xml.Transformer;
import ifs.fnd.util.XmlUtil;
import java.io.StringReader;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.xml.sax.InputSource;

/**
 * I F S Authorize Request X M L To Avalara
 *
 * IMPORTANT !!!
 * Do not place this class inside a package. It should be
 * in the default package.
 */
public class IFSAuthorizeRequestXMLToAvalara implements Transformer {

   @Override
   public void init() throws IfsException {
   }
   
   private String getValueByTagName(String tag, Element element)
   {
      NodeList node = element.getElementsByTagName(tag);
      if (node.getLength() > 0) {
         Element valueElement = (Element)node.item(0);
         if (valueElement.hasChildNodes()) {
            NodeList valueList = valueElement.getChildNodes();
            return valueList.item(0).getNodeValue().trim();
         }
         return "";
      }
      return "";
  }

   @Override
   public String transform(String sIn) throws IfsException {
     StringBuilder sb = new StringBuilder(); 
     String user      = "";
     String password  = "";
     
     try {
         InputSource inputSource = new InputSource(new StringReader(sIn));
         Document doc = XmlUtil.parseDocument(inputSource);
	      doc.getDocumentElement().normalize();
	      
	      Node root = doc.getFirstChild();
	      if (root.getNodeType() == Node.ELEMENT_NODE) {
		      user = getValueByTagName("USER_NAME", (Element)root);
		      password = getValueByTagName("PASSWORD", (Element)root);
		   }
	      sb.append("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n");
	      sb.append("<soapenv:Envelope xmlns:ser=\"http://avatax.avalara.com/services\" xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\">\n");
	      sb.append("<soapenv:Header>\n");
	      sb.append("<wsse:Security soapenv:mustUnderstand=\"1\" xmlns:wsse=\"http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd\" xmlns:wsu=\"http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd\">\n");
	      sb.append("<wsse:UsernameToken wsu:Id=\"UsernameToken-8C7F8EEF3F12DAA695141417798203344\">\n");	      
	      sb.append("<wsse:Username>").append(user).append("</wsse:Username>\n");
	      sb.append("<wsse:Password Type=\"http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText\">");
	      sb.append(password).append("</wsse:Password>\n");      	    
	      sb.append("<wsse:Nonce EncodingType=\"http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-soap-message-security-1.0#Base64Binary\">G3HxCMo63wzdq5miRmCd2A==</wsse:Nonce>\n");
	      sb.append("</wsse:UsernameToken>\n");
	      sb.append("</wsse:Security>\n");
	      sb.append("<ser:Profile>\n");
	      sb.append("<ser:Name>IFS</ser:Name>\n");
	      sb.append("<ser:Client>IFS</ser:Client>\n");
	      sb.append("</ser:Profile>\n");
	      sb.append("</soapenv:Header>\n");
	      
	      sb.append("<soapenv:Body>\n");
	      
	      sb.append("<ser:IsAuthorized>\n");
	      sb.append("</ser:IsAuthorized>\n");
	      
	      sb.append("</soapenv:Body>\n");
	      sb.append("</soapenv:Envelope>\n");
     }catch (Exception err) {
         err.printStackTrace();
      }
      return (sb.toString());
   }
}