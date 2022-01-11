-----------------------------------------------------------------------------
--
--  Logical unit: VertexQSeriesTaxUtil
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  171124  Paralk  Created.
--  191105  Vashlk  Bug 150833, Performance improvement for Vertex.
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------

-------------------- PRIVATE DECLARATIONS -----------------------------------

-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------

-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------

-------------------- LU SPECIFIC PROTECTED METHODS --------------------------

-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

PROCEDURE Fetch_Jurisdiction_Code ( 
   postal_addresses_ IN OUT External_Tax_System_Util_API.postal_address_arr,
   context_          IN     VARCHAR2 )
IS
   stmt_              VARCHAR2(5000);
   zip_code_trunc_    VARCHAR2(7);
   temp_city_         VARCHAR2(35);   
   state_             VARCHAR2(35); 
   county_            VARCHAR2(35);   
   jurisdiction_code_ VARCHAR2(20); 
   exist_             NUMBER := 0;
   next_              NUMBER := 0;
BEGIN
   IF (postal_addresses_.COUNT > 0) THEN
      FOR i IN postal_addresses_.FIRST..postal_addresses_.LAST LOOP
         IF (Iso_Country_API.Get_Fetch_Jurisdiction_Code_Db(postal_addresses_(i).country) = 'TRUE') THEN
            IF (NVL(postal_addresses_(i).country, '*') != 'CA') THEN 
               zip_code_trunc_ := SUBSTR(postal_addresses_(i).zip_code, 0, 5);
            ELSE
               zip_code_trunc_ := SUBSTR(postal_addresses_(i).zip_code, 0, 7);
            END IF;
            temp_city_ := SUBSTR(postal_addresses_(i).city, 0, 25);
            state_     := postal_addresses_(i).state;
            county_    := postal_addresses_(i).county;
            Client_SYS.Clear_Info;   
            IF (Database_SYS.Package_Exist('GEO')) THEN
               stmt_ := '
               DECLARE
                  geo_search_record_     Geo.tGeoSearchRecord;
                  geo_results_record_    Geo.tGeoResultsRecord;
                  geo_code_found_        BOOLEAN;
                  second_geo_code_found_ BOOLEAN := FALSE;
                  a_next_                NUMBER;
                  a_exist_               NUMBER;
                  main_juris_code_       VARCHAR2(20);
                  first_juris_code_      VARCHAR2(20);
               BEGIN
                  IF (LENGTH(:state_) > 2) THEN
                     Geo.GeoSetNameCriteria(geo_search_record_, Geo.cGeoCodeLevelCity, NULL, FALSE, :state_, FALSE, :county_, FALSE, FALSE, :city_, FALSE, :zip_code_trunc_, NULL);
                  ELSE
                     Geo.GeoSetNameCriteria(geo_search_record_, Geo.cGeoCodeLevelCity, :state_, FALSE, NULL, FALSE, :county_, FALSE, FALSE, :city_, FALSE, :zip_code_trunc_, NULL);
                  END IF;
                  main_juris_code_  := NULL;
                  first_juris_code_ := NULL;
                  geo_code_found_ := Geo.GeoRetrieveFirst(geo_search_record_, geo_results_record_);
                  WHILE (geo_code_found_ AND NOT second_geo_code_found_) LOOP
                     main_juris_code_ := TO_CHAR(Geo.GeoPackGeoCode(geo_results_record_.fResGeoState, geo_results_record_.fResGeoCounty, geo_results_record_.fResGeoCity));
                     IF (first_juris_code_ IS NULL) THEN
                        first_juris_code_ := main_juris_code_;
                     ELSIF (first_juris_code_ != main_juris_code_) THEN
                        second_geo_code_found_ := TRUE;
                     END IF;
                     geo_code_found_ := Geo.GeoRetrieveNext(geo_search_record_, geo_results_record_);
                  END LOOP;
                  IF (second_geo_code_found_) THEN
                     a_next_  := 1; -- Multiple found
                     Geo.GeoCloseSearch(geo_search_record_);
                     IF (:state_ IS NOT NULL) AND (:city_ IS NOT NULL) AND (:zip_code_trunc_ IS NOT NULL) THEN
                        main_juris_code_  := first_juris_code_;  -- Use first value found
                     ELSE
                        main_juris_code_  := NULL;
                     END IF;
                  ELSE
                     a_next_  := 0;
                  END IF;
                  IF (main_juris_code_ IS NOT NULL) THEN
                     a_exist_ := 1; -- At least one found
                  ELSE
                     a_exist_ := 0;  -- None found
                  END IF;
                  :exist_ := a_exist_;
                  :jurisdiction_code_ := main_juris_code_;
                  :next_  := a_next_;
               END;
               ';
               @ApproveDynamicStatement(2007-12-15,paralk)
               EXECUTE IMMEDIATE stmt_ USING IN     state_, 
                                             IN     county_, 
                                             IN     temp_city_,
                                             IN     zip_code_trunc_, 
                                             IN OUT exist_, 
                                             OUT    jurisdiction_code_, 
                                             IN OUT next_;                
               postal_addresses_(i).jurisdiction_code := jurisdiction_code_;
            END IF;
            IF (context_ = 'COMPANY_CUSTOMER') THEN
               IF (exist_ = 0) THEN
                  jurisdiction_code_ := NULL;
                  IF (next_ = 1) THEN
                     Error_SYS.Item_General(lu_name_, 'JURISDICTION_CODE', 'MULTIGEO: Multiple Jurisdiction Codes found for City, State, Zip Code and County information. No Jurisdiction Code returned as at least one of City, State or Zip Code is missing.');
                  ELSE 
                     Error_SYS.Item_General(lu_name_, 'JURISDICTION_CODE', 'GEONOTFOUND: No Jurisdiction Code was found based on the City, State, Zip Code and County information.');
                  END IF;
               END IF;
               IF (next_ = 1) THEN
                  Client_SYS.Add_Info(lu_name_, 'MULTJURISCODE: Entered information for City, State, Zip Code and County found more than one Jurisdiction Code. First one returned.');
               END IF;   
            END IF;
         ELSE 
            IF (context_ = 'ORDER_CALCULATION') THEN
               postal_addresses_(i).jurisdiction_code := '770000000';   
            END IF;
         END IF;                     
      END LOOP;         
   END IF;      
END Fetch_Jurisdiction_Code;


PROCEDURE Fetch_And_Calculate_Tax (
   ext_tax_param_out_rec_ OUT External_Tax_System_Util_API.ext_tax_param_out_rec,
   ext_tax_param_in_rec_  IN  External_Tax_System_Util_API.ext_tax_param_in_rec )
IS
   stmt_                         VARCHAR2(32000); 
   cust_del_addr_jdiction_code_  VARCHAR2(20); 
   comp_del_addr_jdiction_code_  VARCHAR2(20); 
   comp_doc_addr_jdiction_code_  VARCHAR2(20); 
   company_                      VARCHAR2(20);   
   trans_date_                   DATE; 
   postal_addresses_             External_Tax_System_Util_API.postal_address_arr;
   postal_address_               External_Tax_System_Util_API.postal_address_rec;
BEGIN   
   postal_addresses_.DELETE;   
   -- customer delivery address
   postal_address_          := NULL;
   IF (ext_tax_param_in_rec_.cust_del_country = 'US') THEN
      postal_address_.zip_code := SUBSTR(ext_tax_param_in_rec_.cust_del_zip_code, 0, 5);
   ELSE
      postal_address_.zip_code := SUBSTR(ext_tax_param_in_rec_.cust_del_zip_code, 0, 7);
   END IF; 
   postal_address_.city     := ext_tax_param_in_rec_.cust_del_city;
   postal_address_.state    := ext_tax_param_in_rec_.cust_del_state;
   postal_address_.county   := ext_tax_param_in_rec_.cust_del_county;
   postal_address_.country  := ext_tax_param_in_rec_.cust_del_country;
   postal_addresses_(0)     := postal_address_;
   -- company deliver address
    postal_address_              := NULL;
    IF (ext_tax_param_in_rec_.comp_del_country = 'US') THEN
       postal_address_.zip_code  := SUBSTR(ext_tax_param_in_rec_.comp_del_zip_code,0,5);
    ELSE                                                                                       
       postal_address_.zip_code  := SUBSTR(ext_tax_param_in_rec_.comp_del_zip_code,0,7);
    END IF;
    postal_address_.city         := ext_tax_param_in_rec_.comp_del_city;
    postal_address_.state        := ext_tax_param_in_rec_.comp_del_state;
    postal_address_.county       := ext_tax_param_in_rec_.comp_del_county;
    postal_address_.country      := ext_tax_param_in_rec_.comp_del_country;
    postal_addresses_(1)         := postal_address_;
   -- company document address
   postal_address_              := NULL;
   IF (ext_tax_param_in_rec_.comp_doc_country = 'US') THEN
      postal_address_.zip_code  := SUBSTR(ext_tax_param_in_rec_.comp_doc_zip_code,0,5);
   ELSE
      postal_address_.zip_code  := SUBSTR(ext_tax_param_in_rec_.comp_doc_zip_code,0,6);
   END IF;   
   postal_address_.city         := ext_tax_param_in_rec_.comp_doc_city;
   postal_address_.state        := ext_tax_param_in_rec_.comp_doc_state;
   postal_address_.county       := ext_tax_param_in_rec_.comp_doc_county;
   postal_address_.country      := ext_tax_param_in_rec_.comp_doc_country;
   postal_addresses_(2)         := postal_address_;
   External_Tax_System_Util_API.Fetch_Jurisdiction_Code(postal_addresses_, NULL, 'ORDER_CALCULATION', 'VERTEX_SALES_TAX_Q_SERIES');
   
   cust_del_addr_jdiction_code_ := postal_addresses_(0).jurisdiction_code;
   IF (cust_del_addr_jdiction_code_ IS NULL) THEN
      Error_SYS.Item_General(lu_name_, 'JURISDICTION_CODE', 'CUSTJDCODENULL: A valid Jurisdiction Code could not be found. Please check the Customer Delivery Address info (City, State, Zip Code, County): :P1 for Country :P2', ext_tax_param_in_rec_.cust_del_city||', '||ext_tax_param_in_rec_.cust_del_state||', '|| ext_tax_param_in_rec_.cust_del_zip_code||', '|| ext_tax_param_in_rec_.cust_del_county, ext_tax_param_in_rec_.cust_del_country);
   END IF;      
   comp_del_addr_jdiction_code_ := postal_addresses_(1).jurisdiction_code;       
   IF (comp_del_addr_jdiction_code_ IS NULL) THEN
      Error_SYS.Item_General(lu_name_, 'JURISDICTION_CODE', 'COMPDELJDNULL: A valid Jurisdiction Code could not be found. Please check the Company Delivery Address info (City, State, Zip Code, County): :P1 for Country :P2', ext_tax_param_in_rec_.comp_del_city||', '||ext_tax_param_in_rec_.comp_del_state||', '||ext_tax_param_in_rec_.comp_del_zip_code||', '||ext_tax_param_in_rec_.comp_del_county, ext_tax_param_in_rec_.comp_del_country);
   END IF;
   comp_doc_addr_jdiction_code_ := postal_addresses_(2).jurisdiction_code;
   IF (comp_doc_addr_jdiction_code_ IS NULL) THEN
      Error_SYS.Item_General(lu_name_, 'JURISDICTION_CODE', 'COMPDOCJDNULL: A valid Jurisdiction Code could not be found. Please check the Company Document Address info (City, State, Zip Code, County): :P1 for Country :P2', ext_tax_param_in_rec_.comp_doc_city||', '||ext_tax_param_in_rec_.comp_doc_state||', '||ext_tax_param_in_rec_.comp_doc_zip_code||', '||ext_tax_param_in_rec_.comp_doc_county, ext_tax_param_in_rec_.comp_doc_country);
   END IF;
   IF (cust_del_addr_jdiction_code_ IS NOT NULL) AND (comp_del_addr_jdiction_code_ IS NOT NULL) THEN                                     
      company_    := SUBSTR(ext_tax_param_in_rec_.company,0,5); 
      trans_date_ := SYSDATE;	 
      IF (Database_SYS.Package_Exist('QSU')) THEN
         stmt_ := '
         DECLARE
            context_record_       QSU.tQSUContextRecord;
            invoice_record_in_    QSU.tQSUInvoiceRecord;
            invoice_record_out_   QSU.tQSUInvoiceRecord;
            line_item_record_     QSU.tQSULineItemRecord;
            line_item_table_in_   QSU.tQSULineItemTable;
            line_item_table_out_  QSU.tQSULineItemTable;
         BEGIN
            QSU.QSUInitializeInvoice(context_record_, invoice_record_in_, line_item_table_in_);
            invoice_record_in_.fJurisSTGeoCd      := TO_NUMBER(:cust_del_addr_jdiction_code_);
            invoice_record_in_.fJurisSTInCi       := (:ext_tax_param_in_rec_.cust_del_addr_in_city = ''TRUE'');
            invoice_record_in_.fJurisSFGeoCd      := TO_NUMBER(:comp_del_addr_jdiction_code_);
            invoice_record_in_.fJurisSFInCi       := (:ext_tax_param_in_rec_.comp_del_addr_in_city = ''TRUE'');
            invoice_record_in_.fJurisOAGeoCd      := TO_NUMBER(:comp_doc_addr_jdiction_code_);
            invoice_record_in_.fJurisOAInCi       := (:ext_tax_param_in_rec_.comp_doc_addr_in_city = ''TRUE'');
            invoice_record_in_.fTDMCustCd         := :ext_tax_param_in_rec_.identity;
            invoice_record_in_.fTDMCustClassCd    := :ext_tax_param_in_rec_.customer_group;
            invoice_record_in_.fTDMCompCd         := :company_;
            invoice_record_in_.fInvIdNum          := :ext_tax_param_in_rec_.invoice_no;
            invoice_record_in_.fInvDate           := :ext_tax_param_in_rec_.invoice_date;
            line_item_record_.fTransType          := QSU.cQSUTransTypeSale;
            line_item_record_.fTransCd            := QSU.cQSUTransCdNormal;
            line_item_record_.fTDMProdCd          := :ext_tax_param_in_rec_.object_id;
            line_item_record_.fTransExtendedAmt   := :ext_tax_param_in_rec_.taxable_amount;
            line_item_record_.fTransQuantity      := :ext_tax_param_in_rec_.quantity;
            line_item_record_.fTransDate          := :trans_date_;
            --add taxability info --
            IF (:ext_tax_param_in_rec_.object_taxable = ''FALSE'') THEN
               line_item_record_.fProdTxblty   := QSU.cQSUTxbltyNonTxbl;
            END IF;
            IF (:ext_tax_param_in_rec_.identity_taxable = ''FALSE'') THEN
               invoice_record_in_.fCustTxblty  := QSU.cQSUTxbltyExmt;
            END IF;
            line_item_table_in_(1) := line_item_record_;            
            IF (:ext_tax_param_in_rec_.write_to_ext_tax_register = ''TRUE'') THEN               
            	QSU.QSUCalculateTaxes(context_record_, invoice_record_in_, line_item_table_in_, invoice_record_out_, line_item_table_out_, TRUE);
            ELSE
               QSU.QSUCalculateTaxes(context_record_, invoice_record_in_, line_item_table_in_, invoice_record_out_, line_item_table_out_, FALSE);   
            END IF;
            
            :ext_tax_param_out_rec_.state_tax_amount     := line_item_table_out_(1).fPriStTaxAmt;
            :ext_tax_param_out_rec_.county_tax_amount    := line_item_table_out_(1).fPriCoTaxAmt + line_item_table_out_(1).fAddCoTaxAmt;
            :ext_tax_param_out_rec_.city_tax_amount      := line_item_table_out_(1).fPriCiTaxAmt + line_item_table_out_(1).fAddCiTaxAmt;
            :ext_tax_param_out_rec_.district_tax_amount  := line_item_table_out_(1).fPriDiTaxAmt + line_item_table_out_(1).fAddDiTaxAmt;
            :ext_tax_param_out_rec_.state_tax_percent    := line_item_table_out_(1).fPriStRate;
            :ext_tax_param_out_rec_.county_tax_percent   := line_item_table_out_(1).fPriCoRate + line_item_table_out_(1).fAddCoRate;
            :ext_tax_param_out_rec_.city_tax_percent     := line_item_table_out_(1).fPriCiRate + line_item_table_out_(1).fAddCiRate;
            :ext_tax_param_out_rec_.district_tax_percent := line_item_table_out_(1).fPriDiRate + line_item_table_out_(1).fAddDiRate;
         END;
         ';
         @ApproveDynamicStatement(2017-12-15,paralk) 
         EXECUTE IMMEDIATE stmt_ USING IN  cust_del_addr_jdiction_code_,
                                       IN  ext_tax_param_in_rec_.cust_del_addr_in_city,
                                       IN  comp_del_addr_jdiction_code_,
                                       IN  ext_tax_param_in_rec_.comp_del_addr_in_city,
                                       IN  comp_doc_addr_jdiction_code_,
                                       IN  ext_tax_param_in_rec_.comp_doc_addr_in_city,
                                       IN  ext_tax_param_in_rec_.identity,
                                       IN  ext_tax_param_in_rec_.customer_group,
                                       IN  company_,
                                       IN  ext_tax_param_in_rec_.invoice_no,
                                       IN  ext_tax_param_in_rec_.invoice_date,
                                       IN  ext_tax_param_in_rec_.object_id,
                                       IN  ext_tax_param_in_rec_.taxable_amount,
                                       IN  ext_tax_param_in_rec_.quantity,			
                                       IN  trans_date_,                                        
                                       IN  ext_tax_param_in_rec_.object_taxable,
                                       IN  ext_tax_param_in_rec_.identity_taxable,
                                       IN  ext_tax_param_in_rec_.write_to_ext_tax_register,
                                       OUT ext_tax_param_out_rec_.state_tax_amount,
                                       OUT ext_tax_param_out_rec_.county_tax_amount,
                                       OUT ext_tax_param_out_rec_.city_tax_amount,
                                       OUT ext_tax_param_out_rec_.district_tax_amount,
                                       OUT ext_tax_param_out_rec_.state_tax_percentage,
                                       OUT ext_tax_param_out_rec_.county_tax_percentage,
                                       OUT ext_tax_param_out_rec_.city_tax_percentage,
                                       OUT ext_tax_param_out_rec_.district_tax_percentage;
      END IF;         	        
   END IF;
END Fetch_And_Calculate_Tax;

-------------------- LU  NEW METHODS -------------------------------------
