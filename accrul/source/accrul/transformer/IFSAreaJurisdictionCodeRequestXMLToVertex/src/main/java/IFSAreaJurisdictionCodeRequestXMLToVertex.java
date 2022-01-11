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
 * IFS Area Jurisdiction Code Request XML To Vertex
 *
 * IMPORTANT !!!
 * Do not place this class inside a package. It should be
 * in the default package.
 */
public class IFSAreaJurisdictionCodeRequestXMLToVertex implements Transformer {

   @Override
   public void init() throws IfsException {
   }

   private String getValue(Element element, String tag) {
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
      String versionId = null;
      try {
         InputSource inputSource = new InputSource(new StringReader(sIn));
         Document doc = XmlUtil.parseDocument(inputSource);
         doc.getDocumentElement().normalize();

         NodeList msgVersion = doc.getElementsByTagName("VERSION");
         if (msgVersion.getLength() > 0) {
            Node msgLinea = msgVersion.item(0);
            if (msgLinea.getNodeType() == Node.ELEMENT_NODE) {
               Element refElementa = (Element) msgLinea;
               versionId = getValue(refElementa, "VERSION_ID");
            }
         }

         String sVertexEnvelope = "<VertexEnvelope xsi:schemaLocation=\"" + "urn:vertexinc:o-series:tps:" + versionId + ":0 VertexInc_Envelope.xsd\" " + "xmlns:xsi=" + "\"http://www.w3.org/2001/XMLSchema-instance\"" + " xmlns=\"urn:vertexinc:o-series:tps:" + versionId + ":0\"> \n";
         sOut.append(sVertexEnvelope);
         NodeList msgLogin = doc.getElementsByTagName("LOGIN");
         if (msgLogin.getLength() > 0) {
            Node msgLinea = msgLogin.item(0);
            if (msgLinea.getNodeType() == Node.ELEMENT_NODE) {
               Element refElementa = (Element) msgLinea;
               sOut.append("<Login>\n");
               String trustedId = getValue(refElementa, "TRUSTED_ID");
               if (trustedId != null && trustedId.length() > 0) {
                  sOut.append("<TrustedId>").append(trustedId).append("</TrustedId>\n");
               } else {
                  sOut.append("<UserName>").append(getValue(refElementa, "USER_NAME")).append("</UserName>\n");
                  sOut.append("<Password>").append(getValue(refElementa, "PASSWORD")).append("</Password>\n");
               }
               sOut.append("</Login>\n");
            }
         }

         sOut.append("<FindTaxAreasRequest>\n");
         NodeList msgAreaRequests = doc.getElementsByTagName("TAX_AREA_REQUEST");
         for (int i = 0; i < msgAreaRequests.getLength(); i++) {
            Node msgLine = msgAreaRequests.item(i);
            if (msgLine.getNodeType() == Node.ELEMENT_NODE) {
               Element refElement = (Element) msgLine;
               sOut.append("<TaxAreaLookup asOfDate=\"").append(getValue(refElement, "LOOKUP_DATE")).append("\">\n");
               NodeList msgPostal = refElement.getElementsByTagName("POSTAL_ADDRESS");
               sOut.append("<PostalAddress>\n");
               if (msgPostal.getLength() > 0) {
                  Node msgLineb = msgPostal.item(0);
                  if (msgLineb.getNodeType() == Node.ELEMENT_NODE) {
                     Element refElementb = (Element) msgLineb;
                     if (getValue(refElementb, "STREET_ADDRESS_1").length() > 0) {
                        sOut.append("<StreetAddress1>").append(getValue(refElementb, "STREET_ADDRESS_1")).append("</StreetAddress1>\n");
                     }
                     if (getValue(refElementb, "STREET_ADDRESS_2").length() > 0) {
                        sOut.append("<StreetAddress2>").append(getValue(refElementb, "STREET_ADDRESS_2")).append("</StreetAddress2>\n");
                     }
                     if (getValue(refElementb, "CITY").length() > 0) {
                        sOut.append("<City>").append(getValue(refElementb, "CITY")).append("</City>\n");
                     }
                     if (getValue(refElementb, "STATE").length() > 0) {
                        sOut.append("<MainDivision>").append(getValue(refElementb, "STATE")).append("</MainDivision>\n");
                     }
                     if (getValue(refElementb, "COUNTY").length() > 0) {
                        sOut.append("<SubDivision>").append(getValue(refElementb, "COUNTY")).append("</SubDivision>\n");
                     }
                     if (getValue(refElementb, "COUNTRY").length() > 0) {
                        sOut.append("<Country>").append(getValue(refElementb, "COUNTRY")).append("</Country>\n");
                     }
                     sOut.append("<PostalCode>").append(getValue(refElementb, "ZIP_CODE")).append("</PostalCode>\n");
                  }
               }
               sOut.append("</PostalAddress>\n");
               sOut.append("</TaxAreaLookup>\n");
            }
         }
         sOut.append("</FindTaxAreasRequest>\n");
         sOut.append("</VertexEnvelope>\n");
      } catch (IOException error) {
         error.printStackTrace();
      }
      return (sOut.toString());
   }
}
