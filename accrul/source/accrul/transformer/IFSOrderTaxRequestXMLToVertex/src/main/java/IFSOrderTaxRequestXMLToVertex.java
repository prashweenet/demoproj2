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
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.xml.sax.InputSource;

/**
 * IFS Order Tax Request XML To Vertex
 *
 * IMPORTANT !!!
 * Do not place this class inside a package. It should be
 * in the default package.
 */
public class IFSOrderTaxRequestXMLToVertex implements Transformer {

   @Override
   public void init() throws IfsException {
   }

   private String getValueByTagName(String tag, Element element) {
      NodeList node = element.getElementsByTagName(tag);
      if (node.getLength() > 0) {
         Element valueElement = (Element) node.item(0);
         if (valueElement.hasChildNodes()) {
            NodeList valueList = valueElement.getChildNodes();
            return ((Node) valueList.item(0)).getNodeValue().trim();
         } else {
            return "";
         }
      } else {
         return "";
      }
   }

   @Override
   public String transform(String sIn) throws IfsException {
      StringBuilder sOut = new StringBuilder();
      String taxAreaId = "";
      String versionId = "";
      String sVertexEnvelope = "";
      try {
         InputSource inputSource = new InputSource(new StringReader(sIn));
         Document doc = XmlUtil.parseDocument(inputSource);
         doc.getDocumentElement().normalize();
         sOut.append("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n");
         NodeList msgVersion = doc.getElementsByTagName("VERSION");
         if (msgVersion.getLength() > 0) {
            Node msgLinea = msgVersion.item(0);
            if (msgLinea.getNodeType() == Node.ELEMENT_NODE) {
               Element refElementa = (Element) msgLinea;
               versionId = getValueByTagName("VERSION_ID", refElementa);
            }
         }
         sVertexEnvelope = "<VertexEnvelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns=\"urn:vertexinc:o-series:tps:" + versionId + ":0\">\n";
         sOut.append(sVertexEnvelope);

         NodeList msgLinesa = doc.getElementsByTagName("LOGIN");
         for (int i = 0; i < msgLinesa.getLength(); i++) {
            Node msgLinea = msgLinesa.item(i);
            if (msgLinea.getNodeType() == Node.ELEMENT_NODE) {
               Element refElementa = (Element) msgLinea;
               sOut.append("<Login>\n");
               String trustedId = getValueByTagName("TRUSTED_ID", refElementa);
               if (trustedId != null && trustedId.length() > 0) {
                  sOut.append("<TrustedId>").append(trustedId).append("</TrustedId>\n");
               } else {
                  sOut.append("<UserName>").append(getValueByTagName("USER_NAME", refElementa)).append("</UserName>\n");
                  sOut.append("<Password>").append(getValueByTagName("PASSWORD", refElementa)).append("</Password>\n");
               }
               sOut.append("</Login>\n");
            }
         }
         NodeList msgLines = doc.getElementsByTagName("ORDER_REQUEST");
         sOut.append("<QuotationRequest ");
         for (int i = 0; i < msgLines.getLength(); i++) {
            Node msgLine = msgLines.item(i);
            if (msgLine.getNodeType() == Node.ELEMENT_NODE) {
               Element refElement = (Element) msgLine;
               sOut.append("documentDate=\"").append(getValueByTagName("DOCUMENT_DATE", refElement)).append("\" transactionType=\"").append(getValueByTagName("TRANSACTION_TYPE", refElement)).append("\">\n");
               sOut.append("<Currency>").append(getValueByTagName("CURRENCY", refElement)).append("</Currency>\n");

            }
         }
         sOut.append("<Seller>\n");
         NodeList msgLinesOut = doc.getElementsByTagName("SELLER");
         for (int i = 0; i < msgLinesOut.getLength(); i++) {
            Node msgLineb = msgLinesOut.item(i);
            if (msgLineb.getNodeType() == Node.ELEMENT_NODE) {
               Element refElementb = (Element) msgLineb;
               sOut.append("<Company>").append(getValueByTagName("COMPANY", refElementb)).append("</Company>\n");
               sOut.append("<Division>").append(getValueByTagName("DIVISION", refElementb)).append("</Division>\n");
               sOut.append("<Department>").append(getValueByTagName("DEPARTMENT", refElementb)).append("</Department>\n");

               taxAreaId = getValueByTagName("PHY_ORI_TAX_AREA_ID", refElementb);
               if (!taxAreaId.isEmpty()) {
                  sOut.append("<PhysicalOrigin taxAreaId=\"").append(taxAreaId).append("\">").append(getValueByTagName("PHYSICAL_ORIGIN", refElementb)).append("</PhysicalOrigin>\n");
               } else {
                  NodeList addList = refElementb.getElementsByTagName("PHYSICAL_ORIGIN");
                  if (addList.getLength() > 0) {
                     sOut.append("<PhysicalOrigin>\n");
                     Node addListItem = addList.item(0);
                     if (addListItem.getNodeType() == Node.ELEMENT_NODE) {
                        Element addrElement = (Element) addListItem;
                        String tempValue = getValueByTagName("STREET_ADDRESS_1", addrElement);
                        if (tempValue != null && tempValue.length() > 0) {
                           sOut.append("<StreetAddress1>").append(tempValue).append("</StreetAddress1>\n");
                        }
                        tempValue = getValueByTagName("STREET_ADDRESS_2", addrElement);
                        if (tempValue != null && tempValue.length() > 0) {
                           sOut.append("<StreetAddress2>").append(tempValue).append("</StreetAddress2>\n");
                        }
                        tempValue = getValueByTagName("CITY", addrElement);
                        if (tempValue != null && tempValue.length() > 0) {
                           sOut.append("<City>").append(tempValue).append("</City>\n");
                        }
                        tempValue = getValueByTagName("STATE", addrElement);
                        if (tempValue != null && tempValue.length() > 0) {
                           sOut.append("<MainDivision>").append(tempValue).append("</MainDivision>\n");
                        }
                        tempValue = getValueByTagName("COUNTY", addrElement);
                        if (tempValue != null && tempValue.length() > 0) {
                           sOut.append("<SubDivision>").append(tempValue).append("</SubDivision>\n");
                        }
                        tempValue = getValueByTagName("ZIP_CODE", addrElement);
                        if (tempValue != null && tempValue.length() > 0) {
                           sOut.append("<PostalCode>").append(tempValue).append("</PostalCode>\n");
                        }
                        tempValue = getValueByTagName("COUNTRY", addrElement);
                        if (tempValue != null && tempValue.length() > 0) {
                           sOut.append("<Country>").append(tempValue).append("</Country>\n");
                        }
                     }
                     sOut.append("</PhysicalOrigin>\n");
                  }
               }

               taxAreaId = getValueByTagName("ADM_ORI_TAX_AREA_ID", refElementb);
               if (!taxAreaId.isEmpty()) {
                  sOut.append("<AdministrativeOrigin taxAreaId=\"").append(taxAreaId).append("\">").append(getValueByTagName("ADMINISTRATIVE_ORIGIN", refElementb)).append("</AdministrativeOrigin>\n");
               } else {
                  NodeList addList = refElementb.getElementsByTagName("ADMINISTRATIVE_ORIGIN");
                  if (addList.getLength() > 0) {
                     sOut.append("<AdministrativeOrigin>\n");
                     Node addListItem = addList.item(0);
                     if (addListItem.getNodeType() == Node.ELEMENT_NODE) {
                        Element addrElement = (Element) addListItem;
                        String tempValue = getValueByTagName("STREET_ADDRESS_1", addrElement);
                        if (tempValue != null && tempValue.length() > 0) {
                           sOut.append("<StreetAddress1>").append(tempValue).append("</StreetAddress1>\n");
                        }
                        tempValue = getValueByTagName("STREET_ADDRESS_2", addrElement);
                        if (tempValue != null && tempValue.length() > 0) {
                           sOut.append("<StreetAddress2>").append(tempValue).append("</StreetAddress2>\n");
                        }
                        tempValue = getValueByTagName("CITY", addrElement);
                        if (tempValue != null && tempValue.length() > 0) {
                           sOut.append("<City>").append(tempValue).append("</City>\n");
                        }
                        tempValue = getValueByTagName("STATE", addrElement);
                        if (tempValue != null && tempValue.length() > 0) {
                           sOut.append("<MainDivision>").append(tempValue).append("</MainDivision>\n");
                        }
                        tempValue = getValueByTagName("COUNTY", addrElement);
                        if (tempValue != null && tempValue.length() > 0) {
                           sOut.append("<SubDivision>").append(tempValue).append("</SubDivision>\n");
                        }
                        tempValue = getValueByTagName("ZIP_CODE", addrElement);
                        if (tempValue != null && tempValue.length() > 0) {
                           sOut.append("<PostalCode>").append(tempValue).append("</PostalCode>\n");
                        }
                        tempValue = getValueByTagName("COUNTRY", addrElement);
                        if (tempValue != null && tempValue.length() > 0) {
                           sOut.append("<Country>").append(tempValue).append("</Country>\n");
                        }
                     }
                     sOut.append("</AdministrativeOrigin>\n");
                  }
               }
            }
         }
         sOut.append("</Seller>\n");
         sOut.append("<Customer>\n");
         NodeList msgLinesc = doc.getElementsByTagName("CUSTOMER");
         for (int i = 0; i < msgLinesc.getLength(); i++) {
            Node msgLinec = msgLinesc.item(i);
            if (msgLinec.getNodeType() == Node.ELEMENT_NODE) {
               Element refElementc = (Element) msgLinec;
               sOut.append("<CustomerCode classCode=\"").append(getValueByTagName("CLASS_CODE", refElementc)).append("\">").append(getValueByTagName("CUSTOMER_CODE", refElementc)).append("</CustomerCode>\n");

               taxAreaId = getValueByTagName("DES_TAX_AREA_ID", refElementc);
               if (!taxAreaId.isEmpty()) {
                  sOut.append("<Destination taxAreaId=\"").append(taxAreaId).append("\">").append(getValueByTagName("DESTINATION", refElementc)).append("</Destination>\n");
               } else {
                  NodeList addList = refElementc.getElementsByTagName("DESTINATION_ADDR");
                  if (addList.getLength() > 0) {
                     sOut.append("<Destination>\n");
                     Node addListItem = addList.item(0);
                     if (addListItem.getNodeType() == Node.ELEMENT_NODE) {
                        Element addrElement = (Element) addListItem;
                        String tempValue = getValueByTagName("STREET_ADDRESS_1", addrElement);
                        if (tempValue != null && tempValue.length() > 0) {
                           sOut.append("<StreetAddress1>").append(tempValue).append("</StreetAddress1>\n");
                        }
                        tempValue = getValueByTagName("STREET_ADDRESS_2", addrElement);
                        if (tempValue != null && tempValue.length() > 0) {
                           sOut.append("<StreetAddress2>").append(tempValue).append("</StreetAddress2>\n");
                        }
                        tempValue = getValueByTagName("CITY", addrElement);
                        if (tempValue != null && tempValue.length() > 0) {
                           sOut.append("<City>").append(tempValue).append("</City>\n");
                        }
                        tempValue = getValueByTagName("STATE", addrElement);
                        if (tempValue != null && tempValue.length() > 0) {
                           sOut.append("<MainDivision>").append(tempValue).append("</MainDivision>\n");
                        }
                        tempValue = getValueByTagName("COUNTY", addrElement);
                        if (tempValue != null && tempValue.length() > 0) {
                           sOut.append("<SubDivision>").append(tempValue).append("</SubDivision>\n");
                        }
                        tempValue = getValueByTagName("ZIP_CODE", addrElement);
                        if (tempValue != null && tempValue.length() > 0) {
                           sOut.append("<PostalCode>").append(tempValue).append("</PostalCode>\n");
                        }
                        tempValue = getValueByTagName("COUNTRY", addrElement);
                        if (tempValue != null && tempValue.length() > 0) {
                           sOut.append("<Country>").append(tempValue).append("</Country>\n");
                        }
                     }
                     sOut.append("</Destination>\n");
                  }
               }
            }
         }
         sOut.append("</Customer>\n");

         NodeList msgLinesd = doc.getElementsByTagName("LINE_ITEM");
         for (int i = 0; i < msgLinesd.getLength(); i++) {
            Node msgLined = msgLinesd.item(i);
            if (msgLined.getNodeType() == Node.ELEMENT_NODE) {
               Element refElementd = (Element) msgLined;
               if (getValueByTagName("TAX_DATE", refElementd).length() > 0) {
                  sOut.append("<LineItem lineItemNumber=\"").append(getValueByTagName("LINE_ITEM_NUMBER", refElementd)).append("\" lineItemId=\"").append(getValueByTagName("LINE_ITEM_ID", refElementd)).append("\" isMulticomponent=\"").append(getValueByTagName("IS_MULTIOMPONENT", refElementd)).append("\" taxDate=\"").append(getValueByTagName("TAX_DATE", refElementd)).append("\">\n");
               } else {
                  sOut.append("<LineItem lineItemNumber=\"").append(getValueByTagName("LINE_ITEM_NUMBER", refElementd)).append("\" lineItemId=\"").append(getValueByTagName("LINE_ITEM_ID", refElementd)).append("\" isMulticomponent=\"").append(getValueByTagName("IS_MULTIOMPONENT", refElementd)).append("\">\n");
               }
               if (getValueByTagName("OVERRIDE_TYPE", refElementd).length() > 0) {
                  sOut.append("<TaxOverride overrideType=\"").append(getValueByTagName("OVERRIDE_TYPE", refElementd)).append("\"></TaxOverride>\n");
               }
               sOut.append("<Product productClass=\"").append(getValueByTagName("PRODUCT_CLASS", refElementd)).append("\">").append(getValueByTagName("PRODUCT", refElementd)).append("</Product>\n");
               sOut.append("<Quantity>").append(getValueByTagName("QUANTITY", refElementd)).append("</Quantity>\n");
               sOut.append("<ExtendedPrice>").append(getValueByTagName("EXTENDED_PRICE", refElementd)).append("</ExtendedPrice>\n");
               sOut.append("</LineItem>\n");
            }
         }
         sOut.append("</QuotationRequest>\n");
         sOut.append("</VertexEnvelope>\n");
      } catch (IOException error) {
         error.printStackTrace();
      }
      return (sOut.toString());
   }
}
