-----------------------------------------------------------------------------
--
--  Logical unit: TaxHandlingUtil
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  150901          Created for HomeRun project
--  180703  Nudilk  Bug 142813, Modifed code in Get_Supp_Tax_Liability_Info.
--  181107  Ajpelk  Bug 145054, Corrected.
--  190128  MaRalk  FIUXX-7198, Added record types/table types source_info_rec, tax_assis_field_visibility_rec, tax_assis_field_editable_rec,  
--  190128          tax_assistant_label_rec, rtn_info_save_tax_assist_rec, tax_assistant_validation_rec, tax_base_curr_and_str_item_rec, tax_base_curr_str_item_table     
--  190128          and methods Fetch_For_Tax_Line_Assistant, Get_Use_Specific_Rate, Set_Tax_Line_Assis_Colm_Labels, Field_Visible_Tax_Line_Assis,     
--  190128          Field_Editable_Tax_Line_Assis, Set_Tax_Cd_Lov_For_Tax_Ln_Asis, Val_Tax_Code_Mand_On_Tax_Asis, Update_Tax_Info_Table,  
--  190128          Save_From_Tax_Line_Assistant, Do_Additional_Validations, Tax_Line_Assis_Set_To_Default in order to use in the 
--  190128          common tax line assistant implementation in Aurena. 
--  190128          Update Set_Tax_Calc_Base_Tax_Str___ in order to keep tax base amount unchanged upon user modifications.
--  190328  Tmahlk  Implemented Create_Source_Info_Param_Rec in order to use in the common tax line assistant implementation in Aurena. 
--  191104  MaRalk  SCXTEND-1411, Tax Assistant code improvements - removed unused structures from the fragment(TaxLinesCommonAssistant.fragment) 
--  191104          and defined in the plsql layer(Default_Info_Structure_Rec, Tax_Calc_Base_Info_Struct_Rec, Tax_Curr_Amount_Struct_Rec,  
--  191104          Tax_Dom_Amount_Struct_Rec, Tax_Para_Amount_Struct_Rec, Tax_Amount_Summary_Struct_Rec, Currency_Rate_Struct_Rec structures). 
--  200224  MaRalk  SCXTEND-3453, Modified method Field_Editable_Tax_Line_Assis by adding parameters taxable_db_ and tax_liability_type_db_
--  200224          in order to evaluate tax percentage editable in the Tax Lines Assistant from order module windows.
--  200702  NiDalk  SCXTEND-4444, Added new data type source_key_arr.
--  201102  Vashlk  FISPRING20-7983, Handle concurrent users for mixed payment manual postings tax lines assistant.
--  210301  Hiralk  FISPRING20-9291, Merged bug 157892, Added new overloaded methods Validate_Max_Overwrite_Level and Check_Max_Overwrite_Level.
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------

-- This record is used to save tax code information and the tax amounts.
-- use_specific_rate and curr_rate is part of it due to use specific calculation which uses tax curr rate.
-- gelr: extend_tax_code_and_tax_struct, Added br_tax_percentage to support Brazil specific tax calculation.
TYPE tax_information_rec IS RECORD                  
   (tax_code                     VARCHAR2(20),
    tax_method_db                VARCHAR2(20), 
    tax_type_db                  VARCHAR2(10),
    tax_calc_structure_id        VARCHAR2(20), 
    tax_calc_structure_item_id   VARCHAR2(20),     
    tax_percentage               NUMBER,
    deductible_factor            NUMBER,
    use_specific_rate            VARCHAR2(5),
    curr_rate                    NUMBER,
    total_tax_curr_amount        NUMBER,
    total_tax_dom_amount         NUMBER,
    total_tax_para_amount        NUMBER,
    tax_curr_amount              NUMBER,
    tax_dom_amount               NUMBER,
    tax_para_amount              NUMBER,
    non_ded_tax_curr_amount      NUMBER,
    non_ded_tax_dom_amount       NUMBER,
    non_ded_tax_para_amount      NUMBER,
    tax_base_curr_amount         NUMBER,
    tax_base_dom_amount          NUMBER,
    tax_base_para_amount         NUMBER,
    br_tax_percentage            NUMBER);
   
TYPE tax_information_table IS TABLE OF tax_information_rec INDEX BY BINARY_INTEGER; 

-- This record is used to save object information which is used in fetching default tax codes from object.
-- object_type stores a hard coded value to identify the type of different objects: 
-- INSTANT INVOICE/OUTGOING SUPPLIER INVOICE - SALES_OBJECT
-- MANUAL CUSTOMER/SUPPLIER INVOICE - IDENTITY
-- CUSTOMER ORDER LINE - SALES_PART
-- CUSTOMER ORDER CHARGE LINE - CHARGE_TYPE
-- REBATE INVOICE - REBATE_TYPE
-- PURCHASE ORDER PURCHASE PART - PURCHASE_PART
-- PURCHASE ORDER NO PART - PURCH_NO_PART
-- PROJECT INVOICE LINE - REPORT_COST
-- PURCHASE ORDER CHARGE - PURCH_CHARGE_TYPE, PURCH_CHARGE_SUPP, PURCH_CHARGE_SUPP_PART
-- SUB CONTRACT - SUB_CONTRACT
TYPE tax_source_object_rec IS RECORD (   
   object_id                     VARCHAR2(50), 		
   object_type                   VARCHAR2(50),
   object_group                  VARCHAR2(25),
   object_tax_code               VARCHAR2(20),		
   object_tax_class_id           VARCHAR2(20),		
   is_taxable_db                 VARCHAR2(20));	-- TRUE/FALSE
   
-- This record is used to save information which is used in fetching default tax codes from address.
TYPE identity_rec IS RECORD (
   identity                   VARCHAR2(20),  
   party_type_db              VARCHAR2(20),
   supply_country_db          VARCHAR2(2),
   delivery_country_db        VARCHAR2(2),  -- only for customer order module
   tax_liability              VARCHAR2(20),			
   tax_liability_type_db      VARCHAR2(20),
   delivery_address_id        VARCHAR2(50),
   delivery_type              VARCHAR2(20), -- only for party_type_db = CUSTOMER
   use_proj_address_for_tax   VARCHAR2(5),  -- TRUE/FALSE
   project_id                 VARCHAR2(10),
   ship_from_address_id       VARCHAR2(50));
 
-- This record is used to save information which is used in fetching default tax codes.
TYPE fetch_default_key_rec IS RECORD (
   contract                   VARCHAR2(5),  -- only for customer order/purchase modules
   charge_connect_part_no     VARCHAR2(25), -- only for purchase module			
   order_code                 VARCHAR2(20), -- only for purchase module		
   service_type               VARCHAR2(20), -- only for purchase module
   connect_charge_seq_no      NUMBER);      -- only for purchase module
   
-- This record is used to save information which is used in validating default tax codes.
TYPE validation_rec IS RECORD (
   calc_base                   VARCHAR2(20), -- GROSS_BASE/NET_BASE
   fetch_validate_action       VARCHAR2(20),	-- FETCH_AND_VALIDATE/FETCH_IF_VALID/FETCH_ALWAYS	
   validate_tax_from_tax_class VARCHAR2(5)); -- TRUE/FALSE, only for contract management module

-- This record is used to save information which is used in fetching saved tax codes from source_tax_item_tab.
TYPE source_key_rec IS RECORD (
   source_ref_type               VARCHAR2(50),
   source_ref1                   VARCHAR2(20),		
   source_ref2                   VARCHAR2(20),		
   source_ref3                   VARCHAR2(20),		
   source_ref4                   VARCHAR2(20),
   source_ref5                   VARCHAR2(20));  
   
TYPE source_key_arr IS TABLE OF source_key_rec INDEX BY BINARY_INTEGER;

-- This record is used to save line level information.
TYPE line_amount_rec IS RECORD (			
   line_tax_curr_amount          NUMBER,			
   line_tax_dom_amount           NUMBER,
   line_tax_para_amount          NUMBER,
   line_non_ded_tax_curr_amount  NUMBER,
   line_non_ded_tax_dom_amount   NUMBER,
   line_non_ded_tax_para_amount  NUMBER,
   line_gross_curr_amount        NUMBER,
   line_gross_dom_amount         NUMBER,
   line_net_curr_amount          NUMBER,
   line_net_dom_amount           NUMBER,
   tax_calc_base_amount          NUMBER,    
   calc_base                     VARCHAR2(20),  -- GROSS_BASE/NET_BASE
   consider_use_tax              VARCHAR2(5));	-- TRUE/FALSE

-- This record is used to save transaction currency information.
TYPE trans_curr_rec IS RECORD (			
   currency                      VARCHAR2(3),  -- only used in Domestic/Parallel Gross/Net Amount Calculation
   tax_rounding_method           VARCHAR2(20),			
   curr_rounding                 NUMBER );   

-- This record is used to save information for calculations in accounting currency.
-- The curr_rate and conv_factor contain relationship between transaction currency and accounting currency.
TYPE acc_curr_rec IS RECORD (			
   acc_curr_code                 VARCHAR2(3),
   curr_rate                     NUMBER,      
   conv_factor                   NUMBER,			
   acc_curr_rounding             NUMBER,
   use_inverted_rate             VARCHAR2(5));
   
-- This record is used to save parallel currency information.   
TYPE para_curr_rec IS RECORD (			
   para_curr_code                VARCHAR2(3),
   para_curr_rate                NUMBER,
   para_conv_factor              NUMBER,			
   para_curr_rounding            NUMBER,
   para_use_inverted_rate        VARCHAR2(5),
   para_curr_base                VARCHAR2(25));  


-- This record is used in the functionality of getting source information when opening the tax line assistant in Aurena.
TYPE source_info_rec IS RECORD (
   company                       VARCHAR2(20),   
   source_ref_type_db            VARCHAR2(50),
   source_ref1                   VARCHAR2(50),		
   source_ref2                   VARCHAR2(50),		
   source_ref3                   VARCHAR2(50),		
   source_ref4                   VARCHAR2(50),
   source_ref5                   VARCHAR2(50),
   source_objversion             VARCHAR2(200),
   source_objkey                 VARCHAR2(200),
   party_type_db                 VARCHAR2(20),   
   identity                      VARCHAR2(20),   
   transaction_date              DATE,
   transaction_currency          VARCHAR2(3),
   delivery_address_id           VARCHAR2(50),	
   advance_invoice               VARCHAR2(5),
   tax_validation_type           VARCHAR2(12),
   taxable                       VARCHAR2(20),
   liability_type                VARCHAR2(20),
   tax_calc_structure_id         VARCHAR2(20),
   curr_rate                     NUMBER,
   tax_curr_rate                 NUMBER, 
   parallel_curr_rate            NUMBER, 
   div_factor                    NUMBER, 
   parallel_div_factor           NUMBER,  
   gross_curr_amount             NUMBER, 
   net_curr_amount               NUMBER,
   tax_curr_amount               NUMBER,
   non_ded_tax_curr_amount       NUMBER,
   total_tax_curr_amount         NUMBER);  

-- This record is used in tax line assistant in Aurena when it is needed to set specific labels 
-- in the tax lines list and the amounts group box.
TYPE tax_assistant_label_rec IS RECORD ( 
   tax_lines_label                      VARCHAR2(50),
   list_tax_percentage_label            VARCHAR2(50),
   list_ded_percentage_label            VARCHAR2(50),
   list_tax_amount_label                VARCHAR2(50),
   list_tax_dom_amount_label            VARCHAR2(50),
   list_tax_parallel_amt_label          VARCHAR2(50),   
   list_tax_base_curr_amt_label         VARCHAR2(50),
   list_tax_base_dom_amount_label       VARCHAR2(50),
   list_tax_base_para_amt_label         VARCHAR2(50),
   list_non_ded_tax_amt_label           VARCHAR2(50),
   list_non_ded_tax_dom_amt_lbl         VARCHAR2(50),
   list_non_ded_tax_para_amt_lbl        VARCHAR2(50),
   list_total_tax_curr_amt_label        VARCHAR2(50),
   list_total_tax_dom_amt_label         VARCHAR2(50),
   list_total_tax_para_amount_label     VARCHAR2(50),
   group_gross_curr_amount_label        VARCHAR2(50),   
   group_net_curr_amount_label          VARCHAR2(50),
   group_vat_curr_amount_label          VARCHAR2(50),
   group_non_ded_curr_amt_label         VARCHAR2(50),
   group_total_tax_curr_amt_lbl         VARCHAR2(50),
   group_cost_curr_amount_label         VARCHAR2(50));        
    
-- This record is used in the functionality of setting fields visible in tax line assistant in Aurena.
TYPE tax_assis_field_visibility_rec IS RECORD (
   tax_dom_amount_visible           VARCHAR2(5),
   tax_parallel_amount_visible      VARCHAR2(5),
   tax_base_curr_amount_visible     VARCHAR2(5),
   tax_base_dom_amount_visible      VARCHAR2(5),
   tax_base_parallel_amt_visible    VARCHAR2(5),
   non_ded_tax_curr_amt_visible     VARCHAR2(5),
   non_ded_tax_dom_amount_visible   VARCHAR2(5),
   non_ded_tax_paral_amt_visible    VARCHAR2(5),
   total_tax_curr_amount_visible    VARCHAR2(5),
   total_tax_dom_amount_visible     VARCHAR2(5),
   total_tax_parallel_amt_visible   VARCHAR2(5),
   deductible_percentage_visible    VARCHAR2(5),
   transferred_visible              VARCHAR2(5),
   sum_non_ded_curr_amt_visible     VARCHAR2(5),
   sum_tot_tax_curr_amt_visible     VARCHAR2(5));      
   
-- This record is used in the functionality of setting fields editable in tax line assistant in Aurena.
TYPE tax_assis_field_editable_rec IS RECORD (
   tax_percentage_editable          VARCHAR2(5),
   tax_curr_amount_editable         VARCHAR2(5),		
   tax_base_curr_amount_editable    VARCHAR2(5),	
   non_ded_tax_curr_amt_editable    VARCHAR2(5),		
   total_tax_curr_amount_editable   VARCHAR2(5));  

-- This record is used in common tax line assistant in Aurena.
-- Using to save copy of tax_base_curr_amount_modified values in tax line virtual table 
-- before the recalculation logic runs.
TYPE tax_base_curr_and_str_item_rec IS RECORD                  
   (tax_calc_structure_item_id    VARCHAR2(20), 
    tax_base_curr_amount_modified NUMBER);

-- This record is used in tax line assistant in Aurena in order to  
-- have some return values of some functional areas.
TYPE rtn_info_save_tax_assist_rec IS RECORD                  
   (tax_limit_applied VARCHAR2(5));

-- This record is used to pass some values that are needed for validations in tax line assistant in Aurena.
TYPE tax_assistant_validation_rec IS RECORD                  
   (tax_validation_type VARCHAR2(12),
    tax_lines_count     NUMBER,
    tax_code            VARCHAR2(20),
    is_transferred      VARCHAR2(5),
    is_modified         VARCHAR2(5),
    is_removed          VARCHAR2(5));

TYPE tax_base_curr_str_item_table IS TABLE OF tax_base_curr_and_str_item_rec INDEX BY BINARY_INTEGER; 

-- This table is used in common tax line assistant in Aurena.
-- Needed to collect the ibjids of the LOV items in order to display in the tax code LOV.
TYPE Objid_Arr IS TABLE OF VARCHAR2(100);

-- This record is used in tax line assistant in Aurena
TYPE Default_Info_Structure_Rec IS RECORD (
   deductible_factor              NUMBER,
   tax_rounding_method            VARCHAR2(4000),
   currency_rounding              NUMBER);

-- This record is used in tax line assistant in Aurena
TYPE Tax_Calc_Base_Info_Struct_Rec IS RECORD (
   calc_base                      VARCHAR2(4000),
   tax_calc_base_percent          NUMBER,
   tax_calc_base_amount           NUMBER,
   use_tax_calc_base_amount       NUMBER);   
   
-- This record is used in tax line assistant in Aurena
TYPE Tax_Curr_Amount_Struct_Rec IS RECORD (
   total_tax_curr_amount          NUMBER,
   tax_curr_amount                NUMBER,
   non_ded_tax_curr_amount        NUMBER,
   attr                           VARCHAR2(4000),
   tax_base_curr_amount           NUMBER,
   summary_tax_curr_amount        NUMBER,
   summary_net_curr_amount        NUMBER,
   summary_non_ded_curr_amount    NUMBER,
   summary_total_tax_curr_amount  NUMBER,
   summary_cost_curr_amount       NUMBER);   
 
-- This record is used in tax line assistant in Aurena 
TYPE Tax_Dom_Amount_Struct_Rec IS RECORD (
   total_tax_dom_amount           NUMBER,
   tax_dom_amount                 NUMBER,
   non_ded_tax_dom_amount         NUMBER,
   tax_base_dom_amount            NUMBER,
   attr                           VARCHAR2(4000)); 
   
-- This record is used in tax line assistant in Aurena    
TYPE Tax_Para_Amount_Struct_Rec IS RECORD (
   total_tax_para_amount          NUMBER,
   tax_para_amount                NUMBER,
   non_ded_tax_para_amount        NUMBER,
   tax_base_para_amount           NUMBER,
   attr                           VARCHAR2(4000));   
   
-- This record is used in tax line assistant in Aurena
TYPE Tax_Amount_Summary_Struct_Rec IS RECORD (
   gross_curr_amount              NUMBER,
   net_curr_amount                NUMBER,
   tax_curr_amount                NUMBER,
   non_ded_tax_curr_amount        NUMBER,
   cost_curr_amount               NUMBER,
   total_tax_curr_amount          NUMBER);
   
-- This record is used in tax line assistant in Aurena   
 TYPE Currency_Rate_Struct_Rec IS RECORD (
   use_specific_rate              VARCHAR2(4000),
   curr_rate                      NUMBER);  
   
-------------------- PRIVATE DECLARATIONS -----------------------------------

-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------

-------------------- IMPLEMENTATION METHODS FOR FETCHING TAX CODE INFO ------

-- This method fetches the tax code on object.
PROCEDURE Fetch_Tax_Code_On_Object___ (
   tax_source_object_rec_  IN OUT tax_source_object_rec,
   company_                IN     VARCHAR2, 
   tax_liability_date_     IN     DATE,
   identity_rec_           IN     identity_rec,
   fetch_default_key_rec_  IN     fetch_default_key_rec)
IS 
BEGIN
   $IF Component_Invoic_SYS.INSTALLED $THEN
      IF (tax_source_object_rec_.object_type IN ('SALES_OBJECT', 'IDENTITY')) THEN
         Tax_Handling_Invoic_Util_API.Fetch_Tax_Code_On_Object(tax_source_object_rec_, company_, identity_rec_.party_type_db);
      END IF;   
   $END 
   $IF Component_Order_SYS.INSTALLED $THEN
      IF (tax_source_object_rec_.object_type IN ('SALES_PART', 'CHARGE_TYPE', 'REBATE_TYPE')) THEN
         Tax_Handling_Order_Util_API.Fetch_Tax_Code_On_Object(tax_source_object_rec_, fetch_default_key_rec_.contract);
      END IF;
   $END  
   $IF Component_Purch_SYS.INSTALLED $THEN 
      IF (tax_source_object_rec_.object_type IN ('PURCHASE_PART', 'PURCH_NO_PART', 'PURCH_CHARGE_TYPE', 'PURCH_CHARGE_SUPP', 'PURCH_CHARGE_SUPP_PART')) THEN
         Tax_Handling_Purch_Util_API.Fetch_Tax_Code_On_Object(tax_source_object_rec_,
                                                              fetch_default_key_rec_.contract,
                                                              company_,
                                                              identity_rec_.identity,
                                                              identity_rec_.party_type_db,
                                                              fetch_default_key_rec_.charge_connect_part_no,
                                                              fetch_default_key_rec_.connect_charge_seq_no,
                                                              fetch_default_key_rec_.order_code,
                                                              fetch_default_key_rec_.service_type);  
      END IF;   
   $END 
   $IF Component_Prjrep_SYS.INSTALLED $THEN 
      IF (tax_source_object_rec_.object_type IN ('REPORT_COST')) THEN
         Tax_Handling_Prjrep_Util_API.Fetch_Tax_Code_On_Object(tax_source_object_rec_, company_, tax_liability_date_);               
      END IF;   
   $END 
   $IF Component_Subcon_SYS.INSTALLED $THEN 
      IF (tax_source_object_rec_.object_type IN ('SUB_CONTRACT')) THEN
         Tax_Handling_Subcon_Util_API.Fetch_Tax_Code_On_Object(tax_source_object_rec_, company_, identity_rec_.party_type_db);               
      END IF;   
   $END      
   IF (tax_source_object_rec_.object_tax_class_id IS NOT NULL) THEN
      tax_source_object_rec_.object_tax_code := Fetch_Tax_Code_On_Tax_Class___(company_, tax_source_object_rec_.object_tax_class_id, tax_liability_date_, identity_rec_);
   END IF;    
END Fetch_Tax_Code_On_Object___;


-- This method fetches the tax code on tax class of object.
FUNCTION Fetch_Tax_Code_On_Tax_Class___ (
   company_                IN VARCHAR2,
   tax_class_id_           IN VARCHAR2,
   tax_liability_date_     IN DATE,
   identity_rec_           IN identity_rec ) RETURN VARCHAR2    
IS 
   tax_code_on_tax_class_  VARCHAR2(20); 
BEGIN
   tax_code_on_tax_class_ := Tax_Class_API.Get_Valid_Fee_Code(company_, tax_class_id_, identity_rec_.delivery_country_db, identity_rec_.tax_liability, tax_liability_date_);                                       
   IF (tax_code_on_tax_class_ IS NULL) THEN
      tax_code_on_tax_class_ := Tax_Class_API.Get_Valid_Fee_Code(company_, tax_class_id_, identity_rec_.supply_country_db, identity_rec_.tax_liability, tax_liability_date_);    
   END IF;                        
   RETURN tax_code_on_tax_class_;   
END Fetch_Tax_Code_On_Tax_Class___;


-- This method fetches the tax codes from Customer/Suppier Address.
PROCEDURE Fetch_Tax_Codes_On_Address___ (
   tax_calc_structure_id_  OUT    VARCHAR2,
   tax_info_table_         IN OUT tax_information_table,
   company_                IN     VARCHAR2,
   tax_code_selection_     IN     VARCHAR2, 
   tax_liability_date_     IN     DATE,
   identity_rec_           IN     identity_rec,
   validation_rec_         IN     validation_rec )
IS
   default_tax_info_table_ tax_information_table;
   supply_country_db_      VARCHAR2(2);   
BEGIN
   IF (identity_rec_.party_type_db = Party_Type_API.DB_CUSTOMER) THEN      
      $IF Component_Invoic_SYS.INSTALLED $THEN
         supply_country_db_ := NVL(identity_rec_.supply_country_db, Company_API.Get_Country_Db(company_));
         Customer_Delivery_Fee_Code_API.Fetch_Tax_Codes_On_Cust_Addr(default_tax_info_table_, tax_calc_structure_id_, company_, identity_rec_.identity, identity_rec_.delivery_address_id, supply_country_db_, tax_code_selection_);                         
      $ELSE
         NULL;
      $END
   ELSIF (identity_rec_.party_type_db = Party_Type_API.DB_SUPPLIER) THEN
      Fetch_Addr_Tax_Codes_Supp___(default_tax_info_table_, tax_calc_structure_id_, company_, identity_rec_);
   END IF;
   IF (tax_calc_structure_id_ IS NOT NULL) THEN
      Fetch_Tax_Codes_On_Tax_Str___(tax_info_table_, company_, identity_rec_.party_type_db, tax_calc_structure_id_, tax_liability_date_, validation_rec_);
   ELSE
      FOR i IN 1 .. default_tax_info_table_.COUNT LOOP
         Add_Tax_Code_Info(tax_info_table_, company_, identity_rec_.party_type_db, default_tax_info_table_(i).tax_code, NULL, NULL, validation_rec_.fetch_validate_action, NULL, tax_liability_date_);
      END LOOP;      
   END IF;   
END Fetch_Tax_Codes_On_Address___;


-- This method fetches the tax codes from Suppier Address.
PROCEDURE Fetch_Addr_Tax_Codes_Supp___ (
   default_tax_info_table_ OUT tax_information_table,
   tax_calc_structure_id_  OUT VARCHAR2,
   company_                IN  VARCHAR2,
   identity_rec_           IN  identity_rec ) 
IS
   use_supp_addr_for_tax_  VARCHAR2(5) := Fnd_Boolean_API.DB_FALSE;
BEGIN   
   use_supp_addr_for_tax_ := NVL(Supplier_Tax_Info_API.Get_Use_Supp_Addr_For_Tax_Db(identity_rec_.identity, identity_rec_.ship_from_address_id, company_), Fnd_Boolean_API.DB_FALSE);
   IF (use_supp_addr_for_tax_ = Fnd_Boolean_API.DB_TRUE) THEN      
      Supplier_Delivery_Tax_Code_API.Fetch_Tax_Codes_On_Supp_Addr(default_tax_info_table_, tax_calc_structure_id_, company_, identity_rec_.identity, identity_rec_.ship_from_address_id);
   ELSE
      IF (identity_rec_.use_proj_address_for_tax = Fnd_Boolean_API.DB_FALSE) THEN
         $IF Component_Invoic_SYS.INSTALLED $THEN
            Delivery_Fee_Code_Company_API.Fetch_Tax_Codes_On_Comp_Addr(default_tax_info_table_, tax_calc_structure_id_, company_, identity_rec_.delivery_address_id);
         $ELSE
            NULL;
         $END
      ELSIF (identity_rec_.use_proj_address_for_tax = Fnd_Boolean_API.DB_TRUE) THEN
         $IF Component_Proj_SYS.INSTALLED $THEN
            Project_Delivery_Fee_Code_API.Fetch_Tax_Codes_On_Proj_Addr(default_tax_info_table_, tax_calc_structure_id_, company_, identity_rec_.project_id, identity_rec_.delivery_address_id);
         $ELSE
            NULL;   
         $END 
      END IF;        
   END IF;  
END Fetch_Addr_Tax_Codes_Supp___;


-- This method fetches tax codes from Tax Structure.
PROCEDURE Fetch_Tax_Codes_On_Tax_Str___ (
   tax_info_table_         OUT tax_information_table,
   company_                IN  VARCHAR2,
   party_type_db_          IN  VARCHAR2,
   tax_calc_structure_id_  IN  VARCHAR2,
   tax_liability_date_     IN  DATE,
   validation_rec_         IN  validation_rec )    
IS 
   default_tax_info_table_    tax_information_table;
BEGIN
   IF (validation_rec_.calc_base = 'GROSS_BASE') THEN
      Validate_Calc_Base_In_Struct();
   ELSE   
      Tax_Calc_Structure_API.Exist(company_, tax_calc_structure_id_);
      default_tax_info_table_ := Tax_Structure_Item_API.Get_Tax_Structure_Items(company_, tax_calc_structure_id_);
      FOR i IN 1 .. default_tax_info_table_.COUNT LOOP
         Add_Tax_Code_Info(tax_info_table_, company_, party_type_db_, default_tax_info_table_(i).tax_code, tax_calc_structure_id_, default_tax_info_table_(i).tax_calc_structure_item_id, validation_rec_.fetch_validate_action, NULL, tax_liability_date_);
      END LOOP; 
   END IF;
END Fetch_Tax_Codes_On_Tax_Str___;


-- This method fetches the tax free tax code on Identity/Company.
PROCEDURE Fetch_Tax_Free_Tax_Code___ (
   tax_info_table_         IN OUT tax_information_table, 
   company_                IN     VARCHAR2,
   object_type_            IN     VARCHAR2,
   fetch_validate_action_  IN     VARCHAR2,
   tax_liability_date_     IN     DATE,
   identity_rec_           IN     identity_rec )
IS 
   party_type_          VARCHAR2(20) := Party_Type_API.Decode(identity_rec_.party_type_db);
   tax_free_tax_code_   VARCHAR2(20); 
BEGIN
   $IF Component_Invoic_SYS.INSTALLED $THEN
      IF (identity_rec_.party_type_db = Party_Type_API.DB_CUSTOMER) THEN      
         tax_free_tax_code_ := Customer_Tax_Free_Tax_Code_API.Get_Tax_Free_Tax_Code(identity_rec_.identity, identity_rec_.delivery_address_id, company_, identity_rec_.supply_country_db, identity_rec_.delivery_type);
      ELSIF (identity_rec_.party_type_db = Party_Type_API.DB_SUPPLIER) THEN
         tax_free_tax_code_ := Identity_Invoice_Info_API.Get_Sup_Vat_Free_Vat_Code(company_, identity_rec_.identity, party_type_);
      END IF;   
   $END
   $IF Component_Discom_SYS.INSTALLED $THEN
      IF (object_type_ IN ('PURCH_NO_PART')) THEN
         IF (tax_free_tax_code_ IS NULL) THEN
            tax_free_tax_code_ := Company_Tax_Discom_Info_API.Get_Tax_Free_Tax_Code(company_);
         END IF;
      END IF;     
   $END 
   IF (tax_free_tax_code_ IS NOT NULL) THEN    
      Add_Tax_Code_Info(tax_info_table_, company_, identity_rec_.party_type_db, tax_free_tax_code_, NULL, NULL, fetch_validate_action_, NULL, tax_liability_date_);    
   END IF;    
END Fetch_Tax_Free_Tax_Code___;


-- This method copies tax codes from message.
PROCEDURE Fetch_Multiple_Tax_Codes___ (
   tax_info_table_         OUT tax_information_table,
   company_                IN  VARCHAR2,
   party_type_db_          IN  VARCHAR2,
   tax_code_msg_           IN  VARCHAR2,
   fetch_validate_action_  IN  VARCHAR2,
   tax_liability_date_     IN  DATE )
IS   
   tax_calc_structure_id_      VARCHAR2(20);
   tax_calc_structure_item_id_ VARCHAR2(20);
   tax_code_                   VARCHAR2(20);
   tax_percentage_             NUMBER; 
   count_                      NUMBER;
   index_                      NUMBER := 0;
   m_s_names_                  Message_SYS.name_table;
   m_s_values_                 Message_SYS.line_table; 
BEGIN
   IF (Message_SYS.Get_Name(tax_code_msg_) = 'TAX_CODES') THEN
      Message_SYS.Get_Attributes(tax_code_msg_, count_, m_s_names_, m_s_values_);
      FOR i IN 1..count_  LOOP
         IF (m_s_names_(i) = 'TAX_CALC_STRUCTURE_ID') THEN
            tax_calc_structure_id_ := m_s_values_(i);
         ELSIF (m_s_names_(i) = 'TAX_CALC_STRUCTURE_ITEM_ID') THEN
            tax_calc_structure_item_id_ := m_s_values_(i);
         ELSIF (m_s_names_(i) = 'TAX_CODE') THEN
            tax_code_ := m_s_values_(i);
         ELSIF (m_s_names_(i) = 'TAX_PERCENTAGE') THEN
            index_          := NVL(tax_info_table_.LAST, 0) + 1;
            tax_percentage_ := Client_SYS.Attr_Value_To_Number(m_s_values_(i));
            Add_Tax_Code_Info(tax_info_table_, company_, party_type_db_, tax_code_, tax_calc_structure_id_, tax_calc_structure_item_id_, fetch_validate_action_, tax_percentage_, tax_liability_date_);
         END IF;       
         IF (NVL(tax_info_table_.LAST, 0) = index_) THEN
            IF (m_s_names_(i) = 'TAX_BASE_CURR_AMOUNT') THEN
               tax_info_table_(index_).tax_base_curr_amount := NVL(m_s_values_(i), 0);
            END IF;
            IF (m_s_names_(i) = 'TAX_CURR_AMOUNT') THEN
               tax_info_table_(index_).tax_curr_amount := m_s_values_(i);
            END IF;
         END IF;         
      END LOOP;   
   END IF;   
END Fetch_Multiple_Tax_Codes___;


-- This method copies saved multiple tax codes from message.
PROCEDURE Add_Saved_Tax_Code_Info___ (
   tax_info_table_             OUT tax_information_table,
   tax_code_                   IN  VARCHAR2,
   saved_tax_code_msg_         IN  VARCHAR2,    
   saved_tax_code_             IN  VARCHAR2,    
   saved_tax_calc_struct_id_   IN  VARCHAR2, 
   saved_tax_percentage_       IN  VARCHAR2, 
   saved_tax_base_curr_amount_ IN  NUMBER, 
   company_                    IN  VARCHAR2, 
   party_type_db_              IN  VARCHAR2, 
   tax_liability_date_         IN  DATE, 
   validation_rec_             IN  validation_rec )
IS
BEGIN
   IF (tax_code_ IS NOT NULL) THEN
      IF (saved_tax_code_ IS NOT NULL AND saved_tax_code_ = tax_code_) THEN
         Add_Tax_Code_Info(tax_info_table_, company_, party_type_db_, saved_tax_code_, NULL, NULL, validation_rec_.fetch_validate_action, saved_tax_percentage_, tax_liability_date_);
         IF (tax_info_table_.COUNT = 1) THEN
            tax_info_table_(1).tax_base_curr_amount := saved_tax_base_curr_amount_;
         END IF;
      ELSE
         Add_Tax_Code_Info(tax_info_table_, company_, party_type_db_, tax_code_, NULL, NULL, validation_rec_.fetch_validate_action, NULL, tax_liability_date_);
      END IF;
   ELSE
      IF (saved_tax_code_msg_ IS NOT NULL AND saved_tax_calc_struct_id_ IS NULL) THEN
         Fetch_Multiple_Tax_Codes___(tax_info_table_, company_, party_type_db_, saved_tax_code_msg_, validation_rec_.fetch_validate_action, tax_liability_date_);
      END IF;
   END IF;
END Add_Saved_Tax_Code_Info___;


-- This method copies tax codes on saved tax structure from message.
PROCEDURE Add_Saved_Tax_Struct_Info___ (
   tax_info_table_             OUT tax_information_table,
   tax_calc_structure_id_      IN  VARCHAR2,
   saved_tax_code_msg_         IN  VARCHAR2,
   saved_tax_calc_struct_id_   IN  VARCHAR2,
   company_                    IN  VARCHAR2, 
   party_type_db_              IN  VARCHAR2, 
   tax_liability_date_         IN  DATE, 
   validation_rec_             IN  validation_rec )
IS
BEGIN
   IF (saved_tax_calc_struct_id_ IS NOT NULL) AND (saved_tax_calc_struct_id_ = tax_calc_structure_id_) THEN
      IF (saved_tax_code_msg_ IS NOT NULL) THEN
         Fetch_Multiple_Tax_Codes___(tax_info_table_, company_, party_type_db_, saved_tax_code_msg_, validation_rec_.fetch_validate_action, tax_liability_date_);
      END IF;
   ELSE        
      Fetch_Tax_Codes_On_Tax_Str___(tax_info_table_, company_, party_type_db_, tax_calc_structure_id_, tax_liability_date_, validation_rec_);
   END IF;
END Add_Saved_Tax_Struct_Info___;

-------------------- IMPLEMENTATION METHODS FOR CALCULATIONS ----------------

-- This method calculates tax curr amounts.
PROCEDURE Calc_Tax_Curr_Amount___ (
   total_tax_curr_amount_     OUT NUMBER,
   tax_curr_amount_           OUT NUMBER,
   non_ded_tax_curr_amount_   OUT NUMBER,
   tax_type_db_               IN  VARCHAR2,
   tax_calc_base_amount_      IN  NUMBER,
   tax_calc_base_percent_     IN  NUMBER,
   use_tax_calc_base_amount_  IN  NUMBER,
   tax_percentage_            IN  NUMBER,
   deductible_factor_         IN  NUMBER,
   trans_curr_rec_            IN  trans_curr_rec )
IS
BEGIN      
   IF (tax_type_db_ IN (Fee_Type_API.DB_TAX, Fee_Type_API.DB_NO_TAX, Fee_Type_API.DB_CALCULATED_TAX, Fee_Type_API.DB_USE_TAX)) THEN      
      IF (tax_calc_base_percent_ != 0) THEN
         total_tax_curr_amount_ := Currency_Amount_API.Round_Amount(trans_curr_rec_.tax_rounding_method, ((tax_calc_base_amount_ * tax_percentage_) / tax_calc_base_percent_), trans_curr_rec_.curr_rounding);
      ELSE
         total_tax_curr_amount_ := 0;
      END IF;
   END IF;
   IF (tax_type_db_ = Fee_Type_API.DB_USE_TAX) THEN
      total_tax_curr_amount_ := Currency_Amount_API.Round_Amount(trans_curr_rec_.tax_rounding_method, ((use_tax_calc_base_amount_ * tax_percentage_) / 100), trans_curr_rec_.curr_rounding);
   END IF;   
   tax_curr_amount_         := Currency_Amount_API.Round_Amount(trans_curr_rec_.tax_rounding_method, (total_tax_curr_amount_ * deductible_factor_), trans_curr_rec_.curr_rounding);
   non_ded_tax_curr_amount_ := total_tax_curr_amount_ - tax_curr_amount_;
   IF (Log_SYS.Is_Log_Set(Log_Category_API.DB_ALL)) THEN
      Trace_SYS.Message('tax_rounding_method       : '||trans_curr_rec_.tax_rounding_method);
      Trace_SYS.Message('curr_rounding             : '||trans_curr_rec_.curr_rounding);
      Trace_SYS.Message('tax_calc_base_amount_     : '||tax_calc_base_amount_);
      Trace_SYS.Message('tax_calc_base_percent_    : '||tax_calc_base_percent_); 
      Trace_SYS.Message('use_tax_calc_base_amount_ : '||use_tax_calc_base_amount_);
      Trace_SYS.Message('tax_percentage_           : '||tax_percentage_);
      Trace_SYS.Message('deductible_factor_        : '||deductible_factor_);
      Trace_SYS.Message('total_tax_curr_amount_    : '||total_tax_curr_amount_);
      Trace_SYS.Message('tax_curr_amount_          : '||tax_curr_amount_);
      Trace_SYS.Message('non_ded_tax_curr_amount_  : '||non_ded_tax_curr_amount_);
      Trace_SYS.Message('***************************************');    
   END IF;
END Calc_Tax_Curr_Amount___;


-- This method loops thru all the tax codes and calculates tax dom/parallel amounts.
-- In Gross Base needed to calculate tax curr amounts to find out the net curr amount.
PROCEDURE Calc_Tax_Dom_Para_Amounts___ (
   tax_info_table_         IN OUT tax_information_table,
   line_amount_rec_        IN OUT line_amount_rec,
   acc_curr_rec_           IN     acc_curr_rec,
   para_curr_rec_          IN     para_curr_rec,
   currency_               IN     VARCHAR2 )
IS
BEGIN
   FOR i IN 1 .. tax_info_table_.COUNT LOOP
      IF (tax_info_table_(i).tax_base_curr_amount IS NULL) THEN   
         tax_info_table_(i).tax_base_curr_amount := line_amount_rec_.line_net_curr_amount;
      END IF;        
      IF (Log_SYS.Is_Log_Set(Log_Category_API.DB_ALL)) THEN
         Trace_SYS.Message('************** Calc_Tax_Dom_Amount ****');
         Trace_SYS.Message('tax_code                : '||tax_info_table_(i).tax_code);      
      END IF;
      Calc_Tax_Dom_Amount___(tax_info_table_(i).total_tax_dom_amount, 
                             tax_info_table_(i).tax_dom_amount, 
                             tax_info_table_(i).non_ded_tax_dom_amount,                             
                             tax_info_table_(i).tax_base_dom_amount, 
                             currency_, 
                             tax_info_table_(i).use_specific_rate,
                             tax_info_table_(i).total_tax_curr_amount, 
                             tax_info_table_(i).tax_curr_amount, 
                             tax_info_table_(i).tax_base_curr_amount, 
                             NVL(tax_info_table_(i).curr_rate, acc_curr_rec_.curr_rate), 
                             tax_info_table_(i).tax_percentage, 
                             tax_info_table_(i).deductible_factor, 
                             acc_curr_rec_);
      IF (line_amount_rec_.consider_use_tax = Fnd_Boolean_API.DB_FALSE) THEN                             
         IF (tax_info_table_(i).tax_type_db IN (Fee_Type_API.DB_TAX, Fee_Type_API.DB_CALCULATED_TAX)) THEN
            line_amount_rec_.line_tax_dom_amount         := line_amount_rec_.line_tax_dom_amount + tax_info_table_(i).tax_dom_amount;
            line_amount_rec_.line_non_ded_tax_dom_amount := line_amount_rec_.line_non_ded_tax_dom_amount + tax_info_table_(i).non_ded_tax_dom_amount;
         END IF;
      ELSIF (line_amount_rec_.consider_use_tax = Fnd_Boolean_API.DB_TRUE) THEN                             
         IF (tax_info_table_(i).tax_type_db IN (Fee_Type_API.DB_TAX, Fee_Type_API.DB_USE_TAX, Fee_Type_API.DB_CALCULATED_TAX)) THEN
            line_amount_rec_.line_tax_dom_amount         := line_amount_rec_.line_tax_dom_amount + tax_info_table_(i).tax_dom_amount;
            line_amount_rec_.line_non_ded_tax_dom_amount := line_amount_rec_.line_non_ded_tax_dom_amount + tax_info_table_(i).non_ded_tax_dom_amount;
         END IF;
      END IF; 
      IF (para_curr_rec_.para_curr_code IS NOT NULL) THEN
         IF (Log_SYS.Is_Log_Set(Log_Category_API.DB_ALL)) THEN
            Trace_SYS.Message('************** Calc_Tax_Para_Amount ****');
            Trace_SYS.Message('tax_code                : '||tax_info_table_(i).tax_code);          
         END IF;
         Calc_Tax_Para_Amount___(tax_info_table_(i).total_tax_para_amount, tax_info_table_(i).tax_para_amount, tax_info_table_(i).non_ded_tax_para_amount, tax_info_table_(i).tax_base_para_amount, currency_, acc_curr_rec_.acc_curr_code, tax_info_table_(i).total_tax_curr_amount, tax_info_table_(i).total_tax_dom_amount, tax_info_table_(i).tax_curr_amount, tax_info_table_(i).tax_dom_amount, tax_info_table_(i).tax_base_curr_amount, tax_info_table_(i).tax_base_dom_amount, para_curr_rec_);
         IF (line_amount_rec_.consider_use_tax = Fnd_Boolean_API.DB_FALSE) THEN
            IF (tax_info_table_(i).tax_type_db IN (Fee_Type_API.DB_TAX, Fee_Type_API.DB_CALCULATED_TAX)) THEN
               line_amount_rec_.line_tax_para_amount         := line_amount_rec_.line_tax_para_amount + tax_info_table_(i).tax_para_amount;
               line_amount_rec_.line_non_ded_tax_para_amount := line_amount_rec_.line_non_ded_tax_para_amount + tax_info_table_(i).non_ded_tax_para_amount;
            END IF;
         ELSIF (line_amount_rec_.consider_use_tax = Fnd_Boolean_API.DB_TRUE) THEN
            IF (tax_info_table_(i).tax_type_db IN (Fee_Type_API.DB_TAX, Fee_Type_API.DB_USE_TAX, Fee_Type_API.DB_CALCULATED_TAX)) THEN
               line_amount_rec_.line_tax_para_amount         := line_amount_rec_.line_tax_para_amount + tax_info_table_(i).tax_para_amount;
               line_amount_rec_.line_non_ded_tax_para_amount := line_amount_rec_.line_non_ded_tax_para_amount + tax_info_table_(i).non_ded_tax_para_amount;
            END IF;
         END IF;         
      END IF;
   END LOOP;
   Update_Gross_Net_Dom_Amounts(line_amount_rec_, currency_, tax_info_table_, acc_curr_rec_);
END Calc_Tax_Dom_Para_Amounts___;


-- This method calculates tax dom amounts.
PROCEDURE Calc_Tax_Dom_Amount___ (
   total_tax_dom_amount_      OUT NUMBER,
   tax_dom_amount_            OUT NUMBER,
   non_ded_tax_dom_amount_    OUT NUMBER,
   tax_base_dom_amount_       OUT NUMBER,
   currency_                  IN  VARCHAR2,
   use_specific_rate_         IN  VARCHAR2,
   total_tax_curr_amount_     IN  NUMBER,
   tax_curr_amount_           IN  NUMBER,
   tax_base_curr_amount_      IN  NUMBER,
   curr_rate_                 IN  NUMBER,   
   tax_percentage_            IN  NUMBER,
   deductible_factor_         IN  NUMBER,
   acc_curr_rec_              IN  acc_curr_rec )
IS
BEGIN
   tax_base_dom_amount_ := Currency_Amount_API.Calc_Rounded_Acc_Curr_Amount(currency_, acc_curr_rec_.acc_curr_code, acc_curr_rec_.use_inverted_rate, tax_base_curr_amount_, curr_rate_, acc_curr_rec_.conv_factor, acc_curr_rec_.acc_curr_rounding);   
   IF (use_specific_rate_ = Fnd_Boolean_API.DB_TRUE) THEN
      IF (currency_ = acc_curr_rec_.acc_curr_code) THEN
         total_tax_dom_amount_ := total_tax_curr_amount_;
         tax_dom_amount_       := tax_curr_amount_;         
      ELSE
         total_tax_dom_amount_ := ROUND(tax_base_dom_amount_  * tax_percentage_ / 100,  acc_curr_rec_.acc_curr_rounding);
         tax_dom_amount_       := ROUND(total_tax_dom_amount_ * deductible_factor_, acc_curr_rec_.acc_curr_rounding);
      END IF;
   ELSE
      total_tax_dom_amount_ := Currency_Amount_API.Calc_Rounded_Acc_Curr_Amount(currency_, acc_curr_rec_.acc_curr_code, acc_curr_rec_.use_inverted_rate, total_tax_curr_amount_, curr_rate_, acc_curr_rec_.conv_factor, acc_curr_rec_.acc_curr_rounding);
      tax_dom_amount_       := Currency_Amount_API.Calc_Rounded_Acc_Curr_Amount(currency_, acc_curr_rec_.acc_curr_code, acc_curr_rec_.use_inverted_rate, tax_curr_amount_, curr_rate_, acc_curr_rec_.conv_factor, acc_curr_rec_.acc_curr_rounding);
   END IF;
   non_ded_tax_dom_amount_  := total_tax_dom_amount_ - tax_dom_amount_;
   IF (Log_SYS.Is_Log_Set(Log_Category_API.DB_ALL)) THEN
      Trace_SYS.Message('************** Calc_Tax_Dom_Amount ****');    
      Trace_SYS.Message('use_specific_rate       : '||NVL(use_specific_rate_, 'FALSE'));
      Trace_SYS.Message('use_inverted_rate       : '||acc_curr_rec_.use_inverted_rate);  
      Trace_SYS.Message('curr_rate_              : '||curr_rate_);
      Trace_SYS.Message('conv_factor             : '||acc_curr_rec_.conv_factor);
      Trace_SYS.Message('acc_curr_rounding       : '||acc_curr_rec_.acc_curr_rounding);
      Trace_SYS.Message('tax_base_curr_amount_   : '||tax_base_curr_amount_);  
      Trace_SYS.Message('tax_base_dom_amount_    : '||tax_base_dom_amount_); 
      Trace_SYS.Message('tax_percentage_         : '||tax_percentage_);
      Trace_SYS.Message('deductible_factor_      : '||deductible_factor_);
      Trace_SYS.Message('total_tax_dom_amount_   : '||total_tax_dom_amount_);
      Trace_SYS.Message('tax_dom_amount_         : '||tax_dom_amount_);
      Trace_SYS.Message('non_ded_tax_dom_amount_ : '||non_ded_tax_dom_amount_);
      Trace_SYS.Message('***************************************');  
   END IF;
END Calc_Tax_Dom_Amount___;


-- This method calculates tax parallel amounts.
PROCEDURE Calc_Tax_Para_Amount___ (
   total_tax_para_amount_     OUT NUMBER,
   tax_para_amount_           OUT NUMBER,
   non_ded_tax_para_amount_   OUT NUMBER,   
   tax_base_para_amount_      OUT NUMBER,
   currency_                  IN  VARCHAR2,
   acc_curr_code_             IN  VARCHAR2, 
   total_tax_curr_amount_     IN  NUMBER,
   total_tax_dom_amount_      IN  NUMBER,
   tax_curr_amount_           IN  NUMBER,
   tax_dom_amount_            IN  NUMBER,
   tax_base_curr_amount_      IN  NUMBER,
   tax_base_dom_amount_       IN  NUMBER,
   para_curr_rec_             IN  para_curr_rec )
IS
BEGIN   
   tax_base_para_amount_    := Currency_Amount_API.Calc_Parallel_Amt_Rate_Round(NULL, tax_base_dom_amount_, tax_base_curr_amount_, acc_curr_code_, currency_, para_curr_rec_.para_curr_rate, para_curr_rec_.para_conv_factor, para_curr_rec_.para_use_inverted_rate, para_curr_rec_.para_curr_code, para_curr_rec_.para_curr_base, para_curr_rec_.para_curr_rounding);          
   total_tax_para_amount_   := Currency_Amount_API.Calc_Parallel_Amt_Rate_Round(NULL, total_tax_dom_amount_, total_tax_curr_amount_, acc_curr_code_, currency_, para_curr_rec_.para_curr_rate, para_curr_rec_.para_conv_factor, para_curr_rec_.para_use_inverted_rate, para_curr_rec_.para_curr_code, para_curr_rec_.para_curr_base, para_curr_rec_.para_curr_rounding);
   tax_para_amount_         := Currency_Amount_API.Calc_Parallel_Amt_Rate_Round(NULL, tax_dom_amount_, tax_curr_amount_, acc_curr_code_, currency_, para_curr_rec_.para_curr_rate, para_curr_rec_.para_conv_factor, para_curr_rec_.para_use_inverted_rate, para_curr_rec_.para_curr_code, para_curr_rec_.para_curr_base, para_curr_rec_.para_curr_rounding);
   non_ded_tax_para_amount_ := total_tax_para_amount_ - tax_para_amount_;
   IF (Log_SYS.Is_Log_Set(Log_Category_API.DB_ALL)) THEN
      Trace_SYS.Message('************** Calc_Tax_Para_Amount ****');
      Trace_SYS.Message('para_curr_base           : '||para_curr_rec_.para_curr_base);
      Trace_SYS.Message('para_use_inverted_rate   : '||para_curr_rec_.para_use_inverted_rate);  
      Trace_SYS.Message('para_curr_rate           : '||para_curr_rec_.para_curr_rate);
      Trace_SYS.Message('para_curr_rounding       : '||para_curr_rec_.para_curr_rounding);
      Trace_SYS.Message('tax_base_para_amount_    : '||tax_base_para_amount_);  
      Trace_SYS.Message('total_tax_para_amount_   : '||total_tax_para_amount_); 
      Trace_SYS.Message('tax_para_amount_         : '||tax_para_amount_);
      Trace_SYS.Message('non_ded_tax_para_amount_ : '||non_ded_tax_para_amount_);
      Trace_SYS.Message('****************************************'); 
   END IF;
END Calc_Tax_Para_Amount___;


-- This method returns the total tax percentage for all the tax codes fetched with tax type TAX.
FUNCTION Get_Total_Tax_Percentage___ (
   tax_info_table_         IN  tax_information_table ) RETURN NUMBER
IS
   total_tax_percentage_   NUMBER := 0;
BEGIN   
   FOR i IN 1 .. tax_info_table_.COUNT LOOP
      IF (tax_info_table_(i).tax_type_db = Fee_Type_API.DB_TAX) THEN
         total_tax_percentage_ := NVL(total_tax_percentage_, 0) + tax_info_table_(i).tax_percentage;
      END IF;
   END LOOP;
   RETURN total_tax_percentage_;
END Get_Total_Tax_Percentage___;


-- This method returns TRUE if all the tax codes fetched are of tax type USE TAX.
FUNCTION Get_Only_Use_Tax___ (
   tax_info_table_         IN  tax_information_table ) RETURN VARCHAR2
IS
   only_use_tax_           VARCHAR2(5) := Fnd_Boolean_API.DB_TRUE;
BEGIN   
   FOR i IN 1 .. tax_info_table_.COUNT LOOP
      IF (only_use_tax_ = Fnd_Boolean_API.DB_TRUE AND tax_info_table_(i).tax_type_db != Fee_Type_API.DB_USE_TAX) THEN
         only_use_tax_ := Fnd_Boolean_API.DB_FALSE;
         RETURN only_use_tax_;
      END IF;
   END LOOP;
   RETURN only_use_tax_;
END Get_Only_Use_Tax___;


-- This method sets basic data for tax amount calculatiion in multiple tax.
PROCEDURE Set_Tax_Calc_Base_Info___ (
   tax_calc_base_percent_     OUT NUMBER,
   tax_calc_base_amount_      OUT NUMBER,
   use_tax_calc_base_amount_  OUT NUMBER,
   tax_info_table_            IN  tax_information_table,
   line_amount_rec_           IN  line_amount_rec )
IS
   only_use_tax_              VARCHAR2(5);
BEGIN
   IF (line_amount_rec_.tax_calc_base_amount IS NOT NULL) THEN
      -- Note: If line total tax curr amount is entered, it should be used to calculate tax amounts. However,
      --       the calculated line total tax curr amount can be different to original in multiple tax codes scenario.
      tax_calc_base_percent_ := Get_Total_Tax_Percentage___(tax_info_table_);
      tax_calc_base_amount_  := line_amount_rec_.tax_calc_base_amount;      
   ELSE
      IF (line_amount_rec_.calc_base = 'GROSS_BASE') THEN
         tax_calc_base_percent_ := Get_Total_Tax_Percentage___(tax_info_table_);
         tax_calc_base_amount_  := (line_amount_rec_.line_gross_curr_amount * tax_calc_base_percent_) / (100 + tax_calc_base_percent_);
      ELSIF (line_amount_rec_.calc_base = 'NET_BASE') THEN
         tax_calc_base_percent_    := 100;
         tax_calc_base_amount_     := line_amount_rec_.line_net_curr_amount;
      END IF; 
   END IF;
   IF (line_amount_rec_.calc_base = 'GROSS_BASE') THEN
      only_use_tax_ := Get_Only_Use_Tax___(tax_info_table_);
      IF (only_use_tax_ = Fnd_Boolean_API.DB_TRUE) THEN
         use_tax_calc_base_amount_ := line_amount_rec_.line_gross_curr_amount;
      ELSE
         use_tax_calc_base_amount_ := line_amount_rec_.line_gross_curr_amount - tax_calc_base_amount_;
      END IF; 
   ELSIF (line_amount_rec_.calc_base = 'NET_BASE') THEN
      use_tax_calc_base_amount_ := line_amount_rec_.line_net_curr_amount;
   END IF;
END Set_Tax_Calc_Base_Info___;


-- This method sets basic data for tax amount calculatiion in tax structure.
PROCEDURE Set_Tax_Calc_Base_Tax_Str___ (
   tax_calc_base_percent_     OUT    NUMBER,
   tax_calc_base_amount_      OUT    NUMBER,
   use_tax_calc_base_amount_  OUT    NUMBER,
   tax_info_table_            IN OUT tax_information_table,
   line_amount_rec_           IN     line_amount_rec,
   company_                   IN     VARCHAR2,
   index_                     IN     NUMBER )
IS
   tax_struct_item_ref_table_   Tax_Structure_Item_Ref_API.tax_structure_item_ref_table;
BEGIN     
   tax_calc_base_amount_  := 0;
   IF (tax_info_table_(index_).tax_base_curr_amount IS NOT NULL) THEN
      tax_calc_base_amount_ := tax_info_table_(index_).tax_base_curr_amount;
   ELSE
      IF (Tax_Structure_Item_API.Get_Incl_Price_In_Tax_Base_Db(company_, tax_info_table_(index_).tax_calc_structure_id, tax_info_table_(index_).tax_calc_structure_item_id) = Fnd_Boolean_API.DB_TRUE) THEN 
         tax_calc_base_amount_  := line_amount_rec_.line_net_curr_amount;
      END IF;            
      tax_struct_item_ref_table_ := Tax_Structure_Item_Ref_API.Get_Tax_Structure_Ref_Items(company_, tax_info_table_(index_).tax_calc_structure_id, tax_info_table_(index_).tax_calc_structure_item_id);
      FOR k IN 1 .. tax_struct_item_ref_table_.COUNT LOOP
         -- items in tax_info_table_ are inserted in calculation order defined in tax structure
         -- so we can assume here that all ref items necessary for calculation of current item are already calculated in tax_info_table_
         FOR i IN 1..(index_-1) LOOP
            IF (tax_info_table_(i).tax_calc_structure_item_id = tax_struct_item_ref_table_(k).item_id_ref) THEN
                tax_calc_base_amount_  := tax_calc_base_amount_ + tax_info_table_(i).total_tax_curr_amount;                
            END IF;   
         END LOOP;
      END LOOP;
   END IF;
   -- gelr: extend_tax_code_and_tax_struct, begin
   IF (Company_Localization_Info_API.Get_Parameter_Value_Db(company_, 'EXTEND_TAX_CODE_AND_TAX_STRUCT') = Fnd_Boolean_API.DB_TRUE) THEN
      Calc_Br_Tax_Base_Amount___(tax_calc_base_amount_, tax_info_table_, company_, index_);
   END IF;
   -- gelr: extend_tax_code_and_tax_struct, end
   tax_info_table_(index_).tax_base_curr_amount := tax_calc_base_amount_;
   use_tax_calc_base_amount_                    := tax_calc_base_amount_;         
   tax_calc_base_percent_                       := 100;
END Set_Tax_Calc_Base_Tax_Str___;


-- gelr: extend_tax_code_and_tax_struct, begin
-- This method is used to calculate tax base amount
PROCEDURE Calc_Br_Tax_Base_Amount___ (
   tax_calc_base_amount_   IN OUT NUMBER,
   tax_info_table_         IN     tax_information_table,
   company_                IN     VARCHAR2,
   index_                  IN     NUMBER )
IS
   mark_up_                NUMBER;
   tax_in_tax_base_        VARCHAR2(20);
   br_tax_percentage_      NUMBER;
BEGIN
   mark_up_ := NVL(Tax_Structure_Item_API.Get_Mark_Up(company_, tax_info_table_(index_).tax_calc_structure_id, tax_info_table_(index_).tax_calc_structure_item_id), 0);
   tax_calc_base_amount_ := tax_calc_base_amount_ * ((100 + mark_up_)/100);
   tax_in_tax_base_ := Statutory_Fee_API.Get_Tax_In_Tax_Base_Db(company_, tax_info_table_(index_).tax_code);
   IF (tax_in_tax_base_ = Fnd_Boolean_API.DB_TRUE) THEN
      br_tax_percentage_ := tax_info_table_(index_).br_tax_percentage;
      tax_calc_base_amount_ := (tax_calc_base_amount_ * 100) / (100 - br_tax_percentage_);
   END IF;
END Calc_Br_Tax_Base_Amount___;
-- gelr: extend_tax_code_and_tax_struct, end

-------------------- IMPLEMENTATION METHODS FOR VALIDATIONS -----------------

-- This method validates tax in objects such as Sales Object, Sales Part, Purchase Part per Supplier etc.
-- Validate_Tax_On_Object___ Input parameters:
-- is_taxable_db_:           TRUE/FALSE
-- tax_validation_type_:     CUSTOMER_TAX/SUPPLIER_TAX
PROCEDURE Validate_Tax_On_Object___ (
   company_                IN VARCHAR2,
   is_taxable_db_          IN VARCHAR2,
   tax_code_               IN VARCHAR2,
   tax_class_id_           IN VARCHAR2,
   object_id_              IN VARCHAR2,
   tax_validation_type_    IN VARCHAR2 )
IS
   tax_code_validation_   VARCHAR2(5);
BEGIN
   tax_code_validation_ := Company_Tax_Control_API.Get_Tax_Code_Validation(company_, tax_validation_type_, 'OBJECT');
   IF (tax_validation_type_ = 'CUSTOMER_TAX') THEN
      IF (tax_code_ IS NOT NULL AND tax_class_id_ IS NOT NULL) THEN
         Error_SYS.Record_General(lu_name_, 'CODE_OR_CLASS: You cannot enter both a Tax Code and a Tax Class.');
      END IF;
      IF (tax_code_validation_ = Fnd_Boolean_API.DB_TRUE) THEN
         IF (is_taxable_db_ = Fnd_Boolean_API.DB_TRUE) THEN
            IF (tax_code_ IS NULL AND tax_class_id_ IS NULL) THEN
               Error_SYS.Record_General(lu_name_, 'CUS_OBJ_TAX_MANDATORY1: A Tax Code or a Tax Class is required when customer tax validation has Object Level selected on Company, Tax Control tab and :P1 is taxable.', object_id_);
            END IF;
         ELSIF (is_taxable_db_ = Fnd_Boolean_API.DB_FALSE) THEN 
            IF (tax_code_ IS NULL AND tax_class_id_ IS NULL) THEN
               Error_SYS.Record_General(lu_name_, 'CUS_OBJ_TAX_MANDATORY2: A 0% Tax Code is required when customer tax validation has Object Level selected on Company, Tax Control tab and :P1 is not taxable.', object_id_);
            END IF;
         END IF;
      END IF;
   ELSIF (tax_validation_type_ = 'SUPPLIER_TAX') THEN
      IF (tax_code_validation_ = Fnd_Boolean_API.DB_TRUE) THEN
         IF (is_taxable_db_ = Fnd_Boolean_API.DB_TRUE) THEN
            IF (tax_code_ IS NULL) THEN
               Error_SYS.Record_General(lu_name_, 'SUP_OBJ_TAX_MANDATORY: A Tax Code is required when supplier tax validation has Object Level selected on Company, Tax Control tab and :P1 is taxable.', object_id_);
            END IF;
         END IF;
      END IF;
   END IF;
END Validate_Tax_On_Object___;


-- This method validates tax code.
-- Validate_Tax_Code___ Input parameters:
-- tax_types_event_:     RESTRICTED for customer side and COMMON for supplier side and common places (which are used from both customer and supplier)
-- taxable_event_:       ALL/EXEMPT/NOTAX
PROCEDURE Validate_Tax_Code___ (
   company_                IN VARCHAR2,
   tax_types_event_        IN VARCHAR2,
   tax_code_               IN VARCHAR2,
   taxable_event_          IN VARCHAR2,
   tax_liability_date_     IN DATE )
IS
   tax_rec_          Statutory_Fee_API.Public_Rec;
BEGIN
   tax_rec_ := Statutory_Fee_API.Fetch_Validate_Tax_Code_Rec(company_, tax_code_, tax_liability_date_, Fnd_Boolean_API.DB_FALSE, Fnd_Boolean_API.DB_TRUE, 'FETCH_AND_VALIDATE');
   IF (tax_types_event_ = 'RESTRICTED') THEN
      IF (tax_rec_.fee_type NOT IN (Fee_Type_API.DB_TAX, Fee_Type_API.DB_CALCULATED_TAX, Fee_Type_API.DB_NO_TAX)) THEN 
         Error_SYS.Record_General(lu_name_, 'INVTAXCODE1: You are not allowed to use Tax Codes of type :P1 or :P2.', Fee_Type_API.Decode(Fee_Type_API.DB_USE_TAX), Fee_Type_API.Decode(Fee_Type_API.DB_TAX_WITHHOLD));
      END IF;
   ELSIF (tax_types_event_ = 'COMMON') THEN
      IF (tax_rec_.fee_type NOT IN (Fee_Type_API.DB_TAX, Fee_Type_API.DB_CALCULATED_TAX, Fee_Type_API.DB_NO_TAX, Fee_Type_API.DB_USE_TAX)) THEN 
         Error_SYS.Record_General(lu_name_, 'INVTAXCODE3: You are not allowed to use Tax Codes of type :P1.', Fee_Type_API.Decode(Fee_Type_API.DB_TAX_WITHHOLD));
      END IF;
   END IF;
   IF (taxable_event_ = 'EXEMPT') THEN
      IF (tax_rec_.fee_type IN (Fee_Type_API.DB_TAX) AND tax_rec_.fee_rate != 0) THEN
         Error_SYS.Record_General(lu_name_, 'INVTAXCODE2: You are not allowed to use Tax Codes of type :P1 with percentage greater than 0%.', Fee_Type_API.Decode(Fee_Type_API.DB_TAX));
      END IF;
   END IF;
   IF (taxable_event_ = 'NOTAX') THEN
      IF (tax_rec_.fee_type != Fee_Type_API.DB_NO_TAX) THEN
         Error_SYS.Record_General(lu_name_, 'INVTAXCODE5: You are only allowed to use Tax Codes of type :P1.', Fee_Type_API.Decode(Fee_Type_API.DB_NO_TAX));
      END IF;
   END IF;
END Validate_Tax_Code___;


PROCEDURE Validate_Tax_Code_In_Struct___ (
   company_              IN VARCHAR2,
   tax_code_             IN VARCHAR2,
   tax_liability_date_   IN DATE )
IS
   tax_rec_          Statutory_Fee_API.Public_Rec;
BEGIN
   tax_rec_ := Statutory_Fee_API.Fetch_Validate_Tax_Code_Rec(company_, tax_code_, tax_liability_date_, Fnd_Boolean_API.DB_FALSE, Fnd_Boolean_API.DB_TRUE, 'FETCH_AND_VALIDATE');
   IF (tax_rec_.fee_type NOT IN (Fee_Type_API.DB_TAX) OR tax_rec_.vat_received NOT IN (Vat_Method_API.DB_INVOICE_ENTRY) OR tax_rec_.vat_disbursed NOT IN (Vat_Method_API.DB_INVOICE_ENTRY)) THEN
      Error_SYS.Record_General(lu_name_, 'INVTAXCODE4: Only Tax Codes of type :P1 and with tax method :P2 are allowed to use.', Fee_Type_API.Decode(Fee_Type_API.DB_TAX), Vat_Method_API.Decode(Vat_Method_API.DB_INVOICE_ENTRY));
   END IF;
END Validate_Tax_Code_In_Struct___;


PROCEDURE Validate_Tax_Code_On_Acc___ (
   company_            IN VARCHAR2,
   account_            IN VARCHAR2,
   tax_code_           IN VARCHAR2 )
IS
   tax_handling_value_   VARCHAR2(10);
   tax_type_db_          VARCHAR2(10);
BEGIN
   IF (account_ IS NOT NULL) THEN
      tax_handling_value_ := Account_API.Get_Tax_Handling_Value_Db(company_, account_);
      tax_type_db_ := Statutory_Fee_API.Get_Fee_Type_Db(company_, tax_code_);
      IF ((tax_handling_value_ = Tax_Handling_Value_API.DB_BLOCKED) AND (tax_code_ IS NOT NULL) AND (tax_type_db_ != Fee_Type_API.DB_NO_TAX)) THEN
         Error_SYS.Record_General(lu_name_, 'ACCOUNTBLOCKED: You are not allowed to enter a Tax Code when Tax Handling for Account :P1 is set to :P2', account_, Tax_Handling_Value_API.Decode(tax_handling_value_));
      END IF;
      IF (tax_handling_value_ = Tax_Handling_Value_API.DB_RESTRICTED AND tax_code_ IS NOT NULL) THEN
         IF (NOT Account_Tax_Code_API.Exists(company_, account_, tax_code_)) THEN
            Error_SYS.Record_General(lu_name_, 'ACCOUNTRES: Tax Code :P1 is not valid to use for Account :P2', tax_code_, account_);
         END IF;
      END IF;
   END IF;
END Validate_Tax_Code_On_Acc___;

-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------

-------------------- LU SPECIFIC PROTECTED METHODS --------------------------

-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

-------------------- PUBLIC METHODS FOR FETCHING TAX CODE INFO -------------

-- This method fetches tax codes to tax table.
-- Fetch_Tax_Codes Input parameters:
-- action_:     FETCH_DEFAULT_TAX/NULL
PROCEDURE Fetch_Tax_Codes (
   multiple_tax_                   OUT VARCHAR2,
   tax_class_id_                   OUT VARCHAR2,
   tax_method_                     OUT VARCHAR2,
   tax_method_db_                  OUT VARCHAR2,
   tax_type_db_                    OUT VARCHAR2,
   tax_percentage_                 OUT NUMBER,
   tax_info_table_              IN OUT tax_information_table,
   tax_source_object_rec_       IN OUT tax_source_object_rec,
   tax_code_                    IN OUT VARCHAR2,
   tax_calc_structure_id_       IN OUT VARCHAR2,
   company_                     IN     VARCHAR2,
   action_                      IN     VARCHAR2,
   tax_liability_date_          IN     DATE,
   identity_rec_                IN     identity_rec,
   fetch_default_key_rec_       IN     fetch_default_key_rec,
   source_key_rec_              IN     source_key_rec,
   validation_rec_              IN     validation_rec,
   add_tax_curr_amount_         IN     VARCHAR2 )
IS
BEGIN
   IF (tax_info_table_.COUNT = 0) THEN
      IF (action_ = 'FETCH_DEFAULT_TAX') THEN
         Fetch_Default_Tax_Codes(tax_info_table_, tax_source_object_rec_, company_, tax_liability_date_, identity_rec_, fetch_default_key_rec_, validation_rec_);
      ELSE
         Fetch_Saved_Tax_Codes(tax_info_table_, company_, identity_rec_.party_type_db, tax_code_, tax_calc_structure_id_, tax_liability_date_, source_key_rec_, validation_rec_, add_tax_curr_amount_);
      END IF;
   END IF;
   Set_Tax_Code_Info(multiple_tax_, tax_calc_structure_id_, tax_class_id_, tax_code_, tax_method_, tax_method_db_, tax_type_db_, tax_percentage_, tax_source_object_rec_, tax_info_table_);      
END Fetch_Tax_Codes;  


-- This method fetches default tax codes to tax table.
PROCEDURE Fetch_Default_Tax_Codes (
   tax_info_table_                 OUT tax_information_table,
   tax_source_object_rec_       IN OUT tax_source_object_rec,
   company_                     IN     VARCHAR2,   
   tax_liability_date_          IN     DATE,
   identity_rec_                IN     identity_rec,
   fetch_default_key_rec_       IN     fetch_default_key_rec,
   validation_rec_              IN     validation_rec )
IS
   tax_calc_structure_id_  VARCHAR2(20);
BEGIN
   Fetch_Tax_Code_On_Object___(tax_source_object_rec_, company_, tax_liability_date_, identity_rec_, fetch_default_key_rec_);
   IF (tax_source_object_rec_.is_taxable_db = Fnd_Boolean_API.DB_FALSE) THEN
      IF (tax_source_object_rec_.object_tax_code IS NOT NULL) THEN    
         Add_Tax_Code_Info(tax_info_table_, company_, identity_rec_.party_type_db, tax_source_object_rec_.object_tax_code, NULL, NULL, validation_rec_.fetch_validate_action, NULL, tax_liability_date_);    
      END IF; 
   ELSIF (tax_source_object_rec_.is_taxable_db = Fnd_Boolean_API.DB_TRUE) THEN
      IF (identity_rec_.tax_liability_type_db =  Tax_Liability_Type_API.DB_EXEMPT) THEN
         IF (tax_source_object_rec_.object_type IN ('PURCHASE_PART', 'PURCH_CHARGE_TYPE', 'PURCH_CHARGE_SUPP', 'PURCH_CHARGE_SUPP_PART')) THEN
            IF (tax_source_object_rec_.object_tax_code IS NOT NULL) THEN    
               Add_Tax_Code_Info(tax_info_table_, company_, identity_rec_.party_type_db, tax_source_object_rec_.object_tax_code, NULL, NULL, validation_rec_.fetch_validate_action, NULL, tax_liability_date_);    
            END IF ;             
         ELSE
            Fetch_Tax_Free_Tax_Code___(tax_info_table_, company_, tax_source_object_rec_.object_type, validation_rec_.fetch_validate_action, tax_liability_date_, identity_rec_);
         END IF;
      ELSIF (identity_rec_.tax_liability_type_db = Tax_Liability_Type_API.DB_TAXABLE) THEN
         Fetch_Tax_Codes_On_Address___(tax_calc_structure_id_, tax_info_table_, company_, tax_source_object_rec_.object_tax_code, tax_liability_date_, identity_rec_, validation_rec_);
         -- do not add tax code from object in case tax structure is used
         IF (tax_calc_structure_id_ IS NULL) THEN            
            IF (tax_source_object_rec_.object_tax_code IS NOT NULL) THEN    
               Add_Tax_Code_Info(tax_info_table_, company_, identity_rec_.party_type_db, tax_source_object_rec_.object_tax_code, NULL, NULL, validation_rec_.fetch_validate_action, NULL, tax_liability_date_);    
            END IF; 
         END IF;   
      END IF; 
   END IF;
   IF (validation_rec_.validate_tax_from_tax_class = Fnd_Boolean_API.DB_TRUE) THEN
      IF (tax_source_object_rec_.object_tax_class_id IS NOT NULL AND tax_source_object_rec_.object_tax_code IS NULL) THEN    
         IF (identity_rec_.tax_liability_type_db = Tax_Liability_Type_API.DB_TAXABLE AND tax_info_table_.COUNT = 0) THEN
            Error_SYS.Record_General(lu_name_, 'NOTAXCLASSTAXID: A tax code cannot be found for the tax class :P1, delivery country :P2 and tax liability :P3.', tax_source_object_rec_.object_tax_class_id, Iso_Country_API.Decode(NVL(identity_rec_.supply_country_db, identity_rec_.delivery_country_db)), identity_rec_.tax_liability);
         ELSE
            tax_source_object_rec_.object_tax_class_id := NULL;
         END IF;
      END IF;
   END IF;
END Fetch_Default_Tax_Codes;


-- This method fetches default tax codes on Address.
PROCEDURE Fetch_Tax_Codes_On_Address (
   tax_info_table_         IN OUT tax_information_table, 
   company_                IN     VARCHAR2,
   calc_base_              IN     VARCHAR2,
   fetch_validate_action_  IN     VARCHAR2,
   tax_code_selection_     IN     VARCHAR2,    
   tax_liability_date_     IN     DATE,
   identity_rec_           IN     identity_rec )
IS 
   tax_calc_structure_id_  VARCHAR2(20);
   validation_rec_         validation_rec;
BEGIN
   validation_rec_ := Create_Validation_Rec(calc_base_, fetch_validate_action_, Fnd_Boolean_API.DB_TRUE, NULL);
   Fetch_Tax_Codes_On_Address___(tax_calc_structure_id_, tax_info_table_, company_, tax_code_selection_, tax_liability_date_, identity_rec_, validation_rec_); 
END Fetch_Tax_Codes_On_Address;


-- This method fetches default tax codes on Tax Structure.
PROCEDURE Fetch_Tax_Codes_On_Tax_Str (
   tax_info_table_         OUT tax_information_table,
   company_                IN  VARCHAR2,
   party_type_db_          IN  VARCHAR2,
   tax_calc_structure_id_  IN  VARCHAR2,
   tax_liability_date_     IN  DATE,
   validation_rec_         IN  validation_rec )    
IS 
BEGIN
  Fetch_Tax_Codes_On_Tax_Str___(tax_info_table_, company_, party_type_db_, tax_calc_structure_id_, tax_liability_date_, validation_rec_); 
END Fetch_Tax_Codes_On_Tax_Str;


PROCEDURE Fetch_Default_Tax_Code_On_Acc (
   tax_code_             OUT VARCHAR2,
   tax_direction_        OUT VARCHAR2,
   tax_type_db_          OUT VARCHAR2,
   tax_percentage_       OUT NUMBER,
   company_              IN  VARCHAR2,
   account_              IN  VARCHAR2,
   transaction_date_     IN  DATE )
IS
   tax_rec_              Statutory_Fee_API.Public_Rec;
   tax_direction_db_     VARCHAR2(20);
BEGIN
   tax_code_ := Account_Tax_Code_API.Get_Default_Tax_Code(company_, account_);
   Fetch_Default_Tax_Direction(tax_direction_, tax_direction_db_, company_, account_, tax_code_);
   IF (tax_code_ IS NOT NULL) THEN
      tax_rec_        := Statutory_Fee_API.Fetch_Validate_Tax_Code_Rec(company_, tax_code_, transaction_date_, Fnd_Boolean_API.DB_FALSE, Fnd_Boolean_API.DB_TRUE, 'FETCH_ALWAYS');
      tax_type_db_    := tax_rec_.fee_type;
      tax_percentage_ := tax_rec_.fee_rate;   
   END IF;
END Fetch_Default_Tax_Code_On_Acc;


-- This method fetches saved tax codes.
-- Note: Always send in saved tax_code_ or saved tax_calc_structure_id_when modifying the @Override
--       Null value considered as deleting of saved tax_code_ or saved tax_calc_structure_id.
PROCEDURE Fetch_Saved_Tax_Codes (
   tax_info_table_            OUT tax_information_table,
   company_                   IN  VARCHAR2,
   party_type_db_             IN  VARCHAR2,
   tax_code_                  IN  VARCHAR2,
   tax_calc_structure_id_     IN  VARCHAR2,
   tax_liability_date_        IN  DATE,
   source_key_rec_            IN  source_key_rec,
   validation_rec_            IN  validation_rec,
   add_tax_curr_amount_       IN  VARCHAR2 )
IS
   saved_tax_code_msg_           VARCHAR2(32000);
   saved_tax_code_               VARCHAR2(20);
   saved_tax_calc_struct_id_     VARCHAR2(20);
   saved_tax_percentage_         NUMBER;    
   saved_tax_base_curr_amount_   NUMBER;
BEGIN
   Source_Tax_Item_API.Get_Tax_Codes(saved_tax_code_msg_, saved_tax_code_, saved_tax_calc_struct_id_, saved_tax_percentage_, saved_tax_base_curr_amount_, company_, source_key_rec_.source_ref_type, source_key_rec_.source_ref1, source_key_rec_.source_ref2, source_key_rec_.source_ref3, source_key_rec_.source_ref4, source_key_rec_.source_ref5, add_tax_curr_amount_); 
   Add_Saved_Tax_Code_Info(tax_info_table_, tax_code_, tax_calc_structure_id_, saved_tax_code_msg_, saved_tax_code_, saved_tax_calc_struct_id_, saved_tax_percentage_, saved_tax_base_curr_amount_, company_, party_type_db_, tax_liability_date_, validation_rec_);   
END Fetch_Saved_Tax_Codes;

-------------------- PUBLIC METHODS FOR FETCHING TAX RELATED INFO ----------

-- This method returns tax liability of the Customer Delivery Address Id.
FUNCTION Get_Customer_Tax_Liability ( 
   customer_id_            IN VARCHAR2,
   delivery_address_id_    IN VARCHAR2,
   company_                IN VARCHAR2, 
   supply_country_db_      IN VARCHAR2 ) RETURN VARCHAR2   
IS
   tax_liability_          VARCHAR2(20);
BEGIN
   $IF Component_Invoic_SYS.INSTALLED $THEN   
      tax_liability_ := Customer_Delivery_Tax_Info_API.Get_Tax_Liability(customer_id_, delivery_address_id_, company_, supply_country_db_);                       
   $END    
   IF (tax_liability_ IS NULL AND Customer_Info_API.Get_Customer_Category_Db(customer_id_) = Customer_Category_API.DB_PROSPECT) THEN
      IF (delivery_address_id_ IS NOT NULL) THEN
         tax_liability_ := 'EXEMPT';
      ELSE
         tax_liability_ := NVL(Company_Tax_Control_API.Get_Tax_Liability(company_), 'EXEMPT'); 
      END IF;
   END IF;
   RETURN tax_liability_;
END Get_Customer_Tax_Liability; 


-- This method returns tax liability type db of the Customer Delivery Address Id.
FUNCTION Get_Cust_Tax_Liability_Type_Db (  
   customer_id_                  IN VARCHAR2,
   delivery_address_id_          IN VARCHAR2,
   company_                      IN VARCHAR2, 
   supply_country_db_            IN VARCHAR2,
   cust_deliv_addr_country_db_   IN VARCHAR2 ) RETURN VARCHAR2      
IS
   tax_liability_                VARCHAR2(20);
   tax_liability_type_db_        VARCHAR2(20);
BEGIN   
   tax_liability_          := Get_Customer_Tax_Liability(customer_id_, delivery_address_id_, company_, supply_country_db_);      
   tax_liability_type_db_  := Tax_Liability_API.Get_Tax_Liability_Type_Db(tax_liability_, cust_deliv_addr_country_db_);
   RETURN tax_liability_type_db_;
END Get_Cust_Tax_Liability_Type_Db;


-- This method returns tax liability/tax liability type db of the Customer Delivery Address Id.
PROCEDURE Get_Cust_Tax_Liability_Info (
   tax_liability_                OUT VARCHAR2,
   tax_liability_type_db_        OUT VARCHAR2,
   customer_id_                  IN  VARCHAR2,
   delivery_address_id_          IN  VARCHAR2,
   company_                      IN  VARCHAR2, 
   supply_country_db_            IN  VARCHAR2,
   cust_deliv_addr_country_db_   IN  VARCHAR2 )   
IS
BEGIN
   tax_liability_ := Get_Customer_Tax_Liability(customer_id_, delivery_address_id_, company_, supply_country_db_);
   tax_liability_type_db_  := Tax_Liability_API.Get_Tax_Liability_Type_Db(tax_liability_, cust_deliv_addr_country_db_);
END Get_Cust_Tax_Liability_Info; 


-- This method returns tax liability/tax liability type db of the Supplier.
PROCEDURE Get_Supp_Tax_Liability_Info (
   tax_liability_          OUT VARCHAR2,
   tax_liability_type_db_  OUT VARCHAR2,
   supplier_id_            IN  VARCHAR2,
   company_                IN  VARCHAR2 ) 
IS
   party_type_             VARCHAR2(20) := Party_Type_API.Decode(Party_Type_API.DB_SUPPLIER);
   supply_country_db_      VARCHAR2(2);   
BEGIN
   IF (Supplier_Info_API.Get_Supplier_Category_Db(supplier_id_) = Supplier_Info_Category_API.DB_PROSPECT) THEN
      tax_liability_  := 'EXEMPT';
   ELSE
      $IF Component_Invoic_SYS.INSTALLED $THEN
         tax_liability_ := Identity_Invoice_Info_API.Get_Tax_Liability(company_, supplier_id_, party_type_);    
      $ELSIF Component_Purch_SYS.INSTALLED $THEN
         tax_liability_ := Supplier_API.Get_Tax_Liability(supplier_id_);
      $ELSE
         NULL;
      $END
   END IF;
   supply_country_db_     := Supplier_Info_General_API.Get_Country_Db(supplier_id_);
   tax_liability_type_db_ := Tax_Liability_API.Get_Tax_Liability_Type_Db(tax_liability_, supply_country_db_);   
END Get_Supp_Tax_Liability_Info; 


-- This method returns tax rounding method db of Customer Delivery Address Id/Company.
@UncheckedAccess
FUNCTION Get_Tax_Rounding_Method_Db (
   company_          IN VARCHAR2,
   identity_         IN VARCHAR2,
   party_type_db_    IN VARCHAR2,
   deliv_address_id_ IN VARCHAR2 ) RETURN VARCHAR2
IS
   tax_rounding_method_db_ VARCHAR2(20);
   address_id_             VARCHAR2(50);
BEGIN
   $IF Component_Invoic_SYS.INSTALLED $THEN
      IF (party_type_db_ = Party_Type_API.DB_CUSTOMER) THEN
         IF (deliv_address_id_ IS NULL) THEN
            address_id_ := Customer_Info_Address_API.Get_Default_Address(identity_, Address_Type_Code_API.Decode(Address_Type_Code_API.DB_DELIVERY));
         ELSE
            address_id_ := deliv_address_id_;
         END IF;
         tax_rounding_method_db_ := Customer_Tax_Info_API.Get_Tax_Rounding_Method_Db(identity_, address_id_, company_);
      END IF;
   $END
   IF (tax_rounding_method_db_ IS NULL) THEN
      tax_rounding_method_db_ := Company_Tax_Control_API.Get_Tax_Rounding_Method_Db(company_);      
   END IF; 
   RETURN tax_rounding_method_db_;
END Get_Tax_Rounding_Method_Db;


FUNCTION Fetch_Default_Tax_Direction_Db (
   company_               IN  VARCHAR2,
   account_               IN  VARCHAR2,
   tax_code_              IN  VARCHAR2 ) RETURN VARCHAR2
IS
   account_type_        VARCHAR2(20);
   tax_type_db_         VARCHAR2(20);
   tax_direction_db_    VARCHAR2(20);
BEGIN 
   IF (tax_code_ IS NOT NULL) THEN
      tax_type_db_ := Statutory_Fee_API.Get_Fee_Type_Db(company_, tax_code_);
   END IF;
   IF (account_ IS NOT NULL) THEN
      account_type_ := Account_API.Get_Accnt_Type_Db(company_, account_);
      IF (tax_type_db_ = Fee_Type_API.DB_NO_TAX) THEN
         tax_direction_db_ := Tax_Direction_API.DB_NO_TAX;
      ELSIF (account_type_ IN (Account_Type_Value_API.DB_ASSETS, Account_Type_Value_API.DB_COST)) THEN
         tax_direction_db_ := Tax_Direction_API.DB_TAX_RECEIVED;
      ELSE
         tax_direction_db_ := Tax_Direction_API.DB_TAX_DISBURSED;
      END IF;
   ELSE
      IF (tax_type_db_ = Fee_Type_API.DB_NO_TAX) THEN
         tax_direction_db_ := Tax_Direction_API.DB_NO_TAX;
      ELSE
         tax_direction_db_ := '';
      END IF;
   END IF;  
   RETURN tax_direction_db_;
END Fetch_Default_Tax_Direction_Db;


PROCEDURE Fetch_Default_Tax_Direction (
   tax_direction_         OUT VARCHAR2,
   tax_direction_db_      OUT VARCHAR2,
   company_               IN  VARCHAR2,
   account_               IN  VARCHAR2,
   tax_code_              IN  VARCHAR2 )
IS   
BEGIN
   tax_direction_db_ := Fetch_Default_Tax_Direction_Db(company_, account_, tax_code_);
   tax_direction_    := Tax_Direction_API.Decode(tax_direction_db_);
END Fetch_Default_Tax_Direction;


@UncheckedAccess
FUNCTION Get_Rounded_Amount (
   company_    IN VARCHAR2,
   identity_   IN VARCHAR2,
   party_type_ IN VARCHAR2,
   curr_code_  IN VARCHAR2,
   amount_     IN NUMBER,
   address_id_ IN VARCHAR2 ) RETURN NUMBER
IS
   rounding_method_ VARCHAR2(20);
   decimals_        NUMBER;
   party_type_db_   VARCHAR2(20) := Party_Type_API.Encode(party_type_);
BEGIN
   rounding_method_ := Get_Tax_Rounding_Method_Db(company_, identity_, party_type_db_, address_id_);
   decimals_        := Currency_Code_API.Get_Currency_Rounding(company_, curr_code_);
   IF (decimals_ IS NULL) THEN
      RETURN amount_;
   END IF;
   RETURN Currency_Amount_API.Round_Amount(rounding_method_, amount_, decimals_);  
END Get_Rounded_Amount;

-------------------- PUBLIC METHODS FOR CALCULATIONS -----------------------

-- This method loops thru all the tax codes and calculates tax curr amounts.
PROCEDURE Calc_Tax_Curr_Amounts ( 
   tax_info_table_         IN OUT tax_information_table,
   line_amount_rec_        IN OUT line_amount_rec,
   company_                IN     VARCHAR2,
   trans_curr_rec_         IN     trans_curr_rec )
IS
   tax_calc_base_percent_     NUMBER;
   tax_calc_base_amount_      NUMBER;
   use_tax_calc_base_amount_  NUMBER;
BEGIN
   FOR i IN 1 .. tax_info_table_.COUNT LOOP
      IF (tax_info_table_(i).tax_curr_amount IS NULL) THEN
         IF (tax_info_table_(i).tax_calc_structure_id IS NULL) THEN   
            Set_Tax_Calc_Base_Info___(tax_calc_base_percent_, tax_calc_base_amount_, use_tax_calc_base_amount_, tax_info_table_, line_amount_rec_);
         ELSE
            Set_Tax_Calc_Base_Tax_Str___(tax_calc_base_percent_, tax_calc_base_amount_, use_tax_calc_base_amount_, tax_info_table_, line_amount_rec_, company_, i);
         END IF;      
         IF (Log_SYS.Is_Log_Set(Log_Category_API.DB_ALL)) THEN
            Trace_SYS.Message('************** Calc_Tax_Curr_Amount ***');
            Trace_SYS.Message('tax_code                  : '||tax_info_table_(i).tax_code);      
         END IF;
         Calc_Tax_Curr_Amount___(tax_info_table_(i).total_tax_curr_amount,
                                 tax_info_table_(i).tax_curr_amount,
                                 tax_info_table_(i).non_ded_tax_curr_amount,
                                 tax_info_table_(i).tax_type_db,
                                 tax_calc_base_amount_,
                                 tax_calc_base_percent_,
                                 use_tax_calc_base_amount_,
                                 tax_info_table_(i).tax_percentage,
                                 tax_info_table_(i).deductible_factor,
                                 trans_curr_rec_);
      END IF;
      IF (line_amount_rec_.consider_use_tax = Fnd_Boolean_API.DB_FALSE) THEN
         IF (tax_info_table_(i).tax_type_db IN (Fee_Type_API.DB_TAX, Fee_Type_API.DB_CALCULATED_TAX)) THEN
            line_amount_rec_.line_tax_curr_amount         := line_amount_rec_.line_tax_curr_amount + tax_info_table_(i).tax_curr_amount;
            line_amount_rec_.line_non_ded_tax_curr_amount := line_amount_rec_.line_non_ded_tax_curr_amount + tax_info_table_(i).non_ded_tax_curr_amount;
         END IF;
      ELSIF (line_amount_rec_.consider_use_tax = Fnd_Boolean_API.DB_TRUE) THEN
         IF (tax_info_table_(i).tax_type_db IN (Fee_Type_API.DB_TAX, Fee_Type_API.DB_USE_TAX, Fee_Type_API.DB_CALCULATED_TAX)) THEN
            line_amount_rec_.line_tax_curr_amount         := line_amount_rec_.line_tax_curr_amount + tax_info_table_(i).tax_curr_amount;
            line_amount_rec_.line_non_ded_tax_curr_amount := line_amount_rec_.line_non_ded_tax_curr_amount + tax_info_table_(i).non_ded_tax_curr_amount;
         END IF;
      END IF;      
   END LOOP;
   Update_Gross_Net_Curr_Amounts(line_amount_rec_);
END Calc_Tax_Curr_Amounts;


-- This method calculates tax curr/dom/parallel amounts for tax codes in tax table.
PROCEDURE Calc_Line_Total_Amounts ( 
   tax_info_table_         IN OUT tax_information_table,
   line_amount_rec_        IN OUT line_amount_rec,
   company_                IN     VARCHAR2,
   trans_curr_rec_         IN     trans_curr_rec,
   acc_curr_rec_           IN     acc_curr_rec,
   para_curr_rec_          IN     para_curr_rec )
IS
BEGIN
   Calc_Tax_Curr_Amounts(tax_info_table_, line_amount_rec_, company_, trans_curr_rec_);
   Calc_Tax_Dom_Para_Amounts___(tax_info_table_, line_amount_rec_, acc_curr_rec_, para_curr_rec_, trans_curr_rec_.currency);
END Calc_Line_Total_Amounts;


--   Calc_Tax_Curr_Amount Input/Output parameters:
--   total_tax_curr_amount_:         used for party_type_db = SUPPLIER
--   non_ded_tax_curr_amount_:       used for party_type_db = SUPPLIER
--   identity_:                      used for party_type_db = CUSTOMER
--   delivery_address_id_:           used for party_type_db = CUSTOMER
--   attr_:                          facilitate extensions in localisation.
--   tax_calc_base_amount_:          refer Set_Tax_Calc_Base_Info___ to set the value.
--   tax_calc_base_percent_:         refer Set_Tax_Calc_Base_Info___ to set the value.
--   use_tax_calc_base_amount_:      refer Set_Tax_Calc_Base_Info___ to set the value.
--   in_deductible_factor_:          used for party_type_db = CUSTOMER
PROCEDURE Calc_Tax_Curr_Amount (
   total_tax_curr_amount_     OUT    NUMBER,
   tax_curr_amount_           OUT    NUMBER,
   non_ded_tax_curr_amount_   OUT    NUMBER,
   attr_                      IN OUT VARCHAR2,  
   company_                   IN     VARCHAR2, 
   identity_                  IN     VARCHAR2,
   party_type_db_             IN     VARCHAR2,
   currency_                  IN     VARCHAR2,
   delivery_address_id_       IN     VARCHAR2,
   tax_code_                  IN     VARCHAR2,
   tax_type_db_               IN     VARCHAR2,
   tax_calc_base_amount_      IN     NUMBER,
   tax_calc_base_percent_     IN     NUMBER,
   use_tax_calc_base_amount_  IN     NUMBER,
   tax_percentage_            IN     NUMBER,
   in_deductible_factor_      IN     NUMBER )
IS
   deductible_factor_         NUMBER;
   trans_curr_rec_            trans_curr_rec;
BEGIN 
   trans_curr_rec_    := Create_Trans_Curr_Rec(company_, identity_, party_type_db_, currency_, delivery_address_id_, attr_, NULL, NULL);
   deductible_factor_ := NVL(in_deductible_factor_, Statutory_Fee_API.Get_Deductible(company_, tax_code_) / 100);
   IF (Log_SYS.Is_Log_Set(Log_Category_API.DB_ALL)) THEN
      Trace_SYS.Message('************** Calc_Tax_Curr_Amount ***');
      Trace_SYS.Message('tax_code                   : '||tax_code_);   
   END IF;
   Calc_Tax_Curr_Amount___(total_tax_curr_amount_, 
                           tax_curr_amount_, 
                           non_ded_tax_curr_amount_,
                           tax_type_db_, 
                           tax_calc_base_amount_, 
                           tax_calc_base_percent_,
                           use_tax_calc_base_amount_,
                           tax_percentage_, 
                           deductible_factor_, 
                           trans_curr_rec_);
END Calc_Tax_Curr_Amount;


-- This method is to be used from supplier side client when modifying total tax amount.
PROCEDURE Calc_Tax_Curr_Amount (
   tax_curr_amount_           OUT NUMBER,
   non_ded_tax_curr_amount_   OUT NUMBER,
   company_                   IN  VARCHAR2, 
   currency_                  IN  VARCHAR2,
   tax_code_                  IN  VARCHAR2,
   total_tax_curr_amount_     IN  NUMBER )
IS
   tax_rounding_method_       VARCHAR2(20);			
   curr_rounding_             NUMBER; 
   deductible_factor_         NUMBER;
BEGIN
   tax_rounding_method_     := Get_Tax_Rounding_Method_Db(company_, NULL, Party_Type_API.DB_SUPPLIER, NULL);
   curr_rounding_           := Currency_Code_API.Get_Currency_Rounding(company_, currency_);
   deductible_factor_       := Statutory_Fee_API.Get_Deductible(company_, tax_code_) / 100; 
   tax_curr_amount_         := Currency_Amount_API.Round_Amount(tax_rounding_method_, (total_tax_curr_amount_ * deductible_factor_), curr_rounding_);
   non_ded_tax_curr_amount_ := total_tax_curr_amount_ - tax_curr_amount_; 
END Calc_Tax_Curr_Amount;


-- This method calculates tax dom amount for a tax code.
PROCEDURE Calc_Tax_Dom_Amount (
   total_tax_dom_amount_      OUT    NUMBER,
   tax_dom_amount_            OUT    NUMBER,
   non_ded_tax_dom_amount_    OUT    NUMBER,   
   tax_base_dom_amount_       OUT    NUMBER,
   attr_                      IN OUT VARCHAR2,  -- this is to facilitate extensions in localisation.
   company_                   IN     VARCHAR2,
   currency_                  IN     VARCHAR2,
   use_specific_rate_         IN     VARCHAR2,
   tax_code_                  IN     VARCHAR2,
   total_tax_curr_amount_     IN     NUMBER,
   tax_curr_amount_           IN     NUMBER,
   tax_base_curr_amount_      IN     NUMBER,
   tax_percentage_            IN     NUMBER,
   in_deductible_factor_      IN     NUMBER,
   curr_rate_                 IN     NUMBER, -- this curr_rate_ should only be used to calculate tax dom amounts.
   conv_factor_               IN     NUMBER )
IS
   deductible_factor_         NUMBER;
   acc_curr_rec_              acc_curr_rec;            
BEGIN 
   acc_curr_rec_      := Create_Acc_Curr_Rec(company_, attr_, curr_rate_, conv_factor_, NULL);
   deductible_factor_ := NVL(in_deductible_factor_, Statutory_Fee_API.Get_Deductible(company_, tax_code_) / 100);  
   Calc_Tax_Dom_Amount___(total_tax_dom_amount_, 
                          tax_dom_amount_,
                          non_ded_tax_dom_amount_,
                          tax_base_dom_amount_, 
                          currency_, 
                          use_specific_rate_,
                          total_tax_curr_amount_, 
                          tax_curr_amount_, 
                          tax_base_curr_amount_, 
                          curr_rate_, 
                          tax_percentage_, 
                          deductible_factor_, 
                          acc_curr_rec_);                         
END Calc_Tax_Dom_Amount;


-- This method calculates tax parallel amount for a tax code.
PROCEDURE Calc_Tax_Para_Amount (
   total_tax_para_amount_     OUT    NUMBER,
   tax_para_amount_           OUT    NUMBER,
   non_ded_tax_para_amount_   OUT    NUMBER,
   tax_base_para_amount_      OUT    NUMBER,
   attr_                      IN OUT VARCHAR2,  -- this is to facilitate extensions in localisation.
   company_                   IN     VARCHAR2,
   currency_                  IN     VARCHAR2,
   calculate_para_amounts_    IN     VARCHAR2,
   total_tax_curr_amount_     IN     NUMBER,
   total_tax_dom_amount_      IN     NUMBER,
   tax_curr_amount_           IN     NUMBER,
   tax_dom_amount_            IN     NUMBER,
   tax_base_curr_amount_      IN     NUMBER,
   tax_base_dom_amount_       IN     NUMBER,
   para_curr_rate_            IN     NUMBER,
   para_conv_factor_          IN     NUMBER )
IS
   acc_curr_code_             VARCHAR2(3);
   para_curr_rec_             para_curr_rec;           
BEGIN
   para_curr_rec_ := Create_Para_Curr_Rec(company_, currency_, calculate_para_amounts_, attr_, para_curr_rate_, para_conv_factor_, NULL);
   IF (para_curr_rec_.para_curr_code IS NOT NULL) THEN
      acc_curr_code_ := Company_Finance_API.Get_Currency_Code(company_);  
      Calc_Tax_Para_Amount___(total_tax_para_amount_, 
                              tax_para_amount_,
                              non_ded_tax_para_amount_,
                              tax_base_para_amount_, 
                              currency_, 
                              acc_curr_code_, 
                              total_tax_curr_amount_, 
                              total_tax_dom_amount_, 
                              tax_curr_amount_, 
                              tax_dom_amount_, 
                              tax_base_curr_amount_, 
                              tax_base_dom_amount_, 
                              para_curr_rec_);                            
   ELSE
      total_tax_para_amount_   := 0;
      tax_para_amount_         := 0;
      non_ded_tax_para_amount_ := 0;
      tax_base_para_amount_    := 0;
   END IF;
END Calc_Tax_Para_Amount; 


-- This method calculates gross or net price, using given net or gross price for objects (Sales Part, Charge Type, etc.). 
-- For objects, only one tax code is applicable and hence its' tax percentage is passed as a parameter.
-- For prices, IFS currency rounding is applicable and need to pass the value.
PROCEDURE Calculate_Prices (
   net_price_         IN OUT NUMBER,
   gross_price_       IN OUT NUMBER,
   calc_base_         IN     VARCHAR2,
   tax_percentage_    IN     VARCHAR2,
   ifs_curr_rounding_ IN     NUMBER )  
IS
   rounding_  NUMBER;
BEGIN
   rounding_ := NVL(ifs_curr_rounding_, 2);
   IF (calc_base_ = 'GROSS_BASE') THEN
      gross_price_ := ROUND(gross_price_, rounding_);  
      net_price_   := gross_price_ - ROUND(NVL(((gross_price_ / ((tax_percentage_ / 100) + 1)) * (tax_percentage_ / 100)),0), rounding_);
   ELSIF (calc_base_ = 'NET_BASE') THEN
      net_price_   := ROUND(net_price_, rounding_);   
      gross_price_ := net_price_ + ROUND(NVL((net_price_ * (tax_percentage_ / 100)),0), rounding_);   
   END IF;
END Calculate_Prices;


-- This method sets gross/net curr amounts.
PROCEDURE Update_Gross_Net_Curr_Amounts (
   line_amount_rec_           IN OUT line_amount_rec )
IS
BEGIN
   IF (line_amount_rec_.calc_base = 'GROSS_BASE') THEN
      line_amount_rec_.line_net_curr_amount   := line_amount_rec_.line_gross_curr_amount  - (NVL(line_amount_rec_.line_tax_curr_amount, 0) + NVL(line_amount_rec_.line_non_ded_tax_curr_amount, 0));
   ELSIF (line_amount_rec_.calc_base = 'NET_BASE') THEN
      line_amount_rec_.line_gross_curr_amount := line_amount_rec_.line_net_curr_amount + (NVL(line_amount_rec_.line_tax_curr_amount, 0) + NVL(line_amount_rec_.line_non_ded_tax_curr_amount, 0));
   END IF;  
END Update_Gross_Net_Curr_Amounts;


-- This method sets gross/net dom amounts.
PROCEDURE Update_Gross_Net_Dom_Amounts (
   line_amount_rec_           IN OUT line_amount_rec,
   currency_                  IN     VARCHAR2,
   tax_info_table_            IN     tax_information_table,
   acc_curr_rec_              IN     acc_curr_rec )
IS
   tax_dom_amount_               NUMBER;
   line_tax_dom_amount_          NUMBER;
   cost_curr_amount_             NUMBER;
   cost_dom_amount_              NUMBER;
BEGIN
   line_amount_rec_.line_net_dom_amount := Currency_Amount_API.Calc_Rounded_Acc_Curr_Amount(currency_, acc_curr_rec_.acc_curr_code, acc_curr_rec_.use_inverted_rate, line_amount_rec_.line_net_curr_amount, acc_curr_rec_.curr_rate, acc_curr_rec_.conv_factor, acc_curr_rec_.acc_curr_rounding);
   -- Note: It is always saved tax/non-ded tax dom amounts(not total tax dom amounts) in line level , independent of calc_base. 
   --       Gross dom amount can be reached by 
   --          1. Converting (cost cnrr amount + tax curr amount) to dom amount
   --          2. Adding cost dom amount + tax dom amount(which is the one that is used for postings, and should be used in every case)
   --       In second approach, tax dom amount should be reacalculated using normal currency rate in case of specific tax currency has been used..   
   cost_curr_amount_ := line_amount_rec_.line_net_curr_amount + line_amount_rec_.line_non_ded_tax_curr_amount;
   cost_dom_amount_  := Currency_Amount_API.Calc_Rounded_Acc_Curr_Amount(currency_, acc_curr_rec_.acc_curr_code, acc_curr_rec_.use_inverted_rate, cost_curr_amount_, acc_curr_rec_.curr_rate, acc_curr_rec_.conv_factor, acc_curr_rec_.acc_curr_rounding);  
   FOR i IN 1 .. tax_info_table_.COUNT LOOP
      tax_dom_amount_      := Currency_Amount_API.Calc_Rounded_Acc_Curr_Amount(currency_, acc_curr_rec_.acc_curr_code, acc_curr_rec_.use_inverted_rate, tax_info_table_(i).tax_curr_amount, acc_curr_rec_.curr_rate, acc_curr_rec_.conv_factor, acc_curr_rec_.acc_curr_rounding);
      line_tax_dom_amount_ := NVL(line_tax_dom_amount_, 0) + NVL(tax_dom_amount_, 0);
   END LOOP;    
   line_amount_rec_.line_gross_dom_amount := NVL(cost_dom_amount_, 0) + NVL(line_tax_dom_amount_, 0);
END Update_Gross_Net_Dom_Amounts;

-------------------- PUBLIC METHODS FOR VALIDATIONS ------------------------

-- This method validates tax code in basic data such as Company Tax Control, Address, Invoice Type etc.
-- Validate_Tax_On_Basic_Data Input parameters:
-- tax_types_event_:     RESTRICTED for customer side and COMMON for supplier side and common places (which are used from both customer and supplier)
-- taxable_event_:       ALL/EXEMPT
PROCEDURE Validate_Tax_On_Basic_Data (
   company_                IN VARCHAR2,
   tax_types_event_        IN VARCHAR2,
   tax_code_               IN VARCHAR2,
   taxable_event_          IN VARCHAR2,
   tax_liability_date_     IN DATE )
IS
BEGIN
   IF (tax_code_ IS NOT NULL) THEN
      Validate_Tax_Code___(company_, tax_types_event_, tax_code_, taxable_event_, tax_liability_date_);
   END IF;
END Validate_Tax_On_Basic_Data;


-- This method validates tax code in objects such as Sales Object, Sales Part, Purchase Part per Supplier etc.
-- Validate_Tax_On_Object Input parameters:
-- tax_types_event_:         RESTRICTED for customer side and COMMON for supplier side and common places (which are used from both customer and supplier)
-- is_taxable_db_:           TRUE/FALSE
-- tax_validation_type_:     CUSTOMER_TAX/SUPPLIER_TAX   
PROCEDURE Validate_Tax_On_Object (
   company_               IN VARCHAR2,
   tax_types_event_       IN VARCHAR2,
   tax_code_              IN VARCHAR2,
   is_taxable_db_         IN VARCHAR2,
   tax_class_id_          IN VARCHAR2,
   object_id_             IN VARCHAR2,
   tax_liability_date_    IN DATE,
   tax_validation_type_   IN VARCHAR2 )
IS
   taxable_event_    VARCHAR2(20):= 'EXEMPT';
BEGIN
   IF (is_taxable_db_ = Fnd_Boolean_API.DB_TRUE) THEN
      taxable_event_ := 'ALL';
   END IF;  
   Validate_Tax_On_Object___(company_, is_taxable_db_, tax_code_, tax_class_id_, object_id_, tax_validation_type_);  
   IF (tax_code_ IS NOT NULL) THEN
      Validate_Tax_Code___(company_, tax_types_event_, tax_code_, taxable_event_, tax_liability_date_);
   END IF;
END Validate_Tax_On_Object;


-- This method validates tax code in transaction level with tax liability.
-- Validate_Tax_On_Transaction Input parameters:
-- tax_types_event_:     RESTRICTED for customer side and COMMON for supplier side and common places (which are used from both customer and supplier)
-- is_taxable_db_:       TRUE/FALSE
PROCEDURE Validate_Tax_On_Transaction (
   company_                IN VARCHAR2,
   tax_types_event_        IN VARCHAR2,
   tax_code_               IN VARCHAR2,
   tax_liability_type_db_  IN VARCHAR2,
   is_taxable_db_          IN VARCHAR2,
   tax_liability_date_     IN DATE )
IS
   taxable_event_    VARCHAR2(20):= 'ALL';
BEGIN
   IF (tax_liability_type_db_ = Tax_Liability_Type_API.DB_EXEMPT OR is_taxable_db_ = Fnd_Boolean_API.DB_FALSE) THEN
      taxable_event_  := 'EXEMPT';
   END IF;
   IF (tax_code_ IS NOT NULL) THEN
      Validate_Tax_Code___(company_, tax_types_event_, tax_code_, taxable_event_, tax_liability_date_);
   END IF;
END Validate_Tax_On_Transaction;


-- This method validates tax code in transaction level without tax liability.
-- Validate_Tax_On_Trans Input parameters:
-- tax_types_event_:        RESTRICTED for customer side and COMMON for supplier side and common places (which are used from both customer and supplier)
-- account_validation_:     TRUE/FALSE
PROCEDURE Validate_Tax_On_Trans (
   company_                IN VARCHAR2,
   tax_types_event_        IN VARCHAR2,
   tax_code_               IN VARCHAR2,
   account_validation_     IN VARCHAR2,
   account_                IN VARCHAR2,
   tax_liability_date_     IN DATE )
IS
   taxable_event_    VARCHAR2(20):= 'ALL';
BEGIN
   IF (tax_code_ IS NOT NULL) THEN
      Validate_Tax_Code___(company_, tax_types_event_, tax_code_, taxable_event_, tax_liability_date_);
   END IF;
   IF (account_validation_ = Fnd_Boolean_API.DB_TRUE) THEN
      Validate_Tax_Code_On_Acc___(company_, account_, tax_code_);
   END IF;
END Validate_Tax_On_Trans;


PROCEDURE Validate_Tax_In_Structure (
   company_                IN VARCHAR2,
   tax_code_               IN VARCHAR2,
   tax_liability_date_     IN DATE )
IS
BEGIN
   IF (tax_code_ IS NOT NULL) THEN
      Validate_Tax_Code_In_Struct___(company_, tax_code_, tax_liability_date_);
   END IF;
END Validate_Tax_In_Structure;


PROCEDURE Validate_Tax_Code_On_Acc (
   company_                IN VARCHAR2,
   tax_code_               IN VARCHAR2,
   account_                IN VARCHAR2 )
IS   
BEGIN
   IF (tax_code_ IS NOT NULL) THEN
      Validate_Tax_Code_On_Acc___(company_, account_, tax_code_);
   END IF;
END Validate_Tax_Code_On_Acc;


-- This method validates if tax is mandatory in transaction level.
-- Validate_Tax_Code_Mandatory Input parameters:
-- tax_validation_type_:     CUSTOMER_TAX/SUPPLIER_TAX
PROCEDURE Validate_Tax_Code_Mandatory (
   company_               IN VARCHAR2,
   tax_validation_type_   IN VARCHAR2 )
IS
   tax_code_validation_ VARCHAR2(20);
BEGIN
   tax_code_validation_ := Company_Tax_Control_API.Get_Tax_Code_Validation(company_, tax_validation_type_, 'TRANSACTION');
   IF (tax_code_validation_ = Fnd_Boolean_API.DB_TRUE) THEN
      IF (tax_validation_type_ = 'CUSTOMER_TAX') THEN
         Error_SYS.Record_General(lu_name_, 'CUS_TAX_MANDATORY: A Tax Code is required when customer tax validation has Transaction Level selected on Company, Tax Control tab.');
      ELSIF (tax_validation_type_ = 'SUPPLIER_TAX') THEN
         Error_SYS.Record_General(lu_name_, 'SUP_TAX_MANDATORY: A Tax Code is required when supplier tax validation has Transaction Level selected on Company, Tax Control tab.');
      END IF;
   END IF;
END Validate_Tax_Code_Mandatory;


-- This method validates if tax is mandatory in transaction level, returns the error message as out parameter.
-- Validate_Tax_Code_Mandatory Input parameters:
-- tax_validation_type_:     CUSTOMER_TAX/SUPPLIER_TAX
PROCEDURE Validate_Tax_Code_Mandatory (
   message_text_         OUT VARCHAR2,
   company_              IN  VARCHAR2,
   tax_validation_type_  IN  VARCHAR2 )
IS
   tax_code_validation_  VARCHAR2(5);
BEGIN
   tax_code_validation_ := Company_Tax_Control_API.Get_Tax_Code_Validation(company_, tax_validation_type_, 'TRANSACTION');
   IF (tax_code_validation_ = Fnd_Boolean_API.DB_TRUE) THEN
      IF (tax_validation_type_ = 'CUSTOMER_TAX') THEN
         message_text_ := Language_SYS.Translate_Constant(lu_name_, 'CUS_TAX_MANDATORY: A Tax Code is required when customer tax validation has Transaction Level selected on Company, Tax Control tab.');
      ELSIF (tax_validation_type_ = 'SUPPLIER_TAX') THEN
         message_text_ := Language_SYS.Translate_Constant(lu_name_, 'SUP_TAX_MANDATORY: A Tax Code is required when supplier tax validation has Transaction Level selected on Company, Tax Control tab.');
      END IF;   
   END IF;
END Validate_Tax_Code_Mandatory;


-- This method validates if tax code is mandatory in transaction level for a specific account.
PROCEDURE Validate_Tax_Code_Manda_On_Acc (
   company_               IN VARCHAR2,
   account_               IN VARCHAR2 )
IS
   tax_code_validation_   VARCHAR2(5);
BEGIN
   tax_code_validation_ := Account_API.Get_Tax_Code_Mandatory(company_, account_);
   IF (tax_code_validation_ = Fnd_Boolean_API.DB_TRUE) THEN
      Error_SYS.Record_General(lu_name_, 'TAXCODEMAND3: It is mandatory to enter a Tax Code for Account :P1.', account_);      
   END IF;
END Validate_Tax_Code_Manda_On_Acc;


-- This method validates if tax code is mandatory in transaction level for a specific account, returns the error message as out parameter.
PROCEDURE Validate_Tax_Code_Manda_On_Acc (
   message_text_      OUT VARCHAR2,
   company_           IN  VARCHAR2,
   account_           IN  VARCHAR2 )
IS
   tax_code_validation_   VARCHAR2(5);
BEGIN
   tax_code_validation_ := Account_API.Get_Tax_Code_Mandatory(company_, account_);
   IF (tax_code_validation_ = Fnd_Boolean_API.DB_TRUE) THEN
      message_text_ := Language_SYS.Translate_Constant(lu_name_, 'TAXCODEMAND4: It is mandatory to enter a Tax Code for Account :P1', NULL, account_);      
   END IF;
END Validate_Tax_Code_Manda_On_Acc;


PROCEDURE Validate_Calc_Base_In_Struct
IS
BEGIN
   Error_SYS.Record_General(lu_name_, 'TAXSTRGROSSNOTALLOWED: Tax Calculation Structure can not be used with Gross Price/Price Including Tax.');         
END Validate_Calc_Base_In_Struct;

-------------------- PUBLIC METHODS FOR RECORD CREATION --------------------

FUNCTION Create_Tax_Source_Object_Rec (
   tax_source_object_id_     IN VARCHAR2,
   tax_source_object_type_   IN VARCHAR2,
   tax_source_taxable_db_    IN VARCHAR2,
   attr_                     IN VARCHAR2 ) RETURN tax_source_object_rec
IS 
   tax_source_object_rec_     tax_source_object_rec;
BEGIN
   tax_source_object_rec_.object_id            := tax_source_object_id_;
   tax_source_object_rec_.object_type          := tax_source_object_type_;
   tax_source_object_rec_.object_group         := NULL;
   tax_source_object_rec_.is_taxable_db        := tax_source_taxable_db_;
   tax_source_object_rec_.object_tax_code      := NULL;		
   tax_source_object_rec_.object_tax_class_id  := NULL;		
   RETURN tax_source_object_rec_;
END Create_Tax_Source_Object_Rec; 


FUNCTION Create_Identity_Rec (
   identity_                  IN VARCHAR2,
   party_type_db_             IN VARCHAR2,
   supply_country_db_         IN VARCHAR2,
   delivery_country_db_       IN VARCHAR2,
   tax_liability_             IN VARCHAR2,			
   tax_liability_type_db_     IN VARCHAR2,
   delivery_address_id_       IN VARCHAR2,
   delivery_type_             IN VARCHAR2,
   use_proj_address_for_tax_  IN VARCHAR2,
   project_id_                IN VARCHAR2,
   ship_from_address_id_      IN VARCHAR2,
   attr_                      IN VARCHAR2 ) RETURN identity_rec
IS 
   identity_rec_              identity_rec;
BEGIN
   identity_rec_.identity                 := identity_; 
   identity_rec_.party_type_db            := party_type_db_;
   identity_rec_.supply_country_db        := supply_country_db_;
   identity_rec_.delivery_country_db      := delivery_country_db_;
   identity_rec_.tax_liability            := tax_liability_;   			
   identity_rec_.tax_liability_type_db    := tax_liability_type_db_;    			
   identity_rec_.delivery_address_id      := delivery_address_id_;
   identity_rec_.delivery_type            := NVL(delivery_type_, '*');
   identity_rec_.use_proj_address_for_tax := NVL(use_proj_address_for_tax_, Fnd_Boolean_API.DB_FALSE);
   identity_rec_.project_id               := project_id_;
   identity_rec_.ship_from_address_id     := ship_from_address_id_;
   RETURN identity_rec_;
END Create_Identity_Rec; 


FUNCTION Create_Fetch_Default_Key_Rec (
   contract_                  IN VARCHAR2,   
   charge_connect_part_no_    IN VARCHAR2,
   order_code_                IN VARCHAR2,
   service_type_              IN VARCHAR2,
   attr_                      IN VARCHAR2,
   connect_charge_seq_no_     IN NUMBER ) RETURN fetch_default_key_rec
IS 
   fetch_default_key_rec_        fetch_default_key_rec;
BEGIN
   fetch_default_key_rec_.contract               := contract_;   
   fetch_default_key_rec_.charge_connect_part_no := charge_connect_part_no_;    			
   fetch_default_key_rec_.order_code             := order_code_;   			
   fetch_default_key_rec_.service_type           := service_type_;    			
   fetch_default_key_rec_.connect_charge_seq_no  := connect_charge_seq_no_;
   RETURN fetch_default_key_rec_;
END Create_Fetch_Default_Key_Rec; 


FUNCTION Create_Validation_Rec (
   calc_base_                   IN VARCHAR2,   
   fetch_validate_action_       IN VARCHAR2,
   validate_tax_from_tax_class_ IN VARCHAR2,
   attr_                        IN VARCHAR2 ) RETURN validation_rec
IS 
   validation_rec_              validation_rec;
BEGIN
   validation_rec_.calc_base                   := calc_base_;   
   validation_rec_.fetch_validate_action       := fetch_validate_action_;    			
   validation_rec_.validate_tax_from_tax_class := validate_tax_from_tax_class_;   			
   RETURN validation_rec_;
END Create_Validation_Rec; 


FUNCTION Create_Source_Key_Rec (
   source_ref_type_           IN VARCHAR2,   
   source_ref1_               IN VARCHAR2,
   source_ref2_               IN VARCHAR2,
   source_ref3_               IN VARCHAR2,
   source_ref4_               IN VARCHAR2,
   source_ref5_               IN VARCHAR2,
   attr_                      IN VARCHAR2 ) RETURN source_key_rec
IS 
   source_key_rec_            source_key_rec;
BEGIN
   source_key_rec_.source_ref_type := source_ref_type_;   
   source_key_rec_.source_ref1     := source_ref1_;    			
   source_key_rec_.source_ref2     := source_ref2_;   			
   source_key_rec_.source_ref3     := source_ref3_;    			
   source_key_rec_.source_ref4     := source_ref4_;
   source_key_rec_.source_ref5     := source_ref5_;
   RETURN source_key_rec_;
END Create_Source_Key_Rec; 


FUNCTION Create_Line_Amount_Rec (
   line_gross_curr_amount_    IN NUMBER,
   line_net_curr_amount_      IN NUMBER,
   tax_calc_base_amount_      IN NUMBER,
   calc_base_                 IN VARCHAR2,
   consider_use_tax_          IN VARCHAR2,
   attr_                      IN VARCHAR2 ) RETURN line_amount_rec
IS 
   line_amount_rec_           line_amount_rec;
BEGIN
   line_amount_rec_.line_tax_curr_amount         := 0;    			
   line_amount_rec_.line_tax_dom_amount          := 0;  
   line_amount_rec_.line_tax_para_amount         := 0;
   line_amount_rec_.line_non_ded_tax_curr_amount := 0;
   line_amount_rec_.line_non_ded_tax_dom_amount  := 0;
   line_amount_rec_.line_non_ded_tax_para_amount := 0;
   line_amount_rec_.line_gross_curr_amount       := line_gross_curr_amount_;  
   line_amount_rec_.line_net_curr_amount         := line_net_curr_amount_;   
   line_amount_rec_.line_gross_dom_amount        := 0;    
   line_amount_rec_.line_net_dom_amount          := 0;
   line_amount_rec_.tax_calc_base_amount         := tax_calc_base_amount_;
   line_amount_rec_.calc_base                    := calc_base_;
   line_amount_rec_.consider_use_tax             := consider_use_tax_;
   RETURN line_amount_rec_;
END Create_Line_Amount_Rec; 


--   Create_Trans_Curr_Rec Input parameters:
--   identity_:                  used for party_type_db = CUSTOMER
--   delivery_address_id_:       used for party_type_db = CUSTOMER
--   attr_:                      facilitate extensions in localisation.
--   tax_rounding_:              facilitate overwriting tax rounding.
--   curr_rounding_:             facilitate overwriting curr rounding.
FUNCTION Create_Trans_Curr_Rec (
   company_                   IN VARCHAR2, 
   identity_                  IN VARCHAR2,
   party_type_db_             IN VARCHAR2,
   currency_                  IN VARCHAR2,
   delivery_address_id_       IN VARCHAR2,
   attr_                      IN VARCHAR2,
   tax_rounding_              IN VARCHAR2,
   curr_rounding_             IN NUMBER ) RETURN trans_curr_rec
IS 
   trans_curr_rec_            trans_curr_rec;
BEGIN   			
   trans_curr_rec_.currency            := currency_;   			   			
   trans_curr_rec_.tax_rounding_method := NVL(tax_rounding_, Get_Tax_Rounding_Method_Db(company_, identity_, party_type_db_, delivery_address_id_));
   trans_curr_rec_.curr_rounding       := NVL(curr_rounding_, Currency_Code_API.Get_Currency_Rounding(company_, currency_));
   RETURN trans_curr_rec_;
END Create_Trans_Curr_Rec;


FUNCTION Create_Acc_Curr_Rec (
   company_                   IN VARCHAR2,
   attr_                      IN VARCHAR2,
   curr_rate_                 IN NUMBER,
   conv_factor_               IN NUMBER,
   acc_curr_rounding_         IN NUMBER ) RETURN acc_curr_rec
IS 
   acc_curr_rec_              acc_curr_rec;
BEGIN   			
   acc_curr_rec_.acc_curr_code       := Company_Finance_API.Get_Currency_Code(company_); 
   acc_curr_rec_.curr_rate           := curr_rate_;
   acc_curr_rec_.conv_factor         := conv_factor_;
   acc_curr_rec_.acc_curr_rounding   := NVL(acc_curr_rounding_, Currency_Code_API.Get_Currency_Rounding(company_, acc_curr_rec_.acc_curr_code));
   acc_curr_rec_.use_inverted_rate   := Currency_Code_API.Get_Inverted(company_, acc_curr_rec_.acc_curr_code);
   RETURN acc_curr_rec_;
END Create_Acc_Curr_Rec;


FUNCTION Create_Para_Curr_Rec (
   company_                   IN VARCHAR2,
   currency_                  IN VARCHAR2,
   calculate_para_amounts_    IN VARCHAR2,
   attr_                      IN VARCHAR2,
   para_curr_rate_            IN NUMBER,
   para_conv_factor_          IN NUMBER,
   para_curr_rounding_        IN NUMBER ) RETURN para_curr_rec
IS 
   para_curr_code_            VARCHAR2(3);
   para_curr_rec_             para_curr_rec;
BEGIN  
   IF (calculate_para_amounts_ = Fnd_Boolean_API.DB_TRUE) THEN
      para_curr_code_ := Company_Finance_API.Get_Parallel_Acc_Currency(company_);
      IF (para_curr_code_ IS NOT NULL) THEN 
         para_curr_rec_.para_curr_code         := para_curr_code_;
         para_curr_rec_.para_curr_rate         := para_curr_rate_;   
         para_curr_rec_.para_conv_factor       := para_conv_factor_;
         para_curr_rec_.para_curr_rounding     := NVL(para_curr_rounding_, Currency_Code_API.Get_Currency_Rounding(company_, para_curr_rec_.para_curr_code));
         para_curr_rec_.para_use_inverted_rate := Currency_Rate_API.Is_Parallel_Curr_Rate_Inverted(company_, currency_);
         para_curr_rec_.para_curr_base         := Company_Finance_API.Get_Parallel_Base_Db(company_);
      END IF;
   END IF;
   RETURN para_curr_rec_;
END Create_Para_Curr_Rec;


-------------------- PUBLIC METHODS FOR COMMON LOGIC -----------------------

-- This method copies tax codes to tax message.
PROCEDURE Create_Tax_Message (
   tax_msg_                   OUT VARCHAR2,
   company_                   IN  VARCHAR2,
   transferred_               IN  VARCHAR2,
   tax_info_table_            IN  tax_information_table )
IS
   tax_item_id_               NUMBER;   
   tax_code_rec_              Statutory_Fee_API.Public_Rec;
BEGIN    
   IF (tax_info_table_.COUNT > 0) THEN        
      tax_msg_              := Message_SYS.Construct('TAX_INFORMATION');
      tax_item_id_          := -1;
      FOR i IN 1 .. tax_info_table_.COUNT LOOP
         IF (Message_SYS.Get_Name(tax_msg_) = 'TAX_INFORMATION') THEN
            tax_code_rec_ := Statutory_Fee_API.Fetch_Validate_Tax_Code_Rec(company_, tax_info_table_(i).tax_code, NULL, Fnd_Boolean_API.DB_TRUE, Fnd_Boolean_API.DB_TRUE, 'FETCH_ALWAYS');   
            Message_SYS.Add_Attribute(tax_msg_, 'TAX_ITEM_ID',                 tax_item_id_);
            Message_SYS.Add_Attribute(tax_msg_, 'TAX_CALC_STRUCTURE_ID',       tax_info_table_(i).tax_calc_structure_id);
            Message_SYS.Add_Attribute(tax_msg_, 'TAX_CALC_STRUCTURE_ITEM_ID',  tax_info_table_(i).tax_calc_structure_item_id);
            Message_SYS.Add_Attribute(tax_msg_, 'TAX_CODE',                    tax_info_table_(i).tax_code);
            Message_SYS.Add_Attribute(tax_msg_, 'TAX_PERCENTAGE',              tax_info_table_(i).tax_percentage);
            Message_SYS.Add_Attribute(tax_msg_, 'TAX_TYPE_DB',                 tax_info_table_(i).tax_type_db);
            Message_SYS.Add_Attribute(tax_msg_, 'TAX_TYPE',                    Fee_Type_API.Decode(tax_info_table_(i).tax_type_db));
            Message_SYS.Add_Attribute(tax_msg_, 'TOTAL_TAX_CURR_AMOUNT',       NVL(tax_info_table_(i).total_tax_curr_amount, 0));
            Message_SYS.Add_Attribute(tax_msg_, 'TOTAL_TAX_DOM_AMOUNT',        NVL(tax_info_table_(i).total_tax_dom_amount, 0));
            Message_SYS.Add_Attribute(tax_msg_, 'TOTAL_TAX_PARALLEL_AMOUNT',   NVL(tax_info_table_(i).total_tax_para_amount, 0));       
            Message_SYS.Add_Attribute(tax_msg_, 'TAX_CURR_AMOUNT',             NVL(tax_info_table_(i).tax_curr_amount, 0));
            Message_SYS.Add_Attribute(tax_msg_, 'TAX_DOM_AMOUNT',              NVL(tax_info_table_(i).tax_dom_amount, 0));
            Message_SYS.Add_Attribute(tax_msg_, 'TAX_PARALLEL_AMOUNT',         NVL(tax_info_table_(i).tax_para_amount, 0)); 
            Message_SYS.Add_Attribute(tax_msg_, 'TAX_BASE_CURR_AMOUNT',        NVL(tax_info_table_(i).tax_base_curr_amount, 0));   
            Message_SYS.Add_Attribute(tax_msg_, 'TAX_BASE_DOM_AMOUNT',         NVL(tax_info_table_(i).tax_base_dom_amount, 0));
            Message_SYS.Add_Attribute(tax_msg_, 'TAX_BASE_PARALLEL_AMOUNT',    NVL(tax_info_table_(i).tax_base_para_amount, 0));   
            Message_SYS.Add_Attribute(tax_msg_, 'NON_DED_TAX_CURR_AMOUNT',     NVL(tax_info_table_(i).non_ded_tax_curr_amount, 0));
            Message_SYS.Add_Attribute(tax_msg_, 'NON_DED_TAX_DOM_AMOUNT',      NVL(tax_info_table_(i).non_ded_tax_dom_amount, 0));
            Message_SYS.Add_Attribute(tax_msg_, 'NON_DED_TAX_PARALLEL_AMOUNT', NVL(tax_info_table_(i).non_ded_tax_para_amount, 0));
            Message_SYS.Add_Attribute(tax_msg_, 'TAX_CODE_DOM_AMOUNT_LIMIT',   NVL(tax_code_rec_.tax_amt_limit, 0));
            Message_SYS.Add_Attribute(tax_msg_, 'TAX_LIMIT_CURR_AMOUNT',       NVL(tax_info_table_(i).tax_curr_amount, 0));
            Message_SYS.Add_Attribute(tax_msg_, 'TRANSFERRED',                 transferred_);  
            Message_SYS.Add_Attribute(tax_msg_, 'DEDUCTIBLE_PERCENTAGE',       tax_info_table_(i).deductible_factor * 100);
         END IF;                     
      END LOOP;
   ELSE   
      tax_msg_ := Message_SYS.Construct('REMOVE_TAX_INFORMATION');      
   END IF;
END Create_Tax_Message;


-- This method copies tax code information per tax code to tax table.
PROCEDURE Add_Tax_Code_Info (
   tax_info_table_             IN OUT tax_information_table,
   company_                    IN     VARCHAR2,
   party_type_db_              IN     VARCHAR2,
   tax_code_                   IN     VARCHAR2, 
   tax_calc_structure_id_      IN     VARCHAR2,
   tax_calc_structure_item_id_ IN     VARCHAR2,
   in_fetch_validate_action_   IN     VARCHAR2,
   in_tax_percentage_          IN     NUMBER,
   tax_liability_date_         IN     DATE )
IS   
   fetch_validate_action_  VARCHAR2(20);
   index_                  BINARY_INTEGER;
   tax_code_rec_           Statutory_Fee_API.Public_Rec;
   -- gelr: extend_tax_code_and_tax_struct, begin
   br_tax_percentage_      NUMBER;
   -- gelr: extend_tax_code_and_tax_struct, end
BEGIN
   IF (tax_calc_structure_id_ IS NOT NULL) THEN 
      fetch_validate_action_ := 'FETCH_ALWAYS';
   ELSE
      fetch_validate_action_ := in_fetch_validate_action_;
   END IF;   
   tax_code_rec_ := Statutory_Fee_API.Fetch_Validate_Tax_Code_Rec(company_, tax_code_, tax_liability_date_, Fnd_Boolean_API.DB_FALSE, Fnd_Boolean_API.DB_TRUE, fetch_validate_action_);   
   IF (tax_code_rec_.fee_code IS NOT NULL) THEN
      IF (tax_info_table_.COUNT > 0) THEN
         index_ := tax_info_table_.LAST + 1;
      ELSE
         index_ := 1;
      END IF;       
      tax_info_table_(index_).tax_code             := tax_code_rec_.fee_code;          
      tax_info_table_(index_).tax_type_db          := tax_code_rec_.fee_type;
      tax_info_table_(index_).tax_percentage       := NVL(in_tax_percentage_, tax_code_rec_.fee_rate); 
      tax_info_table_(index_).deductible_factor    := tax_code_rec_.deductible/100;
      IF (party_type_db_ = Party_Type_API.DB_CUSTOMER) THEN
         tax_info_table_(index_).tax_method_db     := tax_code_rec_.vat_disbursed;
         tax_info_table_(index_).deductible_factor := 1;
      ELSIF (party_type_db_ = Party_Type_API.DB_SUPPLIER) THEN
         tax_info_table_(index_).tax_method_db     := tax_code_rec_.vat_received;
      END IF; 
      tax_info_table_(index_).tax_calc_structure_id      := tax_calc_structure_id_;          
      tax_info_table_(index_).tax_calc_structure_item_id := tax_calc_structure_item_id_;
      -- gelr: extend_tax_code_and_tax_struct, begin
      IF (Company_Localization_Info_API.Get_Parameter_Value_Db(company_, 'EXTEND_TAX_CODE_AND_TAX_STRUCT') = Fnd_Boolean_API.DB_TRUE) THEN
         br_tax_percentage_ := Tax_Structure_Item_API.Get_Br_Tax_Percentage(company_, tax_calc_structure_id_);
         tax_info_table_(index_).br_tax_percentage := br_tax_percentage_;
      END IF;
      -- gelr: extend_tax_code_and_tax_struct, end
   END IF;
END Add_Tax_Code_Info;


-- This method copies saved tax codes to tax table.
PROCEDURE Add_Saved_Tax_Code_Info (
   tax_info_table_             OUT tax_information_table,
   tax_code_                   IN  VARCHAR2,
   tax_calc_structure_id_      IN  VARCHAR2,
   saved_tax_code_msg_         IN  VARCHAR2,    
   saved_tax_code_             IN  VARCHAR2,    
   saved_tax_calc_struct_id_   IN  VARCHAR2, 
   saved_tax_percentage_       IN  VARCHAR2, 
   saved_tax_base_curr_amount_ IN  NUMBER, 
   company_                    IN  VARCHAR2, 
   party_type_db_              IN  VARCHAR2, 
   tax_liability_date_         IN  DATE, 
   validation_rec_             IN  validation_rec)
IS
BEGIN
   IF (tax_calc_structure_id_ IS NULL) THEN
      Add_Saved_Tax_Code_Info___(tax_info_table_, tax_code_, saved_tax_code_msg_, saved_tax_code_, saved_tax_calc_struct_id_, saved_tax_percentage_, saved_tax_base_curr_amount_, company_, party_type_db_, tax_liability_date_, validation_rec_);
   ELSE
      Add_Saved_Tax_Struct_Info___(tax_info_table_, tax_calc_structure_id_, saved_tax_code_msg_, saved_tax_calc_struct_id_, company_, party_type_db_, tax_liability_date_, validation_rec_);
   END IF;
END Add_Saved_Tax_Code_Info;


-- This method sets tax code information.
PROCEDURE Set_Tax_Code_Info (
   multiple_tax_           OUT VARCHAR2,
   tax_calc_structure_id_  OUT VARCHAR2,
   tax_class_id_           OUT VARCHAR2,
   tax_code_               OUT VARCHAR2,
   tax_method_             OUT VARCHAR2,
   tax_method_db_          OUT VARCHAR2,
   tax_type_db_            OUT VARCHAR2,
   tax_percentage_         OUT NUMBER,
   tax_source_object_rec_  IN  tax_source_object_rec,
   tax_info_table_         IN  tax_information_table )
IS 
BEGIN
   tax_class_id_ := tax_source_object_rec_.object_tax_class_id;
   IF (tax_info_table_.COUNT = 0) THEN
      multiple_tax_          := Fnd_Boolean_API.DB_FALSE;
      tax_code_              := NULL;
      tax_calc_structure_id_ := NULL;
   ELSIF (tax_info_table_.COUNT = 1) THEN
      multiple_tax_ := Fnd_Boolean_API.DB_FALSE;
      IF (tax_info_table_(1).tax_calc_structure_id IS NOT NULL) THEN
         tax_code_              := NULL;
         tax_class_id_          := NULL;
         tax_calc_structure_id_ := tax_info_table_(1).tax_calc_structure_id;
      ELSE
         tax_code_              := tax_info_table_(1).tax_code;
         tax_percentage_        := tax_info_table_(1).tax_percentage;
         tax_method_            := Vat_Method_API.Decode(tax_info_table_(1).tax_method_db);
         tax_method_db_         := tax_info_table_(1).tax_method_db;
         tax_type_db_           := tax_info_table_(1).tax_type_db;
         tax_calc_structure_id_ := NULL;
      END IF;
   ELSIF (tax_info_table_.COUNT > 1) THEN
      multiple_tax_          := Fnd_Boolean_API.DB_TRUE;
      tax_code_              := NULL;
      tax_calc_structure_id_ := tax_info_table_(1).tax_calc_structure_id;
      IF (tax_calc_structure_id_ IS NOT NULL) THEN
         tax_class_id_       := NULL;
      END IF;
   END IF;
END Set_Tax_Code_Info;


-- This method checks maximum overwriting level on tax for a tax code.
PROCEDURE Check_Max_Overwrite_Level (
   tax_curr_amount_           OUT NUMBER,
   company_                   IN  VARCHAR2,
   identity_                  IN  VARCHAR2,
   party_type_db_             IN  VARCHAR2,
   currency_                  IN  VARCHAR2,
   delivery_address_id_       IN  VARCHAR2,
   use_specific_rate_         IN  VARCHAR2,
   tax_code_                  IN  VARCHAR2,
   tax_type_db_               IN  VARCHAR2,
   calc_base_                 IN  VARCHAR2,
   tax_calc_base_amount_      IN  NUMBER,
   tax_calc_base_percent_     IN  NUMBER,
   use_tax_calc_base_amount_  IN  NUMBER,
   line_gross_curr_amount_    IN  NUMBER,
   line_net_curr_amount_      IN  NUMBER,
   in_tax_base_curr_amount_   IN  NUMBER,
   tax_percentage_            IN  NUMBER, 
   deductible_factor_         IN  NUMBER,
   curr_rate_                 IN  NUMBER,
   conv_factor_               IN  NUMBER,
   new_tax_curr_amount_       IN  NUMBER,
   in_new_tax_dom_amount_     IN  NUMBER )
IS
   within_level_              VARCHAR2(5);
BEGIN
   Check_Max_Overwrite_Level(within_level_,
                             tax_curr_amount_,
                             company_,
                             identity_,
                             party_type_db_,
                             currency_,
                             delivery_address_id_,
                             use_specific_rate_,
                             tax_code_,
                             tax_type_db_,
                             calc_base_,
                             'TRUE',          -- raise_error_msg_
                             tax_calc_base_amount_,
                             tax_calc_base_percent_,
                             use_tax_calc_base_amount_,
                             line_gross_curr_amount_,
                             line_net_curr_amount_,
                             in_tax_base_curr_amount_,
                             tax_percentage_, 
                             deductible_factor_,
                             curr_rate_,
                             conv_factor_,
                             new_tax_curr_amount_,
                             in_new_tax_dom_amount_);
END Check_Max_Overwrite_Level;


-- This is the overloaded method of Check_Max_Overwrite_Level, with the additional paramters.
-- This method checks maximum overwriting level on tax for a tax code.
PROCEDURE Check_Max_Overwrite_Level (
   within_level_              OUT VARCHAR2,
   tax_curr_amount_           OUT NUMBER,
   company_                   IN  VARCHAR2,
   identity_                  IN  VARCHAR2,
   party_type_db_             IN  VARCHAR2,
   currency_                  IN  VARCHAR2,
   delivery_address_id_       IN  VARCHAR2,
   use_specific_rate_         IN  VARCHAR2,
   tax_code_                  IN  VARCHAR2,
   tax_type_db_               IN  VARCHAR2,
   calc_base_                 IN  VARCHAR2,
   raise_error_msg_           IN  VARCHAR2,
   tax_calc_base_amount_      IN  NUMBER,
   tax_calc_base_percent_     IN  NUMBER,
   use_tax_calc_base_amount_  IN  NUMBER,
   line_gross_curr_amount_    IN  NUMBER,
   line_net_curr_amount_      IN  NUMBER,
   in_tax_base_curr_amount_   IN  NUMBER,
   tax_percentage_            IN  NUMBER, 
   deductible_factor_         IN  NUMBER,
   curr_rate_                 IN  NUMBER,
   conv_factor_               IN  NUMBER,
   new_tax_curr_amount_       IN  NUMBER,
   in_new_tax_dom_amount_     IN  NUMBER )
IS
   attr_                      VARCHAR2(200);
   tax_base_curr_amount_      NUMBER;
   total_tax_curr_amount_     NUMBER;
   non_ded_tax_curr_amount_   NUMBER;
   total_tax_dom_amount_      NUMBER;
   tax_dom_amount_            NUMBER;
   non_ded_tax_dom_amount_    NUMBER;
   tax_base_dom_amount_       NUMBER;
   new_tax_dom_amount_        NUMBER;
   acc_curr_rec_              acc_curr_rec;
BEGIN
   Calc_Tax_Curr_Amount(total_tax_curr_amount_,
                        tax_curr_amount_,
                        non_ded_tax_curr_amount_,
                        attr_,
                        company_, 
                        identity_,
                        party_type_db_,
                        currency_,
                        delivery_address_id_,
                        tax_code_,
                        tax_type_db_,
                        tax_calc_base_amount_,
                        tax_calc_base_percent_,
                        use_tax_calc_base_amount_,
                        tax_percentage_,
                        deductible_factor_); 
   IF (in_tax_base_curr_amount_ IS NOT NULL) THEN
      tax_base_curr_amount_ := in_tax_base_curr_amount_;
   ELSE     
      IF (calc_base_ = 'GROSS_BASE') THEN
         -- Original line net amount cannot be calculated for multiple tax codes 
         -- and will give wrong tax_dom_amount_, when use specific rate is true. 
         tax_base_curr_amount_ := line_gross_curr_amount_ - total_tax_curr_amount_;                          
      ELSE 
         tax_base_curr_amount_ := line_net_curr_amount_;
      END IF; 
   END IF;
   acc_curr_rec_ := Create_Acc_Curr_Rec(company_, attr_, NULL, conv_factor_, NULL);
   Calc_Tax_Dom_Amount(total_tax_dom_amount_,
                       tax_dom_amount_,
                       non_ded_tax_dom_amount_,
                       tax_base_dom_amount_,
                       attr_,
                       company_,
                       currency_,
                       use_specific_rate_,
                       tax_code_,
                       total_tax_curr_amount_,
                       tax_curr_amount_,
                       tax_base_curr_amount_,
                       tax_percentage_,
                       deductible_factor_,
                       curr_rate_,
                       conv_factor_); 
   IF (NVL(in_new_tax_dom_amount_, 0) != 0) THEN
      new_tax_dom_amount_ := in_new_tax_dom_amount_;
   ELSE
      new_tax_dom_amount_ := Currency_Amount_API.Calc_Rounded_Acc_Curr_Amount(currency_, acc_curr_rec_.acc_curr_code, acc_curr_rec_.use_inverted_rate, new_tax_curr_amount_, curr_rate_, acc_curr_rec_.conv_factor, acc_curr_rec_.acc_curr_rounding);
   END IF; 
   -- In tax only scenario, we should not check maximum overwriting level.
   IF NOT(line_net_curr_amount_ = 0 AND new_tax_curr_amount_ != 0) THEN
      Validate_Max_Overwrite_Level(within_level_, company_, tax_code_, raise_error_msg_, tax_dom_amount_, new_tax_dom_amount_, acc_curr_rec_.acc_curr_rounding);
   END IF;
END Check_Max_Overwrite_Level;


-- This method validates maximum overwriting level on tax for a tax code.
PROCEDURE Validate_Max_Overwrite_Level (  
   company_                   IN VARCHAR2,
   tax_code_                  IN VARCHAR2,
   tax_dom_amount_            IN NUMBER,
   new_tax_dom_amount_        IN NUMBER,
   acc_curr_rounding_         IN NUMBER )
IS
   within_level_              VARCHAR2(5);
BEGIN
   Validate_Max_Overwrite_Level(within_level_,
                                company_,
                                tax_code_,
                                'TRUE', -- raise_error_msg_
                                tax_dom_amount_,
                                new_tax_dom_amount_,
                                acc_curr_rounding_);
END Validate_Max_Overwrite_Level;


-- This is the overloaded method of Validate_Max_Overwrite_Level, with the additional paramters.
-- This method validates maximum overwriting level on tax for a tax code.
PROCEDURE Validate_Max_Overwrite_Level ( 
   within_level_             OUT VARCHAR2,
   company_                   IN VARCHAR2,
   tax_code_                  IN VARCHAR2,
   raise_error_msg_           IN VARCHAR2,
   tax_dom_amount_            IN NUMBER,
   new_tax_dom_amount_        IN NUMBER,
   acc_curr_rounding_         IN NUMBER )
IS
   level_in_percent_          NUMBER;
   limit_in_dom_amount_       NUMBER;
   level_in_dom_amount_       NUMBER;
   max_limit_in_dom_amount_   NUMBER;
   min_limit_in_dom_amount_   NUMBER;
   company_tax_control_rec_   Company_Tax_Control_API.Public_Rec;
BEGIN
   company_tax_control_rec_ := Company_Tax_Control_API.Get(company_);
   level_in_percent_    := company_tax_control_rec_.level_in_percent;
   limit_in_dom_amount_ := company_tax_control_rec_.level_in_acc_currency;                        
   within_level_ := 'TRUE';
   IF (level_in_percent_ IS NOT NULL OR limit_in_dom_amount_ IS NOT NULL) THEN
      IF (level_in_percent_ IS NOT NULL) THEN
         level_in_dom_amount_ := ROUND((ABS(tax_dom_amount_) * level_in_percent_ / 100), acc_curr_rounding_); 
         IF (limit_in_dom_amount_ IS NULL OR level_in_dom_amount_ < limit_in_dom_amount_) THEN
            limit_in_dom_amount_ := level_in_dom_amount_;
         END IF;
      END IF; 
      max_limit_in_dom_amount_ := ABS(tax_dom_amount_) + limit_in_dom_amount_;
      IF (limit_in_dom_amount_ < ABS(tax_dom_amount_)) THEN
         min_limit_in_dom_amount_ := ABS(tax_dom_amount_) - limit_in_dom_amount_;
      ELSE
         min_limit_in_dom_amount_ := 0;
      END IF; 
      IF (ABS(new_tax_dom_amount_) >  ABS(max_limit_in_dom_amount_) OR ABS(new_tax_dom_amount_) < ABS(min_limit_in_dom_amount_)) THEN
         IF (raise_error_msg_ = 'TRUE') THEN
            Error_SYS.Record_General(lu_name_,'EXCEEDLIMIT: Tax amount adjustment for tax code :P1 cannot be greater than the maximum overwriting level on tax.', tax_code_);
         END IF;
         within_level_ := 'FALSE';
      END IF;       
   END IF;
END Validate_Max_Overwrite_Level;

-------------------- PUBLIC METHODS FOR COMMON TAX LINE ASSISTANT IN AURENA ----------

--This method is to be used by Aurena 
FUNCTION Fetch_For_Tax_Line_Assistant ( 
   package_name_                 IN   VARCHAR2,
   attr_                         IN   VARCHAR2 ) RETURN source_info_rec
IS 
   source_info_rec_  source_info_rec;
BEGIN 
   IF (package_name_ IN ('AFP_ITEM_API')) THEN 
      $IF Component_Apppay_SYS.INSTALLED $THEN 
         source_info_rec_ := Tax_Handling_Apppay_Util_API.Fetch_For_Tax_Line_Assistant(attr_);          
      $ELSE
         NULL;
      $END
   ELSIF (package_name_ IN ('CONTRACT_ITEM_API')) THEN    
      $IF Component_Conmgt_SYS.INSTALLED $THEN 
         source_info_rec_ := Tax_Handling_Conmgt_Util_API.Fetch_For_Tax_Line_Assistant(attr_);         
      $ELSE
         NULL;
      $END 
   ELSIF (package_name_ IN ('INSTANT_INVOICE_API', 'OUTGOING_SUPPLIER_INVOICE_API', 'MAN_SUPP_INVOICE_API', 'PROJECT_INVOICE_API', 'MAN_CUST_INVOICE_API')) THEN         
      $IF Component_Invoic_SYS.INSTALLED $THEN
         source_info_rec_ := Tax_Handling_Invoic_Util_API.Fetch_For_Tax_Line_Assistant(package_name_, attr_);  
      $ELSE
         NULL;
      $END
   ELSIF (package_name_ IN ('INSTANT_INVOICE_TEMPLATE_API', 'SUPPLIER_INVOICE_TEMPLATE_API')) THEN         
      $IF Component_Invoic_SYS.INSTALLED $THEN
         source_info_rec_ := Tax_Handling_Invoic_Util_API.Fetch_For_Tmpl_Tax_Line_Assis(package_name_, attr_);  
      $ELSE
         NULL;
      $END
   ELSIF (package_name_ IN ('CUSTOMER_ORDER_LINE_API', 'CUSTOMER_ORDER_CHARGE_API', 'ORDER_QUOTATION_LINE_API', 'ORDER_QUOTATION_CHARGE_API',
                           'RETURN_MATERIAL_LINE_API', 'RETURN_MATERIAL_CHARGE_API', 'SHIPMENT_FREIGHT_CHARGE_API', 'CUSTOMER_ORDER_INV_ITEM_API')) THEN         
      $IF Component_Order_SYS.INSTALLED $THEN
         source_info_rec_ := Tax_Handling_Order_Util_API.Fetch_For_Tax_Line_Assistant(package_name_, attr_);  
      $ELSE
         NULL;
      $END   
   ELSIF (package_name_ IN ('MIXED_PAYMENT_MAN_POSTING_API')) THEN
      $IF Component_Payled_SYS.INSTALLED $THEN
         source_info_rec_ := Tax_Handling_Payled_Util_API.Fetch_For_Tax_Line_Assistant(package_name_, attr_); 
      $ELSE
         NULL;
      $END
   ELSIF (package_name_ IN ('SUB_CON_ITEM_API')) THEN   
      $IF Component_Subcon_SYS.INSTALLED $THEN 
         source_info_rec_ := Tax_Handling_Subcon_Util_API.Fetch_For_Tax_Line_Assistant(attr_); 
      $ELSE
         NULL;
      $END
   ELSIF (package_name_ IN ('SUBVAL_VALUATION_LINE_ITEM_API')) THEN   
      $IF Component_Subval_SYS.INSTALLED $THEN 
         source_info_rec_ :=  Tax_Handling_Subval_Util_API.Fetch_For_Tax_Line_Assistant(attr_);          
      $ELSE
         NULL;
      $END
   ELSIF (package_name_ IN ('PURCH_CHANGE_ORDER_CHARGE_API', 'PURCHASE_ORDER_CHARGE_API', 'PURCH_ORDER_LINE_PART_API', 'PURCHASE_CHANGE_ORDER_LINE_API', 'PURCH_ORDER_LINE_NOPART_API', 'PURCHASE_REQUISITION_LINE_API', 'PURCHASE_REQUISITION_LINE_NOPART_API', 'PURCHASE_CHANGE_ORDER_LINE_NOPART_API', 'PURCHASE_QUOTATION_APPROVAL_LINE_API', 'PURCHASE_QUOTATION_LINE_ORDER_API', 'PURCHASE_QUOTATION_LINE_NOPART_ORDER_API')) THEN   
      $IF Component_Purch_SYS.INSTALLED $THEN 
         source_info_rec_ :=  Tax_Handling_Purch_Util_API.Fetch_For_Tax_Line_Assistant(package_name_, attr_);          
      $ELSE
         NULL;
      $END
   END IF;
   RETURN source_info_rec_;
END Fetch_For_Tax_Line_Assistant;


--This method is to be used by Aurena
PROCEDURE Get_Use_Specific_Rate (   
   use_specific_rate_      OUT VARCHAR2,
   curr_rate_              OUT NUMBER,
   parent_source_ref_type_ IN  VARCHAR2,
   company_                IN  VARCHAR2, 
   party_type_db_          IN  VARCHAR2,
   adv_invoice_            IN  VARCHAR2,
   package_name_           IN  VARCHAR2,
   tax_code_               IN  VARCHAR2,
   trans_curr_rate_        IN  NUMBER,
   tax_curr_rate_          IN  NUMBER )
IS    
BEGIN
   IF (parent_source_ref_type_ = Tax_Source_API.DB_INVOICE) THEN           
      $IF Component_Invoic_SYS.INSTALLED $THEN
         Tax_Handling_Invoic_Util_API.Get_Use_Specific_Rate(use_specific_rate_, curr_rate_, company_, party_type_db_, adv_invoice_, package_name_, tax_code_, trans_curr_rate_, tax_curr_rate_); 
      $ELSE
         NULL;
      $END
   ELSIF (parent_source_ref_type_ = Tax_Source_API.DB_DIRECT_CASH_PAYMENT) THEN 
      use_specific_rate_ := Currency_Type_Basic_Data_API.Get_Use_Tax_Rates(company_);
      IF (use_specific_rate_ = Fnd_Boolean_API.DB_TRUE) THEN
         curr_rate_ := tax_curr_rate_;
      ELSE
         curr_rate_ := trans_curr_rate_;
      END IF;   
   ELSE
      -- Revisit: Verify for non-invoice scenarios
      use_specific_rate_ := 'FALSE';
      curr_rate_ := trans_curr_rate_;
   END IF; 
END Get_Use_Specific_Rate;                                                               
   

--This method is to be used by Aurena
PROCEDURE Field_Visible_Tax_Line_Assis (
   field_visibility_rec_   IN OUT tax_assis_field_visibility_rec,   
   package_name_           IN     VARCHAR2,
   tax_calc_structure_id_  IN     VARCHAR2 ) 
IS   
BEGIN
   -- Default settings common to all scenarios.
   field_visibility_rec_.tax_dom_amount_visible := Fnd_Boolean_API.DB_TRUE;
   field_visibility_rec_.tax_parallel_amount_visible := Fnd_Boolean_API.DB_TRUE; 
   IF (tax_calc_structure_id_ IS NOT NULL) THEN
      field_visibility_rec_.tax_base_curr_amount_visible := Fnd_Boolean_API.DB_TRUE;
   ELSE
      field_visibility_rec_.tax_base_curr_amount_visible := Fnd_Boolean_API.DB_FALSE;  
   END IF;    
   field_visibility_rec_.tax_base_dom_amount_visible := Fnd_Boolean_API.DB_FALSE; 
   field_visibility_rec_.tax_base_parallel_amt_visible := Fnd_Boolean_API.DB_FALSE; 
   field_visibility_rec_.non_ded_tax_curr_amt_visible := Fnd_Boolean_API.DB_FALSE; 
   field_visibility_rec_.non_ded_tax_dom_amount_visible := Fnd_Boolean_API.DB_FALSE; 
   field_visibility_rec_.non_ded_tax_paral_amt_visible := Fnd_Boolean_API.DB_FALSE; 
   field_visibility_rec_.total_tax_curr_amount_visible := Fnd_Boolean_API.DB_FALSE;    
   field_visibility_rec_.total_tax_dom_amount_visible := Fnd_Boolean_API.DB_FALSE;  
   field_visibility_rec_.total_tax_parallel_amt_visible := Fnd_Boolean_API.DB_FALSE;
   field_visibility_rec_.deductible_percentage_visible := Fnd_Boolean_API.DB_FALSE;
   field_visibility_rec_.transferred_visible := Fnd_Boolean_API.DB_FALSE;
   field_visibility_rec_.sum_non_ded_curr_amt_visible := Fnd_Boolean_API.DB_FALSE;
   field_visibility_rec_.sum_tot_tax_curr_amt_visible := Fnd_Boolean_API.DB_FALSE;
   -- Special handling of field visible nature relevant to each module/package. 
   IF (package_name_ IN ('MAN_SUPP_INVOICE_API', 'INSTANT_INVOICE_TEMPLATE_API', 'PROJECT_INVOICE_API', 'SUPPLIER_INVOICE_TEMPLATE_API')) THEN
      $IF Component_Invoic_SYS.INSTALLED $THEN
         Tax_Handling_Invoic_Util_API.Field_Visible_Tax_Line_Assis(field_visibility_rec_, package_name_);  
      $ELSE
         NULL;
      $END
   ELSIF (package_name_ IN ('SUB_CON_ITEM_API')) THEN
      $IF Component_Subcon_SYS.INSTALLED $THEN 
         Tax_Handling_Subcon_Util_API.Field_Visible_Tax_Line_Assis(field_visibility_rec_, package_name_);         
      $ELSE
         NULL;
      $END
   ELSIF (package_name_ IN ('SUBVAL_VALUATION_LINE_ITEM_API')) THEN
      $IF Component_Subval_SYS.INSTALLED $THEN 
         Tax_Handling_Subval_Util_API.Field_Visible_Tax_Line_Assis(field_visibility_rec_, package_name_);         
      $ELSE
         NULL;
      $END
   ELSIF (package_name_ IN ('AFP_ITEM_API')) THEN
      $IF Component_Apppay_SYS.INSTALLED $THEN 
         Tax_Handling_Apppay_Util_API.Field_Visible_Tax_Line_Assis(field_visibility_rec_, package_name_);         
      $ELSE
         NULL;
      $END
   ELSIF (package_name_ IN ('CONTRACT_ITEM_API')) THEN
      $IF Component_Conmgt_SYS.INSTALLED $THEN 
         Tax_Handling_Conmgt_Util_API.Field_Visible_Tax_Line_Assis(field_visibility_rec_, package_name_);         
      $ELSE
         NULL;
      $END 
   ELSIF (package_name_ IN ('PURCH_CHANGE_ORDER_CHARGE_API', 'PURCHASE_ORDER_CHARGE_API', 'PURCH_ORDER_LINE_PART_API', 'PURCHASE_CHANGE_ORDER_LINE_API', 'PURCH_ORDER_LINE_NOPART_API', 'PURCHASE_REQUISITION_LINE_API', 'PURCHASE_REQUISITION_LINE_NOPART_API', 'PURCHASE_CHANGE_ORDER_LINE_NOPART_API', 'PURCHASE_QUOTATION_APPROVAL_LINE_API', 'PURCHASE_QUOTATION_LINE_ORDER_API', 'PURCHASE_QUOTATION_LINE_NOPART_ORDER_API')) THEN   
      $IF Component_Purch_SYS.INSTALLED $THEN 
         Tax_Handling_Purch_Util_API.Field_Visible_Tax_Line_Assis(field_visibility_rec_, package_name_);         
      $ELSE
         NULL;
      $END
   ELSIF (package_name_ IN ('CUSTOMER_ORDER_LINE_API', 'CUSTOMER_ORDER_CHARGE_API', 'ORDER_QUOTATION_LINE_API', 'ORDER_QUOTATION_CHARGE_API',
                           'RETURN_MATERIAL_LINE_API', 'RETURN_MATERIAL_CHARGE_API', 'SHIPMENT_FREIGHT_CHARGE_API')) THEN
      $IF Component_Order_SYS.INSTALLED $THEN 
         Tax_Handling_Order_Util_API.Field_Visible_Tax_Line_Assis(field_visibility_rec_, package_name_);
      $ELSE
         NULL;
      $END 
   ELSE
      NULL;
   END IF; 
END Field_Visible_Tax_Line_Assis;


--This method is to be used by Aurena
PROCEDURE Field_Editable_Tax_Line_Assis (
   field_editable_rec_     IN OUT tax_assis_field_editable_rec,
   company_                IN     VARCHAR2,   
   package_name_           IN     VARCHAR2,
   tax_type_db_            IN     VARCHAR2,
   taxable_db_             IN     VARCHAR2,
   tax_liability_type_db_  IN     VARCHAR2,
   tax_calc_structure_id_  IN     VARCHAR2 ) 
IS   
BEGIN
   -- Default settings common to all scenarios.
   field_editable_rec_.tax_percentage_editable := Fnd_Boolean_API.DB_FALSE;   
   IF (tax_type_db_ IN ('CALCTAX', 'NOTAX')) THEN
      field_editable_rec_.tax_curr_amount_editable := Fnd_Boolean_API.DB_FALSE;
      field_editable_rec_.non_ded_tax_curr_amt_editable := Fnd_Boolean_API.DB_FALSE;
      field_editable_rec_.total_tax_curr_amount_editable := Fnd_Boolean_API.DB_FALSE;
   ELSE
      field_editable_rec_.tax_curr_amount_editable := Fnd_Boolean_API.DB_TRUE; 
      field_editable_rec_.non_ded_tax_curr_amt_editable := Fnd_Boolean_API.DB_TRUE;
      field_editable_rec_.total_tax_curr_amount_editable := Fnd_Boolean_API.DB_TRUE;
   END IF;   
   field_editable_rec_.tax_base_curr_amount_editable := Fnd_Boolean_API.DB_FALSE;   
   -- Special handling of field editable nature relevant to each module/package. 
   IF (package_name_ IN ('INSTANT_INVOICE_API', 'OUTGOING_SUPPLIER_INVOICE_API', 'MAN_SUPP_INVOICE_API')) THEN
      $IF Component_Invoic_SYS.INSTALLED $THEN
         Tax_Handling_Invoic_Util_API.Field_Editable_Tax_Line_Assis(field_editable_rec_, package_name_, tax_calc_structure_id_);  
      $ELSE
         NULL;
      $END
   ELSIF (package_name_ IN ('SUB_CON_ITEM_API')) THEN
      $IF Component_Subcon_SYS.INSTALLED $THEN 
         Tax_Handling_Subcon_Util_API.Field_Editable_Tax_Line_Assis(field_editable_rec_, package_name_);
      $ELSE
         NULL;
      $END
   ELSIF (package_name_ IN ('CONTRACT_ITEM_API')) THEN
      $IF Component_Conmgt_SYS.INSTALLED $THEN 
         Tax_Handling_Conmgt_Util_API.Field_Editable_Tax_Line_Assis(field_editable_rec_, package_name_);
      $ELSE
         NULL;
      $END 
   ELSIF (package_name_ IN ('CUSTOMER_ORDER_LINE_API', 'CUSTOMER_ORDER_CHARGE_API', 'ORDER_QUOTATION_LINE_API', 'ORDER_QUOTATION_CHARGE_API',
                           'RETURN_MATERIAL_LINE_API', 'RETURN_MATERIAL_CHARGE_API', 'SHIPMENT_FREIGHT_CHARGE_API')) THEN
      $IF Component_Order_SYS.INSTALLED $THEN 
         Tax_Handling_Order_Util_API.Field_Editable_Tax_Line_Assis(field_editable_rec_, package_name_, company_, tax_type_db_, taxable_db_, tax_liability_type_db_, tax_calc_structure_id_);
      $ELSE
         NULL;
      $END 
   ELSIF (package_name_ IN ('PURCH_CHANGE_ORDER_CHARGE_API', 'PURCHASE_CHANGE_ORDER_LINE_NOPART_API', 'PURCHASE_CHANGE_ORDER_LINE_API', 'PURCHASE_QUOTATION_LINE_ORDER_API', 'PURCHASE_QUOTATION_LINE_NOPART_ORDER_API',
                           'PURCHASE_QUOTATION_APPROVAL_LINE_API', 'PURCHASE_REQUISITION_LINE_NOPART_API', 'PURCHASE_REQUISITION_LINE_API', 'PURCHASE_ORDER_CHARGE_API', 'PURCH_ORDER_LINE_NOPART_API', 'PURCH_ORDER_LINE_PART_API')) THEN
      $IF Component_Purch_SYS.INSTALLED $THEN 
         Tax_Handling_Purch_Util_API.Field_Editable_Tax_Line_Assis(field_editable_rec_, package_name_);
      $ELSE
         NULL;
      $END
   ELSE
      NULL;
   END IF; 
END Field_Editable_Tax_Line_Assis; 


--This method is to be used by Aurena
PROCEDURE Set_Tax_Line_Assis_Colm_Labels (
   label_rec_              IN OUT tax_assistant_label_rec,   
   package_name_           IN     VARCHAR2 ) 
IS   
BEGIN
   -- Default settings common to all scenarios.
   label_rec_.tax_lines_label := Language_SYS.Translate_Constant(lu_name_, 'TAX_LINES_LABEL: Tax Line Details');
   label_rec_.list_tax_percentage_label := Language_SYS.Translate_Constant(lu_name_, 'LIST_TAX_PERCENTAGE_LABEL: Tax(%)');
   label_rec_.list_ded_percentage_label := Language_SYS.Translate_Constant(lu_name_, 'LIST_TAX_DED_PERCENTAGE_LABEL: Deductible(%)');
   label_rec_.list_tax_amount_label := Language_SYS.Translate_Constant(lu_name_, 'TAX_AMOUNT_LABEL: Tax Amount');
   label_rec_.list_tax_dom_amount_label := Language_SYS.Translate_Constant(lu_name_, 'LIST_TAX_DOM_AMOUNT_LABEL: Tax Amount in Accounting Currency');
   label_rec_.list_tax_parallel_amt_label := Language_SYS.Translate_Constant(lu_name_, 'LIST_TAX_PARALLEL_AMOUNT_LABEL: Tax Amount in Parallel Currency');
   label_rec_.list_tax_base_curr_amt_label := Language_SYS.Translate_Constant(lu_name_, 'LIST_TAX_BASE_CURR_AMOUNT_LBL: Tax Base Amount'); 
   label_rec_.list_tax_base_dom_amount_label := Language_SYS.Translate_Constant(lu_name_, 'LIST_TAX_BASE_DOM_AMOUNT_LABEL: Tax Base Amount in Accounting Currency');
   label_rec_.list_tax_base_para_amt_label := Language_SYS.Translate_Constant(lu_name_, 'LIST_TAX_BASE_PARA_AMOUNT_LBL: Tax Base Amount in Parallel Currency');
   label_rec_.list_non_ded_tax_amt_label := Language_SYS.Translate_Constant(lu_name_, 'NON_DED_TAX_AMOUNT_LABEL: Non-deductible Tax Amount');
   label_rec_.list_non_ded_tax_dom_amt_lbl := Language_SYS.Translate_Constant(lu_name_, 'LIST_NON_DED_TAX_DOM_AMT_LABEL: Non-deductible Tax Amount in Accounting Currency');
   label_rec_.list_non_ded_tax_para_amt_lbl := Language_SYS.Translate_Constant(lu_name_, 'LIST_NON_DED_TAX_PARA_AMT_LBL: Non-deductible Tax Amount in Parallel Currency');
   label_rec_.list_total_tax_curr_amt_label := Language_SYS.Translate_Constant(lu_name_, 'TOTAL_TAX_AMOUNT_LABEL: Total Tax Amount');
   label_rec_.list_total_tax_dom_amt_label := Language_SYS.Translate_Constant(lu_name_, 'LIST_TOTAL_TAX_DOM_AMT_LABEL: Total Tax Dom Amount');
   label_rec_.list_total_tax_para_amount_label := Language_SYS.Translate_Constant(lu_name_, 'LIST_TOTAL_TAX_PARA_AMT_LABEL: Total Tax Parallel Amount');
   label_rec_.group_gross_curr_amount_label := Language_SYS.Translate_Constant(lu_name_, 'GROUP_GROSS_CURR_AMOUNT_LABEL: Gross Amount');
   label_rec_.group_net_curr_amount_label := Language_SYS.Translate_Constant(lu_name_, 'GROUP_NET_CURR_AMOUNT_LABEL: Net Amount');   
   label_rec_.group_vat_curr_amount_label := Language_SYS.Translate_Constant(lu_name_, 'TAX_AMOUNT_LABEL: Tax Amount');
   label_rec_.group_non_ded_curr_amt_label := Language_SYS.Translate_Constant(lu_name_, 'NON_DED_TAX_AMOUNT_LABEL: Non-deductible Tax Amount');
   label_rec_.group_total_tax_curr_amt_lbl := Language_SYS.Translate_Constant(lu_name_, 'TOTAL_TAX_AMOUNT_LABEL: Total Tax Amount');
   label_rec_.group_cost_curr_amount_label := Language_SYS.Translate_Constant(lu_name_, 'GROUP_COST_CURR_AMOUNT_LABEL: Cost');
   -- Overridden column names when it is required to have another label.
   IF (package_name_ IN ('PURCH_CHANGE_ORDER_CHARGE_API', 'PURCHASE_ORDER_CHARGE_API', 'PURCH_ORDER_LINE_PART_API', 'PURCHASE_CHANGE_ORDER_LINE_API', 'PURCH_ORDER_LINE_NOPART_API', 'PURCHASE_REQUISITION_LINE_API', 'PURCHASE_REQUISITION_LINE_NOPART_API', 'PURCHASE_CHANGE_ORDER_LINE_NOPART_API', 'PURCHASE_QUOTATION_APPROVAL_LINE_API', 'PURCHASE_QUOTATION_LINE_ORDER_API', 'PURCHASE_QUOTATION_LINE_NOPART_ORDER_API')) THEN
      $IF Component_Purch_SYS.INSTALLED $THEN
         Tax_Handling_Purch_Util_API.Set_Tax_Line_Assis_Colm_Labels(label_rec_, package_name_);            
      $ELSE
         NULL;
      $END
   ELSIF (package_name_ IN ('CUSTOMER_ORDER_LINE_API', 'CUSTOMER_ORDER_CHARGE_API', 'ORDER_QUOTATION_LINE_API', 'ORDER_QUOTATION_CHARGE_API', 'RETURN_MATERIAL_LINE_API', 'RETURN_MATERIAL_CHARGE_API', 'SHIPMENT_FREIGHT_CHARGE_API')) THEN
      $IF Component_Order_SYS.INSTALLED $THEN
         Tax_Handling_Order_Util_API.Set_Tax_Line_Assis_Colm_Labels(label_rec_, package_name_);            
      $ELSE
         NULL;
      $END
   ELSE
      NULL;
   END IF; 
END Set_Tax_Line_Assis_Colm_Labels;


-- This method is to be used by Aurena
-- Set Tax Code Lov For Tax Line Assistant
FUNCTION Set_Tax_Cd_Lov_For_Tax_Ln_Asis ( 
   company_               IN VARCHAR2,   
   taxable_               IN VARCHAR2,
   liability_type_        IN VARCHAR2,
   tax_calc_structure_id_ IN VARCHAR2,
   party_type_            IN VARCHAR2,
   transaction_date_      IN DATE,
   package_name_          IN VARCHAR2,
   source_ref4_           IN VARCHAR2 )  RETURN Objid_Arr
IS
   base_collection_ Objid_Arr := Objid_Arr();
BEGIN
   IF (package_name_ IN ('MIXED_PAYMENT_MAN_POSTING_API')) THEN
      $IF Component_Payled_SYS.INSTALLED $THEN
         base_collection_ := Tax_Handling_Payled_Util_API.Set_Tax_Cd_Lov_For_Tax_Ln_Asis(source_ref4_);
      $ELSE
         NULL;
      $END      
   END IF;
   RETURN  base_collection_;  
END Set_Tax_Cd_Lov_For_Tax_Ln_Asis;    


-- This method is to be used by Aurena
-- Validate Tax code Mandatory on Tax Line Assistant
PROCEDURE Val_Tax_Code_Mand_On_Tax_Asis (
   company_                IN VARCHAR2,     
   source_ref_type_db_     IN VARCHAR2,
   source_ref1_            IN VARCHAR2,
   source_ref2_            IN VARCHAR2,
   source_ref3_            IN VARCHAR2,
   source_ref4_            IN VARCHAR2,
   source_ref5_            IN VARCHAR2,
   tax_validation_type_    IN VARCHAR2 )
IS
BEGIN
   IF (source_ref_type_db_ = Tax_Source_API.DB_DIRECT_CASH_PAYMENT) THEN      
      $IF Component_Payled_SYS.INSTALLED $THEN
         Tax_Handling_Payled_Util_API.Validate_Tax_Code_Manda_On_Acc(NVL(source_ref4_, company_), source_ref_type_db_, source_ref1_, source_ref2_, source_ref3_, source_ref4_, source_ref5_); 
      $ELSE
         NULL;
      $END      
   ELSE   
      Validate_Tax_Code_Mandatory(company_, tax_validation_type_);
   END IF;
END Val_Tax_Code_Mand_On_Tax_Asis;    


-- This method is to be used by Aurena
PROCEDURE Update_Tax_Info_Table (
   tax_info_table_         IN OUT tax_information_table,
   company_                IN     VARCHAR2,
   package_name_           IN     VARCHAR2,   
   adv_invoice_            IN     VARCHAR2,
   action_                 IN     VARCHAR2,
   source_ref1_            IN     VARCHAR2,
   curr_rate_              IN     NUMBER,
   in_tax_curr_rate_       IN     NUMBER,
   dummy_tax_info_table_   IN     tax_information_table )
IS
  use_specific_rate_      VARCHAR2(5); 
BEGIN
   IF (package_name_ IN ('INSTANT_INVOICE_API', 'OUTGOING_SUPPLIER_INVOICE_API', 'MAN_SUPP_INVOICE_API', 'MAN_CUST_INVOICE_API')) THEN
      $IF Component_Invoic_SYS.INSTALLED $THEN 
         Tax_Handling_Invoic_Util_API.Update_Tax_Info_Table(tax_info_table_,
                                                            company_,
                                                            package_name_,
                                                            adv_invoice_,
                                                            action_, 
                                                            TO_NUMBER(source_ref1_),
                                                            in_tax_curr_rate_,
                                                            dummy_tax_info_table_);  
      $END
      NULL;
   ELSIF (package_name_ = 'MIXED_PAYMENT_MAN_POSTING_API') THEN  
      $IF Component_Payled_SYS.INSTALLED $THEN 
          use_specific_rate_ := Currency_Type_Basic_Data_API.Get_Use_Tax_Rates(company_);
          Tax_Handling_Payled_Util_API.Update_Tax_Info_Table(tax_info_table_,
                                                             package_name_,
                                                             NULL,
                                                             use_specific_rate_,
                                                             in_tax_curr_rate_);  
      $END
      NULL;
   ELSIF (package_name_ IN ('CUSTOMER_ORDER_LINE_API', 'CUSTOMER_ORDER_CHARGE_API', 'ORDER_QUOTATION_LINE_API', 'ORDER_QUOTATION_CHARGE_API',
                            'RETURN_MATERIAL_LINE_API', 'RETURN_MATERIAL_CHARGE_API', 'SHIPMENT_FREIGHT_CHARGE_API', 'CUSTOMER_ORDER_INV_ITEM_API')) THEN  
      $IF Component_Order_SYS.INSTALLED $THEN 
          Tax_Handling_Order_Util_API.Update_Tax_Info_Table(tax_info_table_,
                                                            company_,
                                                            package_name_,
                                                            source_ref1_,
                                                            curr_rate_);  
      $END
      NULL;
   END IF;
END Update_Tax_Info_Table;      


--This method is to be used by Aurena    
PROCEDURE Save_From_Tax_Line_Assistant (
   return_info_rec_              OUT rtn_info_save_tax_assist_rec,
   package_name_                 IN  VARCHAR2,
   company_                      IN  VARCHAR2,   
   source_key_rec_               IN  source_key_rec,
   previous_source_objversion_   IN  VARCHAR2, 
   tax_info_table_               IN  tax_information_table,
   calc_base_                    IN  VARCHAR2,
   tax_class_id_                 IN  VARCHAR2,
   transaction_date_             IN  DATE )    
IS    
BEGIN 
   IF (package_name_ IN ('CONTRACT_ITEM_API')) THEN    
      $IF Component_Conmgt_SYS.INSTALLED $THEN 
         Tax_Handling_Conmgt_Util_API.Save_From_Tax_Line_Assistant(company_, source_key_rec_, tax_info_table_, calc_base_, package_name_);       
      $ELSE
         NULL;
      $END 
   ELSIF (package_name_ IN ('INSTANT_INVOICE_API', 'OUTGOING_SUPPLIER_INVOICE_API', 'MAN_SUPP_INVOICE_API', 'PROJECT_INVOICE_API', 'INSTANT_INVOICE_TEMPLATE_API', 'SUPPLIER_INVOICE_TEMPLATE_API')) THEN         
      $IF Component_Invoic_SYS.INSTALLED $THEN
         Tax_Handling_Invoic_Util_API.Save_From_Tax_Line_Assistant(return_info_rec_, company_, source_key_rec_, previous_source_objversion_, tax_info_table_, calc_base_, tax_class_id_, package_name_);  
      $ELSE
         NULL;
      $END 
   ELSIF (package_name_ IN ('CUSTOMER_ORDER_LINE_API', 'CUSTOMER_ORDER_CHARGE_API', 'ORDER_QUOTATION_LINE_API', 'ORDER_QUOTATION_CHARGE_API',
                           'RETURN_MATERIAL_LINE_API', 'RETURN_MATERIAL_CHARGE_API', 'SHIPMENT_FREIGHT_CHARGE_API', 'CUSTOMER_ORDER_INV_ITEM_API')) THEN         
      $IF Component_Order_SYS.INSTALLED $THEN
         Tax_Handling_Order_Util_API.Save_From_Tax_Line_Assistant(company_, source_key_rec_, previous_source_objversion_, tax_info_table_, calc_base_, tax_class_id_, package_name_);  
      $ELSE
         NULL;
      $END
   ELSIF (package_name_ IN ('MIXED_PAYMENT_MAN_POSTING_API')) THEN
      $IF Component_Payled_SYS.INSTALLED $THEN            
         Tax_Handling_Payled_Util_API.Save_From_Tax_Line_Assistant(company_, source_key_rec_, previous_source_objversion_, tax_info_table_, calc_base_, package_name_); 
      $ELSE
         NULL;
      $END         
   ELSIF (package_name_ IN ('SUB_CON_ITEM_API')) THEN   
      $IF Component_Subcon_SYS.INSTALLED $THEN 
         NULL;
         Tax_Handling_Subcon_Util_API.Save_From_Tax_Line_Assistant(company_, source_key_rec_, tax_info_table_, calc_base_, package_name_, transaction_date_);
      $ELSE
         NULL;
      $END      
   ELSIF (package_name_ IN ('PURCH_CHANGE_ORDER_CHARGE_API', 'PURCHASE_ORDER_CHARGE_API', 'PURCH_ORDER_LINE_PART_API', 'PURCHASE_CHANGE_ORDER_LINE_API', 'PURCH_ORDER_LINE_NOPART_API', 'PURCHASE_REQUISITION_LINE_API', 'PURCHASE_REQUISITION_LINE_NOPART_API', 'PURCHASE_CHANGE_ORDER_LINE_NOPART_API', 'PURCHASE_QUOTATION_APPROVAL_LINE_API', 'PURCHASE_QUOTATION_LINE_ORDER_API', 'PURCHASE_QUOTATION_LINE_NOPART_ORDER_API')) THEN   
      $IF Component_Purch_SYS.INSTALLED $THEN 
         NULL;
         Tax_Handling_Purch_Util_API.Save_From_Tax_Line_Assistant(company_, source_key_rec_, tax_info_table_, calc_base_, package_name_);
      $ELSE
         NULL;
      $END      
   END IF;      
END Save_From_Tax_Line_Assistant;

                                                      
--This method is to be used by Aurena  
PROCEDURE Do_Additional_Validations (
   company_             IN VARCHAR2,
   package_name_        IN VARCHAR2,
   source_ref_type_db_  IN VARCHAR2,
   source_ref1_         IN VARCHAR2,
   source_ref2_         IN VARCHAR2,
   source_ref3_         IN VARCHAR2,
   source_ref4_         IN VARCHAR2,
   source_ref5_         IN VARCHAR2,   
   validate_rec_        tax_assistant_validation_rec )  
IS
BEGIN
   IF ((validate_rec_.tax_lines_count = 0) AND (validate_rec_.is_removed = Fnd_Boolean_API.DB_TRUE)) THEN
      Validate_Tax_Code_Mandatory(company_, validate_rec_.tax_validation_type);
   END IF;   
   IF (source_ref_type_db_ IN (Tax_Source_API.DB_CUSTOMER_ORDER_LINE, Tax_Source_API.DB_CUSTOMER_ORDER_CHARGE, 
                               Tax_Source_API.DB_ORDER_QUOTATION_LINE, Tax_Source_API.DB_ORDER_QUOTATION_CHARGE, 
                               Tax_Source_API.DB_RETURN_MATERIAL_LINE, Tax_Source_API.DB_RETURN_MATERIAL_CHARGE, 
                               Tax_Source_API.DB_SHIPMENT_FREIGHT_CHARGE)) THEN 
      $IF Component_Order_SYS.INSTALLED $THEN
         Tax_Handling_Order_Util_API.Do_Additional_Validations(source_ref_type_db_,
                                                               source_ref1_,
                                                               source_ref2_,
                                                               source_ref3_,
                                                               source_ref4_,
                                                               source_ref5_,
                                                               validate_rec_);     
      $ELSE
         NULL;
      $END 
   ELSIF (source_ref_type_db_ = Tax_Source_API.DB_INVOICE) THEN 
      $IF Component_Invoic_SYS.INSTALLED $THEN
         Tax_Handling_Invoic_Util_API.Do_Additional_Validations(company_,
                                                                package_name_,
                                                                source_ref_type_db_,
                                                                source_ref1_,
                                                                source_ref2_,
                                                                source_ref3_,
                                                                source_ref4_,
                                                                source_ref5_,                                                                                                                                      
                                                                validate_rec_);     
      $ELSE
         NULL;
      $END
   ELSIF (source_ref_type_db_ = Tax_Source_API.DB_DIRECT_CASH_PAYMENT) THEN 
      $IF Component_Payled_SYS.INSTALLED $THEN
         Tax_Handling_Payled_Util_API.Do_Additional_Validations(company_,
                                                                source_ref_type_db_,
                                                                source_ref1_,
                                                                source_ref2_,
                                                                source_ref3_,
                                                                source_ref4_,
                                                                source_ref5_,                                                                                                                                      
                                                                validate_rec_);     
      $ELSE
         NULL;
      $END   
   END IF;   
END Do_Additional_Validations;


--This method is to be used by Aurena in PURCH
FUNCTION Create_Source_Info_Param_Rec (   
   company_                    IN VARCHAR2,   
   source_ref_type_db_         IN VARCHAR2,
   source_ref1_                IN VARCHAR2,      
   source_ref2_                IN VARCHAR2,      
   source_ref3_                IN VARCHAR2,      
   source_ref4_                IN VARCHAR2,
   source_ref5_                IN VARCHAR2,
   source_objversion_          IN VARCHAR2,
   party_type_db_              IN VARCHAR2,   
   identity_                   IN VARCHAR2,   
   transaction_date_           IN DATE,
   transaction_currency_       IN VARCHAR2,
   delivery_address_id_        IN VARCHAR2,   
   advance_invoice_            IN VARCHAR2,
   tax_validation_type_        IN VARCHAR2,
   taxable_                    IN VARCHAR2,
   liability_type_             IN VARCHAR2,
   tax_calc_structure_id_      IN VARCHAR2,
   curr_rate_                  IN NUMBER,
   tax_curr_rate_              IN NUMBER, 
   parallel_curr_rate_         IN NUMBER, 
   div_factor_                 IN NUMBER, 
   parallel_div_factor_        IN NUMBER,  
   gross_curr_amount_          IN NUMBER, 
   net_curr_amount_            IN NUMBER,
   tax_curr_amount_            IN NUMBER,
   non_ded_tax_curr_amount_    IN NUMBER,
   total_tax_curr_amount_      IN NUMBER ) RETURN source_info_rec
IS 
   source_info_param_rec_        source_info_rec;
BEGIN   
   source_info_param_rec_.company                  := company_;
   source_info_param_rec_.source_ref_type_db       := source_ref_type_db_;
   source_info_param_rec_.source_ref1              := source_ref1_;
   source_info_param_rec_.source_ref2              := source_ref2_;
   source_info_param_rec_.source_ref3              := source_ref3_;
   source_info_param_rec_.source_ref4              := source_ref4_;
   source_info_param_rec_.source_ref5              := source_ref5_;
   source_info_param_rec_.source_objversion        := source_objversion_;
   source_info_param_rec_.party_type_db            := party_type_db_;
   source_info_param_rec_.identity                 := identity_;
   source_info_param_rec_.transaction_date         := transaction_date_;
   source_info_param_rec_.transaction_currency     := transaction_currency_;
   source_info_param_rec_.delivery_address_id      := delivery_address_id_;
   source_info_param_rec_.advance_invoice          := advance_invoice_;
   source_info_param_rec_.tax_validation_type      := tax_validation_type_;
   source_info_param_rec_.taxable                  := taxable_;
   source_info_param_rec_.liability_type           := liability_type_;
   source_info_param_rec_.tax_calc_structure_id    := tax_calc_structure_id_;
   source_info_param_rec_.curr_rate                := curr_rate_; 
   source_info_param_rec_.tax_curr_rate            := tax_curr_rate_;
   source_info_param_rec_.parallel_curr_rate       := parallel_curr_rate_;
   source_info_param_rec_.div_factor               := div_factor_;  
   source_info_param_rec_.parallel_div_factor      := parallel_div_factor_;
   source_info_param_rec_.gross_curr_amount        := gross_curr_amount_;
   source_info_param_rec_.net_curr_amount          := net_curr_amount_;
   source_info_param_rec_.tax_curr_amount          := tax_curr_amount_;
   source_info_param_rec_.non_ded_tax_curr_amount  := non_ded_tax_curr_amount_;
   source_info_param_rec_.total_tax_curr_amount    := total_tax_curr_amount_;
   RETURN source_info_param_rec_;
END Create_Source_Info_Param_Rec;


-- This method is to be used by Aurena
PROCEDURE Tax_Line_Assis_Set_To_Default (
   tax_info_table_         OUT tax_information_table,
   line_amount_rec_        OUT line_amount_rec, 
   tax_calc_structure_id_  OUT VARCHAR2,
   tax_class_id_           OUT VARCHAR2,
   package_name_           IN  VARCHAR2,
   company_                IN  VARCHAR2, 
   source_ref_type_db_     IN  VARCHAR2,
   source_ref1_            IN  VARCHAR2,
   source_ref2_            IN  VARCHAR2,
   source_ref3_            IN  VARCHAR2,
   source_ref4_            IN  VARCHAR2,
   source_ref5_            IN  VARCHAR2,
   calc_base_              IN  VARCHAR2 )
IS  
BEGIN
   IF (package_name_ IN ('INSTANT_INVOICE_API', 'OUTGOING_SUPPLIER_INVOICE_API', 'MAN_SUPP_INVOICE_API', 'MAN_CUST_INVOICE_API', 'CUSTOMER_ORDER_INV_ITEM_API', 'CUSTOMER_ORDER_INV_HEAD_API', 'SUPPLIER_INVOICE_TEMPLATE_API', 'INSTANT_INVOICE_TEMPLATE_API')) THEN
      $IF Component_Invoic_SYS.INSTALLED $THEN 
         Tax_Handling_Invoic_Util_API.Tax_Line_Assis_Set_To_Default(tax_info_table_,
                                                                    line_amount_rec_, 
                                                                    tax_calc_structure_id_,
                                                                    tax_class_id_,
                                                                    company_, 
                                                                    package_name_,
                                                                    source_ref_type_db_,
                                                                    source_ref1_,
                                                                    source_ref2_,     
                                                                    source_ref3_,
                                                                    source_ref4_,
                                                                    source_ref5_,
                                                                    calc_base_);  
      $ELSE
         NULL;
      $END
   ELSIF (package_name_ IN ('CUSTOMER_ORDER_LINE_API', 'CUSTOMER_ORDER_CHARGE_API', 'ORDER_QUOTATION_LINE_API', 'ORDER_QUOTATION_CHARGE_API', 'RETURN_MATERIAL_LINE_API', 'RETURN_MATERIAL_CHARGE_API', 'SHIPMENT_FREIGHT_CHARGE_API')) THEN
      $IF Component_Order_SYS.INSTALLED $THEN
         Tax_Handling_Order_Util_API.Tax_Line_Assis_Set_To_Default(tax_info_table_,
                                                                    line_amount_rec_, 
                                                                    tax_calc_structure_id_,
                                                                    tax_class_id_,
                                                                    company_, 
                                                                    package_name_,
                                                                    source_ref_type_db_,
                                                                    source_ref1_,
                                                                    source_ref2_,     
                                                                    source_ref3_,
                                                                    source_ref4_,
                                                                    source_ref5_,
                                                                    calc_base_);            
      $ELSE
         NULL;
      $END
   ELSIF (package_name_ = 'CONTRACT_ITEM_API') THEN
      $IF Component_Conmgt_SYS.INSTALLED $THEN
         Tax_Handling_Conmgt_Util_API.Tax_Line_Assis_Set_To_Default(tax_info_table_,
                                                                    line_amount_rec_, 
                                                                    tax_calc_structure_id_,
                                                                    company_, 
                                                                    package_name_,
                                                                    source_ref_type_db_,
                                                                    source_ref1_,
                                                                    source_ref2_,     
                                                                    source_ref3_,
                                                                    source_ref4_,
                                                                    source_ref5_,
                                                                    calc_base_);            
      $ELSE
         NULL;
      $END
   ELSIF (package_name_ = 'SUB_CON_ITEM_API') THEN
      $IF Component_Subcon_SYS.INSTALLED $THEN
         Tax_Handling_Subcon_Util_API.Tax_Line_Assis_Set_To_Default(tax_info_table_,
                                                                    line_amount_rec_, 
                                                                    tax_calc_structure_id_,
                                                                    company_, 
                                                                    package_name_,
                                                                    source_ref_type_db_,
                                                                    source_ref1_,
                                                                    source_ref2_,     
                                                                    source_ref3_,
                                                                    source_ref4_,
                                                                    source_ref5_,
                                                                    calc_base_);            
      $ELSE
         NULL;
      $END         
   END IF;
END Tax_Line_Assis_Set_To_Default;
