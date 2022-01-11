-----------------------------------------------------------------------------
--
--  Logical unit: AvalaraTaxUtil
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  191024  Hairlk  SCXTEND-1151, Avalara integration, Modified Write_To_Ext_Avalara_Tax_Regis, refactored code and moved code realted to customer order invoice to CustomerOrderInvHead.
--  200702  NiDalk  SCXTEND-4444, Added new Fetch_And_Calculate_Tax with array parameters to support new bundle call.
--  200804  Erlise  Bug 154357(SCZ-10335), Removed usage of Rem_Special_Char() in Create_Line_Item___. The transformers have been improved to handle special characters correctly.
--  210129  NiDalk  SC2020R1-12305, Modified Fetch_And_Calculate_Tax methods to show error messages from AVALARA when fetching taxes.
--  210210  THPELK  FISPRING20-9000 - Changed code in Create_Invoice_Avalara_Tax_Info_Req_Data___ to Corrected deployment issue.
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------

-------------------- PRIVATE DECLARATIONS -----------------------------------

-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------

FUNCTION Get_Val_By_Tag_Name___ (
   xml_       IN CLOB,
   tag_name_  IN VARCHAR2 ) RETURN VARCHAR2
IS
   begin_index_      NUMBER;
   end_index_        NUMBER;
   tag_length_       NUMBER;
   start_tag_name_   VARCHAR2(100);
   end_tag_name_     VARCHAR2(100);
   value_            VARCHAR2(4000);
BEGIN
   start_tag_name_ := '<'||tag_name_||'>';
   end_tag_name_   := '</'||tag_name_||'>';
   tag_length_     := LENGTH(tag_name_);
   begin_index_    := INSTR(xml_, start_tag_name_);
   end_index_      := INSTR(xml_, end_tag_name_);
   value_ := SUBSTR(xml_, begin_index_ + tag_length_ + 2 , end_index_ - (begin_index_ + tag_length_ + 2));
   RETURN value_;
END Get_Val_By_Tag_Name___;


PROCEDURE Set_Login_And_Version_Info___ (
   document_      IN OUT Plsqlap_Document_API.Document,
   element_id_    IN     Plsqlap_Document_API.Element_Id)
IS
   tmp_element_id_      Plsqlap_Document_API.Element_Id;
   ext_param_rec_       Ext_Tax_System_Parameters_API.Public_Rec;   
BEGIN
   ext_param_rec_ := Ext_Tax_System_Parameters_API.Get(1);    
   tmp_element_id_ := Plsqlap_Document_API.Add_Aggregate(document_, 'LOGIN_INFO', 'LOGIN', element_id_);
   Plsqlap_Document_API.Add_Attribute(document_, 'USER_NAME', ext_param_rec_.user_name_avalara, tmp_element_id_);   
   Plsqlap_Document_API.Add_Attribute(document_, 'PASSWORD', ext_param_rec_.password_avalara, tmp_element_id_);
END Set_Login_And_Version_Info___;


FUNCTION Get_Next_Val_By_Tag_Name___ (
   xml_       IN CLOB,
   tag_name_  IN VARCHAR2,
   index_     IN NUMBER ) RETURN VARCHAR2
IS
   begin_index_      NUMBER;
   end_index_        NUMBER;
   tag_length_       NUMBER;
   start_tag_name_   VARCHAR2(100);
   end_tag_name_     VARCHAR2(100);
   value_            VARCHAR2(4000);
   xml2_             VARCHAR2(32000);
   first_pos_        NUMBER;
BEGIN
   first_pos_      := INSTR(xml_, '<TAX_DETAILS>', 1, 1);
   xml2_           := SUBSTR(xml_, first_pos_, LENGTH(xml_));
   start_tag_name_ := '<'||tag_name_||'>';
   end_tag_name_   := '</'||tag_name_||'>';
   tag_length_     := LENGTH(tag_name_);
   begin_index_    := INSTR(xml2_, start_tag_name_, 1, index_);
   end_index_      := INSTR(xml2_, end_tag_name_, 1, index_);
   value_ := SUBSTR(xml2_, begin_index_ + tag_length_ + 2 , end_index_ - (begin_index_ + tag_length_ + 2));
   RETURN value_;
END Get_Next_Val_By_Tag_Name___;


FUNCTION Get_Next_Val_By_Tag_Name___ (
   xml_        IN CLOB,
   tag_name_   IN VARCHAR2,
   index_      IN NUMBER,
   index2_     IN NUMBER ) RETURN VARCHAR2
IS
   begin_index_      NUMBER;
   end_index_        NUMBER;
   tag_length_       NUMBER;
   start_tag_name_   VARCHAR2(100);
   end_tag_name_     VARCHAR2(100);
   value_            VARCHAR2(4000);
   xml2_             VARCHAR2(32000);
   first_pos_        NUMBER;
   last_pos_         NUMBER;      
   tag_detail_len_   NUMBER;
BEGIN
   first_pos_      := INSTR(xml_, '<TAX_DETAILS>', 1, index2_);           
   tag_detail_len_ := LENGTH('</TAX_DETAILS>');
   last_pos_       := INSTR(xml_, '</TAX_DETAILS>', 1, index2_);         
   xml2_           := SUBSTR(xml_, first_pos_, ((last_pos_ + tag_detail_len_)-first_pos_));
   start_tag_name_ := '<'||tag_name_||'>';
   end_tag_name_   := '</'||tag_name_||'>';
   tag_length_     := LENGTH(tag_name_);
   begin_index_    := INSTR(xml2_, start_tag_name_, 1, index_);
   end_index_      := INSTR(xml2_, end_tag_name_, 1, index_);
   value_ := SUBSTR(xml2_, begin_index_ + tag_length_ + 2 , end_index_ - (begin_index_ + tag_length_ + 2));
   RETURN value_; 
END Get_Next_Val_By_Tag_Name___;


PROCEDURE Create_Order_Request___ (
   document_               IN OUT Plsqlap_Document_API.Document,
   ord_req_element_id_     OUT    Plsqlap_Document_API.Element_Id,
   invoice_date_           IN     DATE,
   invoice_no_             IN     VARCHAR2,
   company_                IN     VARCHAR2,
   exemption_no_           IN     VARCHAR2,
   doc_type_               IN     VARCHAR2,
   customer_no_            IN     VARCHAR2 )
IS
   
BEGIN
   ord_req_element_id_ := Plsqlap_Document_API.Add_Aggregate(document_, 'ORDER_REQUESTS', 'ORDER_REQUEST', document_.root_id);
   --Add lookupdate
   IF (invoice_no_ IS NOT NULL) THEN
      Plsqlap_Document_API.Add_Attribute(document_, 'DOC_DATE', TO_CHAR(invoice_date_, 'YYYY-MM-DD'), ord_req_element_id_);
   ELSE
      Plsqlap_Document_API.Add_Attribute(document_, 'DOC_DATE', TO_CHAR(SYSDATE, 'YYYY-MM-DD'), ord_req_element_id_);
   END IF;
   Plsqlap_Document_API.Add_Attribute(document_, 'COMPANY', company_, ord_req_element_id_);
   Plsqlap_Document_API.Add_Attribute(document_, 'EXEMPTION_NO', exemption_no_, ord_req_element_id_);
   Plsqlap_Document_API.Add_Attribute(document_, 'DOC_TYPE', 'SalesOrder', ord_req_element_id_);
   Plsqlap_Document_API.Add_Attribute(document_, 'DOC_CODE', invoice_no_, ord_req_element_id_);
   Plsqlap_Document_API.Add_Attribute(document_, 'CUSTOMER_CODE', customer_no_, ord_req_element_id_);
   Plsqlap_Document_API.Add_Attribute(document_, 'DETAIL_LEVEL', 'Tax', ord_req_element_id_);
   Plsqlap_Document_API.Add_Attribute(document_, 'COMMIT', 'false', ord_req_element_id_);
END Create_Order_Request___;


PROCEDURE Create_Tax_Override_Item___ (
   document_               IN OUT Plsqlap_Document_API.Document,
   parent_id_              IN     Plsqlap_Document_API.Element_Id,
   invoice_date_           IN     DATE,
   series_ref_             IN     VARCHAR2,
   number_ref_             IN     VARCHAR2 )
IS
   element_id_    Plsqlap_Document_API.Element_Id;
BEGIN
   element_id_ := Plsqlap_Document_API.Add_Document(document_, 'TAX_OVERRIDE', parent_id_);         
   Plsqlap_Document_API.Add_Attribute(document_, 'TAX_OVERRIDE_TYPE', 'TaxDate', element_id_);
   Plsqlap_Document_API.Add_Attribute(document_, 'TAX_AMOUNT', '0', element_id_);
   Plsqlap_Document_API.Add_Attribute(document_, 'TAX_DATE', TO_CHAR(invoice_date_, 'YYYY-MM-DD'), element_id_);
   Plsqlap_Document_API.Add_Attribute(document_, 'REASON', 'Credit for '||series_ref_||number_ref_, element_id_);      
END Create_Tax_Override_Item___;


PROCEDURE Create_Base_Address_Item___ (
   document_         IN OUT Plsqlap_Document_API.Document,
   parent_id_        IN     Plsqlap_Document_API.Element_Id,
   address_code_     IN     VARCHAR2,
   address1_         IN     VARCHAR2,
   address2_         IN     VARCHAR2,
   city_             IN     VARCHAR2,
   region_           IN     VARCHAR2,
   postal_code_      IN     VARCHAR2,
   country_          IN     VARCHAR2 )
IS
   element_id_    Plsqlap_Document_API.Element_Id;
BEGIN
   element_id_ := Plsqlap_Document_API.Add_Document(document_, 'BASE_ADDRESS', parent_id_);   
   Plsqlap_Document_API.Add_Attribute(document_, 'ADDRESS_CODE', address_code_, element_id_);
   Plsqlap_Document_API.Add_Attribute(document_, 'LINE1', NVL(address1_, '*'), element_id_);
   Plsqlap_Document_API.Add_Attribute(document_, 'LINE2', address2_, element_id_);
   Plsqlap_Document_API.Add_Attribute(document_, 'CITY', city_, element_id_);
   Plsqlap_Document_API.Add_Attribute(document_, 'REGION', region_, element_id_);
   Plsqlap_Document_API.Add_Attribute(document_, 'POSTAL_CODE', postal_code_, element_id_);
   Plsqlap_Document_API.Add_Attribute(document_, 'COUNTRY', country_, element_id_);
   Plsqlap_Document_API.Add_Attribute(document_, 'TAX_REGION_ID', '0', element_id_);
   Plsqlap_Document_API.Add_Attribute(document_, 'TAX_INCLUDED', 'true', element_id_);
END Create_Base_Address_Item___;


PROCEDURE Create_Line_Item___ (
   document_            IN OUT Plsqlap_Document_API.Document,
   parent_id_           IN     Plsqlap_Document_API.Element_Id,
   item_no_             IN     VARCHAR2,
   origin_code_         IN     VARCHAR2,
   destination_code_    IN     VARCHAR2,
   item_code_           IN     VARCHAR2,
   qty_                 IN     NUMBER,
   amount_              IN     NUMBER,
   customer_usage_type_ IN     VARCHAR2,
   tax_code_            IN     VARCHAR2,
   description_         IN     VARCHAR2 )
IS
   element_id_    Plsqlap_Document_API.Element_Id;
BEGIN
   element_id_ := Plsqlap_Document_API.Add_Document(document_, 'LINE_ITEM', parent_id_);   
   Plsqlap_Document_API.Add_Attribute(document_, 'NO', item_no_, element_id_);
   Plsqlap_Document_API.Add_Attribute(document_, 'ORIGIN_CODE', origin_code_, element_id_);
   Plsqlap_Document_API.Add_Attribute(document_, 'DESTINATION_CODE', destination_code_, element_id_);
   Plsqlap_Document_API.Add_Attribute(document_, 'ITEM_CODE', item_code_, element_id_);
   Plsqlap_Document_API.Add_Attribute(document_, 'QTY', qty_, element_id_);
   Plsqlap_Document_API.Add_Attribute(document_, 'AMOUNT', NVL(amount_,0), element_id_);
   Plsqlap_Document_API.Add_Attribute(document_, 'CUSTOMER_USAGE_TYPE',customer_usage_type_, element_id_);
   Plsqlap_Document_API.Add_Attribute(document_, 'TAX_CODE', tax_code_, element_id_);
   Plsqlap_Document_API.Add_Attribute(document_, 'DESCRIPTION', description_, element_id_);
END Create_Line_Item___;


PROCEDURE Assign_Tax_Amount_Percentage___ (
   ext_tax_param_out_rec_ IN OUT External_Tax_System_Util_API.ext_tax_param_out_rec,
   xml_trans_             IN     CLOB,
   i_                     IN     NUMBER )
IS
   parish_tax_amount_            NUMBER:= NULL;
   parish_tax_percentage_        NUMBER:= NULL;
BEGIN
   -- Get different taxes: state city, county and district
   FOR j_ IN 1 .. 10 LOOP
      IF (Get_Next_Val_By_Tag_Name___(xml_trans_, 'JURIS_TYPE', j_, i_) = 'State') THEN
         IF (Get_Next_Val_By_Tag_Name___(xml_trans_,'TAXABLE', j_, i_) != 0) THEN
            ext_tax_param_out_rec_.state_tax_amount     := NVL(ext_tax_param_out_rec_.state_tax_amount, 0) + Get_Next_Val_By_Tag_Name___(xml_trans_, 'TAX', j_, i_);
            ext_tax_param_out_rec_.state_tax_percentage := NVL(ext_tax_param_out_rec_.state_tax_percentage, 0) + Get_Next_Val_By_Tag_Name___(xml_trans_, 'RATE', j_, i_);
         END IF;
      ELSIF (Get_Next_Val_By_Tag_Name___(xml_trans_, 'JURIS_TYPE', j_, i_) = 'City') THEN
         IF (Get_Next_Val_By_Tag_Name___(xml_trans_,'TAXABLE', j_, i_) != 0) THEN
            ext_tax_param_out_rec_.city_tax_amount     := NVL(ext_tax_param_out_rec_.city_tax_amount, 0) + Get_Next_Val_By_Tag_Name___(xml_trans_, 'TAX', j_, i_);
            ext_tax_param_out_rec_.city_tax_percentage := NVL(ext_tax_param_out_rec_.city_tax_percentage, 0) + Get_Next_Val_By_Tag_Name___(xml_trans_, 'RATE', j_, i_);
         END IF;
      ELSIF (Get_Next_Val_By_Tag_Name___(xml_trans_, 'JURIS_TYPE', j_, i_) = 'County') THEN
         IF (Get_Next_Val_By_Tag_Name___(xml_trans_,'TAXABLE', j_, i_) != 0) THEN
            ext_tax_param_out_rec_.county_tax_amount     := NVL(ext_tax_param_out_rec_.county_tax_amount, 0) + Get_Next_Val_By_Tag_Name___(xml_trans_, 'TAX', j_, i_);
            ext_tax_param_out_rec_.county_tax_percentage := NVL( ext_tax_param_out_rec_.county_tax_percentage, 0) + Get_Next_Val_By_Tag_Name___(xml_trans_, 'RATE', j_, i_);
         END IF;
      ELSIF (Get_Next_Val_By_Tag_Name___(xml_trans_, 'JURIS_TYPE', j_, i_) = 'Special') THEN
         IF (Get_Next_Val_By_Tag_Name___(xml_trans_,'TAXABLE', j_, i_) != 0) THEN
            ext_tax_param_out_rec_.district_tax_amount     := NVL(ext_tax_param_out_rec_.district_tax_amount, 0) + NVL(Get_Next_Val_By_Tag_Name___(xml_trans_, 'TAX', j_, i_), 0);
            ext_tax_param_out_rec_.district_tax_percentage := NVL(ext_tax_param_out_rec_.district_tax_percentage, 0) + NVL(Get_Next_Val_By_Tag_Name___(xml_trans_, 'RATE', j_, i_), 0);
         END IF;  
      ELSIF (Get_Next_Val_By_Tag_Name___(xml_trans_, 'JURIS_TYPE', j_, i_) = 'Parish') THEN
         IF (Get_Next_Val_By_Tag_Name___(xml_trans_,'TAXABLE', j_, i_) != 0) THEN
            parish_tax_amount_     := NVL(parish_tax_amount_, 0) + Get_Next_Val_By_Tag_Name___(xml_trans_, 'TAX', j_, i_);
            parish_tax_percentage_ := NVL(parish_tax_percentage_, 0) + Get_Next_Val_By_Tag_Name___(xml_trans_, 'RATE', j_, i_);
         END IF;
      END IF;
   END LOOP;
   IF (parish_tax_amount_ IS NOT NULL) THEN
      ext_tax_param_out_rec_.county_tax_amount := NVL(ext_tax_param_out_rec_.county_tax_amount, 0) +  parish_tax_amount_;
   END IF;
   IF (parish_tax_percentage_ IS NOT NULL) THEN
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
END Assign_Tax_Amount_Percentage___;


FUNCTION Create_Invoice_Avalara_Tax_Info_Req_Data___ (   
   invoice_tax_info_request_rec_ IN Avalara_Tax_Util_API.Invoice_Tax_Info_Request_Rec) RETURN Avalara_Tax_Util_API.Invoice_Avalara_Tax_Info_Request_Struct_Rec   
IS
   rec_                             Avalara_Tax_Util_API.Invoice_Avalara_Tax_Info_Request_Struct_Rec;
   tax_rec_                         Invoice_Avalara_Tax_Info_Request_Struct_Tax_Override_Qry_Rec;                                    
   tax_arr_                         Invoice_Avalara_Tax_Info_Request_Struct_Tax_Override_Qry_Arr := Invoice_Avalara_Tax_Info_Request_Struct_Tax_Override_Qry_Arr();
   tax_request_rec_                 Invoice_Avalara_Tax_Info_Request_Struct_Get_Tax_Request_Qry_Rec;   
   tax_request_arr_                 Invoice_Avalara_Tax_Info_Request_Struct_Get_Tax_Request_Qry_Arr := Invoice_Avalara_Tax_Info_Request_Struct_Get_Tax_Request_Qry_Arr();   
   line_item_arr_                   Invoice_Avalara_Tax_Info_Request_Struct_Line_Item_Qry_Arr := Invoice_Avalara_Tax_Info_Request_Struct_Line_Item_Qry_Arr();
   base_address_arr_                Invoice_Avalara_Tax_Info_Request_Struct_Base_Address_Qry_Arr := Invoice_Avalara_Tax_Info_Request_Struct_Base_Address_Qry_Arr();
   from_base_address_rec_           Invoice_Avalara_Tax_Info_Request_Struct_Base_Address_Qry_Rec;
   to_base_address_rec_             Invoice_Avalara_Tax_Info_Request_Struct_Base_Address_Qry_Rec;   
   count_                           INTEGER;   
   invoice_date_act_                VARCHAR2(30);
   invoice_date_temp_               DATE;
   company_                         VARCHAR2(20);
   def_col_cor_inv_type_            VARCHAR2(20);
   def_co_cor_inv_type_             VARCHAR2(20);   
   invoice_date_                    VARCHAR2(30);
   number_ref_                      VARCHAR2(30);
   series_ref_                      VARCHAR2(30);
   invoice_id_                      NUMBER;
   inv_date_                        DATE;   
   tax_liablity_                    VARCHAR2(20);
   cust_usage_type_                 VARCHAR2(50);
   tax_code_                        VARCHAR2(50);
   catalog_desc_                    VARCHAR2(200);
   taxable_prod_                    VARCHAR2(1);
   taxable_customer_                VARCHAR2(1);   
   from_address_                    VARCHAR2(200);
   to_address_                      VARCHAR2(200);
   attr_                            VARCHAR2(32000);
   attr2_                           VARCHAR2(32000);   

   $IF Component_Order_SYS.INSTALLED $THEN      
      head_rec_                     Invoice_Head_Structure_Rec;
      invoice_line_item_rec_        Invoice_Head_Structure_Invoice_Line_Item_Rec;
      line_item_rec_                Invoice_Avalara_Tax_Info_Request_Struct_Line_Item_Qry_Rec;   
      company_def_invoice_type_rec_    Company_Def_Invoice_Type_API.Public_Rec;   
   $END
BEGIN
   $IF Component_Order_SYS.INSTALLED $THEN
      rec_.user_id := invoice_tax_info_request_rec_.user_id;
      rec_.password := invoice_tax_info_request_rec_.password;
      head_rec_.company := invoice_tax_info_request_rec_.company_id;
      head_rec_.invoice_id := invoice_tax_info_request_rec_.invoice_id;
      head_rec_ := Get_Invoice_Head_Structure_Rec___(invoice_tax_info_request_rec_.company_id, invoice_tax_info_request_rec_.invoice_id);
      invoice_date_temp_ := head_rec_.invoice_date;   
      invoice_date_act_ := To_Char(invoice_date_temp_, 'YYYY-MM-DD');
      tax_request_rec_.company_code := head_rec_.company;
      tax_request_rec_.doc_type := 'SalesInvoice';
      tax_request_rec_.doc_code := invoice_tax_info_request_rec_.doc_code;
      tax_request_rec_.doc_date := invoice_date_act_;
      tax_request_rec_.customer_code := head_rec_.delivery_identity;
      tax_request_rec_.detail_level := 'Tax';
      tax_request_rec_.commit := 'true';
      company_ := head_rec_.company;
      company_def_invoice_type_rec_ := Company_Def_Invoice_Type_API.Get(company_);
      def_col_cor_inv_type_ := company_def_invoice_type_rec_.def_col_cor_inv_type;
      def_co_cor_inv_type_ := company_def_invoice_type_rec_.def_co_cor_inv_type;
      IF (('CUSTORDCRE' = head_rec_.invoice_type) OR (def_co_cor_inv_type_ IS NOT NULL AND def_co_cor_inv_type_ = head_rec_.invoice_type) OR
          ('CUSTCOLCRE' = head_rec_.invoice_type) OR (def_col_cor_inv_type_ IS NOT NULL AND def_col_cor_inv_type_ = head_rec_.invoice_type) ) THEN
         number_ref_ := head_rec_.number_reference;
         series_ref_ := head_rec_.series_reference;
         invoice_id_ := Customer_Order_Inv_Head_API.Get_Invoice_Id_By_No(company_, number_ref_, series_ref_);
         inv_date_ := Customer_Order_Inv_Head_API.Get_Invoice_Date(company_, invoice_id_);
         invoice_date_ := To_Char(inv_date_, 'YYYY-MM-DD');
         IF (number_ref_ IS NOT NULL) THEN
            tax_rec_.tax_override_type := 'TaxDate';
            tax_rec_.tax_amount := '0';
            tax_rec_.tax_date := invoice_date_;
            tax_rec_.reason := 'Credit for ' || series_ref_ || number_ref_;
            tax_arr_.extend;
            tax_arr_(tax_arr_.last) := tax_rec_;            
         END IF;         
      END IF;         
      count_ := 0;
      FOR i_ IN 1..head_rec_.items.count LOOP
         invoice_line_item_rec_ := head_rec_.items(i_);
         tax_liablity_ := Tax_Handling_Order_Util_API.Get_Line_Tax_Liability(invoice_line_item_rec_.order_no,
                                                                             invoice_line_item_rec_.line_no,
                                                                             invoice_line_item_rec_.release_no,
                                                                             invoice_line_item_rec_.line_item_no,
                                                                             invoice_line_item_rec_.charge_seq_no,
                                                                             invoice_line_item_rec_.rma_no,
                                                                             invoice_line_item_rec_.rma_line_no,
                                                                             invoice_line_item_rec_.rma_charge_no);
         Tax_Handling_Order_Util_API.Get_Tax_Liability_Info(taxable_prod_,
                                                            taxable_customer_,
                                                            invoice_line_item_rec_.contract,
                                                            invoice_line_item_rec_.catalog_no,                                                            
                                                            invoice_line_item_rec_.order_no,
                                                            invoice_line_item_rec_.line_no,
                                                            invoice_line_item_rec_.release_no,
                                                            invoice_line_item_rec_.line_item_no,
                                                            invoice_line_item_rec_.rma_no,
                                                            invoice_line_item_rec_.rma_line_no,
                                                            invoice_line_item_rec_.charge_seq_no,
                                                            invoice_line_item_rec_.rma_charge_no);
         IF (tax_liablity_ = 'TAX' AND taxable_prod_ = 'Y' AND taxable_customer_ = 'Y') THEN
            -- For coorection invoices, use different sequence for line no
            IF (invoice_line_item_rec_.prel_update_allowed = 'FALSE') THEN
               count_ := count_ + 1;
               line_item_rec_.no := invoice_line_item_rec_.pos || '-' || count_;               
            ELSE
               line_item_rec_.no := invoice_line_item_rec_.pos;
            END IF;
            line_item_rec_.origin_code := invoice_line_item_rec_.pos || '-' || '001';
            line_item_rec_.destination_code := invoice_line_item_rec_.pos || '-' || '002';
            line_item_rec_.item_code := invoice_line_item_rec_.catalog_no;
            line_item_rec_.qty := invoice_line_item_rec_.invoiced_qty;            
            catalog_desc_ := Customer_Order_Line_API.Get_Catalog_Desc(invoice_line_item_rec_.order_no, invoice_line_item_rec_.line_no, invoice_line_item_rec_.release_no, invoice_line_item_rec_.line_item_no);
            cust_usage_type_ := Invoice_Item_API.Get_Customer_Tax_Usage_Type(invoice_line_item_rec_.company, invoice_line_item_rec_.invoice_id, invoice_line_item_rec_.item_id);
            tax_code_ := Sales_Part_Ext_Tax_Params_API.Get_Avalara_Tax_Code(invoice_line_item_rec_.contract, invoice_line_item_rec_.catalog_no);
            -- line_item_rec_.amount is a string and invoice_line_item_rec_.net_dom_amount is a number. Do we need to 
            -- consider specific number formatting in conversion to string?
            -- For example using an explicit conversion like this:
            -- to_char(12345.4560, 'TM9', 'NLS_NUMERIC_CHARACTERS = ''. ''') will ensure that the decimal symbol is always a period
            line_item_rec_.amount := invoice_line_item_rec_.net_dom_amount;
            line_item_rec_.customer_usage_type := cust_usage_type_;
            line_item_rec_.tax_code := tax_code_;
            line_item_rec_.description := catalog_desc_;
            line_item_arr_.extend;
            line_item_arr_(line_item_arr_.last) := line_item_rec_;
            Tax_Handling_Order_Util_API.Get_Ship_From_Addr(from_address_, invoice_line_item_rec_.contract, invoice_line_item_rec_.company);
            attr_ := from_address_;
            from_base_address_rec_.address_code := invoice_line_item_rec_.pos || '-' || Client_SYS.Get_Item_Value('ADDRESS_CODE', attr_);
            from_base_address_rec_.line1 := Client_SYS.Get_Item_Value('LINE1', attr_);
            from_base_address_rec_.line2 := Client_SYS.Get_Item_Value('LINE2', attr_);
            from_base_address_rec_.city := Client_SYS.Get_Item_Value('CITY', attr_);
            from_base_address_rec_.region := Client_SYS.Get_Item_Value('REGION', attr_);
            from_base_address_rec_.postal_code := Client_SYS.Get_Item_Value('POSTAL_CODE', attr_);
            from_base_address_rec_.country := Client_SYS.Get_Item_Value('COUNTRY', attr_);
            from_base_address_rec_.tax_region_id := Client_SYS.Get_Item_Value('TAX_REGION_ID', attr_);
            from_base_address_rec_.tax_included := Client_SYS.Get_Item_Value('TAX_INCLUDED', attr_);
            base_address_arr_.extend;
            base_address_arr_(base_address_arr_.last) := from_base_address_rec_;
            Tax_Handling_Order_Util_API.Get_Ship_To_Addr(to_address_, invoice_line_item_rec_.item_id, invoice_line_item_rec_.invoice_id, invoice_line_item_rec_.company);
            attr2_ := to_address_;
            to_base_address_rec_.address_code := invoice_line_item_rec_.pos || '-' || Client_SYS.Get_Item_Value('ADDRESS_CODE', attr2_);
            to_base_address_rec_.line1 := Client_SYS.Get_Item_Value('LINE1', attr2_);
            to_base_address_rec_.line2 := Client_SYS.Get_Item_Value('LINE2', attr2_);
            to_base_address_rec_.city := Client_SYS.Get_Item_Value('CITY', attr2_);
            to_base_address_rec_.region := Client_SYS.Get_Item_Value('REGION', attr2_);
            to_base_address_rec_.postal_code := Client_SYS.Get_Item_Value('POSTAL_CODE', attr2_);
            to_base_address_rec_.country := Client_SYS.Get_Item_Value('COUNTRY', attr2_);
            to_base_address_rec_.tax_region_id := Client_SYS.Get_Item_Value('TAX_REGION_ID', attr2_);
            to_base_address_rec_.tax_included := Client_SYS.Get_Item_Value('TAX_INCLUDED', attr2_);            
            base_address_arr_.extend;
            base_address_arr_(base_address_arr_.last) := to_base_address_rec_;                        
         END IF;
      END LOOP;            
      tax_request_rec_.tax_overrides := tax_arr_;
      tax_request_rec_.addresses := base_address_arr_;      
      tax_request_rec_.line_items := line_item_arr_;
      tax_request_arr_.extend;
      tax_request_arr_(tax_request_arr_.last) := tax_request_rec_;
      rec_.get_tax_requests := tax_request_arr_;      
   $ELSE
      tax_request_rec_.tax_overrides := tax_arr_;
      tax_request_rec_.addresses := base_address_arr_;      
      tax_request_rec_.line_items := line_item_arr_;  
      tax_request_arr_.extend;
      tax_request_arr_(tax_request_arr_.last) := tax_request_rec_;      
      rec_.get_tax_requests := tax_request_arr_;      
   $END
   RETURN rec_;
END Create_Invoice_Avalara_Tax_Info_Req_Data___;

-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------


-------------------- LU SPECIFIC PROTECTED METHODS --------------------------


-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

PROCEDURE Fetch_And_Calc_Tax_At_Print (
   ext_tax_param_out_rec_ OUT External_Tax_System_Util_API.ext_tax_param_out_rec,
   ext_tax_param_in_rec_  IN  External_Tax_System_Util_API.ext_tax_param_in_rec,
   xml_trans_             IN  CLOB )
IS
   counter_                NUMBER := 0;
   error_or_sucess_        VARCHAR2(20);
   detail_error_msg_       VARCHAR2(2000);
BEGIN
   counter_          := ext_tax_param_in_rec_.counter;
   error_or_sucess_  := Get_Val_By_Tag_Name___(xml_trans_, 'RESULT_CODE');
   detail_error_msg_ := SUBSTR(Get_Val_By_Tag_Name___(xml_trans_, 'SUMMARY')|| ' '||Get_Val_By_Tag_Name___(xml_trans_, 'DETAILS'), 1, 250);
   IF (error_or_sucess_ = 'Error') THEN
      Error_SYS.Record_General(lu_name_, 'TAXREGERROR: An error occurred when trying to Register Avalara Tax. Error Message from Avalara: :P1 ', detail_error_msg_ );
   END IF;
   Assign_Tax_Amount_Percentage___(ext_tax_param_out_rec_, xml_trans_, counter_);
END Fetch_And_Calc_Tax_At_Print;


PROCEDURE Fetch_And_Calculate_Tax (
   ext_tax_param_out_rec_ OUT External_Tax_System_Util_API.ext_tax_param_out_rec,
   ext_tax_param_in_rec_  IN  External_Tax_System_Util_API.ext_tax_param_in_rec )
IS
   invoice_date_                 DATE;
   invoice_no_                   VARCHAR2(50);  
   exemption_no_                 VARCHAR2(50);
   document_                     Plsqlap_Document_API.Document;
   ord_req_element_id_           Plsqlap_Document_API.Element_Id;
   tax_or_element_id_            Plsqlap_Document_API.Element_Id;
   addr_element_id_              Plsqlap_Document_API.Element_Id;
   line_element_id_              Plsqlap_Document_API.Element_Id;
   xml_clob_                     CLOB; 
   error_or_sucess_              VARCHAR2(20);
   detail_error_msg_             VARCHAR2(2000);
BEGIN
   invoice_date_    := NVL(ext_tax_param_in_rec_.invoice_date, SYSDATE);
   invoice_no_      := SUBSTR(ext_tax_param_in_rec_.invoice_no, 1, INSTR(ext_tax_param_in_rec_.invoice_no,'-')-1);
   -- build order tax information request messsage
   document_ := Plsqlap_Document_API.New_Document('ORDER_TAX_INFO_REQUEST');
   --Add login and version info
   Set_Login_And_Version_Info___(document_, document_.root_id);
   Create_Order_Request___(document_, ord_req_element_id_, invoice_date_, invoice_no_, ext_tax_param_in_rec_.company, exemption_no_, 'SalesOrder', ext_tax_param_in_rec_.identity);
   IF (ext_tax_param_in_rec_.number_ref IS NOT NULL AND ext_tax_param_in_rec_.corr_credit_invoice) THEN
      -- Tax overrides
      tax_or_element_id_ := Plsqlap_Document_API.Add_Array(document_, 'TAX_OVERRIDES', ord_req_element_id_);
      Create_Tax_Override_Item___(document_, tax_or_element_id_, ext_tax_param_in_rec_.org_invoice_date, ext_tax_param_in_rec_.series_ref, ext_tax_param_in_rec_.number_ref);
   END IF; 
   addr_element_id_ := Plsqlap_Document_API.Add_Array(document_, 'ADDRESSES', ord_req_element_id_);
   -- company deliver address
   Create_Base_Address_Item___(document_,
                               addr_element_id_,
                               '001',
                               ext_tax_param_in_rec_.comp_del_address1,
                               ext_tax_param_in_rec_.comp_del_address2,
                               ext_tax_param_in_rec_.comp_del_city,
                               ext_tax_param_in_rec_.comp_del_state,
                               ext_tax_param_in_rec_.comp_del_zip_code,
                               ext_tax_param_in_rec_.comp_del_country);
   -- customer delivery address
   Create_Base_Address_Item___(document_,
                               addr_element_id_,
                               '002',
                               ext_tax_param_in_rec_.cust_del_address1,
                               ext_tax_param_in_rec_.cust_del_address2,
                               ext_tax_param_in_rec_.cust_del_city,
                               ext_tax_param_in_rec_.cust_del_state,
                               ext_tax_param_in_rec_.cust_del_zip_code,
                               ext_tax_param_in_rec_.cust_del_country );
   --Add Line Item info
   line_element_id_ := Plsqlap_Document_API.Add_Array(document_, 'LINE_ITEMS', ord_req_element_id_);
   Create_Line_Item___(document_,
                       line_element_id_,
                       '01',
                       '001',
                       '002',
                       ext_tax_param_in_rec_.object_id,
                       ext_tax_param_in_rec_.quantity,
                       ext_tax_param_in_rec_.taxable_amount,
                       ext_tax_param_in_rec_.cust_usage_type,
                       ext_tax_param_in_rec_.avalara_tax_code,
                       ext_tax_param_in_rec_.object_desc);
   --Sent Tax Request to Avalara
   IF (ext_tax_param_in_rec_.comp_del_country IN ('US','CA') AND (ext_tax_param_in_rec_.cust_del_country IN ('US','CA'))) THEN
      -- Convert to a Plsqlap_Document by first converting to an XML
      -- Add XML attribute data so that the XML will be backward compatible with Apps 10 
      -- and existing transformers built upon that XML will work. 
      -- This should be changed in the long run so that it is model-driven and sent to IFS Connect as JSON
      Plsqlap_Document_API.Add_Xml_Attribute(document_, 'xmlns:xsi', 'http://www.w3.org/2001/XMLSchema-instance');
      -- The following line was the namespace information that was added by the old Biz API. If needed the following line can be uncommented
      --Plsqlap_Document_API.Add_Xml_Attribute(document_, 'xmlns', 'urn:ifsworld-com:schemas:avalara_services_handler_send_order_info_receive_avalara_tax_info_response');      
      Plsqlap_Document_API.To_Xml(xml_clob_, document_, TRUE, TRUE, NULL, FALSE, TRUE, NULL, FALSE, TRUE);      
      -- The following lines can be uncommented if message should be sent in JSON format
      --Plsqlap_Document_API.To_Camel_Case(document_);
      --Plsqlap_Document_API.To_Json(xml_clob_, document_);
      Plsqlap_Server_API.Invoke_Outbound_Message(xml_clob_,
                                                 sender_       => 'IFS',
                                                 receiver_     => 'AVALARA',
                                                 message_type_ => 'APPLICATION_MESSAGE',                                            
                                                 message_function_ => 'SEND_ORDER_INFO_RECEIVE_AVALARA_TAX_INFO');                                                             
      error_or_sucess_  := Get_Val_By_Tag_Name___(xml_clob_, 'RESULT_CODE');
      IF (error_or_sucess_ = 'Error') THEN
         detail_error_msg_ := SUBSTR(Get_Val_By_Tag_Name___(xml_clob_, 'SUMMARY')|| ' '||Get_Val_By_Tag_Name___(xml_clob_, 'DETAILS'), 1, 250);
         Error_SYS.Record_General(lu_name_, 'TAXREGERROR: An error occurred when trying to Register Avalara Tax. Error Message from Avalara: :P1 ', detail_error_msg_ );
      END IF;                                           
   END IF;    
   Assign_Tax_Amount_Percentage___(ext_tax_param_out_rec_, xml_clob_, 1);
END Fetch_And_Calculate_Tax;


PROCEDURE Fetch_And_Calculate_Tax (
   ext_tax_param_out_arr_ OUT External_Tax_System_Util_API.ext_tax_param_out_arr,
   ext_tax_param_in_arr_  IN  External_Tax_System_Util_API.ext_tax_param_in_arr )
IS
   rec_count_                    NUMBER;
   invoice_date_                 DATE;
   invoice_no_                   VARCHAR2(50);  
   exemption_no_                 VARCHAR2(50);
   error_or_sucess_              VARCHAR2(20);
   detail_error_msg_             VARCHAR2(2000);
   document_                     Plsqlap_Document_API.Document;
   ord_req_element_id_           Plsqlap_Document_API.Element_Id;
   tax_or_element_id_            Plsqlap_Document_API.Element_Id;
   addr_element_id_              Plsqlap_Document_API.Element_Id;
   line_element_id_              Plsqlap_Document_API.Element_Id;
   xml_clob_                     CLOB;         
BEGIN
   invoice_date_    := NVL(ext_tax_param_in_arr_(1).invoice_date, SYSDATE);
   invoice_no_      := SUBSTR(ext_tax_param_in_arr_(1).invoice_no, 1, INSTR(ext_tax_param_in_arr_(1).invoice_no,'-')-1);
   -- build order tax information request messsage
   document_ := Plsqlap_Document_API.New_Document('ORDER_TAX_INFO_REQUEST');
    --Add login and version info
   Set_Login_And_Version_Info___(document_, document_.root_id);
   Create_Order_Request___(document_, ord_req_element_id_, invoice_date_, invoice_no_, ext_tax_param_in_arr_(1).company, exemption_no_, 'SalesOrder', ext_tax_param_in_arr_(1).identity);
   rec_count_ := ext_tax_param_in_arr_.count;
   tax_or_element_id_ := Plsqlap_Document_API.Add_Array(document_, 'TAX_OVERRIDES', ord_req_element_id_);
   FOR i_ IN 1 .. rec_count_ LOOP
      IF (ext_tax_param_in_arr_(i_).number_ref IS NOT NULL AND ext_tax_param_in_arr_(i_).corr_credit_invoice) THEN
         -- Tax overrides
         Create_Tax_Override_Item___(document_, ord_req_element_id_, ext_tax_param_in_arr_(i_).org_invoice_date, ext_tax_param_in_arr_(i_).series_ref, ext_tax_param_in_arr_(i_).number_ref);
      END IF; 
   END LOOP;
   addr_element_id_ := Plsqlap_Document_API.Add_Array(document_, 'ADDRESSES', ord_req_element_id_);
   FOR i_ IN 1 .. rec_count_ LOOP
      -- company deliver address
      Create_Base_Address_Item___(document_,
                                  addr_element_id_,
                                  i_ || '_001',
                                  ext_tax_param_in_arr_(i_).comp_del_address1,
                                  ext_tax_param_in_arr_(i_).comp_del_address2,
                                  ext_tax_param_in_arr_(i_).comp_del_city,
                                  ext_tax_param_in_arr_(i_).comp_del_state,
                                  ext_tax_param_in_arr_(i_).comp_del_zip_code,
                                  ext_tax_param_in_arr_(i_).comp_del_country);
      -- customer delivery address
      Create_Base_Address_Item___(document_,
                                  addr_element_id_,
                                  i_ || '_002',
                                  ext_tax_param_in_arr_(i_).cust_del_address1,
                                  ext_tax_param_in_arr_(i_).cust_del_address2,
                                  ext_tax_param_in_arr_(i_).cust_del_city,
                                  ext_tax_param_in_arr_(i_).cust_del_state,
                                  ext_tax_param_in_arr_(i_).cust_del_zip_code,
                                  ext_tax_param_in_arr_(i_).cust_del_country);
   END LOOP; 
   line_element_id_ := Plsqlap_Document_API.Add_Array(document_, 'LINE_ITEMS', ord_req_element_id_);
   FOR i_ IN 1 .. rec_count_ LOOP
      --Add Line Item info
      IF (ext_tax_param_in_arr_(i_).comp_del_country IN ('US','CA') AND (ext_tax_param_in_arr_(i_).cust_del_country IN ('US','CA'))) THEN
         Create_Line_Item___(document_,
                             line_element_id_,
                             i_,
                             i_ || '_001',
                             i_ || '_002',
                             ext_tax_param_in_arr_(i_).object_id,
                             ext_tax_param_in_arr_(i_).quantity,
                             ext_tax_param_in_arr_(i_).taxable_amount,
                             ext_tax_param_in_arr_(i_).cust_usage_type,
                             ext_tax_param_in_arr_(i_).avalara_tax_code,
                             ext_tax_param_in_arr_(i_).object_desc);
         
      END IF;
   END LOOP;
    -- Convert to a Plsqlap_Document by first converting to an XML
   -- Add XML attribute data so that the XML will be backward compatible with Apps 10 
   -- and existing transformers built upon that XML will work. 
   -- This should be changed in the long run so that it is model-driven and sent to IFS Connect as JSON
   Plsqlap_Document_API.Add_Xml_Attribute(document_, 'xmlns:xsi', 'http://www.w3.org/2001/XMLSchema-instance');
   -- The following line was the namespace information that was added by the old Biz API. If needed the following line can be uncommented
   --Plsqlap_Document_API.Add_Xml_Attribute(document_, 'xmlns', 'urn:ifsworld-com:schemas:avalara_services_handler_send_order_info_receive_avalara_tax_info_response');      
   Plsqlap_Document_API.To_Xml(xml_clob_, document_, TRUE, TRUE, NULL, FALSE, TRUE, NULL, FALSE, TRUE);      
   -- The following lines can be uncommented if message should be sent in JSON format
   --Plsqlap_Document_API.To_Camel_Case(document_);
   --Plsqlap_Document_API.To_Json(xml_clob_, document_);
   Plsqlap_Server_API.Invoke_Outbound_Message(xml_clob_,
                                              sender_       => 'IFS',
                                              receiver_     => 'AVALARA',
                                              message_type_ => 'APPLICATION_MESSAGE',                                            
                                              message_function_ => 'SEND_ORDER_INFO_RECEIVE_AVALARA_TAX_INFO');                                                             
   
   error_or_sucess_  := Get_Val_By_Tag_Name___(xml_clob_, 'RESULT_CODE');
   IF (error_or_sucess_ = 'Error') THEN
      detail_error_msg_ := SUBSTR(Get_Val_By_Tag_Name___(xml_clob_, 'SUMMARY')|| ' '||Get_Val_By_Tag_Name___(xml_clob_, 'DETAILS'), 1, 250);
      Error_SYS.Record_General(lu_name_, 'TAXREGERROR: An error occurred when trying to Register Avalara Tax. Error Message from Avalara: :P1 ', detail_error_msg_ );
   END IF;
   FOR i_ IN 1 .. rec_count_ LOOP
      ext_tax_param_out_arr_(i_).state_tax_amount     := NULL;
      ext_tax_param_out_arr_(i_).state_tax_percentage := NULL;
      ext_tax_param_out_arr_(i_).city_tax_amount      := NULL;
      ext_tax_param_out_arr_(i_).city_tax_percentage  := NULL;
      ext_tax_param_out_arr_(i_).county_tax_amount    := NULL;
      ext_tax_param_out_arr_(i_).county_tax_percentage := NULL;
      ext_tax_param_out_arr_(i_).district_tax_amount  := NULL;
      ext_tax_param_out_arr_(i_).district_tax_percentage := NULL;
      Assign_Tax_Amount_Percentage___(ext_tax_param_out_arr_(i_), xml_clob_, i_);
   END LOOP;
END Fetch_And_Calculate_Tax;


PROCEDURE Authorize_Credentials (
   info_     OUT VARCHAR2 )
IS   
   xml_trans_     CLOB;
   result_        VARCHAR2(32000) := 'ERROR';
   document_      Plsqlap_Document_API.Document;
   xml_clob_      CLOB;                
   element_id_    Plsqlap_Document_API.Element_Id;   
BEGIN
   -- build address validation request message   
   document_ := Plsqlap_Document_API.New_Document('VALIDATE');
   Set_Login_And_Version_Info___(document_, document_.root_id);
   element_id_ := Plsqlap_Document_API.Add_Aggregate(document_, 'VALIDATE_REQUEST', 'ADDRESS', document_.root_id);
   Plsqlap_Document_API.Add_Attribute(document_, 'ADDRESS_CODE', '01', element_id_);   
   Plsqlap_Document_API.Add_Attribute(document_, 'LINE1', 'xx', element_id_);   
   Plsqlap_Document_API.Add_Attribute(document_, 'LINE2', 'xx', element_id_);   
   Plsqlap_Document_API.Add_Attribute(document_, 'CITY', 'xx', element_id_);   
   Plsqlap_Document_API.Add_Attribute(document_, 'REGION', 'xx', element_id_);   
   Plsqlap_Document_API.Add_Attribute(document_, 'POSTAL_CODE', 'xx', element_id_);   
   Plsqlap_Document_API.Add_Attribute(document_, 'COUNTRY', 'xx', element_id_);   
   --send Authorization request to Avalara   
   BEGIN            
      -- Add XML attribute data so that the XML will be backward compatible with Apps 10 
      -- and existing transformers built upon that XML will work. 
      -- This should be changed in the long run so that it is model-driven and sent to IFS Connect as JSON
      Plsqlap_Document_API.Add_Xml_Attribute(document_, 'xmlns:xsi', 'http://www.w3.org/2001/XMLSchema-instance');
      -- The following line was the namespace information that was added by the old Biz API. If needed the following line can be uncommented
      --Plsqlap_Document_API.Add_Xml_Attribute(document_, 'xmlns', 'urn:ifsworld-com:schemas:avalara_services_handler_send_receive_avalara_authorization_request');      
      -- Convert to XML
      Plsqlap_Document_API.To_Xml(xml_clob_, document_, TRUE, TRUE, NULL, FALSE, TRUE, NULL, FALSE, TRUE);                                                 
      -- The following lines can be uncommented if message should be sent in JSON format
      --Plsqlap_Document_API.To_Camel_Case(document_);
      --Plsqlap_Document_API.To_Json(xml_clob_, document_);            
      Plsqlap_Server_API.Invoke_Outbound_Message(xml_clob_,
                                                 sender_       => 'IFS',
                                                 receiver_     => 'AVALARA',
                                                 message_type_ => 'APPLICATION_MESSAGE',                                            
                                                 message_function_ => 'SEND_RECEIVE_AVALARA_AUTHORIZATION');                                                             
      xml_trans_ := xml_clob_;   
      result_ := Get_Val_By_Tag_Name___(xml_trans_, 'RESULT_CODE');
   EXCEPTION
      WHEN OTHERS THEN 
         result_ := SUBSTR(SQLERRM, INSTR(SQLERRM, '<faultstring xml:lang="en-US">') + LENGTH('<faultstring xml:lang="en-US">'), (LENGTH(SQLERRM) + 1) - INSTR(SQLERRM, '</faultstring>'));
   END;
   IF (UPPER(result_) != 'SUCCESS') THEN 
      Error_SYS.Record_General(lu_name_, 'AUTHFAILD: Connection was not successful, :P1', result_);
   ELSE
      Client_SYS.Add_Info(lu_name_,'AUTHSUCCESS: Connection was successful.');
      info_ := info_ || Client_SYS.Get_All_Info;
   END IF;
END Authorize_Credentials;


PROCEDURE Validate_Address (
   postal_addresses_ IN External_Tax_System_Util_API.postal_address_arr )
IS   
   xml_trans_     CLOB;
   result_        VARCHAR2(50);
   message_       VARCHAR2(4000);
  
   document_      Plsqlap_Document_API.Document;
   element_id_    Plsqlap_Document_API.Element_Id;
   xml_clob_      CLOB;             
BEGIN   
   -- build address validation request message
   document_ := Plsqlap_Document_API.New_Document('VALIDATE');
   --Add login and version info   
   Set_Login_And_Version_Info___(document_, document_.root_id);      
   element_id_ := Plsqlap_Document_API.Add_Aggregate(document_, 'VALIDATE_REQUEST', 'ADDRESS', document_.root_id);
   Plsqlap_Document_API.Add_Attribute(document_,'ADDRESS_CODE', postal_addresses_(0).address_id, element_id_); 
   Plsqlap_Document_API.Add_Attribute(document_,'LINE1', Rem_Special_Char(postal_addresses_(0).address1), element_id_);
   Plsqlap_Document_API.Add_Attribute(document_,'LINE2', Rem_Special_Char(postal_addresses_(0).address2), element_id_);
   Plsqlap_Document_API.Add_Attribute(document_,'CITY', postal_addresses_(0).city, element_id_);
   Plsqlap_Document_API.Add_Attribute(document_,'REGION', postal_addresses_(0).state, element_id_);
   Plsqlap_Document_API.Add_Attribute(document_,'POSTAL_CODE', postal_addresses_(0).zip_code, element_id_);
   Plsqlap_Document_API.Add_Attribute(document_,'COUNTRY', postal_addresses_(0).country, element_id_);
   Plsqlap_Document_API.Add_Attribute(document_,'TAX_REGION_ID', '1', element_id_);  
   -- Convert to XML
   Plsqlap_Document_API.To_Xml(xml_clob_, document_, TRUE, TRUE, NULL, FALSE, TRUE, NULL, FALSE, TRUE);   
   IF (postal_addresses_(0).country = 'US') THEN         
      -- Add XML attribute data so that the XML will be backward compatible with Apps 10 
      -- and existing transformers built upon that XML will work. 
      -- This should be changed in the long run so that it is model-driven and sent to IFS Connect as JSON
      Plsqlap_Document_API.Add_Xml_Attribute(document_, 'xmlns:xsi', 'http://www.w3.org/2001/XMLSchema-instance');
      --Plsqlap_Document_API.Add_Xml_Attribute(document_, 'xmlns', 'urn:ifsworld-com:schemas:avalara_services_handler_send_address_receive_avalara_validation_request');      
      Plsqlap_Document_API.To_Xml(xml_clob_, document_, TRUE, TRUE, NULL, FALSE, TRUE, NULL, FALSE, TRUE);                                                 
      -- The following lines can be uncommented if message should be sent in JSON format
      --Plsqlap_Document_API.To_Camel_Case(document_);
      --Plsqlap_Document_API.To_Json(xml_clob_, document_);      
      Plsqlap_Server_API.Invoke_Outbound_Message(xml_clob_,
                                                 sender_       => 'IFS',
                                                 receiver_     => 'AVALARA',
                                                 message_type_ => 'APPLICATION_MESSAGE',                                            
                                                 message_function_ => 'SEND_ADDRESS_RECEIVE_AVALARA_VALIDATION');      
   END IF; 
   xml_trans_ := xml_clob_;
   -- check transaction result
   result_ := Get_Val_By_Tag_Name___(xml_trans_,'RESULT_CODE');
   IF (UPPER(result_) != 'SUCCESS') THEN 
      message_ := CHR(13)||CHR(10) || Get_Val_By_Tag_Name___(xml_trans_,'SEVERITY');
      message_ := message_ || ': ' || Get_Val_By_Tag_Name___(xml_trans_,'MESSAGE') ||CHR(13)||CHR(10);
      message_ := message_ || 'Source: ' || Get_Val_By_Tag_Name___(xml_trans_,'REFERS_TO');
      Error_SYS.Record_General(lu_name_, 'ADDRESSFAILED: Address validation failed.'||CHR(13)||CHR(10) ||'Returned Message from Avalara: :P1', SUBSTR(message_, 1, 1000));
   END IF;
END Validate_Address;


PROCEDURE Write_To_Ext_Avalara_Tax_Regis (
   xml_trans_           OUT CLOB,
   company_             IN  VARCHAR2,
   invoice_id_          IN  NUMBER,
   invoice_no_          IN  VARCHAR2,
   series_id_           IN  VARCHAR2,
   invoice_date_        IN  DATE,
   corr_credit_invoice_ IN  BOOLEAN )
IS 
   ext_param_rec_       Ext_Tax_System_Parameters_API.Public_Rec;
   rec_                 Invoice_Avalara_Tax_Info_Request_Struct_Rec;
   in_rec_              Invoice_Tax_Info_Request_Rec;   
   document_            Plsqlap_Document_API.Document;
   temp_xml_            CLOB;
   xml_clob_            CLOB;   
BEGIN   
   --Set Login Info
   ext_param_rec_ := Ext_Tax_System_Parameters_API.Get(1);    
   in_rec_.user_id := ext_param_rec_.user_name_avalara;
   in_rec_.password := ext_param_rec_.password_avalara;
   in_rec_.company_id := company_;
   in_rec_.invoice_id := invoice_id_;
   in_rec_.doc_code := series_id_ || invoice_no_;
   in_rec_.invoice_date := TO_CHAR(SYSDATE, 'YYYY-MM-DD');   
   IF (corr_credit_invoice_) THEN
      in_rec_.invoice_date := TO_CHAR(invoice_date_, 'YYYY-MM-DD');
   END IF;
   rec_ := Create_Invoice_Avalara_Tax_Info_Req_Data___(in_rec_);  
   temp_xml_ := Invoice_Avalara_Tax_Info_Request_Struct_Rec_To_Xml___(rec_);
   -- Convert into Plsqlap_Document
   Plsqlap_Document_API.From_Xml(document_, temp_xml_, add_type_ => true);
   -- Convert to_upper since all tag in old XML was upper
   Plsqlap_Document_API.To_Upper_Case(document_);      
   -- Rename to match old XML tags
   Plsqlap_Document_API.Rename(document_, 'INVOICE_AVALARA_TAX_INFO_REQUEST_STRUCT', 'INVOICE_AVALARA_TAX_INFO_REQUEST', false, false, true);  
   Plsqlap_Document_API.Rename(document_, 'GET_TAX_REQUEST_QRY', 'GET_TAX_REQUEST', false, false, true);  
   Plsqlap_Document_API.Rename(document_, 'LINE_ITEM_QRY', 'LINE_ITEM', false, false, true);  
   Plsqlap_Document_API.Rename(document_, 'BASE_ADDRESS_QRY', 'BASE_ADDRESS', false, false, true);  
   Plsqlap_Document_API.Rename(document_, 'TAX_OVERRIDE_QRY', 'TAX_OVERRIDE', false, false, true);  
   -- Convert to XML
   Plsqlap_Document_API.To_Xml(xml_clob_, document_, xml_attrs_ => true, add_header_ => true, elem_type_ => false, use_crlf_ => true); 
   -- The following lines can be uncommented if message should be sent in JSON format
   --Plsqlap_Document_API.To_Camel_Case(document_);
   --Plsqlap_Document_API.To_Json(xml_clob_, document_);
   Plsqlap_Server_API.Invoke_Outbound_Message(xml_clob_, 
                                              sender_       => 'IFS', 
                                              receiver_     => 'AVALARA',
                                              message_type_ => 'APPLICATION_MESSAGE',                                            
                                              message_function_ => 'SEND_INVOICE_INFO_RECEIVE_AVALARA_TAX_INFO');                                               
   xml_trans_ := xml_clob_;
END Write_To_Ext_Avalara_Tax_Regis;


FUNCTION Rem_Special_Char (
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
END Rem_Special_Char;
