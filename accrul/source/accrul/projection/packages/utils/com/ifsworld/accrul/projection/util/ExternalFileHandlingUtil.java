//
//  Template:     3.0
//  Built by:     IFS Developer Studio 9.802.2451.20160623
//
//
// ---------------------------------------------------------------------------
//
// ---------------------------------------------------------------------------
//
//  Logical unit: 
//  Type:         
//  Component:    UXX
//
// ---------------------------------------------------------------------------

package com.ifsworld.accrul.projection.util;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.FileInputStream;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

/*
 * Implementation class for all global functions required for External File handling.
 */

public class ExternalFileHandlingUtil {
   /*
   Use this method to download normal text file when the content of the file is in a String
   parameters -
   String output - The content of the file in String
   String fileName - Name of the file
   String streamAttributeName - The name of the 'Stream' type attribute (in the projection)
   Connection connection - Connection
   */
   public Map<String, Object> downloadFile(String output, String fileName, String streamAttributeName) {
      FileWriter fileWriter;
      BufferedWriter bufferedWriter;
      InputStream returnInputStream = null;
      try {
         fileWriter = new FileWriter(fileName);
         bufferedWriter = new BufferedWriter(fileWriter);
         bufferedWriter.write(output);        
         bufferedWriter.close();
         returnInputStream = new FileInputStream(fileName);
      } catch (IOException ex) {
         Logger.getLogger(ExternalFileHandlingUtil.class.getName()).log(Level.SEVERE, null, ex);
      }
      return CreateFileInfoMap(returnInputStream, streamAttributeName, fileName);
   }
   
   /*
   Use this method to download normal text file when the content of the file is in Message_SYS.Attribute structure
   parameters -
   String outputMessage - The content of the file in Message_SYS.Attribute structure
   int totalLines - Total number of lines in the file content
   String subMessageAttrName - If the outputMessage is consists of submessages (ex: In Ext File Assistant) the AttributeName of the file content in sub message. Pass null if no sub message is not involved
   String fileName - Name of the file
   String streamAttributeName - The name of the 'Stream' type attribute (in the projection)
   Connection connection - Connection
   */
   public Map<String, Object> downloadFile(String outputMessage, int totalLines, String subMessageAttrName, String fileName, String streamAttributeName, final Connection connection) {
      String output = null;
      int i = 1;
      while(totalLines > 0)
      {
         String fileLine = getAttributeValueFromMessage(outputMessage, String.valueOf(i), connection);
         if (subMessageAttrName != null) {
            fileLine = getAttributeValueFromMessage(fileLine, subMessageAttrName, connection);
         }
         if (output == null) 
         {
            output = fileLine;
         }
         else {
            output = output + System.lineSeparator() + fileLine;
         }
            
         totalLines -= 1;
         i += 1;
      }
      return downloadFile(output, fileName, streamAttributeName);
   }
   
   /*
   Use this method to download normal text file when the content of the file is in an ArrayList
   parameters -
   ArrayList<String> output - The content of the file in an ArrayList
   String fileName - Name of the file
   String streamAttributeName - The name of the 'Stream' type attribute (in the projection)
   Connection connection - Connection
   */
   public Map<String, Object> downloadFile(ArrayList<String> output, String fileName, String streamAttributeName) {
      String outputString = null;
      for (int i = 0; i < output.size(); i++) {
         if (outputString == null) 
         {
            outputString = output.get(i);
         }
         else {
            outputString = outputString + System.lineSeparator() + output.get(i);
         }
      }
      return downloadFile(outputString, fileName, streamAttributeName);
   }
   
   /*
   Use this method to get Message_SYS type message from the inputstream
   parameters -
   InputStream inputStream - The InputStream which has to be read
   Connection connection - Connection
   */
   public String getMessageFromInputStream(InputStream inputStream, Connection connection)  {
      int nCounter = 0;
      String finalMessage = new String();
      BufferedReader reader = new BufferedReader(new InputStreamReader(inputStream));
      
      try {
         String line = reader.readLine();
         while(line != null)
         {
            nCounter += 1;
            String subMessage = new String();
            subMessage = getAttributeAddedMessage(subMessage, "FILE_LINE", line, connection);
            finalMessage = getAttributeAddedMessage(finalMessage, Integer.toString(nCounter), subMessage, connection);               
            line = reader.readLine();             
         }
      } catch (IOException ex) {
         Logger.getLogger(ExternalFileHandlingUtil.class.getName()).log(Level.SEVERE, null, ex);
      }
      return finalMessage;
   }
   
   /*
   Use this method to get the value of an attribute from Message_SYS type variable
   parameters -
   String message - The Message from which the value needs to extracted from
   String name - Name of the attrbute
   Connection connection - Connection
   */   
   public String getAttributeValueFromMessage(String message, String name, Connection connection) {
      CallableStatement stmt;
      String attributeValue = null;
      try {
         stmt = connection.prepareCall("{call Message_SYS.Get_Attribute(?, ?, ?)}");
         stmt.setString(1, message);
         stmt.setString(2, name);
         stmt.registerOutParameter(3, java.sql.Types.VARCHAR);
         stmt.execute();
         attributeValue = stmt.getString(3);
      } catch (SQLException ex) {
         Logger.getLogger(ExternalFileHandlingUtil.class.getName()).log(Level.SEVERE, null, ex);
      }
      return attributeValue;
   }
   
   /*
   Use this method to insert the specified attribute and value to a Message_SYS type variable and return
   parameters -
   String message - The Current Message
   String name - Name of the attrbute
   String attributeValue - Value of the attribute
   Connection connection - Connection
   */   
   private String getAttributeAddedMessage(String message, String attributeName, String attributeValue, Connection connection) {
      CallableStatement stmt;
      try {
         stmt = connection.prepareCall("{call Message_SYS.Add_Attribute(?, ?, ?)}");
         stmt.setString(1, message);
         stmt.registerOutParameter(1, java.sql.Types.VARCHAR);
         stmt.setString(2, attributeName);
         stmt.setString(3, attributeValue);
         stmt.execute();
         message = stmt.getString(1);
      } catch (SQLException ex) {
         Logger.getLogger(ExternalFileHandlingUtil.class.getName()).log(Level.SEVERE, null, ex);
      }
      return message;
   }
   
   /*
   Use this method to get the value for a key from the parameters map
   parameters -
   Map<String, Object> parameters - Parameters stated in a map
   String keyName - Name of the key (this is same as the attribute name of the key in the projection)
   */
   public Object GetKeyValue(final Map<String, Object> parameters, String keyName) {
      Object keyValue = null;
      for (String key : parameters.keySet())
      {
         if(keyName.equals(key)) 
         {
            keyValue = parameters.get(key);
         }
      }
      return keyValue;
   }
   
   /*
   Use this method to get the InputStream from the parameters map when uploading file
   parameters -
   Map<String, Object> parameters - Parameters stated in a map
   String streamAttributeName - The name of the 'Stream' type attribute (in the projection)
   */
   public InputStream GetInputStream(final Map<String, Object> parameters, String streamAttributeName) {
      return (InputStream)GetKeyValue(parameters, streamAttributeName);
   }

   /*
   This method creates a Map for the file (inputstream) that is ready to be downoaded
   parameters -
   InputStream returnInputStream - The content of the file as an inputstream
   String streamAttributeName - The name of the 'Stream' type attribute (in the projection)
   String fileName - Name of the file
   */
   private Map<String, Object> CreateFileInfoMap(InputStream returnInputStream, String streamAttributeName, String fileName) {
      Map<String, Object> returnMap = new HashMap<>();
      returnMap.put(streamAttributeName, returnInputStream);
      returnMap.put("FileName", fileName);
      return returnMap;
   }
}