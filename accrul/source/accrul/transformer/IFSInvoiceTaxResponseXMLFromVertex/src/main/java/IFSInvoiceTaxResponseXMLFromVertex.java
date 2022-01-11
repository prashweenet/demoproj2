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
 * IFS Invoice Tax Response XML From Vertex
 *
 * IMPORTANT !!!
 * Do not place this class inside a package. It should be
 * in the default package.
 */
public class IFSInvoiceTaxResponseXMLFromVertex implements Transformer {

   @Override
   public void init() throws IfsException {
   }

   private String getValue(Element element, String tag, int level) {
      NodeList node = element.getElementsByTagName(tag);
      if (node.getLength() > 0) {
         Element valueElement = (Element) node.item(level);
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

   private String encode(String s) {
      StringBuilder result = new StringBuilder(s.length());
      char c;
      for (int i = 0; i < s.length(); i++) {
         c = s.charAt(i);
         switch (c) {
            case '&':
               result.append("&amp;");
               break;
            case '\'':
               result.append("&apos;");
               break;
            case '>':
               result.append("&gt;");
               break;
            case '<':
               result.append("&lt;");
               break;
            case '"':
               result.append("&quot;");
               break;
            default:
               result.append(c);
         }
      }
      return result.toString();
   }

   @Override
   public String transform(String sIn) throws IfsException {
      StringBuilder sOut = new StringBuilder();
      try {
         InputSource inputSource = new InputSource(new StringReader(sIn));
         Document doc = XmlUtil.parseDocument(inputSource);
         // normalize text representation            
         doc.getDocumentElement().normalize();
         sOut.append("<TAX_INVOICE_RESPONSE>\n");
         sOut.append("<INVOICE_RESPONSES>\n");
         NodeList msgLinesa = doc.getElementsByTagName("InvoiceResponse");
         sOut.append("<INVOICE_RESPONSE>\n");

         for (int i = 0; i < msgLinesa.getLength(); i++) {
            Node msgLinea = msgLinesa.item(i);
            if (msgLinea.getNodeType() == Node.ELEMENT_NODE) {
               Element refElementa = (Element) msgLinea;
               sOut.append("<DOCUMENT_DATE>").append(refElementa.getAttribute("documentDate")).append("</DOCUMENT_DATE>\n");
               sOut.append("<SUB_TOTAL>").append(getValue(refElementa, "SubTotal", i)).append("</SUB_TOTAL>\n");
               sOut.append("<TOTAL>").append(getValue(refElementa, "Total", i)).append("</TOTAL>\n");
               sOut.append("<TOTAL_TAX>").append(getValue(refElementa, "TotalTax", i)).append("</TOTAL_TAX>\n");

               //-- get lower level
               sOut.append("<LINE_ITEMS>\n");
               NodeList msgLinesb = refElementa.getElementsByTagName("LineItem");
               sOut.append("<LINE_ITEM>\n");
               for (int j = 0; j < msgLinesb.getLength(); j++) {
                  Node msgLineb = msgLinesb.item(j);
                  if (msgLineb.getNodeType() == Node.ELEMENT_NODE) {
                     Element refElementb = (Element) msgLineb;
                     sOut.append("<LINE_ITEM_NUMBER>").append(refElementb.getAttribute("lineItemNumber")).append("</LINE_ITEM_NUMBER>\n");
                     sOut.append("<LINE_ITEM_ID>").append(refElementb.getAttribute("lineItemId")).append("</LINE_ITEM_ID>\n");
                     sOut.append("<PRODUCT>").append(getValue(refElementa, "Product", j)).append("</PRODUCT>\n");
                     sOut.append("<PRODUCT_CLASS>" + "" + "</PRODUCT_CLASS>\n");
                     sOut.append("<EXTENDED_PRICE>").append(getValue(refElementa, "ExtendedPrice", i)).append("</EXTENDED_PRICE>\n");
                     sOut.append("<QUANTITY>").append(getValue(refElementa, "Quantity", i)).append("</QUANTITY>\n");
                     sOut.append("<TAXESES>\n");
                     NodeList msgLinesc = refElementb.getElementsByTagName("Taxes");

                     for (int k = 0; k < msgLinesc.getLength(); k++) {
                        sOut.append("<TAXES>\n");
                        Node msgLinec = msgLinesc.item(k);
                        if (msgLinec.getNodeType() == Node.ELEMENT_NODE) {
                           Element refElementc = (Element) msgLinec;
                           NodeList msgLinesd = refElementc.getElementsByTagName("Jurisdiction");
                           for (int l = 0; l < msgLinesd.getLength(); l++) {
                              Node msgLined = msgLinesd.item(l);
                              if (msgLined.getNodeType() == Node.ELEMENT_NODE) {
                                 Element refElementd = (Element) msgLined;
                                 sOut.append("<TAX_RESULT>").append(refElementc.getAttribute("taxResult")).append("</TAX_RESULT>\n");
                                 sOut.append("<TAX_TYPE>").append(encode(refElementc.getAttribute("taxType"))).append("</TAX_TYPE>\n");
                                 sOut.append("<SITUS>").append(refElementc.getAttribute("situs")).append("</SITUS>\n");
                                 sOut.append("<JURISDICTION>" + "" + "</JURISDICTION>\n");
                                 sOut.append("<JURISDICTION_ID>").append(refElementd.getAttribute("jurisdictionId")).append("</JURISDICTION_ID>\n");
                                 sOut.append("<JURISDICTION_LEVEL>").append(refElementd.getAttribute("jurisdictionLevel")).append("</JURISDICTION_LEVEL>\n");
                                 sOut.append("<CALCULATED_TAX>").append(getValue(refElementc, "CalculatedTax", l)).append("</CALCULATED_TAX>\n");
                                 sOut.append("<EFFECTIVE_RATE>").append(getValue(refElementc, "EffectiveRate", l)).append("</EFFECTIVE_RATE>\n");
                                 sOut.append("<TAXABLE>").append(getValue(refElementc, "Taxable", l)).append("</TAXABLE>\n");
                                 sOut.append("<IMPOSITION>").append(encode(getValue(refElementc, "Imposition", l))).append("</IMPOSITION>\n");
                                 sOut.append("<TAX_RULE_ID>").append(getValue(refElementc, "TaxRuleId", l)).append("</TAX_RULE_ID>\n");
                              }
                           }
                        }
                        sOut.append("</TAXES>\n");
                     }
                     sOut.append("</TAXESES>\n");
                  }
               }
               sOut.append("</LINE_ITEM>\n");
               sOut.append("</LINE_ITEMS>\n");
            }
         }
         sOut.append("</INVOICE_RESPONSE>\n");
         sOut.append("</INVOICE_RESPONSES>\n");
         sOut.append("</TAX_INVOICE_RESPONSE>\n");
      } catch (Exception err) {
         err.printStackTrace();
      }
      return (sOut.toString());
   }
}
