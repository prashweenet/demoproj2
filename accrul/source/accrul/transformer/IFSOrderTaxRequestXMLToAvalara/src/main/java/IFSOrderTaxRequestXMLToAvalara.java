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
import java.io.IOException;
import java.io.StringReader;
import java.io.StringWriter;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.xml.soap.MessageFactory;
import javax.xml.soap.SOAPBody;
import javax.xml.soap.SOAPElement;
import javax.xml.soap.SOAPEnvelope;
import javax.xml.soap.SOAPException;
import javax.xml.soap.SOAPFactory;
import javax.xml.soap.SOAPHeader;
import javax.xml.soap.SOAPHeaderElement;
import javax.xml.soap.SOAPMessage;
import javax.xml.soap.SOAPPart;
import javax.xml.transform.OutputKeys;
import javax.xml.transform.Source;
import javax.xml.transform.TransformerConfigurationException;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.stream.StreamResult;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.xml.sax.InputSource;

/**
 * IFS Order Tax Request XML To Avalara
 *
 * IMPORTANT !!!
 * Do not place this class inside a package. It should be
 * in the default package.
 */
public class IFSOrderTaxRequestXMLToAvalara implements Transformer {

   public static final String SER_NS = "http://avatax.avalara.com/services";
   public static final String WSSE_NS = "http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd";
   public static final String WSU_NS = "http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd";
   public static final String PASSWORD_TEXT_TYPE = "http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText";
   public static final String ENCODING_TYPE = "http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-soap-message-security-1.0#Base64Binary";
   public static final String SER_NS_PREFIX = "ser";
   public static final String WSSE_NS_PREFIX = "wsse";
   public static final String WSU_NS_PREFIX = "wsu";

   @Override
   public void init() throws IfsException {
   }

   private String getValueByTagName(String tag, Element element) {
      NodeList node = element.getElementsByTagName(tag);
      if (node.getLength() > 0) {
         Element valueElement = (Element) node.item(0);
         if (valueElement.hasChildNodes()) {
            NodeList valueList = valueElement.getChildNodes();
            return valueList.item(0).getNodeValue().trim();
         }
         else {
            return "";
         }
      }
      else {
         return "";
      }
   }

   private void createSoapHeader(String user, String password, SOAPEnvelope soapEnvelope) throws SOAPException {
      SOAPHeader soapHeader = soapEnvelope.getHeader();
      SOAPFactory sf = SOAPFactory.newInstance();

      // Add Security section
      SOAPHeaderElement securityElem = soapHeader.addHeaderElement(sf.createName("Security", WSSE_NS_PREFIX, WSSE_NS));
      securityElem.addNamespaceDeclaration(WSU_NS_PREFIX, WSU_NS);
      securityElem.setMustUnderstand(true);

      // UsernameToken section
      SOAPElement usernameTokenMsgElem = sf.createElement("UsernameToken", WSSE_NS_PREFIX, WSSE_NS);
      usernameTokenMsgElem.addAttribute(sf.createName("Id", WSU_NS_PREFIX, WSU_NS), "UsernameToken-1");

      // Username tag
      SOAPElement usernameMsgElem = sf.createElement("Username", WSSE_NS_PREFIX, WSSE_NS).addTextNode(user);
      usernameTokenMsgElem.addChildElement(usernameMsgElem);

      // Password tag
      SOAPElement passwordMsgElem = sf.createElement("Password", WSSE_NS_PREFIX, WSSE_NS).addTextNode(password).addAttribute(sf.createName("Type"), PASSWORD_TEXT_TYPE);
      usernameTokenMsgElem.addChildElement(passwordMsgElem);

      // Nonce tag
      SOAPElement nonceMsgElem = sf.createElement("Nonce", WSSE_NS_PREFIX, WSSE_NS).addTextNode("FiIvkXmBzd0uBEsexvpzeA==").addAttribute(sf.createName("EncodingType"), ENCODING_TYPE);
      usernameTokenMsgElem.addChildElement(nonceMsgElem);

      // Created tag
      SOAPElement createdMsgElem = sf.createElement("Created", WSU_NS_PREFIX, WSU_NS).addTextNode("2014-10-22T13:53:04.159Z");
      usernameTokenMsgElem.addChildElement(createdMsgElem);

      // Add UsernameToken section to parent
      securityElem.addChildElement(usernameTokenMsgElem);

      // Add Profile section
      SOAPHeaderElement profileElem = soapHeader.addHeaderElement(sf.createName("Profile", SER_NS_PREFIX, SER_NS));
      profileElem.addChildElement(sf.createElement(sf.createName("Name", SER_NS_PREFIX, SER_NS)).addTextNode("aa"));
      profileElem.addChildElement(sf.createElement(sf.createName("Client", SER_NS_PREFIX, SER_NS)).addTextNode("aa"));

   }

   /**
    *
    * @param sIn
    * @return
    * @throws IfsException
    */
   @Override
   public String transform(String sIn) throws IfsException {
      StringWriter writer = new StringWriter();
      String user = "";
      String password = "";

      try {
         InputSource inputSource = new InputSource(new StringReader(sIn));
         Document doc = XmlUtil.parseDocument(inputSource);

         doc.getDocumentElement().normalize();

         Node rootNode = doc.getDocumentElement();
         // Fetch the login information
         if (rootNode.getNodeType() == Node.ELEMENT_NODE) {
            user = getValueByTagName("USER_NAME", (Element) rootNode);
            password = getValueByTagName("PASSWORD", (Element) rootNode);
         }

         MessageFactory messageFactory = MessageFactory.newInstance();
         SOAPMessage soapMessage = messageFactory.createMessage();
         SOAPPart soapPart = soapMessage.getSOAPPart();

         // SOAP Envelope
         SOAPEnvelope soapEnvelope = soapPart.getEnvelope();
         soapEnvelope.addNamespaceDeclaration(SER_NS_PREFIX, SER_NS);

         // SOAP Header
         createSoapHeader(user, password, soapEnvelope);

         // SOAP Body
         SOAPBody soapBody = soapEnvelope.getBody();

         SOAPElement getTaxElem = soapBody.addChildElement("GetTax", SER_NS_PREFIX);
         SOAPElement getTaxRequestElem = getTaxElem.addChildElement("GetTaxRequest", SER_NS_PREFIX);

         // Request header section
         NodeList orderRequestList = doc.getElementsByTagName("ORDER_REQUEST");
         for (int i = 0; i < orderRequestList.getLength(); i++) {
            Node orderRequestNode = orderRequestList.item(i);
            if (orderRequestNode.getNodeType() == 1) {
               Element refOrderRequestElem = (Element) orderRequestNode;
               getTaxRequestElem.addChildElement("CompanyCode", SER_NS_PREFIX).addTextNode(getValueByTagName("COMPANY", refOrderRequestElem));
               getTaxRequestElem.addChildElement("DocType", SER_NS_PREFIX).addTextNode(getValueByTagName("DOC_TYPE", refOrderRequestElem));
               if (getValueByTagName("DOC_CODE", refOrderRequestElem).length() > 0) {
                  getTaxRequestElem.addChildElement("DocCode", SER_NS_PREFIX).addTextNode(getValueByTagName("DOC_CODE", refOrderRequestElem));
               }
               getTaxRequestElem.addChildElement("DocDate", SER_NS_PREFIX).addTextNode(getValueByTagName("DOC_DATE", refOrderRequestElem));
               getTaxRequestElem.addChildElement("CustomerCode", SER_NS_PREFIX).addTextNode(getValueByTagName("CUSTOMER_CODE", refOrderRequestElem));
               getTaxRequestElem.addChildElement("ExemptionNo", SER_NS_PREFIX).addTextNode(getValueByTagName("EXEMPTION_NO", refOrderRequestElem));
               getTaxRequestElem.addChildElement("Commit", SER_NS_PREFIX).addTextNode(getValueByTagName("COMMIT", refOrderRequestElem));
               getTaxRequestElem.addChildElement("DetailLevel", SER_NS_PREFIX).addTextNode(getValueByTagName("DETAIL_LEVEL", refOrderRequestElem));
            }
         }

         // Tax override section
         SOAPElement taxOverrideElem = getTaxRequestElem.addChildElement("TaxOverride", SER_NS_PREFIX);
         NodeList taxOverrideList = doc.getElementsByTagName("TAX_OVERRIDE");
         for (int i = 0; i < taxOverrideList.getLength(); i++) {
            Node taxOverrideNode = taxOverrideList.item(i);
            if (taxOverrideNode.getNodeType() == 1) {
               Element refTaxOverrideElem = (Element) taxOverrideNode;
               taxOverrideElem.addChildElement("TaxOverrideType", SER_NS_PREFIX).addTextNode(getValueByTagName("TAX_OVERRIDE_TYPE", refTaxOverrideElem));
               taxOverrideElem.addChildElement("TaxAmount", SER_NS_PREFIX).addTextNode(getValueByTagName("TAX_AMOUNT", refTaxOverrideElem));
               taxOverrideElem.addChildElement("TaxDate", SER_NS_PREFIX).addTextNode(getValueByTagName("TAX_DATE", refTaxOverrideElem));
               taxOverrideElem.addChildElement("Reason", SER_NS_PREFIX).addTextNode(getValueByTagName("REASON", refTaxOverrideElem));
            }
         }

         // Address section
         SOAPElement addressArrElem = getTaxRequestElem.addChildElement("Addresses", SER_NS_PREFIX);
         NodeList addressArrList = doc.getElementsByTagName("ADDRESSES");
         for (int i = 0; i < addressArrList.getLength(); i++) {
            Node addressArrNode = addressArrList.item(i);
            if (addressArrNode.getNodeType() == 1) {
               Element refAddressArrElem = (Element) addressArrNode;
               NodeList baseAddressList = refAddressArrElem.getElementsByTagName("BASE_ADDRESS");
               for (int k = 0; k < baseAddressList.getLength(); k++) {
                  SOAPElement baseAddressElem = addressArrElem.addChildElement("BaseAddress", SER_NS_PREFIX);
                  Node baseAddressNode = baseAddressList.item(k);
                  if (baseAddressNode.getNodeType() == 1) {
                     Element refBaseAddressElem = (Element) baseAddressNode;
                     baseAddressElem.addChildElement("AddressCode", SER_NS_PREFIX).addTextNode(getValueByTagName("ADDRESS_CODE", refBaseAddressElem));

                     baseAddressElem.addChildElement("Line1", SER_NS_PREFIX).addTextNode(getValueByTagName("LINE1", refBaseAddressElem));

                     if (getValueByTagName("LINE2", refBaseAddressElem).length() > 0) {
                        baseAddressElem.addChildElement("Line2", SER_NS_PREFIX).addTextNode(getValueByTagName("LINE2", refBaseAddressElem));
                     }
                     if (getValueByTagName("CITY", refBaseAddressElem).length() > 0) {
                        baseAddressElem.addChildElement("City", SER_NS_PREFIX).addTextNode(getValueByTagName("CITY", refBaseAddressElem));
                     }
                     if (getValueByTagName("REGION", refBaseAddressElem).length() > 0) {
                        baseAddressElem.addChildElement("Region", SER_NS_PREFIX).addTextNode(getValueByTagName("REGION", refBaseAddressElem));
                     }
                     if (getValueByTagName("POSTAL_CODE", refBaseAddressElem).length() > 0) {
                        baseAddressElem.addChildElement("PostalCode", SER_NS_PREFIX).addTextNode(getValueByTagName("POSTAL_CODE", refBaseAddressElem));
                     }
                     if (getValueByTagName("COUNTRY", refBaseAddressElem).length() > 0) {
                        baseAddressElem.addChildElement("Country", SER_NS_PREFIX).addTextNode(getValueByTagName("COUNTRY", refBaseAddressElem));
                     }
                     baseAddressElem.addChildElement("TaxRegionId", SER_NS_PREFIX).addTextNode(getValueByTagName("TAX_REGION_ID", refBaseAddressElem));
                  }
               }
            }
         }

         // Order lines section
         SOAPElement lineArrElem = getTaxRequestElem.addChildElement("Lines", SER_NS_PREFIX);
         NodeList lineArrList = doc.getElementsByTagName("LINE_ITEMS");
         for (int i = 0; i < lineArrList.getLength(); i++) {
            Node lineArrNode = lineArrList.item(i);
            if (lineArrNode.getNodeType() == 1) {
               Element refLineArrElem = (Element) lineArrNode;
               NodeList lineItemList = refLineArrElem.getElementsByTagName("LINE_ITEM");
               for (int k = 0; k < lineItemList.getLength(); k++) {
                  SOAPElement lineItemElem = lineArrElem.addChildElement("Line", SER_NS_PREFIX);
                  Node lineItemNode = lineItemList.item(k);
                  if (lineItemNode.getNodeType() == 1) {
                     Element refLineItemElem = (Element) lineItemNode;
                     lineItemElem.addChildElement("No", SER_NS_PREFIX).addTextNode(getValueByTagName("NO", refLineItemElem));
                     lineItemElem.addChildElement("OriginCode", SER_NS_PREFIX).addTextNode(getValueByTagName("ORIGIN_CODE", refLineItemElem));
                     lineItemElem.addChildElement("DestinationCode", SER_NS_PREFIX).addTextNode(getValueByTagName("DESTINATION_CODE", refLineItemElem));
                     lineItemElem.addChildElement("ItemCode", SER_NS_PREFIX).addTextNode(getValueByTagName("ITEM_CODE", refLineItemElem));
                     lineItemElem.addChildElement("Qty", SER_NS_PREFIX).addTextNode(getValueByTagName("QTY", refLineItemElem));
                     lineItemElem.addChildElement("Amount", SER_NS_PREFIX).addTextNode(getValueByTagName("AMOUNT", refLineItemElem));
                     lineItemElem.addChildElement("CustomerUsageType", SER_NS_PREFIX).addTextNode(getValueByTagName("CUSTOMER_USAGE_TYPE", refLineItemElem));
                     lineItemElem.addChildElement("TaxCode", SER_NS_PREFIX).addTextNode(getValueByTagName("TAX_CODE", refLineItemElem));
                     lineItemElem.addChildElement("Description", SER_NS_PREFIX).addTextNode(getValueByTagName("DESCRIPTION", refLineItemElem));
                  }
               }
            }
         }

         soapMessage.saveChanges();

         TransformerFactory transformerFactory = TransformerFactory.newInstance();
         javax.xml.transform.Transformer trans = transformerFactory.newTransformer();

         trans.setOutputProperty(OutputKeys.ENCODING, "UTF-8");
         trans.setOutputProperty(OutputKeys.INDENT, "yes");
         trans.setOutputProperty("{http://xml.apache.org/xslt}indent-amount", "3");

         Source source = soapMessage.getSOAPPart().getContent();

         StreamResult output = new StreamResult(writer);
         trans.transform(source, output);

      } 
      catch (IOException ex) {
         Logger.getLogger(IFSOrderTaxRequestXMLToAvalara.class.getName()).log(Level.SEVERE, null, ex);
      } 
      catch (SOAPException ex) {
         Logger.getLogger(IFSOrderTaxRequestXMLToAvalara.class.getName()).log(Level.SEVERE, null, ex);
      } 
      catch (TransformerConfigurationException ex) {
         Logger.getLogger(IFSOrderTaxRequestXMLToAvalara.class.getName()).log(Level.SEVERE, null, ex);
      } 
      catch (TransformerException ex) {
         Logger.getLogger(IFSOrderTaxRequestXMLToAvalara.class.getName()).log(Level.SEVERE, null, ex);
      }

      return writer.toString();
   }
}
