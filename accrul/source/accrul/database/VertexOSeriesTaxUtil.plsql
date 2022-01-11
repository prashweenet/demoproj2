-----------------------------------------------------------------------------
--
--  Logical unit: VertexOSeriesTaxUtil
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  171124  Paralk  Created.
--  191105  Vashlk  Bug 150833, Performance improvement for Vertex.
--  201102  RasDlk  SCZ-12209, Modified Fetch_And_Calculate_Tax() by changing a condtion to check parish_tax_amount_ is equal to zero or not.
--  210601  Smallk  FIZ-13216, Fixed issue with Vertex Fetch_Jurisdiction_Code(). 
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------

-------------------- PRIVATE DECLARATIONS -----------------------------------

-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------

FUNCTION Get_Next_Val_By_Tag_Name___ (
   xml_       IN VARCHAR2,
   tag_name_  IN VARCHAR2,
   index_     IN NUMBER ) RETURN VARCHAR2
IS
   begin_index_      NUMBER;
   end_index_        NUMBER;
   tag_length_       NUMBER;
   start_tag_name_   VARCHAR2(100);
   end_tag_name_     VARCHAR2(100);
   value_            VARCHAR2(2000);
BEGIN   
   start_tag_name_ := '<'||tag_name_||'>';
   end_tag_name_   := '</'||tag_name_||'>';
   tag_length_     := LENGTH(tag_name_);
   begin_index_    := INSTR(xml_,start_tag_name_, 1, index_);
   end_index_      := INSTR(xml_,end_tag_name_, 1, index_);
   value_          := SUBSTR(xml_, begin_index_ + tag_length_ + 2 , end_index_ - (begin_index_ + tag_length_ + 2));
   RETURN value_;
END Get_Next_Val_By_Tag_Name___;


FUNCTION Rem_Special_Char___ (
   in_str_ IN VARCHAR2 ) RETURN VARCHAR2
IS
   process_str_      VARCHAR2(2000);
BEGIN   
   -- ' and " s is handled by fnd, no need to convert
   IF (INSTR(in_str_,'&') >0) THEN
      process_str_ := REPLACE(in_str_, '&', '&'||'amp;');
   ELSE
      process_str_ := in_str_;  
   END IF; 
   IF (INSTR(in_str_,'>') >0) THEN
      process_str_ := REPLACE(process_str_, '>', '&'||'gt;');
   END IF; 
   IF (INSTR(in_str_,'<') >0) THEN
      process_str_ := REPLACE(process_str_, '<', '&'||'lt;');
   END IF; 
   RETURN process_str_;
END Rem_Special_Char___;


PROCEDURE Set_Login_And_Version_Info___ (   
   document_      IN OUT Plsqlap_Document_API.Document,
   element_id_    IN     Plsqlap_Document_API.Element_Id)
IS
   tmp_element_id_      Plsqlap_Document_API.Element_Id;
   ext_param_rec_       Ext_Tax_System_Parameters_API.Public_Rec;   
BEGIN
   ext_param_rec_ := Ext_Tax_System_Parameters_API.Get(1);    
   tmp_element_id_ := Plsqlap_Document_API.Add_Aggregate(document_, 'LOGIN_INFO', 'LOGIN', element_id_);
   IF (ext_param_rec_.trusted_id_vertex IS NOT NULL) THEN
      Plsqlap_Document_API.Add_Attribute(document_, 'TRUSTED_ID', ext_param_rec_.trusted_id_vertex, tmp_element_id_);   
   ELSE
      Plsqlap_Document_API.Add_Attribute(document_, 'USER_NAME', ext_param_rec_.user_name_vertex, tmp_element_id_);   
      Plsqlap_Document_API.Add_Attribute(document_, 'PASSWORD', ext_param_rec_.password_vertex, tmp_element_id_);         
   END IF;                            
   tmp_element_id_ := Plsqlap_Document_API.Add_Aggregate(document_, 'VERSION_INFO', 'VERSION', element_id_);
   Plsqlap_Document_API.Add_Attribute(document_, 'VERSION_ID', ext_param_rec_.version_vertex, tmp_element_id_);
END Set_Login_And_Version_Info___;

-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------

-------------------- LU SPECIFIC PROTECTED METHODS --------------------------

-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

PROCEDURE Fetch_Jurisdiction_Code (   
   postal_addresses_ IN OUT External_Tax_System_Util_API.postal_address_arr,
   context_          IN     VARCHAR2 )
IS
   xml_trans_              CLOB;
   temp_street_addr_       VARCHAR2(200);      
   document_               Plsqlap_Document_API.Document;
   tax_list_element_id_    Plsqlap_Document_API.Element_Id;
   tax_rec_element_id_     Plsqlap_Document_API.Element_Id;
   postal_addr_element_id_ Plsqlap_Document_API.Element_Id;
   xml_clob_               CLOB;             
BEGIN
   document_ := Plsqlap_Document_API.New_Document('JURISDICTION_CODE_REQUEST');
   IF (postal_addresses_.COUNT > 0) THEN
      tax_list_element_id_ := Plsqlap_Document_API.Add_Array(document_, 'TAX_AREA_REQUEST_LIST', document_.root_id);
      FOR i IN postal_addresses_.FIRST..postal_addresses_.LAST LOOP 
         tax_rec_element_id_ := Plsqlap_Document_API.Add_Document(document_, 'TAX_AREA_REQUEST', tax_list_element_id_);         
                  
         Plsqlap_Document_API.Add_Attribute(document_, 'LOOKUP_DATE', TO_CHAR(SYSDATE, 'YYYY-MM-DD'), tax_rec_element_id_); 
         postal_addr_element_id_ := Plsqlap_Document_API.Add_Aggregate(document_, 'ADDRESS_INFO', 'POSTAL_ADDRESS', tax_rec_element_id_);
         IF (postal_addresses_(i).address1 IS NOT NULL) THEN
            temp_street_addr_ := Rem_Special_Char___(postal_addresses_(i).address1);         
            Plsqlap_Document_API.Add_Attribute(document_, 'STREET_ADDRESS_1', temp_street_addr_, postal_addr_element_id_); 
         END IF;
         IF (postal_addresses_(i).address2 IS NOT NULL) THEN
            temp_street_addr_ := Rem_Special_Char___(postal_addresses_(i).address2);         
            Plsqlap_Document_API.Add_Attribute(document_, 'STREET_ADDRESS_2', temp_street_addr_, postal_addr_element_id_); 
         END IF;
         IF (postal_addresses_(i).zip_code IS NOT NULL) THEN
            Plsqlap_Document_API.Add_Attribute(document_, 'ZIP_CODE', postal_addresses_(i).zip_code, postal_addr_element_id_); 
         END IF;
         IF (postal_addresses_(i).city IS NOT NULL) THEN
            Plsqlap_Document_API.Add_Attribute(document_, 'CITY', postal_addresses_(i).city, postal_addr_element_id_); 
         END IF;
         IF (postal_addresses_(i).state IS NOT NULL) THEN
            Plsqlap_Document_API.Add_Attribute(document_, 'STATE', postal_addresses_(i).state, postal_addr_element_id_); 
         END IF;
         IF (postal_addresses_(i).county IS NOT NULL) THEN
            Plsqlap_Document_API.Add_Attribute(document_, 'COUNTY', postal_addresses_(i).county, postal_addr_element_id_); 
         END IF;
         IF (postal_addresses_(i).country IS NOT NULL) THEN
            Plsqlap_Document_API.Add_Attribute(document_, 'COUNTRY', postal_addresses_(i).country, postal_addr_element_id_); 
         END IF;
      END LOOP;
      --Add login and version info
      Set_Login_And_Version_Info___(document_, document_.root_id);   
      -- Add XML attribute data so that the XML will be backward compatible with Apps 10 
      -- and existing transformers built upon that XML will work. 
      -- This should be changed in the long run so that it is model-driven and sent to IFS Connect as JSON            
      Plsqlap_Document_API.Add_Xml_Attribute(document_, 'xmlns:xsi', 'http://www.w3.org/2001/XMLSchema-instance');
      -- The following line was the namespace information that was added by the old Biz API. If needed the following line can be uncommented
      --Plsqlap_Document_API.Add_Xml_Attribute(document_, 'xmlns', 'urn:ifsworld-com:schemas:vertex_services_handler_send_area_receive_jurisdiction_code_response');      
      Plsqlap_Document_API.To_Xml(xml_clob_, document_, TRUE, TRUE, NULL, FALSE, TRUE, NULL, FALSE, TRUE);                                                 
      Plsqlap_Server_API.Invoke_Outbound_Message(xml_clob_,
                                                 sender_       => 'IFS',
                                                 receiver_     => 'VERTEX',
                                                 message_type_ => 'APPLICATION_MESSAGE',                                            
                                                 message_function_ => 'SEND_AREA_RECEIVE_JURISDICTION_CODE');                                                             
      xml_trans_ := xml_clob_;
      FOR index_ IN 0..(postal_addresses_.COUNT - 1) LOOP
         IF (Iso_Country_API.Get_Fetch_Jurisdiction_Code_Db(postal_addresses_(index_).country) = 'TRUE') THEN
            postal_addresses_(index_).jurisdiction_code := Get_Next_Val_By_Tag_Name___(xml_trans_, 'TAX_AREA_ID', (index_ + 1));
         ELSE
            IF (context_ = 'ORDER_CALCULATION') THEN
               postal_addresses_(index_).jurisdiction_code := '770000000';
            END IF;
         END IF;    
      END LOOP;
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      IF (context_ = 'COMPANY_CUSTOMER') THEN
         Error_SYS.Record_General(lu_name_, 'NO_JURISDICTION_CODE: No Jurisdiction Code was found based on the Address 1, Address 2, City, State, Zip Code and County information.');
      END IF;
END Fetch_Jurisdiction_Code;


PROCEDURE Fetch_And_Calculate_Tax (
   ext_tax_param_out_rec_ OUT External_Tax_System_Util_API.ext_tax_param_out_rec,
   ext_tax_param_in_rec_  IN  External_Tax_System_Util_API.ext_tax_param_in_rec )
IS
   xml_trans_                    CLOB;
   cust_del_addr_jdiction_code_  VARCHAR2(20);
   comp_del_addr_jdiction_code_  VARCHAR2(20);
   comp_doc_addr_jdiction_code_  VARCHAR2(20);   
   object_group_                 VARCHAR2(25);   
   parish_tax_amount_            NUMBER:= 0;
   parish_tax_percentage_        NUMBER:= 0;
   invoice_date_                 DATE;
   postal_addresses_             External_Tax_System_Util_API.postal_address_arr;
   postal_address_               External_Tax_System_Util_API.postal_address_rec;   
   document_                     Plsqlap_Document_API.Document;
   requests_element_id_          Plsqlap_Document_API.Element_Id;
   request_element_id_           Plsqlap_Document_API.Element_Id;
   sellers_element_id_           Plsqlap_Document_API.Element_Id;
   seller_element_id_            Plsqlap_Document_API.Element_Id;
   customers_element_id_         Plsqlap_Document_API.Element_Id;
   customer_element_id_          Plsqlap_Document_API.Element_Id;
   lines_element_id_             Plsqlap_Document_API.Element_Id;
   line_element_id_              Plsqlap_Document_API.Element_Id;
   xml_clob_                     CLOB;  
BEGIN        
   invoice_date_    := NVL(ext_tax_param_in_rec_.invoice_date, SYSDATE);
   object_group_    := NVL(ext_tax_param_in_rec_.object_group, ext_tax_param_in_rec_.object_id);
   postal_addresses_.DELETE;  
   -- customer delivery address
   postal_address_          := NULL;
   postal_address_.address1 := ext_tax_param_in_rec_.cust_del_address1;
   postal_address_.address2 := ext_tax_param_in_rec_.cust_del_address2;
   postal_address_.zip_code := ext_tax_param_in_rec_.cust_del_zip_code;      
   postal_address_.city     := ext_tax_param_in_rec_.cust_del_city;
   postal_address_.state    := ext_tax_param_in_rec_.cust_del_state;
   postal_address_.county   := ext_tax_param_in_rec_.cust_del_county;
   postal_address_.country  := ext_tax_param_in_rec_.cust_del_country;
   postal_addresses_(0)     := postal_address_;
   -- company deliver address
   postal_address_ := NULL;
   postal_address_.address1 := ext_tax_param_in_rec_.comp_del_address1;
   postal_address_.address2 := ext_tax_param_in_rec_.comp_del_address2;
   postal_address_.zip_code := ext_tax_param_in_rec_.comp_del_zip_code;   
   postal_address_.city     := ext_tax_param_in_rec_.comp_del_city;
   postal_address_.state    := ext_tax_param_in_rec_.comp_del_state;
   postal_address_.county   := ext_tax_param_in_rec_.comp_del_county;
   postal_address_.country  := ext_tax_param_in_rec_.comp_del_country;
   postal_addresses_(1)     := postal_address_;
   -- company document address
   postal_address_ := NULL;
   postal_address_.address1 := ext_tax_param_in_rec_.comp_doc_address1;
   postal_address_.address2 := ext_tax_param_in_rec_.comp_doc_address2;
   postal_address_.zip_code := ext_tax_param_in_rec_.comp_doc_zip_code;   
   postal_address_.city     := ext_tax_param_in_rec_.comp_doc_city;
   postal_address_.state    := ext_tax_param_in_rec_.comp_doc_state;
   postal_address_.county   := ext_tax_param_in_rec_.comp_doc_county;
   postal_address_.country  := ext_tax_param_in_rec_.comp_doc_country;
   postal_addresses_(2)     := postal_address_;
   External_Tax_System_Util_API.Fetch_Jurisdiction_Code(postal_addresses_, NULL, 'ORDER_CALCULATION', 'VERTEX_SALES_TAX_O_SERIES');
   cust_del_addr_jdiction_code_  := postal_addresses_(0).jurisdiction_code;
   comp_del_addr_jdiction_code_  := postal_addresses_(1).jurisdiction_code;
   comp_doc_addr_jdiction_code_ := postal_addresses_(2).jurisdiction_code;
   IF (cust_del_addr_jdiction_code_ IS NULL) THEN
      Error_SYS.Appl_General(lu_name_, 'GEONOTFOUND10: A valid Jurisdiction Code could not be found. Please check the Customer Delivery Address info (City, State, Zip Code, County): :P1 for Country :P2', ext_tax_param_in_rec_.cust_del_city||', '||ext_tax_param_in_rec_.cust_del_state||', '||ext_tax_param_in_rec_.cust_del_zip_code||', '||ext_tax_param_in_rec_.cust_del_county, ext_tax_param_in_rec_.cust_del_country);
   END IF;
   IF (comp_del_addr_jdiction_code_ IS NULL) THEN
      Error_SYS.Appl_General(lu_name_, 'GEONOTFOUND11: A valid Jurisdiction Code could not be found. Please check the Company Delivery Address info (City, State, Zip Code, County): :P1 for Country :P2', ext_tax_param_in_rec_.comp_del_city||', '||ext_tax_param_in_rec_.comp_del_state||', '||ext_tax_param_in_rec_.comp_del_zip_code||', '||ext_tax_param_in_rec_.comp_del_county, ext_tax_param_in_rec_.comp_del_country);
   END IF;
   IF (comp_doc_addr_jdiction_code_ IS NULL)  THEN
      Error_SYS.Appl_General(lu_name_, 'GEONOTFOUND12: A valid Jurisdiction Code could not be found. Please check the Company Document Address info (City, State, Zip Code, County): :P1 for Country :P2', ext_tax_param_in_rec_.comp_doc_city||', '||ext_tax_param_in_rec_.comp_doc_state||', '||ext_tax_param_in_rec_.comp_doc_zip_code||', '||ext_tax_param_in_rec_.comp_doc_county, ext_tax_param_in_rec_.comp_doc_country);
   END IF;
   IF (ext_tax_param_in_rec_.write_to_ext_tax_register = 'TRUE') THEN
      document_ := Plsqlap_Document_API.New_Document('INVOICE_TAX_INFO_REQUEST');
   ELSE
      document_ := Plsqlap_Document_API.New_Document('ORDER_TAX_INFO_REQUEST');
   END IF;
   --Add login and version info
   Set_Login_And_Version_Info___(document_, document_.root_id);   
   --Add lookupdate
   IF (ext_tax_param_in_rec_.write_to_ext_tax_register = 'TRUE') THEN
      requests_element_id_ := Plsqlap_Document_API.Add_Array(document_, 'INVOICE_REQUESTS', document_.root_id);
      request_element_id_ := Plsqlap_Document_API.Add_Document(document_, 'INVOICE_REQUEST', requests_element_id_);
      Plsqlap_Document_API.Add_Attribute(document_, 'DOCUMENT_DATE', TO_CHAR(invoice_date_, 'YYYY-MM-DD'), request_element_id_);
      IF (ext_tax_param_in_rec_.invoice_no IS NOT NULL) THEN
         Plsqlap_Document_API.Add_Attribute(document_, 'DOCUMENT_NUMBER', ext_tax_param_in_rec_.invoice_no, request_element_id_);
      END IF;
   ELSE
      requests_element_id_ := Plsqlap_Document_API.Add_Array(document_, 'ORDER_REQUESTS', document_.root_id);
      request_element_id_ := Plsqlap_Document_API.Add_Document(document_, 'ORDER_REQUEST', requests_element_id_);               
      Plsqlap_Document_API.Add_Attribute(document_, 'DOCUMENT_DATE', TO_CHAR(SYSDATE, 'YYYY-MM-DD'), request_element_id_);
   END IF;
   Plsqlap_Document_API.Add_Attribute(document_, 'TRANSACTION_TYPE', 'SALE', request_element_id_);
   --Add Seller info
   sellers_element_id_ := Plsqlap_Document_API.Add_Array(document_, 'SELLERS', request_element_id_);
   seller_element_id_ := Plsqlap_Document_API.Add_Document(document_, 'SELLER', sellers_element_id_);                  
   Plsqlap_Document_API.Add_Attribute(document_, 'COMPANY', ext_tax_param_in_rec_.company, seller_element_id_);
   Plsqlap_Document_API.Add_Attribute(document_, 'PHY_ORI_TAX_AREA_ID', comp_del_addr_jdiction_code_, seller_element_id_);
   Plsqlap_Document_API.Add_Attribute(document_, 'ADM_ORI_TAX_AREA_ID', comp_doc_addr_jdiction_code_, seller_element_id_);
   --Add Customer info
   customers_element_id_ := Plsqlap_Document_API.Add_Array(document_, 'CUSTOMERS', request_element_id_);
   customer_element_id_ := Plsqlap_Document_API.Add_Document(document_, 'CUSTOMER', customers_element_id_);                  
   IF (ext_tax_param_in_rec_.identity IS NOT NULL) THEN
      Plsqlap_Document_API.Add_Attribute(document_, 'CUSTOMER_CODE', ext_tax_param_in_rec_.identity, customer_element_id_);   
   END IF;
   IF (ext_tax_param_in_rec_.customer_group IS NOT NULL) THEN
      Plsqlap_Document_API.Add_Attribute(document_, 'CLASS_CODE', Rem_Special_Char___(ext_tax_param_in_rec_.customer_group), customer_element_id_);   
   END IF;
   Plsqlap_Document_API.Add_Attribute(document_, 'DES_TAX_AREA_ID', cust_del_addr_jdiction_code_, customer_element_id_);   
   --Add Line Item info
   lines_element_id_ := Plsqlap_Document_API.Add_Array(document_, 'LINE_ITEMS', request_element_id_);
   line_element_id_ := Plsqlap_Document_API.Add_Document(document_, 'LINE_ITEM', lines_element_id_);                     
   Plsqlap_Document_API.Add_Attribute(document_, 'LINE_ITEM_NUMBER', '1', line_element_id_);   
   Plsqlap_Document_API.Add_Attribute(document_, 'LINE_ITEM_ID', '1', line_element_id_);   
   Plsqlap_Document_API.Add_Attribute(document_, 'IS_MULTIOMPONENT', 'false', line_element_id_);   
   IF ((ext_tax_param_in_rec_.identity_taxable = 'FALSE') OR (ext_tax_param_in_rec_.object_taxable = 'FALSE')) THEN
      Plsqlap_Document_API.Add_Attribute(document_, 'OVERRIDE_TYPE', 'NONTAXABLE', line_element_id_);   
   END IF;
   IF (invoice_date_ IS NOT NULL) THEN
      Plsqlap_Document_API.Add_Attribute(document_, 'TAX_DATE', TO_CHAR(invoice_date_, 'YYYY-MM-DD'), line_element_id_);   
   END IF;
   IF (ext_tax_param_in_rec_.object_id IS NOT NULL) THEN
      Plsqlap_Document_API.Add_Attribute(document_, 'PRODUCT', ext_tax_param_in_rec_.object_id, line_element_id_);   
   END IF;
   IF (object_group_ IS NOT NULL) THEN  
      Plsqlap_Document_API.Add_Attribute(document_, 'PRODUCT_CLASS', object_group_, line_element_id_);   
   END IF;
   Plsqlap_Document_API.Add_Attribute(document_, 'EXTENDED_PRICE', NVL(ext_tax_param_in_rec_.taxable_amount,0), line_element_id_);   
   Plsqlap_Document_API.Add_Attribute(document_, 'QUANTITY', ext_tax_param_in_rec_.quantity, line_element_id_);      
   IF (ext_tax_param_in_rec_.write_to_ext_tax_register = 'TRUE') THEN
      -- Add XML attribute data so that the XML will be backward compatible with Apps 10 
      -- and existing transformers built upon that XML will work. 
      -- This should be changed in the long run so that it is model-driven and sent to IFS Connect as JSON
      Plsqlap_Document_API.Add_Xml_Attribute(document_, 'xmlns:xsi', 'http://www.w3.org/2001/XMLSchema-instance');
      -- The following line was the namespace information that was added by the old Biz API. If needed the following line can be uncommented
      --Plsqlap_Document_API.Add_Xml_Attribute(document_, 'xmlns', 'urn:ifsworld-com:schemas:vertex_services_handler_send_invoice_info_receive_tax_info_response');      
      Plsqlap_Document_API.To_Xml(xml_clob_, document_, TRUE, TRUE, NULL, FALSE, TRUE, NULL, FALSE, TRUE);                                                 
      Plsqlap_Server_API.Invoke_Outbound_Message(xml_clob_,
                                                 sender_       => 'IFS',
                                                 receiver_     => 'VERTEX',
                                                 message_type_ => 'APPLICATION_MESSAGE',                                            
                                                 message_function_ => 'SEND_INVOICE_INFO_RECEIVE_TAX_INFO');                                                 
   ELSE
      -- Add XML attribute data so that the XML will be backward compatible with Apps 10 
      -- and existing transformers built upon that XML will work. 
      -- This should be changed in the long run so that it is model-driven and sent to IFS Connect as JSON
      Plsqlap_Document_API.Add_Xml_Attribute(document_, 'xmlns:xsi', 'http://www.w3.org/2001/XMLSchema-instance');
      -- The following line was the namespace information that was added by the old Biz API. If needed the following line can be uncommented
      --Plsqlap_Document_API.Add_Xml_Attribute(document_, 'xmlns', 'urn:ifsworld-com:schemas:vertex_services_handler_send_order_info_receive_tax_info_response');      
      Plsqlap_Document_API.To_Xml(xml_clob_, document_, TRUE, TRUE, NULL, FALSE, TRUE, NULL, FALSE, TRUE);                                                 
      Plsqlap_Server_API.Invoke_Outbound_Message(xml_clob_,
                                                 sender_       => 'IFS',
                                                 receiver_     => 'VERTEX',
                                                 message_type_ => 'APPLICATION_MESSAGE',                                            
                                                 message_function_ => 'SEND_ORDER_INFO_RECEIVE_TAX_INFO');      
   END IF;
   xml_trans_ := xml_clob_;
   -- Get different taxes: state, city, county and district
   FOR i IN 1..20 LOOP
     IF (Get_Next_Val_By_Tag_Name___(xml_trans_,'JURISDICTION_LEVEL', i) IN ('STATE', 'TERRITORY', 'COUNTRY')) THEN
         ext_tax_param_out_rec_.state_tax_amount     := NVL(ext_tax_param_out_rec_.state_tax_amount, 0) +  NVL(Get_Next_Val_By_Tag_Name___(xml_trans_,'CALCULATED_TAX', i), 0); 
         ext_tax_param_out_rec_.state_tax_percentage := NVL(ext_tax_param_out_rec_.state_tax_percentage, 0) + NVL(Get_Next_Val_By_Tag_Name___(xml_trans_,'EFFECTIVE_RATE', i), 0);
     ELSIF Get_Next_Val_By_Tag_Name___(xml_trans_,'JURISDICTION_LEVEL', i) = 'CITY' THEN
         ext_tax_param_out_rec_.city_tax_amount     := NVL(ext_tax_param_out_rec_.city_tax_amount, 0) + NVL(Get_Next_Val_By_Tag_Name___(xml_trans_,'CALCULATED_TAX', i), 0); 
         ext_tax_param_out_rec_.city_tax_percentage := NVL(ext_tax_param_out_rec_.city_tax_percentage, 0) + NVL(Get_Next_Val_By_Tag_Name___(xml_trans_,'EFFECTIVE_RATE', i), 0);
     ELSIF Get_Next_Val_By_Tag_Name___(xml_trans_,'JURISDICTION_LEVEL', i) IN ('COUNTY', 'PROVINCE' ) THEN 
         ext_tax_param_out_rec_.county_tax_amount     := NVL(ext_tax_param_out_rec_.county_tax_amount, 0) + NVL(Get_Next_Val_By_Tag_Name___(xml_trans_,'CALCULATED_TAX', i), 0); 
         ext_tax_param_out_rec_.county_tax_percentage := NVL(ext_tax_param_out_rec_.county_tax_percentage, 0) + NVL(Get_Next_Val_By_Tag_Name___(xml_trans_,'EFFECTIVE_RATE', i), 0);
     ELSIF (Get_Next_Val_By_Tag_Name___(xml_trans_,'JURISDICTION_LEVEL', i) IN ( 'DISTRICT', 'SPECIAL_PURPOSE_DISTRICT', 'LOCAL_IMPROVEMENT_DISTRICT', 'TRANSIT_DISTRICT')) THEN
         ext_tax_param_out_rec_.district_tax_amount     := NVL(ext_tax_param_out_rec_.district_tax_amount, 0) + NVL(Get_Next_Val_By_Tag_Name___(xml_trans_,'CALCULATED_TAX', i), 0); 
         ext_tax_param_out_rec_.district_tax_percentage := NVL(ext_tax_param_out_rec_.district_tax_percentage, 0) + NVL(Get_Next_Val_By_Tag_Name___(xml_trans_,'EFFECTIVE_RATE', i), 0);
     ELSIF Get_Next_Val_By_Tag_Name___(xml_trans_,'JURISDICTION_LEVEL', i) = 'PARISH' THEN
         parish_tax_amount_  := NVL(parish_tax_amount_, 0) + NVL(Get_Next_Val_By_Tag_Name___(xml_trans_,'CALCULATED_TAX', i), 0); 
         parish_tax_percentage_ := NVL(parish_tax_percentage_, 0) + NVL(Get_Next_Val_By_Tag_Name___(xml_trans_,'EFFECTIVE_RATE', i), 0);
     END IF;
   END LOOP;
   IF (parish_tax_amount_ != 0) THEN
      ext_tax_param_out_rec_.county_tax_amount := NVL(ext_tax_param_out_rec_.county_tax_amount, 0) +  parish_tax_amount_;
   END IF;
   IF (parish_tax_percentage_> 0) THEN
      ext_tax_param_out_rec_.county_tax_percentage := NVL(ext_tax_param_out_rec_.county_tax_percentage, 0) +  parish_tax_percentage_;
   END IF; 
   ext_tax_param_out_rec_.state_tax_amount        := NVL(ext_tax_param_out_rec_.state_tax_amount, 0);
   ext_tax_param_out_rec_.city_tax_amount         := NVL(ext_tax_param_out_rec_.city_tax_amount, 0);
   ext_tax_param_out_rec_.county_tax_amount       := NVL(ext_tax_param_out_rec_.county_tax_amount, 0);
   ext_tax_param_out_rec_.district_tax_amount     := NVL(ext_tax_param_out_rec_.district_tax_amount, 0);
   ext_tax_param_out_rec_.state_tax_percentage    := NVL(ext_tax_param_out_rec_.state_tax_percentage, 0);
   ext_tax_param_out_rec_.city_tax_percentage     := NVL(ext_tax_param_out_rec_.city_tax_percentage, 0);
   ext_tax_param_out_rec_.county_tax_percentage   := NVL(ext_tax_param_out_rec_.county_tax_percentage, 0);
   ext_tax_param_out_rec_.district_tax_percentage := NVL(ext_tax_param_out_rec_.district_tax_percentage, 0);
END Fetch_And_Calculate_Tax;

-------------------- LU  NEW METHODS -------------------------------------
