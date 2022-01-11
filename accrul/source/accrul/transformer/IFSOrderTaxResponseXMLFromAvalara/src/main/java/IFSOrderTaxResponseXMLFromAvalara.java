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
 * I F S Order Tax Response X M L From Avalara
 *
 * IMPORTANT !!!
 * Do not place this class inside a package. It should be
 * in the default package.
 */
public class IFSOrderTaxResponseXMLFromAvalara implements Transformer {

   @Override
   public void init() throws IfsException {
   }

   private String getValue(Element element, String tag, int level) {
      NodeList node = element.getElementsByTagName(tag);
      if (node.getLength() > 0) {
         Element valueElement = (Element) node.item(level);

         if (valueElement.hasChildNodes()) {
            NodeList valueList = valueElement.getChildNodes();
            return valueList.item(0).getNodeValue().trim();
         }
         return "";
      }
      return "";
   }

   private String getValueByTagName(String tag, Element element) {
      NodeList node = element.getElementsByTagName(tag);
      if (node.getLength() > 0) {
         Element valueElement = (Element) node.item(0);

         if (valueElement.hasChildNodes()) {
            NodeList valueList = valueElement.getChildNodes();
            return valueList.item(0).getNodeValue().trim();
         }
         return "";
      }
      return "";
   }

   private String encode(String s) {
      StringBuilder result = new StringBuilder(s.length());

      for (int i = 0; i < s.length(); i++) {
         char c = s.charAt(i);
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
      StringBuilder sb = new StringBuilder();
      try {
         InputSource inputSource = new InputSource(new StringReader(sIn));
         Document doc = XmlUtil.parseDocument(inputSource);

         doc.getDocumentElement().normalize();
         NodeList msgLinesa = doc.getElementsByTagName("GetTaxResult");
         sb.append("<GET_TAX_RESULT>\n");

         for (int i = 0; i < msgLinesa.getLength(); i++) {
            Node msgLinea = msgLinesa.item(i);
            if (msgLinea.getNodeType() == 1) {
               Element refElementa = (Element) msgLinea;

               sb.append("<TRANSACTION_ID>" + getValue(refElementa, "TransactionId", i) + "</TRANSACTION_ID>\n");
               sb.append("<RESULT_CODE>" + getValue(refElementa, "ResultCode", i) + "</RESULT_CODE>\n");
               sb.append("<DOC_ID>" + getValue(refElementa, "DocId", i) + "</DOC_ID>\n");
               sb.append("<DOCTYPE>" + getValue(refElementa, "DocType", i) + "</DOCTYPE>\n");
               sb.append("<DOC_CODE>" + getValue(refElementa, "DocCode", i) + "</DOC_CODE>\n");
               sb.append("<DOC_DATE>" + getValue(refElementa, "DocDate", i) + "</DOC_DATE>\n");
               sb.append("<TOTAL_AMOUNT>" + getValue(refElementa, "TotalAmount", i) + "</TOTAL_AMOUNT>\n");
               sb.append("<TOTAL_DISCOUNT>" + getValue(refElementa, "TotalDiscount", i) + "</TOTAL_DISCOUNT>\n");
               sb.append("<TOTAL_EXEMPTION>" + getValue(refElementa, "TotalExemption", i) + "</TOTAL_EXEMPTION>\n");
               sb.append("<TOTAL_TAXABLE>" + getValue(refElementa, "TotalTaxable", i) + "</TOTAL_TAXABLE>\n");
               sb.append("<TOTAL_TAX>" + getValue(refElementa, "TotalTax", i) + "</TOTAL_TAX>\n");
               sb.append("<TOTAL_TAX_CALCULATED>" + getValue(refElementa, "TotalTaxCalculated", i) + "</TOTAL_TAX_CALCULATED>\n");

               sb.append("<TAX_LINES>\n");

               NodeList msgLinesb = refElementa.getElementsByTagName("TaxLine");

               for (int j = 0; j < msgLinesb.getLength(); j++) {
                  sb.append("<TAX_LINE>\n");

                  Node msgLineb = msgLinesb.item(j);
                  if (msgLineb.getNodeType() == 1) {
                     Element refElementb = (Element) msgLineb;

                     sb.append("<NO>" + getValue(refElementa, "No", j) + "</NO>\n");
                     sb.append("<TAX_CODE>" + getValue(refElementa, "TaxCode", j) + "</TAX_CODE>\n");
                     sb.append("<TAXABILITY>" + getValue(refElementa, "Taxability", j) + "</TAXABILITY>\n");
                     sb.append("<BOUNDARY_LEVEL>" + getValue(refElementa, "BoundaryLevel", j) + "</BOUNDARY_LEVEL>\n");
                     sb.append("<EXEMPTION>" + getValue(refElementa, "Exemption", j) + "</EXEMPTION>\n");
                     sb.append("<TAXABLE>" + getValue(refElementa, "Taxable", j) + "</TAXABLE>\n");
                     sb.append("<RATE>" + getValue(refElementa, "Rate", j) + "</RATE>\n");
                     sb.append("<TAX>" + getValue(refElementa, "Tax", j) + "</TAX>\n");
                     sb.append("<TAX_CALCULATED>" + getValue(refElementa, "TaxCalculated", j) + "</TAX_CALCULATED>\n");

                     sb.append("<TAX_DETAILS>\n");

                     NodeList msgLinesc = refElementb.getElementsByTagName("TaxDetail");

                     for (int k = 0; k < msgLinesc.getLength(); k++) {
                        Node msgLinec = msgLinesc.item(k);
                        if (msgLinec.getNodeType() == 1) {
                           Element refElementc = (Element) msgLinec;

                           sb.append("<TAX_DETAIL>\n");
                           sb.append("<COUNTRY>" + getValueByTagName("Country", refElementc) + "</COUNTRY>\n");
                           sb.append("<REGION>" + getValueByTagName("Region", refElementc) + "</REGION>\n");
                           sb.append("<JURIS_TYPE>" + getValueByTagName("JurisType", refElementc) + "</JURIS_TYPE>\n");
                           sb.append("<JURIS_CODE>" + getValueByTagName("JurisCode", refElementc) + "</JURIS_CODE>\n");
                           sb.append("<TAXABLE>" + getValueByTagName("Taxable", refElementc) + "</TAXABLE>\n");
                           sb.append("<RATE>" + getValueByTagName("Rate", refElementc) + "</RATE>\n");
                           sb.append("<TAX>" + getValueByTagName("Tax", refElementc) + "</TAX>\n");
                           sb.append("<TAX_CALCULATED>" + getValueByTagName("TaxCalculated", refElementc) + "</TAX_CALCULATED>\n");
                           sb.append("<NON_TAXABLE>" + getValueByTagName("NonTaxable", refElementc) + "</NON_TAXABLE>\n");
                           sb.append("<EXEMPTION>" + getValueByTagName("Exemption", refElementc) + "</EXEMPTION>\n");
                           sb.append("<JURIS_NAME>" + encode(getValueByTagName("JurisName", refElementc)) + "</JURIS_NAME>\n");
                           sb.append("<TAX_NAME>" + getValueByTagName("TaxName", refElementc) + "</TAX_NAME>\n");
                           sb.append("</TAX_DETAIL>\n");
                        }
                     }
                     sb.append("</TAX_DETAILS>\n");
                  }
                  sb.append("</TAX_LINE>\n");
               }
               sb.append("</TAX_LINES>\n");
            }
         }
         sb.append("</GET_TAX_RESULT>\n");
      } catch (Exception error) {
         error.printStackTrace();
      }
      return sb.toString();

   }
}
