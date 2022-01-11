-----------------------------------------------------------------------------
--
--  Logical unit: SaftReportingUtil
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  180110  Chwtlk  Created.
--  191212  Chwtlk  Bug 150764, Corrected.
--  210203  Nudilk  FISPRING20-9294, Merged Bug 157869, Corrected in Add_Analysis_Type_Info___.
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------

-------------------- PRIVATE DECLARATIONS -----------------------------------
saft_date_format_                    CONSTANT VARCHAR2(10)  := Saft_Reporting_Enterp_Util_API.saft_date_format_;
-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------
PROCEDURE Add_Header_Info___(
   row_no_        IN OUT NUMBER,
   load_file_id_  IN     NUMBER,
   company_       IN     VARCHAR2,
   country_       IN     VARCHAR2,
   report_type_   IN     VARCHAR2,
   report_id_     IN     NUMBER)
IS
BEGIN
   -- Add Header information.
   Add_Header_Main___(row_no_, load_file_id_, company_, country_, report_type_);
   -- Add Header information related to the company
   Saft_Reporting_Enterp_Util_API.Add_Header_Company(row_no_, load_file_id_, company_, country_, report_type_);
   -- Add company Addresses
   Saft_Reporting_Enterp_Util_API.Add_Company_Addresses(row_no_, load_file_id_, company_, country_, report_type_);
   -- Add Company Contact details.
   Add_Company_Contacts___(row_no_, load_file_id_, company_, country_, report_type_);
   $IF Component_Invoic_SYS.INSTALLED $THEN
      -- Add company tax registration information
      Saft_Reporting_Invoic_Util_API.Add_Company_Tax_Reg(row_no_, load_file_id_, company_, country_, report_type_);
   $END
   $IF Component_Payled_SYS.INSTALLED $THEN
      -- Add company bank information
      Saft_Reporting_Payled_Util_API.Add_Company_Bank_Info(row_no_, load_file_id_, company_, country_, report_type_);   
   $END
   -- Add selection criteria of the report
   Add_Selection_Criteria_Info___(row_no_, load_file_id_, company_, country_, report_type_, report_id_);
END Add_Header_Info___;

PROCEDURE Add_Master_Files_Info___(
   row_no_        IN OUT NUMBER,
   load_file_id_  IN     NUMBER,
   company_       IN     VARCHAR2,
   country_       IN     VARCHAR2,
   report_type_   IN     VARCHAR2,
   from_date_     IN     DATE,
   to_date_       IN     DATE)
IS
BEGIN
   Initialize_Master_Files_Info___(row_no_, load_file_id_);
   -- Add_Master_Info Gl Accounts      
   $IF Component_Genled_SYS.INSTALLED $THEN
      -- Add_Master_Info Gl Accounts      
      Saft_Reporting_Genled_Util_API.Add_Master_Info_Gl_Accounts(row_no_, load_file_id_, company_, from_date_, to_date_, country_, report_type_);
   $END
   $IF Component_Payled_SYS.INSTALLED $THEN
      -- Add_Master Customer_Info 
      Saft_Reporting_Payled_Util_API.Add_Customer_Headers(row_no_, load_file_id_, company_, from_date_, to_date_, country_);
      -- Add Supplier Information
      Saft_Reporting_Payled_Util_API.Add_Supplier_Headers(row_no_, load_file_id_, company_, from_date_, to_date_, country_);
   $END
   -- Add Tax Code Information
   Add_Tax_Info___(row_no_, load_file_id_, company_, country_, report_type_);
   -- Add Analysis type Details
   Add_Analysis_Type_Info___(row_no_, load_file_id_, company_);
END Add_Master_Files_Info___;


-- Insert SAF-T report related header information to the Ext_File_Trans_Tab.
PROCEDURE Add_Header_Main___(
   row_no_       IN OUT NUMBER,
   load_file_id_ IN     NUMBER,
   company_      IN     VARCHAR2,
   country_      IN     VARCHAR2,
   report_type_  IN     VARCHAR2)
IS
   country_db_        VARCHAR2(5)  := Iso_Country_API.Encode(country_);
   report_type_db_    VARCHAR2(10) := Audit_Report_Types_API.Encode(report_type_);
   newrec_            Ext_File_Trans_Tab%ROWTYPE;
   rec_saft_header_   Audit_Basic_Data_Master_API.Public_Rec;
BEGIN
   rec_saft_header_ := Audit_Basic_Data_Master_API.Get(company_,
                                                       country_db_,
                                                       report_type_db_);
      
   row_no_ := row_no_ + 1;
   newrec_.load_file_id      := load_file_id_;
   newrec_.row_no            := row_no_;
   newrec_.record_type_id    := '1';

   newrec_.c1  := company_;
   newrec_.c2  := rec_saft_header_.country;
   newrec_.c3  := rec_saft_header_.audit_file_version;
   newrec_.c4  := rec_saft_header_.audit_file_region;
   newrec_.c5  := TO_CHAR(sysdate, saft_date_format_);
   newrec_.c6  := rec_saft_header_.software_company_name;
   newrec_.c7  := rec_saft_header_.software_i_d;
   newrec_.c8  := rec_saft_header_.software_version;
   newrec_.c9  := Company_Finance_API.Get_Currency_Code(company_);
   newrec_.c10 := rec_saft_header_.header_comment;
   newrec_.c11 := rec_saft_header_.tax_accounting_basis;
   newrec_.c12 := rec_saft_header_.tax_entity;
   newrec_.c13 := Fnd_Session_API.Get_Fnd_User;
   IF (rec_saft_header_.reporting_currency = 'ACCOUNTINGCURRENCY') THEN
      newrec_.c14 := '0';
   ELSE
      newrec_.c14 := '1';
   END IF;   
   newrec_.c15 := rec_saft_header_.include_source_doc;
   newrec_.row_state  := '1';
   newrec_.rowversion := sysdate;
   Ext_File_Trans_API.Insert_Record ( newrec_ );
END Add_Header_Main___;


-- Insert Company contact information which is defined in the Audit File Basic Data to the Ext_File_Trans_Tab.
PROCEDURE Add_Company_Contacts___(
   row_no_       IN OUT NUMBER,
   load_file_id_ IN     NUMBER,
   company_      IN     VARCHAR2,
   country_      IN     VARCHAR2,
   report_type_  IN     VARCHAR2)
IS
   newrec_           Ext_File_Trans_Tab%ROWTYPE;
   emptyrec_         Ext_File_Trans_Tab%ROWTYPE;
   country_db_       VARCHAR2(5)  := Iso_Country_API.Encode(country_);
   report_type_db_   VARCHAR2(10) := Audit_Report_Types_API.Encode(report_type_);
   
   CURSOR saft_company_contact IS
      SELECT acp.company     company,
             acp.person_id   contact_person,
             pi.title        title,
             pi.first_name   first_name,
             pi.initials     initials,
             pi.prefix       last_name_prefix,
             pi.last_name    last_name,
             pi.birth_name   birth_name
      FROM   audit_contact_person_tab acp, person_info pi
      WHERE  acp.person_id = pi.person_id
      AND    acp.country   = country_db_
      AND    report_type   = report_type_db_
      AND    company       = company_;  
BEGIN
   FOR saft_company_contact_rec_ IN saft_company_contact LOOP
      newrec_ := emptyrec_;
      row_no_ := row_no_ + 1;
      newrec_.load_file_id      := load_file_id_;
      newrec_.row_no            := row_no_;
      newrec_.record_type_id    := '1.1.2';

      newrec_.c1  := saft_company_contact_rec_.company;
      newrec_.c2  := saft_company_contact_rec_.contact_person;
      newrec_.c3  := Comm_Method_API.Get_Default_Value('PERSON', newrec_.c2, 'PHONE');
      newrec_.c4  := Comm_Method_API.Get_Default_Value('PERSON', newrec_.c2, 'FAX');
      newrec_.c5  := Comm_Method_API.Get_Default_Value('PERSON', newrec_.c2, 'E_MAIL');
      newrec_.c6  := Comm_Method_API.Get_Default_Value('PERSON', newrec_.c2, 'WWW');
      newrec_.c7  := Comm_Method_API.Get_Default_Value('PERSON', newrec_.c2, 'MOBILE');
      newrec_.c9  := saft_company_contact_rec_.first_name;
      newrec_.c10 := saft_company_contact_rec_.initials;
      newrec_.c11 := saft_company_contact_rec_.last_name_prefix;
      newrec_.c12 := saft_company_contact_rec_.last_name;
      newrec_.c13 := saft_company_contact_rec_.birth_name;
      newrec_.c15 := saft_company_contact_rec_.title;
           
      newrec_.row_state   := '1';
      newrec_.rowversion  := sysdate;
      Ext_File_Trans_API.Insert_Record (newrec_);               
   END LOOP;
END Add_Company_Contacts___;

-- Insert selection criteria information to the Ext_File_Trans_Tab.
PROCEDURE Add_Selection_Criteria_Info___(
   row_no_       IN OUT NUMBER,
   load_file_id_ IN     NUMBER,
   company_      IN     VARCHAR2,
   country_      IN     VARCHAR2,
   report_type_  IN     VARCHAR2,
   report_id_    IN     NUMBER)
IS
   newrec_                       Ext_File_Trans_Tab%ROWTYPE;
   country_db_                   VARCHAR2(5)  := Iso_Country_API.Encode(country_);
   report_type_db_               VARCHAR2(10) := Audit_Report_Types_API.Encode(report_type_);
   rec_saft_selection_criteria_  Audit_Selection_Criteria_API.Public_Rec;
BEGIN
   row_no_ := row_no_ + 1;
   newrec_.load_file_id      := load_file_id_;
   newrec_.row_no            := row_no_;
   newrec_.record_type_id    := '1.2';   
   rec_saft_selection_criteria_ := Audit_Selection_Criteria_API.Get(company_,
                                                                       country_db_,
                                                                       report_type_db_,
                                                                       report_id_);      
   newrec_.c1 := company_;
   newrec_.c2 := rec_saft_selection_criteria_.company_entity;
   newrec_.c3 := rec_saft_selection_criteria_.document_type;
   newrec_.c4 := rec_saft_selection_criteria_.other_criteria;
   newrec_.c5 := rec_saft_selection_criteria_.tax_rep_jur;
   newrec_.c6 := TO_CHAR(rec_saft_selection_criteria_.selection_start_date, saft_date_format_);
   newrec_.c7 := TO_CHAR(rec_saft_selection_criteria_.selection_end_date, saft_date_format_);
   newrec_.n1 := rec_saft_selection_criteria_.period_start;
   newrec_.n2 := rec_saft_selection_criteria_.period_start_year;
   newrec_.n3 := rec_saft_selection_criteria_.period_end;
   newrec_.n4 := rec_saft_selection_criteria_.period_end_year;

   newrec_.row_state      := '1';
   newrec_.rowversion     := SYSDATE;
   Ext_File_Trans_API.Insert_Record (newrec_); 
END Add_Selection_Criteria_Info___;

-- Insert a break to separate the Master Files selection to the Ext_File_Trans_Tab.
PROCEDURE Initialize_Master_Files_Info___(
   row_no_        IN OUT NUMBER,
   load_file_id_  IN     NUMBER)
IS
   newrec_        Ext_File_Trans_Tab%ROWTYPE;
BEGIN
   row_no_ := row_no_ + 1;
   newrec_.load_file_id   := load_file_id_;
   newrec_.row_no         := row_no_;
   newrec_.record_type_id := '2';
   newrec_.row_state      := '1';
   newrec_.rowversion     := SYSDATE;
   Ext_File_Trans_API.Insert_Record ( newrec_ ); 
END Initialize_Master_Files_Info___;

/*
 Query all the accounts which has a Standard account ID defined in the accounting attributes and sends 
 those information to calculate the balance of that account for a given period.
*/
PROCEDURE Add_Master_Info_Gl_Accounts___(
   row_no_        IN OUT   NUMBER, 
   load_file_id_  IN       NUMBER,
   company_       IN       VARCHAR2,
   from_date_     IN       DATE,
   to_date_       IN       DATE,
   country_       IN       VARCHAR2,
   report_type_   IN       VARCHAR2)
IS
   accounting_year_from_   NUMBER;
   accounting_period_from_ NUMBER;
   accounting_year_to_     NUMBER;
   accounting_period_to_   NUMBER;
   is_debit_               BOOLEAN:= FALSE;
   newrec_                 Ext_File_Trans_Tab%ROWTYPE;
   emptyrec_               Ext_File_Trans_Tab%ROWTYPE;
   code_part_attr_         VARCHAR2(200);
   std_acc_id_             VARCHAR2(2000);
   
   CURSOR get_accounts IS
      SELECT company           company,
             code_part_value   account,
             accnt_group       account_group,
             accnt_type        account_type
      FROM   accounting_code_part_value_tab t
      WHERE  code_part = 'A'
      AND    company   = company_;
BEGIN
   Accounting_Period_API.Get_Accounting_Year(accounting_year_from_, accounting_period_from_, company_, from_date_);
   Accounting_Period_API.Get_Accounting_Year(accounting_year_to_, accounting_period_to_, company_, to_date_);
   
   code_part_attr_ := Audit_Basic_Data_Master_API.Get_Code_Part_Attr(company_,country_,report_type_);
   
   IF (accounting_period_from_ = 0) THEN
      accounting_period_from_ := 1;
   END IF;
   
   $IF Component_Genled_SYS.INSTALLED $THEN
      FOR rec_accounts IN get_accounts LOOP
         newrec_ := emptyrec_;   
         std_acc_id_ := Accounting_Attribute_Con_API.Get_Attribute_Value(company_, 'A', rec_accounts.account, code_part_attr_);
         IF (std_acc_id_ IS NOT NULL) THEN
            IF (rec_accounts.account_type IN ('ASSETS', 'COST')) THEN
              is_debit_:= TRUE;
            ELSE
              is_debit_:= FALSE;
            END IF;
            Saft_Reporting_Genled_Util_API.Add_Gl_Account_Balances(row_no_, 
                                                                  load_file_id_, 
                                                                  company_, 
                                                                  rec_accounts.account,
                                                                  std_acc_id_,
                                                                  accounting_year_from_, 
                                                                  accounting_period_from_, 
                                                                  accounting_year_to_, 
                                                                  accounting_period_to_, 
                                                                  is_debit_,
                                                                  'GL',
                                                                  NULL,
                                                                  rec_accounts.account_group, 
                                                                  SUBSTR(Account_Group_API.Get_Description(company_, rec_accounts.account_group), 0, 30));
         END IF;
      END LOOP;
   $END
END Add_Master_Info_Gl_Accounts___;

-- Insert tax code information to the Ext_File_Trans_Tab.
PROCEDURE Add_Tax_Info___(
   row_no_        IN OUT   NUMBER, 
   load_file_id_  IN       NUMBER,
   company_       IN       VARCHAR2,
   country_       IN       VARCHAR2,
   report_type_   IN       VARCHAR2)
IS
   newrec_            Ext_File_Trans_Tab%ROWTYPE;
   emptyrec_          Ext_File_Trans_Tab%ROWTYPE;
   standard_tax_code_ VARCHAR2(2000);
   
   CURSOR saft_company_tax_info IS 
      SELECT  company           company,
              UPPER(fee_type)   tax_type,
              UPPER(description) description,
              fee_code          tax_code,
              TO_CHAR(valid_from, saft_date_format_)  
                                effective_date,
              TO_CHAR(valid_until, saft_date_format_) 
                                expiration_date,
              description       tax_code_description,
              fee_rate          tax_percentage,
              country_          country,
              report_type_      report_type
      FROM    statutory_fee_tab
      WHERE   company = company_;
BEGIN
   FOR saft_company_tax_info_rec_ IN saft_company_tax_info LOOP
      standard_tax_code_ := Standard_Audit_Tax_Codes_API.Get_Standard_Tax_Id(company_,
                                                                             country_,
                                                                             report_type_,
                                                                             saft_company_tax_info_rec_.tax_code);      
      newrec_ := emptyrec_;
      row_no_ := row_no_ + 1;
      newrec_.load_file_id      := load_file_id_;
      newrec_.row_no            := row_no_;
      newrec_.record_type_id    := '2.5.1';

      newrec_.c2  := saft_company_tax_info_rec_.tax_type;
      newrec_.c3 := Standard_Tax_Code_API.Get_Description(company_,standard_tax_code_);
      newrec_.c4  := saft_company_tax_info_rec_.tax_code;
      newrec_.c5  := saft_company_tax_info_rec_.effective_date;
      newrec_.c6  := saft_company_tax_info_rec_.expiration_date;
      newrec_.c7  := saft_company_tax_info_rec_.tax_code_description;
      newrec_.c8  := saft_company_tax_info_rec_.tax_percentage;
      newrec_.c9  := Iso_Country_API.Encode(saft_company_tax_info_rec_.country);
      newrec_.c11 := standard_tax_code_;
      newrec_.c13 := '100';

      newrec_.row_state  := '1';
      newrec_.rowversion := SYSDATE;
      Ext_File_Trans_API.Insert_Record ( newrec_ );
   END LOOP;
END Add_Tax_Info___;


-- Insert Code part information to the Ext_File_Trans_Tab.
PROCEDURE Add_Analysis_Type_Info___(
   row_no_        IN OUT   NUMBER, 
   load_file_id_  IN       NUMBER,
   company_       IN       VARCHAR2)
IS
   newrec_        Ext_File_Trans_Tab%ROWTYPE;
   emptyrec_      Ext_File_Trans_Tab%ROWTYPE;
   
   CURSOR saft_analysis_type_info IS 
      SELECT cv.company          company,
             cv.code_part        analysis_type,
             cv.code_part_value  analysis_id,
             cv.description      description,
             TO_CHAR(cv.valid_from, saft_date_format_)
                              start_date,
             TO_CHAR(cv.valid_until, saft_date_format_)
                              end_date
      FROM  accounting_code_part_value_tab cv, accounting_code_part_tab c
      WHERE c.company      = cv.company
      AND   c.code_part    = cv.code_part       
      AND   cv.code_part   != 'A'        
      AND   c.logical_code_part IN ('CostCenter', 'Project')
      AND   cv.company     = company_;
BEGIN
   FOR saft_analysis_type_info_rec_ IN saft_analysis_type_info LOOP
      newrec_ := emptyrec_;
      row_no_ := row_no_ + 1;
      newrec_.load_file_id      := load_file_id_;
      newrec_.row_no            := row_no_;
      newrec_.record_type_id    := '2.7.1';

      newrec_.c2 := saft_analysis_type_info_rec_.analysis_type;
      newrec_.c3 := Accounting_Code_Parts_API.Get_Description(company_, saft_analysis_type_info_rec_.analysis_type);
      newrec_.c4 := saft_analysis_type_info_rec_.analysis_id;
      newrec_.c5 := substr(nvl(Enterp_Comp_Connect_V170_API.Get_Company_Translation(company_,
                                                                                    'ACCRUL',
                                                                                    'CODE' ||
                                                                                    saft_analysis_type_info_rec_.analysis_type,
                                                                                    saft_analysis_type_info_rec_.analysis_id), saft_analysis_type_info_rec_.description), 1, 100);
      newrec_.c6 := saft_analysis_type_info_rec_.start_date;
      newrec_.c7 := saft_analysis_type_info_rec_.end_date;

      newrec_.row_state   := '1';
      newrec_.rowversion  := SYSDATE;
      Ext_File_Trans_API.Insert_Record (newrec_);
   END LOOP;
END Add_Analysis_Type_Info___;

-- This procedure is the starting porint of the report generation and this calls other procedures and functions which creates diffrent entries.
@SecurityCheck Company.UserAuthorized(company_)
PROCEDURE Generate_Report___(
   error_exists_  OUT   VARCHAR2,
   objid_         OUT   VARCHAR2,
   company_       IN    VARCHAR2,
   country_       IN    VARCHAR2,
   report_type_   IN    VARCHAR2,
   file_type_     IN    VARCHAR2,
   file_template_ IN    VARCHAR2,
   path_          IN    VARCHAR2,
   batch_         IN    VARCHAR2 DEFAULT 'FALSE',
   from_date_     IN    DATE     DEFAULT NULL,
   to_date_       IN    DATE     DEFAULT NULL)
IS   
   company_tmp_          VARCHAR2(100);
   set_id_               VARCHAR2(100);
   msg_                  VARCHAR2(32000); 
   file_template_id_     VARCHAR2(100); 
   file_direction_db_    VARCHAR2(100); 
   file_direction_       VARCHAR2(100); 
   file_name_            VARCHAR2(100); 
   client_server_        VARCHAR2(100); 
   column_name_          VARCHAR2(100); 
   column_value_         VARCHAR2(100);
   load_file_id_         NUMBER; 
   clob_out_             CLOB;
   rec_                  Audit_Selection_Criteria_Tab%ROWTYPE;
   include_source_docs_  VARCHAR2(5);
   row_no_               NUMBER := 0;
BEGIN
   Validate_Basic_Data__(company_, country_, report_type_);
   company_tmp_ :=  company_;
   Audit_Selection_Criteria_API.Add_New_Log__(rec_, company_, country_, report_type_, from_date_, to_date_);   
   include_source_docs_ := Audit_Basic_Data_Master_API.Get_Include_Source_Doc(company_, country_, report_type_);
   file_template_id_    := file_template_;
   Ext_File_Message_API.Return_For_Trans_Form(file_type_ , 
                                              set_id_, 
                                              msg_, 
                                              file_template_id_, 
                                              file_direction_db_, 
                                              file_direction_, 
                                              file_name_, 
                                              company_tmp_, 
                                              client_server_, 
                                              column_name_, 
                                              column_value_);                                            
   Ext_File_Load_API.Create_Load_Id_Param(load_file_id_,  msg_);   
   Add_Header_Info___(row_no_, load_file_id_, company_, country_, report_type_, rec_.report_id);
   Add_Master_Files_Info___(row_no_, load_file_id_, company_, country_, report_type_, from_date_, to_date_);
   $IF Component_Genled_SYS.INSTALLED $THEN
      Saft_Reporting_Genled_Util_API.Add_Gl_Entries(row_no_, load_file_id_, company_, from_date_, to_date_);  
   $END
   $IF Component_Invoic_SYS.INSTALLED $THEN
   IF (NVL(include_source_docs_, 'FALSE') = 'TRUE') THEN
      Saft_Reporting_Invoic_Util_API.Add_Source_Doc_Info(row_no_, load_file_id_, company_, from_date_, to_date_);
   END IF;
   $END
   External_File_Utility_API.Create_Xml_File(clob_out_, error_exists_, load_file_id_);
   IF (batch_ = 'TRUE') THEN
      External_File_Utility_API.Write_Xml_File(clob_out_, path_, file_template_id_);
      IF (error_exists_ = 'TRUE') THEN      
         Error_SYS.Record_General(lu_name_, 'XMLERROROCCURED: An error occurred while generating the XML file. Please refer the partially generated XML file for more details.');
      END IF;
   ELSE
      External_File_Utility_API.Add_Xml_Data__(objid_, load_file_id_, clob_out_);
   END IF;
END Generate_Report___;  

-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------
-- Used during batch process. Since SAF-T is a a large file, normally users the batch process to create the file.
PROCEDURE Generate_Report_Batch__(
   attr_    IN   VARCHAR2)
IS
   company_          VARCHAR2(20);
   country_          VARCHAR2(20);
   objid_            VARCHAR2(50);
   report_type_      VARCHAR2(20);
   file_type_        VARCHAR2(30);
   file_template_    VARCHAR2(30);
   path_             VARCHAR2(2000);
   from_date_        DATE;
   to_date_          DATE;
   error_exists_     VARCHAR2(5);
BEGIN
   company_       := Client_SYS.Get_Item_Value('COMPANY', attr_);
   objid_         := Client_SYS.Get_Item_Value('OBJID', attr_);
   country_       := Client_SYS.Get_Item_Value('COUNTRY', attr_);
   report_type_   := Client_SYS.Get_Item_Value('REPORT_TYPE', attr_);
   file_type_     := Client_SYS.Get_Item_Value('FILE_TYPE', attr_);
   file_template_ := Client_SYS.Get_Item_Value('FILE_TEMPLATE', attr_);
   path_          := Client_SYS.Get_Item_Value('PATH', attr_);
   from_date_     := Client_SYS.Get_Item_Value_To_Date('FROM_DATE', attr_, lu_name_);
   to_date_       := Client_SYS.Get_Item_Value_To_Date('TO_DATE', attr_, lu_name_);
      
   Generate_Report___(error_exists_,
                      objid_,
                      company_,
                      country_,
                      report_type_,
                      file_type_,
                      file_template_,
                      path_, 
                      'TRUE',
                      from_date_,
                      to_date_);
END Generate_Report_Batch__;

-- Validate whether all the mandotory basic data are avaiable.
PROCEDURE Validate_Basic_Data__(
   company_       IN VARCHAR2,
   country_       IN VARCHAR2,
   report_type_   IN VARCHAR2)
IS
   temp_              VARCHAR2(1);
   country_tmp_       VARCHAR2(2)  := Iso_Country_API.Encode(country_);
   report_type_tmp_   VARCHAR2(10) := Audit_Report_Types_API.Encode(report_type_);
   
   CURSOR check_basic_data_exists IS
      SELECT 1
      FROM   audit_basic_data_master_tab abdm 
      WHERE  abdm.company     = company_ 
      AND    abdm.country     = country_tmp_
      AND    abdm.report_type = report_type_tmp_
      AND    abdm.code_part_attr IS NOT NULL
      AND EXISTS (SELECT 1 
                  FROM   audit_contact_person_tab acp
                  WHERE  acp.company     = company_ 
                  AND    acp.country     = country_tmp_
                  AND    acp.report_type = report_type_tmp_)
      AND EXISTS (SELECT 1 
                  FROM   standard_audit_tax_codes_tab satc
                  WHERE  satc.company     = company_ 
                  AND    satc.country     = country_tmp_
                  AND    satc.report_type = report_type_tmp_);
BEGIN 
   OPEN check_basic_data_exists;
   FETCH check_basic_data_exists INTO temp_;
   IF (check_basic_data_exists%NOTFOUND) THEN
      CLOSE check_basic_data_exists;
      Error_SYS.Record_General(lu_name_, 'NOAUDITBASICDATAFOUND: Audit format basic data have not been properly entered for report type :P1 of country :P2', report_type_, country_);
   END IF;
   CLOSE check_basic_data_exists;
END Validate_Basic_Data__;

-- Build the file name.
FUNCTION Generate_File_Name__(
   company_    IN  VARCHAR2) RETURN VARCHAR2
IS
   file_name_     VARCHAR2(200);
   file_type_     VARCHAR2(200) := 'SAF-T Financial';
   company_name_  VARCHAR2(200) := company_;
   timestamp_     VARCHAR2(200) := TO_CHAR(sysdate, 'YYYYMMDDHH24MISS');
   file_no_       VARCHAR2(10)  := '1' || '_' || '1';
   format_        VARCHAR2(5)   := '.xml';
BEGIN
   file_name_ := file_type_ || '_' || company_name_ || '_' || timestamp_ || '_' || file_no_ || format_;
   RETURN file_name_;
END Generate_File_Name__;

-------------------- LU SPECIFIC PROTECTED METHODS --------------------------


-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------
PROCEDURE Generate_Output(
   error_exists_  OUT   VARCHAR2,
   job_id_        OUT   NUMBER,
   objid_         OUT   VARCHAR2,
   company_       IN    VARCHAR2,
   country_       IN    VARCHAR2,
   report_type_   IN    VARCHAR2,
   file_type_     IN    VARCHAR2,
   file_template_ IN    VARCHAR2,
   path_          IN    VARCHAR2,
   batch_         IN    VARCHAR2 DEFAULT  'FALSE',
   from_date_     IN    DATE     DEFAULT  NULL,
   to_date_       IN    DATE     DEFAULT  NULL)
IS
BEGIN
   Generate_Report___(error_exists_,
                     objid_,
                     company_,
                     country_,
                     report_type_,
                     file_type_,
                     file_template_,
                     path_, 
                     batch_,
                     from_date_,
                     to_date_);
END Generate_Output;
-------------------- LU  NEW METHODS -------------------------------------
