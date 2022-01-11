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
 * I F S Authorize Response X M L From Avalara
 *
 * IMPORTANT !!!
 * Do not place this class inside a package. It should be
 * in the default package.
 */
public class IFSAuthorizeResponseXMLFromAvalara implements Transformer {

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
      NodeList nodes;
      Node node;
      Element refElement;
    
    try
    {
        InputSource inputSource = new InputSource(new StringReader(sIn));
        Document doc = XmlUtil.parseDocument(inputSource);
        doc.getDocumentElement().normalize();

        sb.append("<VALIDATE_SIMPLE_RESPONSE>\n");
        
        nodes = doc.getElementsByTagName("IsAuthorizedResult");

        if(nodes.getLength() > 0){
	        node = nodes.item(0);
	        if (node.getNodeType() == Node.ELEMENT_NODE) {
			     refElement = (Element)node;
              sb.append("<RESULT_CODE>").append(getValueByTagName("ResultCode", refElement)).append("</RESULT_CODE>\n");
	        }
        }
        
        nodes = doc.getElementsByTagName("s:Fault");
        if(nodes.getLength() > 0){
	        node = nodes.item(0);
	        if (node.getNodeType() == Node.ELEMENT_NODE) {
			    refElement = (Element)node;
             sb.append("<MESSAGE>").append(getValueByTagName("faultstring", refElement)).append("</MESSAGE>\n");		    
	        }
        }
        sb.append("</VALIDATE_SIMPLE_RESPONSE>\n");
 	     
	}catch (Exception err) {
	   err.printStackTrace();
	}
      return sb.toString();
   }
}