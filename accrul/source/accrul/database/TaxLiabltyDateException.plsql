-----------------------------------------------------------------------------
--
--  Logical unit: TaxLiabltyDateException
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  060908  Hawalk  FIPL602A, Created. This LU is related to tax code specific tax liability date controls.
--  060914  Maaylk  FIPL602A, Added methods 'Is_Cust_Crdt_Liab_Date_Manual', 'Is_Cust_Liab_Date_Manual'
--  060922  Paralk  FIPL602A, Add new method Taxcode_Not_In_Exception
--  061003  ThWilk  FIPL602A, Add new method Is_Sup_Liab_Date_Manual
--  061103  ThWilk  FIPL602A, Added new method Man_Sup_Invoice_Line_Checks
--  061113  Maaylk  FIPL602A, Added  Is_Cust_Any_Liab_Date_Manual()
--  061117  Paralk  B139949,  Add new PROCEDURE Remove_Exception_Tax_Codes().
--  061123  Hawalk  FIPL602A, Added VIEWPCT and Make_Company(), Export___(), Copy___() and Import___(), used for company
--  061123          creation purposes.
--  070530  Kagalk  B144936, Modified Import___() to check the validity of tax codes.
--  090123  Jeguse  Bug 80023, Modified in Import___
--  090605  THPELK  Bug 82609 - Added UNDEFINE section and the missing statements for VIEWPCT. 
--  110712  Sacalk  FIDEAGLE-296, Merged LCS Bug 94970, Change the method call to get fee type method. Call to a method to Get FeeType which does not 
--                  use for any validations.
--  120514  SALIDE  EDEL-698, Added VIEW_AUDIT
--  130819  Clstlk  Bug 111221, Corrected functions without RETURN statement in all code paths
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------

@Override
PROCEDURE Check_Insert___ (
   newrec_ IN OUT tax_liablty_date_exception_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
   name_     VARCHAR2(30);
   value_    VARCHAR2(4000);
   fee_type_ statutory_fee_tab.fee_type%TYPE;
   company_flag_             BOOLEAN := FALSE;
   fee_code_flag_            BOOLEAN := FALSE;
   cus_crdt_date_flag_       BOOLEAN := FALSE;
   cus_crdt_date_db_flag_    BOOLEAN := FALSE;
   cus_liab_date_flag_       BOOLEAN := FALSE;
   cus_liab_date_db_flag_    BOOLEAN := FALSE;
   sup_liab_date_flag_       BOOLEAN := FALSE;
   sup_liab_date_db_flag_    BOOLEAN := FALSE;
BEGIN
   company_flag_          := Client_SYS.Item_Exist('COMPANY',attr_);
   fee_code_flag_         := Client_SYS.Item_Exist('FEE_CODE',attr_);
   cus_crdt_date_flag_    := Client_SYS.Item_Exist('CUSTOMER_CRDT_LIABLTY_DATE',attr_);
   cus_crdt_date_db_flag_ := Client_SYS.Item_Exist('CUSTOMER_CRDT_LIABLTY_DATE_DB',attr_);
   cus_liab_date_flag_    := Client_SYS.Item_Exist('CUSTOMER_LIABILITY_DATE',attr_);
   cus_liab_date_db_flag_ := Client_SYS.Item_Exist('CUSTOMER_LIABILITY_DATE_DB',attr_);
   sup_liab_date_flag_    := Client_SYS.Item_Exist('SUPPLIER_LIABILITY_DATE',attr_);
   sup_liab_date_db_flag_ := Client_SYS.Item_Exist('SUPPLIER_LIABILITY_DATE_DB',attr_);
   
   newrec_.customer_credit_liability_date := NVL(newrec_.customer_credit_liability_date, 'VOUCHERDATE');  
   newrec_.customer_liability_date        := NVL(newrec_.customer_liability_date, 'VOUCHERDATE');
   newrec_.supplier_liability_date        := NVL(newrec_.supplier_liability_date, 'VOUCHERDATE');
   super(newrec_, indrec_, attr_);
   
   IF NOT company_flag_ THEN
      Company_Finance_API.Exist(newrec_.company);
   END IF;
   IF NOT fee_code_flag_ THEN
      Statutory_Fee_API.Exist(newrec_.company, newrec_.fee_code);
   END IF;
   
   fee_type_ := Statutory_Fee_API.Get_Fee_Type_Db(newrec_.company, newrec_.fee_code);
   IF (fee_type_ IN (Fee_Type_API.DB_TAX_WITHHOLD, Fee_Type_API.DB_NO_TAX)) THEN
      Error_SYS.Record_General(lu_name_,
                               'WRNGTXCDETYPE: Tax codes of type :P1 not allowed here.', CHR(39) || Fee_Type_API.Decode(fee_type_) || CHR(39));
   END IF;
   
   IF NOT cus_crdt_date_flag_ AND newrec_.customer_credit_liability_date IS NOT NULL THEN
      Tax_Liability_Date_API.Exist_Db(newrec_.customer_credit_liability_date);
   END IF;
   IF NOT cus_crdt_date_db_flag_ AND newrec_.customer_credit_liability_date IS NOT NULL  THEN
      Tax_Liability_Date_API.Exist_Db(newrec_.customer_credit_liability_date);
   END IF;
   
   IF NOT cus_liab_date_flag_ AND newrec_.customer_liability_date IS NOT NULL THEN
      Tax_Liability_Date_API.Exist_Db(newrec_.customer_liability_date);
   END IF;
   IF NOT cus_liab_date_db_flag_ AND newrec_.customer_liability_date IS NOT NULL THEN
      Tax_Liability_Date_API.Exist_Db(newrec_.customer_liability_date);
   END IF;
   
   IF NOT sup_liab_date_flag_ AND newrec_.supplier_liability_date IS NOT NULL THEN
      Tax_Liability_Date_API.Exist_Db(newrec_.supplier_liability_date);
   END IF;
   IF NOT sup_liab_date_db_flag_ AND newrec_.supplier_liability_date IS NOT NULL THEN
      Tax_Liability_Date_API.Exist_Db(newrec_.supplier_liability_date);
   END IF;
      
EXCEPTION
   WHEN value_error THEN
      Error_SYS.Item_Format(lu_name_, name_, value_);
END Check_Insert___;


-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------

-------------------- LU SPECIFIC PROTECTED METHODS --------------------------

-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

@UncheckedAccess
FUNCTION Is_Cust_Any_Liab_Date_Manual (
   company_ IN VARCHAR2,
   vat_code_ IN VARCHAR2,
   multi_tax_exists_ IN VARCHAR2 DEFAULT 'FALSE',
   tax_line_info_msg_ IN VARCHAR2 DEFAULT NULL ) RETURN VARCHAR2
IS
   m_s_names_       Message_SYS.name_table;
   m_s_values_      Message_SYS.line_table;
   count_         NUMBER;
BEGIN
   IF ( multi_tax_exists_ = 'TRUE')  THEN
      Message_SYS.Get_Attributes(tax_line_info_msg_, count_, m_s_names_, m_s_values_);
      FOR dummy_ IN 1..count_  LOOP
         IF (m_s_names_(dummy_) = 'TAX_CODE') THEN
            IF (Get_Customer_Liability_Date_Db(company_,m_s_values_(dummy_)) = 'MANUAL' OR
                Get_Customer_Crdt_Liablty_D_Db(company_,m_s_values_(dummy_)) = 'MANUAL') THEN
               RETURN 'TRUE';
            END IF;
         END IF;
      END LOOP;
   ELSE
      IF (Get_Customer_Liability_Date_Db(company_,vat_code_) = 'MANUAL' OR
          Get_Customer_Crdt_Liablty_D_Db(company_,vat_code_) = 'MANUAL') THEN
         RETURN 'TRUE';
      END IF;
   END IF;

   RETURN 'FALSE';
END Is_Cust_Any_Liab_Date_Manual;




@UncheckedAccess
FUNCTION Is_Cust_Liab_Date_Manual (
   company_            IN VARCHAR2,
   vat_code_           IN VARCHAR2,
   multi_tax_exists_   IN VARCHAR2 DEFAULT 'FALSE',
   tax_line_info_msg_  IN VARCHAR2 DEFAULT NULL ) RETURN VARCHAR2
IS
   m_s_names_       Message_SYS.name_table;
   m_s_values_      Message_SYS.line_table;
   count_         NUMBER;
BEGIN
   IF ( multi_tax_exists_ = 'TRUE')  THEN
      Message_SYS.Get_Attributes(tax_line_info_msg_, count_, m_s_names_, m_s_values_);
      FOR dummy_ IN 1..count_  LOOP
         IF (m_s_names_(dummy_) = 'TAX_CODE') THEN
            IF ( Get_Customer_Liability_Date_Db(company_,m_s_values_(dummy_)) = 'MANUAL' ) THEN
               RETURN 'TRUE';
            END IF;
         END IF;
      END LOOP;
   ELSE
      IF (Get_Customer_Liability_Date_Db(company_,vat_code_) = 'MANUAL' ) THEN
         RETURN 'TRUE';
      END IF;
   END IF;

   RETURN 'FALSE';
END Is_Cust_Liab_Date_Manual;




@UncheckedAccess
FUNCTION Is_Cust_Crdt_Liab_Date_Manual (
   company_            IN VARCHAR2,
   vat_code_           IN VARCHAR2,
   multi_tax_exists_   IN VARCHAR2 DEFAULT 'FALSE',
   tax_line_info_msg_  IN VARCHAR2 DEFAULT NULL ) RETURN VARCHAR2
IS
   m_s_names_       Message_SYS.name_table;
   m_s_values_      Message_SYS.line_table;
   count_         NUMBER;
BEGIN
   IF ( multi_tax_exists_ = 'TRUE')  THEN
      Message_SYS.Get_Attributes(tax_line_info_msg_, count_, m_s_names_, m_s_values_);
      FOR dummy_ IN 1..count_  LOOP
         IF (m_s_names_(dummy_) = 'TAX_CODE') THEN
            IF ( Get_Customer_Crdt_Liablty_D_Db(company_,m_s_values_(dummy_)) = 'MANUAL') THEN
               RETURN 'TRUE';
            END IF;
         END IF;
      END LOOP;
   ELSE
      IF (Get_Customer_Crdt_Liablty_D_Db(company_,vat_code_) = 'MANUAL') THEN
         RETURN 'TRUE';
      END IF;
   END IF;

   RETURN 'FALSE';
END Is_Cust_Crdt_Liab_Date_Manual;




@UncheckedAccess
FUNCTION Taxcode_Not_In_Exception(
   company_         IN VARCHAR2,
   vat_code_        IN VARCHAR2 ) RETURN BOOLEAN
IS

BEGIN

   IF Check_Exist___(company_ , vat_code_) THEN
      RETURN(FALSE);
   ELSE
      RETURN(TRUE);
   END IF;

END Taxcode_Not_In_Exception;




@UncheckedAccess
FUNCTION Is_Sup_Liab_Date_Manual (
   company_           IN VARCHAR2,
   vat_code_          IN VARCHAR2,
   multi_tax_exists_  IN VARCHAR2 DEFAULT 'FALSE',
   tax_line_info_msg_ IN VARCHAR2 DEFAULT NULL ) RETURN VARCHAR2
IS
   m_s_names_       Message_SYS.name_table;
   m_s_values_      Message_SYS.line_table;
   count_         NUMBER;
BEGIN
   IF ( multi_tax_exists_ = 'TRUE')  THEN
      Message_SYS.Get_Attributes(tax_line_info_msg_, count_, m_s_names_, m_s_values_);
      FOR dummy_ IN 1..count_  LOOP
         IF (m_s_names_(dummy_) = 'TAX_CODE') THEN
            IF (Get_Supplier_Liability_Date_Db(company_,m_s_values_(dummy_)) = 'MANUAL') THEN
               RETURN 'TRUE';
            END IF;
         END IF;
      END LOOP;
   ELSE
      IF (Get_Supplier_Liability_Date_Db(company_,vat_code_) = 'MANUAL') THEN
         RETURN 'TRUE';
      END IF;
   END IF;
   RETURN 'FALSE';
END Is_Sup_Liab_Date_Manual;




@UncheckedAccess
FUNCTION Man_Sup_Invoice_Line_Checks (
   company_           IN VARCHAR2,
   vat_code_          IN VARCHAR2,
   current_state_     IN VARCHAR2,
   multi_tax_exists_  IN VARCHAR2 DEFAULT 'FALSE',
   tax_line_info_msg_ IN VARCHAR2 DEFAULT NULL ) RETURN VARCHAR2
IS
   m_s_names_        Message_SYS.name_table;
   m_s_values_       Message_SYS.line_table;
   count_            NUMBER;
   multi_vat_code_   VARCHAR2(200);
   tax_received_db_  VARCHAR2(20);
BEGIN
   IF ( multi_tax_exists_ = 'TRUE')  THEN
      Message_SYS.Get_Attributes(tax_line_info_msg_, count_, m_s_names_, m_s_values_);
      FOR dummy_ IN 1..count_  LOOP
         IF (m_s_names_(dummy_) = 'TAX_CODE') THEN
            multi_vat_code_  := m_s_values_(dummy_);
            tax_received_db_ := Statutory_Fee_API.Get_Vat_Received_Db(company_, multi_vat_code_);
            IF (( tax_received_db_ != '2') AND
               (Get_Supplier_Liability_Date_Db(company_,multi_vat_code_) = 'MANUAL') AND
               (current_state_ is NULL OR current_state_='Preliminary')) THEN
                  RETURN 'TRUE';
            ELSIF ((tax_received_db_ = '2') AND
                  (Get_Supplier_Liability_Date_Db(company_,multi_vat_code_) = 'MANUAL') AND
                  ((current_state_ is NULL) OR  current_state_ IN ('Preliminary','PrelPosted','PrelPostedAuth','PartlyPaidPrelPosted','PaidPrelPosted')))THEN
                     RETURN 'TRUE';
            END IF;             
         END IF;
      END LOOP;
   ELSE
      IF (Statutory_Fee_API.Get_Vat_Received_Db(company_,vat_code_) != '2' AND
         (Get_Supplier_Liability_Date_Db(company_,vat_code_) = 'MANUAL') AND
         (current_state_ is NULL OR current_state_='Preliminary'))THEN
            RETURN 'TRUE';
      ELSIF (Statutory_Fee_API.Get_Vat_Received_Db(company_,vat_code_) = '2' AND
            (Get_Supplier_Liability_Date_Db(company_,vat_code_) = 'MANUAL') AND
            ((current_state_ is NULL) OR  current_state_ IN ('Preliminary','PrelPosted','PrelPostedAuth','PartlyPaidPrelPosted','PaidPrelPosted')))THEN
               RETURN 'TRUE';
      END IF;
   END IF;
   RETURN 'FALSE';
END Man_Sup_Invoice_Line_Checks;




PROCEDURE Remove_Exception_Tax_Codes (
   info_     OUT VARCHAR2,
   company_  IN VARCHAR2,
   fee_code_ IN VARCHAR2 )
IS
   temp_objid_      tax_liablty_date_exception.objid%TYPE;
   temp_objversion_ tax_liablty_date_exception.objversion%TYPE;
BEGIN
   IF Check_Exist___(company_,fee_code_) THEN

       Get_Id_Version_By_Keys___ (temp_objid_,
                               temp_objversion_,
                               company_,
                               fee_code_);
       Remove__(info_ ,
                temp_objid_ ,
                temp_objversion_ ,
                'DO');
    END IF;
END Remove_Exception_Tax_Codes;

