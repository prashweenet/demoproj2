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
 * I F S Area Jurisdiction Code Response X M L From Vertex
 *
 * IMPORTANT !!!
 * Do not place this class inside a package. It should be
 * in the default package.
 */
public class IFSAreaJurisdictionCodeResponseXMLFromVertex implements Transformer {

   @Override
   public void init() throws IfsException {
   }

   @Override
   public String transform(String sIn) throws IfsException {
      StringBuilder sOut = new StringBuilder();
      int highestConfIndicatorIndex = 0;
      try {
         InputSource inputSource = new InputSource(new StringReader(sIn));
         Document doc = XmlUtil.parseDocument(inputSource);
         doc.getDocumentElement().normalize();
         sOut.append("<TAX_AREA_RESPONSE>\n");
         NodeList msgTaxAreaResults = doc.getElementsByTagName("TaxAreaLookupResult");
         for (int i = 0; i < msgTaxAreaResults.getLength(); i++) {
            Node msgTaxAreaResult = msgTaxAreaResults.item(i);
            if (msgTaxAreaResult.getNodeType() == Node.ELEMENT_NODE) {
               sOut.append("<TAX_AREA_RESULT_LIST>\n");
               Element refElement1 = (Element) msgTaxAreaResult;
               NodeList msgTaxAreas = refElement1.getElementsByTagName("TaxAreaResult");
               highestConfIndicatorIndex = getHighestConfIndicator(msgTaxAreas);
               Node msgTaxArea = msgTaxAreas.item(highestConfIndicatorIndex);
               if (msgTaxArea.getNodeType() == Node.ELEMENT_NODE) {
                  Element refElement2 = (Element) msgTaxArea;
                  sOut.append("<TAX_AREA_RESULT>\n");
                  sOut.append("<TAX_AREA_ID>").append(refElement2.getAttribute("taxAreaId")).append("</TAX_AREA_ID>\n");
                  sOut.append("<TAX_ADDR_POS>").append(String.valueOf(i)).append("</TAX_ADDR_POS>\n");
                  sOut.append("<AS_OF_DATE>").append(refElement2.getAttribute("asOfDate")).append("</AS_OF_DATE>\n");
                  sOut.append("<CONFIDENCE_INDICATOR>").append(refElement2.getAttribute("confidenceIndicator")).append("</CONFIDENCE_INDICATOR>\n");
                  sOut.append("</TAX_AREA_RESULT>\n");
               }
               sOut.append("</TAX_AREA_RESULT_LIST>\n");
            }
         }
         sOut.append("</TAX_AREA_RESPONSE>\n");
      } catch (IOException error) {
         error.printStackTrace();
      }
      return (sOut.toString());
   }
   
   public int getHighestConfIndicator(NodeList msgTaxAreas) {

      int noOfTaxAreaIds = msgTaxAreas.getLength();
      int[] confIndicators = new int[noOfTaxAreaIds];
      int highestConfIndicatorIndex = 0;

      for (int j = 0; j < noOfTaxAreaIds; j++) {
         confIndicators[j] = Integer.parseInt(((Element) msgTaxAreas.item(j)).getAttribute("confidenceIndicator"));
      }
      for (int i = 1; i < confIndicators.length; i++) {
         if (confIndicators[i] > confIndicators[highestConfIndicatorIndex]) {
            highestConfIndicatorIndex = i;
         }
      }
      return highestConfIndicatorIndex;
   }
}
