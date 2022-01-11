-----------------------------------------------------------------------------
--
--  Logical unit: ExternalTaxSystemUtility
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  171124  Paralk  Created.
--  190620  Chwtlk  Bug 148866, Modified Fetch_Tax_From_External_System().
--  191028  Hairlk  SCXTEND-1165, Modified Fetch_Tax_From_External_System, made sure that virtex o series and avalara behaves the same with IN_CITY parameter
--  191105  Vashlk  Bug 150833, Performance improvement for Vertex. Added new overloaded method Fetch_Jurisdiction_Code
--  200702  NiDalk  SCXTEND-4444, Added new method Set_Tax_From_External_System and data types ext_tax_param_in_arr and ext_tax_param_out_arr.
--  200819  Jadulk  FISPRING20-6770, Temporary solution added to solve deploy issues.
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------
   
TYPE ext_tax_param_in_rec IS RECORD (
   company                     VARCHAR2(20), 
   contract                    VARCHAR2(5), 
   identity                    VARCHAR2(20),
   identity_taxable            VARCHAR2(5),       
   customer_group              VARCHAR2(10),    
   object_id                   VARCHAR2(25), 
   object_group                VARCHAR2(25),   
   object_taxable              VARCHAR2(5),     
   invoice_no                  VARCHAR2(50),
   invoice_date                DATE, 
   taxable_amount              NUMBER,   
   quantity                    NUMBER, 
   cust_del_address1           VARCHAR2(35),
   cust_del_address2           VARCHAR2(35),   
   cust_del_zip_code           VARCHAR2(35),   
   cust_del_city               VARCHAR2(35), 
   cust_del_state              VARCHAR2(35),   
   cust_del_county             VARCHAR2(35),   
   cust_del_country            VARCHAR2(20),
   cust_del_addr_in_city       VARCHAR2(5),      
   comp_del_address1           VARCHAR2(35),
   comp_del_address2           VARCHAR2(35),   
   comp_del_zip_code           VARCHAR2(35),   
   comp_del_city               VARCHAR2(35), 
   comp_del_state              VARCHAR2(35),   
   comp_del_county             VARCHAR2(35),   
   comp_del_country            VARCHAR2(20),
   comp_del_addr_in_city       VARCHAR2(5),      
   comp_doc_address1           VARCHAR2(35),
   comp_doc_address2           VARCHAR2(35),   
   comp_doc_zip_code           VARCHAR2(35),   
   comp_doc_city               VARCHAR2(35), 
   comp_doc_state              VARCHAR2(35),   
   comp_doc_county             VARCHAR2(35),   
   comp_doc_country            VARCHAR2(20),
   comp_doc_addr_in_city       VARCHAR2(5),      
   write_to_ext_tax_register   VARCHAR2(5),
   invoice_id                  NUMBER,
   cust_usage_type             VARCHAR2(5),
   object_desc                 VARCHAR2(200),
   item_id                     NUMBER,
   counter                     NUMBER,
   invoice_type                VARCHAR2(20),
   avalara_tax_code            VARCHAR2(20),
   number_ref                  VARCHAR2(50),
   series_ref                  VARCHAR2(20),
   org_invoice_date            DATE,
   corr_credit_invoice         BOOLEAN);
   
TYPE ext_tax_param_out_rec IS RECORD (
   city_tax_amount             NUMBER,
   state_tax_amount            NUMBER, 
   county_tax_amount           NUMBER,
   district_tax_amount         NUMBER,
   city_tax_percentage         NUMBER,   
   state_tax_percentage        NUMBER,
   county_tax_percentage       NUMBER,
   district_tax_percentage     NUMBER);
   
TYPE postal_address_rec IS RECORD ( 
   address1                       customer_info_address_tab.address1%TYPE,
   address2                       customer_info_address_tab.address2%TYPE,
   zip_code                       customer_info_address_tab.zip_code%TYPE,
   city                           customer_info_address_tab.city%TYPE,
   state                          customer_info_address_tab.state%TYPE,   
   county                         customer_info_address_tab.county%TYPE,
   country                        customer_info_address_tab.country%TYPE,
   jurisdiction_code              customer_info_address_tab.jurisdiction_code%TYPE,
   address_id                     customer_info_address_tab.address_id%TYPE);
   
TYPE postal_address_arr IS TABLE OF postal_address_rec INDEX BY BINARY_INTEGER;   

TYPE addresses_info_arr IS TABLE OF VARCHAR2(20)  INDEX BY VARCHAR2(32000);

@ApproveGlobalVariable
addresses_info_   addresses_info_arr;

TYPE ext_tax_param_in_arr IS TABLE OF ext_tax_param_in_rec INDEX BY BINARY_INTEGER;

TYPE ext_tax_param_out_arr IS TABLE OF ext_tax_param_out_rec INDEX BY BINARY_INTEGER;

-------------------- PRIVATE DECLARATIONS -----------------------------------

-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------

FUNCTION Check_Required_Fields___ (
   zip_code_          IN  VARCHAR2,
   city_              IN  VARCHAR2,
   state_             IN  VARCHAR2,
   county_            IN  VARCHAR2,
   country_           IN  VARCHAR2 ) RETURN BOOLEAN    
IS 
   req_field_           VARCHAR2(50):= ''; 
BEGIN
   IF (zip_code_ IS NULL) THEN
      req_field_ := req_field_||', '||'Zip Code';
   END IF;   
   IF (city_ IS NULL) THEN
      req_field_ := req_field_||', '||'City';
   END IF;
   IF (state_ IS NULL) THEN
      req_field_ := req_field_||', '||'State';
   END IF;
   IF (country_ != 'CA') THEN
      IF (county_ IS NULL) THEN
         req_field_ := req_field_||', '||'County';
      END IF;   
   END IF;
   IF (req_field_ IS NULL) THEN
      RETURN TRUE;
   ELSE
      RETURN FALSE;
   END IF;      
END Check_Required_Fields___;


PROCEDURE Validate_Default_Tax_Codes___ (
   cust_del_country_  IN VARCHAR2,
   tax_code_city_     IN VARCHAR2,
   tax_code_state_    IN VARCHAR2,
   tax_code_county_   IN VARCHAR2,
   tax_code_district_ IN VARCHAR2 ) 
IS  
BEGIN
   IF (cust_del_country_ = 'CA') THEN
      -- Country CA operates with 2 tax codes. These 2 tax codes are mapped to the State and the County tax code fields 
      IF (tax_code_state_ IS NULL OR tax_code_county_ IS NULL) THEN
         Error_Sys.Record_General(lu_name_, 'NULLTAXCODES: One or more of the generic tax codes for the external tax system is missing. Please check the generic tax codes in Company/Tax Control/External Tax System.');            
      END IF;
   ELSE
      IF (tax_code_city_ IS NULL OR tax_code_state_ IS NULL OR tax_code_county_ IS NULL OR tax_code_district_ IS NULL) THEN
         Error_Sys.Record_General(lu_name_, 'NULLTAXCODES: One or more of the generic tax codes for the external tax system is missing. Please check the generic tax codes in Company/Tax Control/External Tax System.');            
      END IF;
   END IF;   
END Validate_Default_Tax_Codes___;


FUNCTION Set_Tax_Information___ (
   ext_tax_param_out_rec_     IN   ext_tax_param_out_rec,
   ext_tax_param_in_rec_      IN   ext_tax_param_in_rec,
   external_tax_cal_method_   IN   VARCHAR2,
   tax_code_city_             IN   VARCHAR2,
   tax_code_state_            IN   VARCHAR2,
   tax_code_county_           IN   VARCHAR2,
   tax_code_district_         IN   VARCHAR2 ) RETURN Tax_Handling_Util_API.tax_information_table
IS
   tax_item_tab_            Tax_Handling_Util_API.tax_information_table;
   tax_percentage_          NUMBER;   
   index_                   NUMBER := 0;
   city_tax_amount_         NUMBER := 0;
BEGIN
   city_tax_amount_ := ext_tax_param_out_rec_.city_tax_amount;
   IF (tax_code_state_ IS NOT NULL) THEN
      IF (ext_tax_param_out_rec_.state_tax_amount = 0) THEN
         tax_percentage_ := 0;
      ELSE
         tax_percentage_ := ext_tax_param_out_rec_.state_tax_percentage * 100;
      END IF;
      index_ := index_ + 1;
      tax_item_tab_(index_).tax_code        := tax_code_state_;
      tax_item_tab_(index_).tax_curr_amount := ext_tax_param_out_rec_.state_tax_amount;
      tax_item_tab_(index_).tax_percentage  := tax_percentage_;
   END IF;
   IF (tax_code_county_ IS NOT NULL) THEN
      IF (ext_tax_param_out_rec_.county_tax_amount = 0) THEN
         tax_percentage_ := 0;
      ELSE
         tax_percentage_ := ext_tax_param_out_rec_.county_tax_percentage * 100;
      END IF;
      index_ := index_ + 1;
      tax_item_tab_(index_).tax_code        := tax_code_county_;
      tax_item_tab_(index_).tax_curr_amount := ext_tax_param_out_rec_.county_tax_amount;
      tax_item_tab_(index_).tax_percentage  := tax_percentage_;
   END IF;
   IF (tax_code_city_ IS NOT NULL) THEN
      IF (external_tax_cal_method_ = 'VERTEX_SALES_TAX_Q_SERIES') THEN
         IF (ext_tax_param_in_rec_.cust_del_addr_in_city = 'TRUE') THEN
            IF (city_tax_amount_ = 0) THEN
               tax_percentage_ := 0;
            ELSE
               tax_percentage_ := ext_tax_param_out_rec_.city_tax_percentage * 100;
            END IF;
         ELSE
            city_tax_amount_ := 0;
            tax_percentage_ := 0;
         END IF;
      ELSIF (external_tax_cal_method_ = 'VERTEX_SALES_TAX_O_SERIES' OR external_tax_cal_method_ = 'AVALARA_SALES_TAX') THEN 
         IF (city_tax_amount_ = 0) THEN
            tax_percentage_ := 0;
         ELSE
            tax_percentage_ := ext_tax_param_out_rec_.city_tax_percentage * 100;
         END IF;
      END IF;
      index_ := index_ + 1;
      tax_item_tab_(index_).tax_code        := tax_code_city_;
      tax_item_tab_(index_).tax_curr_amount := city_tax_amount_;
      tax_item_tab_(index_).tax_percentage  := tax_percentage_;
   END IF;
   IF (tax_code_district_ IS NOT NULL) THEN
      IF (ext_tax_param_out_rec_.district_tax_amount = 0) THEN
        tax_percentage_ := 0;
      ELSE
         tax_percentage_ := ext_tax_param_out_rec_.district_tax_percentage * 100;
      END IF;
      index_ := index_ + 1;
      tax_item_tab_(index_).tax_code        := tax_code_district_;
      tax_item_tab_(index_).tax_curr_amount := ext_tax_param_out_rec_.district_tax_amount;
      tax_item_tab_(index_).tax_percentage  := tax_percentage_;
   END IF;
   RETURN tax_item_tab_;
END Set_Tax_Information___;

-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------

-------------------- LU SPECIFIC PROTECTED METHODS --------------------------

-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

PROCEDURE Fetch_Jurisdiction_Code (
   postal_addresses_ IN OUT External_Tax_System_Util_API.postal_address_arr,
   company_          IN     VARCHAR2,
   context_          IN     VARCHAR2 )
IS
   external_tax_cal_method_   VARCHAR2(50); 
   req_field_ok_              BOOLEAN;
BEGIN  
   external_tax_cal_method_ := Company_Tax_Control_API.Get_External_Tax_Cal_Method_Db(company_);
   req_field_ok_ := Check_Required_Fields___(postal_addresses_(0).zip_code, postal_addresses_(0).city, postal_addresses_(0).state, postal_addresses_(0).county, postal_addresses_(0).country);
   IF (req_field_ok_) THEN
      IF (external_tax_cal_method_ = 'VERTEX_SALES_TAX_Q_SERIES') THEN      
         Vertex_Q_Series_Tax_Util_API.Fetch_Jurisdiction_Code(postal_addresses_, context_);   
      ELSIF (external_tax_cal_method_ = 'VERTEX_SALES_TAX_O_SERIES') THEN
         Vertex_O_Series_Tax_Util_API.Fetch_Jurisdiction_Code(postal_addresses_, context_);
      END IF;
   ELSE
      postal_addresses_(0).jurisdiction_code := NULL;      
   END IF;
END Fetch_Jurisdiction_Code;


PROCEDURE Handle_Address_Information (
   postal_addresses_ IN OUT External_Tax_System_Util_API.postal_address_arr,
   company_          IN     VARCHAR2,
   context_          IN     VARCHAR2 )
IS
   external_tax_cal_method_   VARCHAR2(50);
BEGIN  
   external_tax_cal_method_ := Company_Tax_Control_API.Get_External_Tax_Cal_Method_Db(company_);
   IF (external_tax_cal_method_ = 'AVALARA_SALES_TAX') THEN
      Avalara_Tax_Util_API.Validate_Address(postal_addresses_);
   ELSE
      Fetch_Jurisdiction_Code(postal_addresses_, company_, 'COMPANY_CUSTOMER', external_tax_cal_method_);
   END IF;
END Handle_Address_Information;


FUNCTION Fetch_Tax_From_External_System (
   ext_tax_param_in_rec_ IN ext_tax_param_in_rec,
   xml_trans_            IN CLOB ) RETURN Tax_Handling_Util_API.tax_information_table
IS
   tax_code_city_           VARCHAR2(20);
   tax_code_state_          VARCHAR2(20);   
   tax_code_county_         VARCHAR2(20);   
   tax_code_district_       VARCHAR2(20);  
   external_tax_cal_method_ VARCHAR2(50);  
   tax_item_tab_            Tax_Handling_Util_API.tax_information_table;
   ext_tax_param_out_rec_   ext_tax_param_out_rec;
BEGIN
   external_tax_cal_method_ := Company_Tax_Control_API.Get_External_Tax_Cal_Method_Db(ext_tax_param_in_rec_.company);                                        
   Company_Tax_Control_API.Get_Default_Tax_Codes(tax_code_city_, tax_code_state_, tax_code_county_, tax_code_district_, ext_tax_param_in_rec_.company);
   Validate_Default_Tax_Codes___(ext_tax_param_in_rec_.cust_del_country, tax_code_city_, tax_code_state_, tax_code_county_, tax_code_district_);    
   IF (external_tax_cal_method_ = 'VERTEX_SALES_TAX_Q_SERIES') THEN
      Vertex_Q_Series_Tax_Util_API.Fetch_And_Calculate_Tax(ext_tax_param_out_rec_, ext_tax_param_in_rec_);         
   ELSIF (external_tax_cal_method_ = 'VERTEX_SALES_TAX_O_SERIES') THEN
      Vertex_O_Series_Tax_Util_API.Fetch_And_Calculate_Tax(ext_tax_param_out_rec_, ext_tax_param_in_rec_);
   ELSIF (external_tax_cal_method_ = 'AVALARA_SALES_TAX') THEN
      IF (ext_tax_param_in_rec_.write_to_ext_tax_register = 'TRUE') AND (xml_trans_ IS NOT NULL) THEN
         Avalara_Tax_Util_API.Fetch_And_Calc_Tax_At_Print(ext_tax_param_out_rec_, ext_tax_param_in_rec_,xml_trans_);
         IF (ext_tax_param_out_rec_.state_tax_amount IS NULL) THEN
            tax_code_state_ := NULL;
         END IF;
         IF (ext_tax_param_out_rec_.city_tax_amount IS NULL) THEN
            tax_code_city_ := NULL;
         END IF;
         IF (ext_tax_param_out_rec_.county_tax_amount IS NULL) THEN
            tax_code_county_ := NULL;
         END IF;
         IF (ext_tax_param_out_rec_.district_tax_amount IS NULL) THEN
            tax_code_district_ := NULL;
         END IF;      
      ELSE
         Avalara_Tax_Util_API.Fetch_And_Calculate_Tax(ext_tax_param_out_rec_, ext_tax_param_in_rec_);   
      END IF;
   END IF;
   tax_item_tab_ := Set_Tax_Information___(ext_tax_param_out_rec_, ext_tax_param_in_rec_, external_tax_cal_method_, tax_code_city_, tax_code_state_, tax_code_county_, tax_code_district_);
   RETURN tax_item_tab_;
END Fetch_Tax_From_External_System;


PROCEDURE Fetch_Tax_From_External_System (
   tax_code_city_         OUT   VARCHAR2,
   tax_code_state_        OUT   VARCHAR2,   
   tax_code_county_       OUT   VARCHAR2,   
   tax_code_district_     OUT   VARCHAR2,
   ext_tax_param_out_arr_ OUT   ext_tax_param_out_arr,
   ext_tax_param_in_arr_  IN    ext_tax_param_in_arr,
   company_               IN    VARCHAR2 )
IS
   external_tax_cal_method_      VARCHAR2(50);
BEGIN
   external_tax_cal_method_ := Company_Tax_Control_API.Get_External_Tax_Cal_Method_Db(company_);
   Company_Tax_Control_API.Get_Default_Tax_Codes(tax_code_city_, tax_code_state_, tax_code_county_, tax_code_district_, company_);
   IF (external_tax_cal_method_ = 'AVALARA_SALES_TAX') THEN
      Avalara_Tax_Util_API.Fetch_And_Calculate_Tax(ext_tax_param_out_arr_, ext_tax_param_in_arr_);
   END IF; 
END Fetch_Tax_From_External_System;


FUNCTION Set_Tax_From_External_System (
   tax_code_city_             IN    VARCHAR2,
   tax_code_state_            IN    VARCHAR2,   
   tax_code_county_           IN    VARCHAR2,   
   tax_code_district_         IN    VARCHAR2,
   ext_tax_param_out_rec_     IN    ext_tax_param_out_rec,
   ext_tax_param_in_rec_      IN    ext_tax_param_in_rec,
   external_tax_cal_method_   IN    VARCHAR2 ) RETURN Tax_Handling_Util_API.tax_information_table
IS
   tax_item_tab_            Tax_Handling_Util_API.tax_information_table;
BEGIN
   Validate_Default_Tax_Codes___(ext_tax_param_in_rec_.cust_del_country, tax_code_city_, tax_code_state_, tax_code_county_, tax_code_district_); 
   tax_item_tab_ := Set_Tax_Information___(ext_tax_param_out_rec_, ext_tax_param_in_rec_, external_tax_cal_method_, tax_code_city_, tax_code_state_, tax_code_county_, tax_code_district_);
   RETURN tax_item_tab_;                                          
END Set_Tax_From_External_System;


PROCEDURE Fetch_Jurisdiction_Code (
   postal_addresses_          IN OUT External_Tax_System_Util_API.postal_address_arr,
   company_                   IN     VARCHAR2,
   context_                   IN     VARCHAR2,
   external_tax_cal_method_   IN     VARCHAR2 )
IS
   address_index_                VARCHAR2(32000) := NULL;
   in_address_count_             NUMBER;
   out_address_count_            NUMBER;
   address_not_exist_            BOOLEAN;
BEGIN  
   in_address_count_ := postal_addresses_.FIRST;
   WHILE in_address_count_ IS NOT NULL LOOP
      address_index_   := postal_addresses_(in_address_count_).address1||'^'||postal_addresses_(in_address_count_).address2||'^'||postal_addresses_(in_address_count_).city||'^'||postal_addresses_(in_address_count_).state||'^'||postal_addresses_(in_address_count_).zip_code||'^'||postal_addresses_(in_address_count_).county||'^'||postal_addresses_(in_address_count_).country;
      IF (addresses_info_.EXISTS(address_index_)) THEN
         postal_addresses_(in_address_count_).jurisdiction_code := addresses_info_(address_index_);
      ELSE
         address_not_exist_ := TRUE;
         EXIT;
      END IF;
      in_address_count_ := postal_addresses_.NEXT(in_address_count_);
   END LOOP;
   IF (address_not_exist_) THEN
      IF (context_ = 'ORDER_CALCULATION') THEN
         IF (external_tax_cal_method_ = 'VERTEX_SALES_TAX_O_SERIES') THEN
            Vertex_O_Series_Tax_Util_API.Fetch_Jurisdiction_Code(postal_addresses_, 'ORDER_CALCULATION');
         ELSIF (external_tax_cal_method_ = 'VERTEX_SALES_TAX_Q_SERIES') THEN
            Vertex_Q_Series_Tax_Util_API.Fetch_Jurisdiction_Code(postal_addresses_, 'ORDER_CALCULATION');
         END IF;
      ELSIF (context_ = 'COMPANY_CUSTOMER') THEN
         Fetch_Jurisdiction_Code(postal_addresses_, company_, 'COMPANY_CUSTOMER'); 
      END IF;
      out_address_count_ := postal_addresses_.FIRST;
      WHILE out_address_count_ IS NOT NULL LOOP
         address_index_   := postal_addresses_(out_address_count_).address1||'^'||postal_addresses_(out_address_count_).address2||'^'||postal_addresses_(out_address_count_).city||'^'||postal_addresses_(out_address_count_).state||'^'||postal_addresses_(out_address_count_).zip_code||'^'||postal_addresses_(out_address_count_).county||'^'||postal_addresses_(out_address_count_).country;
         IF (postal_addresses_.EXISTS(out_address_count_)) THEN
            IF (NOT addresses_info_.EXISTS(address_index_)) THEN
               addresses_info_(address_index_) := postal_addresses_(out_address_count_).jurisdiction_code;
            END IF;
         END IF;
         out_address_count_ := postal_addresses_.NEXT(out_address_count_);
      END LOOP;
   END IF;
END Fetch_Jurisdiction_Code;

-------------------- LU  NEW METHODS -------------------------------------
