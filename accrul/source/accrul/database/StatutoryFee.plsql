-----------------------------------------------------------------------------
--
--  Logical unit: StatutoryFee
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  970609  MiJo     Cheanged column name from Percentage to Fee_Rate.
--  970718  SLKO     Converted to Foundation 1.2.2d
--  970813  SLKO     To short variable in Get_Description function.
--  970808  ARBI     Added VALID_FROM to key - modifications of LU
--  970825  MiJo     Bug 97-0053, added default date for valid from and valid until.
--  990415  JPS      Performed Template Changes. (Foundation 2.2.1)
--  990824  AnTo     Added columns vat_received and vat_disbursed
--  990929  Uma      Fixed Bug#11752
--  000119  Uma      Global Date Definition.
--  000707  BmEk     A527: Added Check_Fee_Code
--  000914  HiMu     Added General_SYS.Init_Method
--  000915  LiSv     A806: Added check_exist_deductible and exist_deductible. Added new view
--                   STATUTORY_FEE_DEDUCTIBLE
--  000920  LiSv     Call #48841 corrected.
--  000926  BmEk     A520: Modified Check_Delete___ and added Validate_Modify___
--  001003  LiSv     A808: Added control in Upack_Check_Insert and Unpack_Check_Update.
--  001004  BmEk     A527: Corrected cursor in Get_Fee_Percent.
--  001013  prtilk   BUG # 15677  Checked General_SYS.Init_Method
--  001026  BmEk     Call #50952. Modified fee_rate and description to not null columns.
--  001122  LiSv     For new Create Company concept added new view statutory_fee_etc and statutory_fee_pct.
--                   Added procedures Make_Company, Copy___, Import___ and Export___.
--  010221  ToOs     Bug # 20177 Added Global Lu constants for check for transaction_sys calls
--  010502  BmEk     IID 9001. Added view STATUTORY_FEE_NON_VAT and STATUTORY_FEE_VAT
--  010510  JeGu     Bug #21705 Implementation New Dummyinterface
--                   Changed Insert__ RETURNING rowid INTO objid_
--  010531  Bmekse   Removed methods used by the old way for transfer basic data from
--                   master to slave (nowdays is Replication used instead)
--  010814  AjRolk   Bug ID 23691 Fixed, Included check for the FEE_RATE
--  010816  OVJOSE   Added Create Company translation method Create_Company_Translations___
--  011016  FaMese   Bug # 19207.
--  011025  LiSV     Futher correction of Bug #19207.
--  011207  LiSv     IID 10001. Added ncf_inv_tax_rate. NOTE This is only used by companies in Norway.
--  011207  ovjose   IID 20001 Enhancement of Update Company. Changes inside make_company method
--                   Changed Import___, Export___ and Copy___ methods to use records and update on key
--  020103  KuPelk   IID 10950 Added new table column as tax_recoverable to Statutory_Fee_Tab.
--  020121  LiSv     IID 10120 Added check for tax type IRS1099TX. Added view STATUTORY_FEE_TAX_WITHHOLD.
--  020213  Mnisse   IID 21003, Added company translation support for description
--  020219  KAGALK   Call 27275 corrected. Added if statement to unpack_check_update.
--  020307  BmEk     Added Get_Fee_Type_Client
--  020312  KuPelk   Call Id 77128 Corrected.
--  020314  Thsrlk   Redo Call 27275 using dynamic calls.
--  020314  Upulp    Call ID 78269 Fixed
--  020315  BmEk     Added view VIEWNONVATCUST
--  020320  LiSv     Additional correction of Bug #19207. Changed Get_Description
--  020320  Mnisse   Copy__ changed FOUND -> NOTFOUND
--  020325  Shsalk   Call Id 79630 Fixed. changed get_description and get_pecentage.
--                   Added view TAX_CODE_LOV. Added functions get_valid_until and get_valid_from
--  020531  MACHLK   Bug# 29512 Fixed. Added new view TAX_CODE_LOV1.
--  020611  ovjose   Bug 29600 Corrected. Removed function call in STATUTORY_FEE_PCT.
--  021002  Nimalk   Removed usage of the view Company_Finance_Auth in viewes
--                   and replaced by view Company_Finance_Auth1 using EXISTS caluse instead of joins
--  021112  risrlk   SALSA-IID ITFI101E. Modified Check_delete___ and Insert___ methods.
--  021120  Jakalk   SALSA-IIDFRFI105E. Added public method Get_Deductible_Percent.
--  021202  mgutse   SALSA-IIDITFI127N. Allow tax withholding tax codes to be deductible.
--  021209  ISJALK   IIDESFI109E, added attribute multiple_tax, views STATUTORY_FEE_MULTIPLE, STATUTORY_FEE_DEDUCT_MULTIPLE,
--                   STATUTORY_FEE_VAT_MULTIPLE, STATUTORY_FEE_VSR and changed WHERE clauses of some existing views.
--  021209  ISJALK   IIDESFI109E, Changed Get_Description.
--                   Added public method Set_Multiple_Tax.
--  021230  ISJALK   SP3 merge, BUG 32675.
--  030109  ISJALK   IIDESFI109E, Addded STATUTORY_FEE_NON_VAT_MULTIPLE.
--  030116  ISJALK   Call 92685, Added STATUTORY_FEE_NON_RDE.
--  030122  Hecolk   IID ESFI109EB. Added view 'STATUTORY_FEE_NON_RDE_MULTIPLE'
--  030205  Hecolk   IID ESFI109EB. Modified views 'STATUTORY_FEE_NON_RDE' and 'STATUTORY_FEE_NON_RDE_MULTIPLE'
--  030226  Hecolk   B94551 for IID ESFI109EB, Added Checks in 'Unpack_Check_Insert___' & 'Unpack_Check_Update___'
--  030306  Hecolk   IID ESFI109E, Modified VIEW 'STATUTORY_FEE'
--  030317  RAFA     IID ITFI127N, added new columns to Statutory_fee_tab
--  030320  prdilk   B94834 Added Checks in 'Unpack_Check_Insert___' & 'Unpack_Check_Update___'
--  030324  Hecolk   B95580 for IID ESFI109E, Modified view 'STATUTORY_FEE_NON_RDE_MULTIPLE'
--  030403  Hecolk   IID ESFI109E, Quality Issues
--  030408  mgutse   IID ITFI127N. Validation of tax code when using tax withhold amount table.
--  030505  ChFolk   Call ID 96247. Added FUNCTION Get_Order_Fee_Rate.
--  030602  mgutse   IID ITFI127N. Validation of tax code when using tax withhold amount table.
--  030611  ChFolk   Added new View STATUTORY_FEE_ADV_PAY_VAT_LOV.
--  030613  RAFA     ARFI144N Added tax_amount_at_inv_print
--  030627  Hecolk   Modified Precedure Unpack_Check_Insert___
--  030703  Hecolk   Modified Precedure Unpack_Check_Update___
--  030703  Hecolk   Added New FUNCTION Check_Attached & Modified PROCEDURE Check_Delete___
--  030709  ChFolk   Reserved the changes that have been done for Advance Payment. Removed View STATUTORY_FEE_ADV_PAY_VAT_LOV.
--  040329  Gepelk   2004 SP1 Merge.
--  040407  Hecolk   Touch down Merge - FI01 Minimum Tax
--  040615  sachlk   FIPR338A2: Unicode Changes.
--  040910  GeKalk   Added a new public method Get_Tot_Attached_Fee_Rate.
--  040918  AnGiSe   FITH352. Added field minimum_base_amount to views STATUTORY_FEE and STATUTORY_FEE_DEDUCT_MULTIPLE,
--                   to methods for insert,update and get.
--  041112  Risrlk   Merged LCS Bug 45341
--  041122  AnGiSe   B119979 Added method Exist_Withhold for control of valid tax_withholding_codes.
--  050106  NiFelk   B12076, Added method Exist_Deduct.
--  050223  AnGiSe   B122004 Default value set to NULL instead of SYSDATE for in parameter in get_fee_type
--  050223           and added null handling in cursor instead, since it's not working with default sysdate.
--  051208  GaWiLk   LCS merge 45867. Added Get_Vat_Received_Db, Get_Vat_Disbursed_Db
--  051228  Kagalk   LCS merge 54341, Modified error message.
--  060124  Ingulk   Call ID 130035 Added a method Is_Withheld
--  060209  Nalslk   LCS merge 48733, Added validation to check, deductible percentage with Sales tax and Use tax
--  060302  Nalslk   LCS merge 53770, To support CALCTAX with deductible less than 100%, removed existing validations.
--  061117  Paralk   B139949 , Call PROCEDURE Remove_Exception_Tax_Codes() in Remove__().
--  070420  Shsalk   LCS merge 64353, Added new method Get_Fee_Type_For_Basic_Data().
--  070510  Prdilk   B141476, Modified Unpack_Check_Update___ to support translations. 
--  070601  Surmlk   Merged Bug 65074, corrected. Modifications done to allow change tax pecentage for sales and use tax 
--                   in all tax regimes. To avoid changing tax pecentage for VAT in all tax regimes. 
--  070810  Shwilk   Done Assert_SYS corrections.
--  071212  Maaylk   Bug 69131, Added new function Get_Fee_Type()
--  080709  Kagalk   Bug 75220, Changed error text constant to enable to translate it correctly.
--  090421  mawelk   Bug 80044, Corrected. Changesto Check_Delete___() and  Delete___()
--  090717  ErFelk   Bug 83174, Changed some error messages in Unpack_Check_Insert___, Unpack_Check_Update___ and Import___.
--  091106  Jofise   Bug 86773, Added column tax_reporting_category to STATUTORY_FEE_TAB. Changed from triangulation_trade
--                   to tax_reporting_category on all places in this file. Added new functions, Get_Tax_Reporting_Category_Db()
--                   and Get_Tax_Reporting_Category().
--  091224  Pwewlk   EAFH-1264, Removed the obsolete view TAX_CODE_LOV
--  100330  Nsillk   EAFH-2575, Added some validations in Copy method
--  100728  Umdolk   EANE-3003, Reverse engineering, Removed manual check for hold table in check_delete_.
--  100624  Gawilk   Bug 91364. Modified function Get.
--  101125  Elarse   Added a new view, STATUTORY_FEE_VAT_MULT, without restrictions for multiple tax.
--  110113  Elarse   DF-553, Added Get_Tax_Code_Info().
--  110503  Hiralk   EASTONE-16079, Added a new view STATUTORY_FEE_VAT_MULT_ZERO to restrict for non zero tax precentage VAT codes.
--  111018  Shdilk   SFI-135, Conditional compilation.
--  111104  Sacalk   SFI-618, Modified PROCEDURE Copy___
--  120627  THPELK   Bug 97225, Added Get_Tax_Code_Info() and Check_Fee_Code().
--  121123  Thpelk   Bug 106680 - Modified Conditional compilation to use single component package.
--  121130  SURBLK   Removed Genaral_SYS and Added pragma in to Check_Fee_Code().
--  121207  Maaylk   PEPA-183, Removed global variables
--  130515  Hawalk   Bug 108966, Checks whether a certain tax code is connected to an invoice in state 'Preliminary', before
--  130515           it is attempted to be deleted. Code changes inside Check_Delete___() and Validate_Modify___().
--  130612  JuKoDE   EDEL-2132, Added Check_Fee_Type_Not_Allowed()
--  130620  Dihelk   Bug 110672, Missing LOV tag was added for all views.
--  130807  Dihelk   Bug 111707, Missing LOV tag was added to the STATUTORY_FEE vie
--  140425  Lamalk   PBFI-6935, Modified 'Prepare_Insert___'. Added Decode method to fetch the correct value for TAX_REPORTING_CATEGORY column.
--  150318  Dipelk   KES-51, Added validation that checks deductible != 100 for 'RDE'(Surcharge VAT).
--  150422  Raablk   Bug 121320, Tax Code Created from Company Template should update correctly to basic data.
--  181823  Nudilk   Bug 143758, Corrected.
--  190522  Dakplk   Bug 147872, Modified Copy_To_Companies__.
--  191015  WaSalk   gelr: Added to support Global Extension Functionalities.
--  200210  NWeelk   GESPRING20-3571, Modified Prepare_Insert___ to set default values for TAX_TYPE_CATEGORY and TAX_FACTOR. 
--  200409  Hiralk   GESPRING20-3953, Modified Validate_Modify___ to check the validation for Diot_Tax_Classification, Tax_Factor and Tax_Type_Category.
--  200611  Kagalk   GESPRING20-4693, Modifications for it_xml_invoice functionality.
--  200723  PraWlk   GESPRING20-5190, Modified Check_Common___() and Import_Assign___() for tax_char_on_invoice functionality.
--  200729  Kabelk   GESPRING20-5230, Modifications for round_tax_customs_documents functionality.
--  201007  PraWlk   FISPRING20-7606, Modified Prepare_Insert___() to set default value for TAX_CHARACTER.
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------

-------------------- PRIVATE DECLARATIONS -----------------------------------

-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------

PROCEDURE Validate_Modify___ (
   newrec_ IN statutory_fee_tab%ROWTYPE,
   oldrec_ IN statutory_fee_tab%ROWTYPE )
IS
   result_             VARCHAR2(5);
   allow_update_tax_   company_tax_control_tab.update_tax_percent%TYPE := 'FALSE';
BEGIN
   allow_update_tax_ := Company_Tax_Control_API.Get_Update_Tax_Percent_Db(newrec_.company);
   IF (newrec_.fee_rate != oldrec_.fee_rate AND allow_update_tax_ = 'TRUE') THEN
      -- Tax percentage can be modified if the company parameter is checked along with the tax type 'TAX' or 'USE tax' and tax method 'invoice entry' or 'final posting'.  
      IF (newrec_.fee_type IN (Fee_Type_API.DB_CALCULATED_TAX, Fee_Type_API.DB_NO_TAX, Fee_Type_API.DB_TAX_WITHHOLD) OR newrec_.vat_received IN (Vat_Method_API.DB_PAYMENT, Vat_Method_API.DB_NO_TAX) OR newrec_.vat_disbursed IN (Vat_Method_API.DB_PAYMENT, Vat_Method_API.DB_NO_TAX)) THEN
         Error_SYS.Record_General(lu_name_, 'NOTMODIFYTAXRATE: You are not allowed to modify Tax % of Tax Code :P1 since it is of the type Calculated Tax, No Tax or Tax Withhold or its Tax Method is Payment or No Tax.', newrec_.fee_code);
      ELSE
         Client_SYS.Add_Warning(lu_name_, 'MODIFYTAXRATE: Tax Code :P1 might already be used in the application. Modifying tax % will require update of existing tax information in preliminary invoices/documents and prices on the basic data such as sales parts, supplier for purchase parts etc. It could also affect some tax reconciliation reports.', newrec_.fee_code);
         $IF Component_Invoic_SYS.INSTALLED $THEN
            IF (Ext_Inc_Inv_Default_Tax_API.Check_Tax_Code_Exist(newrec_.company, newrec_.fee_code) = 'TRUE') THEN
               Client_SYS.Add_Info(lu_name_, 'EXTTAXCODE: Tax Code :P1 is used in External Supplier Invoice Tax Codes. You have to set up correct Incoming Tax (%) manually.', newrec_.fee_code);
            END IF;
         $ELSE
            NULL;
         $END
      END IF;
   END IF;
   IF (newrec_.fee_type != oldrec_.fee_type) OR 
      (newrec_.fee_rate != oldrec_.fee_rate AND allow_update_tax_ = 'FALSE') OR 
      (newrec_.vat_received != oldrec_.vat_received) OR 
      (newrec_.vat_disbursed != oldrec_.vat_disbursed) OR 
      (newrec_.deductible != oldrec_.deductible) OR (newrec_.diot_tax_classification != oldrec_.diot_tax_classification) OR 
      (newrec_.tax_factor != oldrec_.tax_factor) OR (newrec_.tax_type_category != oldrec_.tax_type_category) THEN
      -- Check if tax code exists in invoice in state 'Preliminary' (i.e., no voucher yet).
      $IF Component_Invoic_SYS.INSTALLED $THEN
         result_ := Source_Tax_Item_Invoic_API.Check_Tax_Code_In_Prel_Invoice(newrec_.company, newrec_.fee_code);               
         IF (result_ = 'TRUE') THEN
            Error_SYS.Record_General(lu_name_, 'NOTMODIFYPRELINV: You are not allowed to modify Tax Code :P1 since it is used in an invoice in preliminary state.', newrec_.fee_code);
         END IF;
      $END
      -- Check if tax code exist in Hold Table
      Voucher_Row_API.Tax_Code_In_Voucher_Row(result_, newrec_.company, newrec_.fee_code);
      IF (result_ = 'TRUE') THEN
         Error_Sys.Record_General(lu_name_,'NOTMODIFY: You are not allowed to modify Tax Code :P1 since it is used in the hold table.', newrec_.fee_code);
      END IF;
      -- Check if tax code exist in General Ledger
      $IF Component_Genled_SYS.INSTALLED $THEN
         Gen_Led_Voucher_Row_API.Tax_Code_In_Gl_Voucher_Row(newrec_.company, newrec_.fee_code);
      $END
   END IF;
END Validate_Modify___;


@Override
PROCEDURE Import_Assign___ (
   newrec_      IN OUT statutory_fee_tab%ROWTYPE,
   crecomp_rec_ IN     Enterp_Comp_Connect_V170_API.Crecomp_Lu_Public_Rec,
   pub_rec_     IN     Create_Company_Template_Pub%ROWTYPE )
IS
BEGIN
   super(newrec_, crecomp_rec_, pub_rec_);
   newrec_.valid_from := crecomp_rec_.valid_from;
END Import_Assign___;

   
@Override
PROCEDURE Prepare_Insert___ (
   attr_ IN OUT VARCHAR2 )
IS
   valid_until_      accrul_attribute_tab.attribute_value%TYPE;
   -- gelr:mx_xml_doc_reporting, begin
   company_          VARCHAR2(20):= Client_SYS.Get_Item_Value('COMPANY', attr_ );
   -- gelr:mx_xml_doc_reporting, end
BEGIN
   super(attr_);
   valid_until_ := Accrul_Attribute_API.Get_Attribute_Value('DEFAULT_VALID_TO');
   Client_SYS.Add_To_Attr('VALID_UNTIL', to_date(valid_until_, 'YYYYMMDD'), attr_);   
   Client_SYS.Add_To_Attr('VALID_FROM', SYSDATE, attr_);
   Client_SYS.Add_To_Attr('VAT_RECEIVED', Vat_Method_API.Decode(1), attr_);
   Client_SYS.Add_To_Attr('VAT_DISBURSED', Vat_Method_API.Decode(1), attr_);
   Client_SYS.Add_To_Attr('USE_WITHHOLD_AMOUNT_TABLE', 'FALSE', attr_);
   Client_SYS.Add_To_Attr('TAX_AMOUNT_AT_INV_PRINT', Tax_Amount_At_Inv_Print_API.Decode('SEPARATE'), attr_);
   Client_SYS.Add_To_Attr('TAX_REPORTING_CATEGORY', Tax_Reporting_Category_API.Decode('NONE'), attr_);
   -- gelr: extend_tax_code_and_tax_struct, begin
   IF (Company_Localization_Info_API.Get_Parameter_Value_Db(company_, 'MX_XML_DOC_REPORTING') = Fnd_Boolean_API.DB_TRUE) THEN
      -- gelr:mx_xml_doc_reporting, begin
      Client_SYS.Add_To_Attr('TAX_TYPE_CATEGORY', Tax_Type_Category_API.Decode('ISR'), attr_);
      Client_SYS.Add_To_Attr('TAX_FACTOR', Tax_Factor_API.Decode('TASA'), attr_);
      -- gelr:mx_xml_doc_reporting, end
   ELSE
      Client_SYS.Add_To_Attr('TAX_TYPE_CATEGORY', Tax_Type_Category_API.Decode('NONE'), attr_);
      Client_SYS.Add_To_Attr('TAX_FACTOR', Tax_Factor_API.Decode('NONE'), attr_);
   END IF;
   Client_SYS.Add_To_Attr('TAX_IN_TAX_BASE', 'FALSE', attr_);
   -- gelr: extend_tax_code_and_tax_struct, end
   -- gelr:es_sii_reporting, begin
   Client_SYS.Add_To_Attr('EXCLUDE_FROM_SII_REPORTING', 'FALSE', attr_);
   -- gelr:es_sii_reporting, end
   -- gelr:diot_report_data, begin
   Client_SYS.Add_To_Attr('DIOT_TAX_CLASSIFICATION', Diot_Tax_Classification_API.Decode('NONE'), attr_);
   -- gelr:diot_report_data, end
   -- gelr:it_xml_invoice, begin
   Client_SYS.Add_To_Attr('STAMP_DUTY', 'FALSE', attr_);
   -- gelr:it_xml_invoice, end
   -- gelr:round_tax_customs_documents
   Client_SYS.Add_To_Attr('ROUND_ZERO_DECIMAL', 'FALSE', attr_);
   -- gelr:round_tax_customs_documents
   -- gelr:tax_char_on_invoice, begin
   Client_SYS.Add_To_Attr('TAX_CHARACTER', Tax_Character_API.Decode('NORMAL'), attr_);
   -- gelr:tax_char_on_invoice, end
END Prepare_Insert___;


@Override
PROCEDURE Insert___ (
   objid_      OUT    VARCHAR2,
   objversion_ OUT    VARCHAR2,
   newrec_     IN OUT statutory_fee_tab%ROWTYPE,
   attr_       IN OUT VARCHAR2 )
IS
BEGIN
   super(objid_, objversion_, newrec_, attr_);
   Tax_Book_API.New_Fee_Code(newrec_.company, newrec_.fee_code);
END Insert___;


@Override
PROCEDURE Update___ (
   objid_      IN     VARCHAR2,
   oldrec_     IN     statutory_fee_tab%ROWTYPE,
   newrec_     IN OUT NOCOPY statutory_fee_tab%ROWTYPE,
   attr_       IN OUT NOCOPY VARCHAR2,
   objversion_ IN OUT NOCOPY VARCHAR2,
   by_keys_    IN     BOOLEAN DEFAULT FALSE )
IS
BEGIN
   super(objid_, oldrec_, newrec_, attr_, objversion_, by_keys_);
   IF (newrec_.deductible != oldrec_.deductible) THEN
      $IF Component_Trvexp_SYS.INSTALLED $THEN
         Expense_Code_Tax_Lines_API.Update_Recoverable(newrec_.company, newrec_.fee_code, newrec_.deductible);
      $ELSE
         NULL;
      $END
   END IF;
END Update___;
   

@Override
PROCEDURE Check_Delete___ (
   remrec_ IN statutory_fee_tab%ROWTYPE )
IS
   result_ VARCHAR2(100);
   key_    VARCHAR2(2000);
BEGIN   
   IF (App_Context_Sys.Find_Value(lu_name_||'.copy_to_company_', 'FALSE') != 'TRUE') THEN
      IF (Company_Basic_Data_Window_API.Check_Copy_From_Company(remrec_.company, lu_name_)) THEN
         Error_SYS.Record_General(lu_name_, 'NODIRECTREMOVE: A record cannot be removed as :P1 window has been set up for copying data only from source company in Basic Data Synchronization window.', Basic_Data_Window_API.Get_Window(lu_name_));
      END IF;
   END IF;  
   
   IF (NOT remrec_.valid_from IS NULL) THEN      
      -- Check if tax code exists in invoice in state 'Preliminary' (i.e., no voucher yet).
      $IF Component_Invoic_SYS.INSTALLED $THEN
         result_ := Source_Tax_Item_Invoic_API.Check_Tax_Code_In_Prel_Invoice(remrec_.company, remrec_.fee_code);
         IF (result_ = 'TRUE') THEN
            Error_Sys.Record_General(lu_name_, 'NOTDELETEPRELINV: You are not allowed to delete Tax Code :P1 since it is used in an invoice in preliminary state.', remrec_.fee_code);
         END IF;
      $END
      -- Check if tax code exist in General Ledger
      $IF Component_Genled_SYS.INSTALLED $THEN
         Gen_Led_Voucher_Row_API.Tax_Code_In_Gl_Voucher_Row(remrec_.company, remrec_.fee_code);
      $END            
      key_ := remrec_.company || '^' || remrec_.fee_code || '^' || remrec_.valid_from || '^';
      Reference_SYS.Check_Restricted_Delete(lu_name_, key_);
   ELSE
      super(remrec_);  
   END IF; 
END Check_Delete___;


@Override
PROCEDURE Delete___ (
   objid_  IN VARCHAR2,
   remrec_ IN statutory_fee_tab%ROWTYPE )
IS
   key_  VARCHAR2(2000);
   info_ VARCHAR2(4000);
BEGIN   
   IF (NOT remrec_.valid_from IS NULL) THEN 
      key_ := remrec_.company || '^' || remrec_.fee_code || '^' || remrec_.valid_from || '^';
      Reference_SYS.Do_Cascade_Delete(lu_name_, key_);
      DELETE
         FROM  statutory_fee_tab
         WHERE rowid = objid_;      
   ELSE
      super(objid_,remrec_);
   END IF;   
   Tax_Liablty_Date_Exception_API.Remove_Exception_Tax_Codes(info_, remrec_.company, remrec_.fee_code);   
END Delete___;


@Override
PROCEDURE Check_Common___ (
   oldrec_ IN     statutory_fee_tab%ROWTYPE,
   newrec_ IN OUT statutory_fee_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
   currency_code_   VARCHAR2(20);
BEGIN
   IF (App_Context_SYS.Find_Value(lu_name_||'.copy_to_company_', 'FALSE') != 'TRUE') THEN
      IF (Company_Basic_Data_Window_API.Check_Copy_From_Company(newrec_.company, lu_name_)) THEN
         Error_SYS.Record_General(lu_name_, 'NODIRECTINSERT: A record cannot be entered/modified as :P1 window has been set up for copying data only from source company in Basic Data Synchronization window.', Basic_Data_Window_API.Get_Window(lu_name_));
      END IF;
   END IF;   
   IF (newrec_.use_withhold_amount_table IS NOT NULL AND newrec_.use_withhold_amount_table NOT IN ('TRUE', 'FALSE')) THEN
      newrec_.use_withhold_amount_table := Fnd_Boolean_API.Encode(newrec_.use_withhold_amount_table);
   END IF;
   super(oldrec_, newrec_, indrec_, attr_);
   IF (indrec_.fee_rate) THEN
      IF (newrec_.fee_rate < 0) THEN
         Error_SYS.Appl_General(lu_name_,'INVALIDFEERATE: Tax Percentage can not be less than 0%');
      END IF;
   END IF;
   IF (indrec_.deductible) THEN
      IF (newrec_.deductible < 0 OR newrec_.deductible > 100) THEN
         Error_SYS.Appl_General(lu_name_, 'DEDUCT: Deductible must be between 0% - 100%');
      END IF;
   END IF;   
   IF (newrec_.valid_from > newrec_.valid_until) THEN
      Error_SYS.Record_General(lu_name_, 'WRONGDATE: Valid until must be greater than valid from');
   END IF;
   IF (newrec_.vat_disbursed = Vat_Method_API.DB_FINAL_POSTING) THEN
      Error_SYS.Appl_General(lu_name_, 'NOTVATMETH: Tax Method :P1 is not allowed for Outgoing Invoices ', Vat_Method_API.Decode(newrec_.vat_disbursed));
   END IF;
   IF (newrec_.fee_type IN (Fee_Type_API.DB_TAX, Fee_Type_API.DB_CALCULATED_TAX, Fee_Type_API.DB_USE_TAX)) THEN
      IF (newrec_.vat_disbursed = Vat_Method_API.DB_NO_TAX OR newrec_.vat_received = Vat_Method_API.DB_NO_TAX) THEN
         Error_SYS.Appl_General(lu_name_, 'INV_METHOD: Tax Method must not be :P1 for Tax Type :P2', Vat_Method_API.Decode(Vat_Method_API.DB_NO_TAX), Fee_Type_API.Decode(newrec_.fee_type));
      END IF;
   END IF;
   IF (newrec_.fee_type IN (Fee_Type_API.DB_NO_TAX, Fee_Type_API.DB_TAX_WITHHOLD)) THEN
      IF (newrec_.tax_amt_limit IS NOT NULL ) THEN
         Error_SYS.Appl_General(lu_name_, 'INVALID_LIMIT: Not possible to use a Tax Amount Limit for tax code :P1 of tax type :P2', newrec_.fee_code, Fee_Type_API.Decode(newrec_.fee_type));
      END IF;
   END IF;
   IF (newrec_.fee_type IN (Fee_Type_API.DB_NO_TAX, Fee_Type_API.DB_USE_TAX)) THEN
      IF (newrec_.tax_reporting_category IN (Tax_Reporting_Category_API.DB_EU_SERVICES, Tax_Reporting_Category_API.DB_TRIPARTITE_EU_TRADE)) THEN
         Error_SYS.Appl_General(lu_name_, 'INVALID_CATEGORY: It is not allowed to set Tax Reporting Category to :P1 in combination with Tax Type :P2.', Tax_Reporting_Category_API.Decode(newrec_.tax_reporting_category), Fee_Type_API.Decode(newrec_.fee_type));
      END IF;
   END IF;   
   IF (newrec_.fee_type = Fee_Type_API.DB_USE_TAX) THEN
      IF (newrec_.vat_disbursed = Vat_Method_API.DB_PAYMENT OR newrec_.vat_received = Vat_Method_API.DB_PAYMENT) THEN
         Error_SYS.Appl_General(lu_name_, 'PAYMTONLYVATWITH: Tax Method :P1 is not valid for the selected Tax Type.', Vat_Method_API.Decode(Vat_Method_API.DB_PAYMENT));
      END IF;
      IF (newrec_.vat_received = Vat_Method_API.DB_FINAL_POSTING) THEN
         Error_SYS.Record_General(lu_name_, 'USETAXWITHFINAL: It is not allowed to use Use Tax with Tax Method Tax Received equals to Final Posting.');
      END IF;
   ELSIF (newrec_.fee_type = Fee_Type_API.DB_NO_TAX) THEN
      IF (newrec_.fee_rate != 0) THEN
         Error_SYS.Appl_General(lu_name_, 'INVALID_RATE: Percentage must be 0 for Tax Code with Tax Type :P1', Fee_Type_API.Decode(newrec_.fee_type));
      END IF;
      IF (newrec_.deductible != 100) THEN
         Error_SYS.Appl_General(lu_name_, 'INVALID_DEDUCT: The Deductible % must be 100 for a tax code with tax type :P1', Fee_Type_API.Decode(newrec_.fee_type));
      END IF;
      IF (newrec_.vat_disbursed != Vat_Method_API.DB_NO_TAX OR newrec_.vat_received != Vat_Method_API.DB_NO_TAX) THEN
         Error_SYS.Appl_General(lu_name_, 'INVALID_METHOD: Tax Method must be :P1 for Tax Code with Tax Type :P2', Vat_Method_API.Decode(Vat_Method_API.DB_NO_TAX), Fee_Type_API.Decode(newrec_.fee_type));
      END IF;
   ELSIF (newrec_.fee_type = Fee_Type_API.DB_TAX_WITHHOLD) THEN
      IF (newrec_.vat_received IN (Vat_Method_API.DB_FINAL_POSTING, Vat_Method_API.DB_NO_TAX) OR newrec_.vat_disbursed IN (Vat_Method_API.DB_NO_TAX)) THEN   
         Error_SYS.Appl_General(lu_name_, 'TAXWITHOLD: Only Tax Method :P1 or :P2 is valid for a Tax Code with Tax Type :P3', Vat_Method_API.Decode(Vat_Method_API.DB_INVOICE_ENTRY), Vat_Method_API.Decode(Vat_Method_API.DB_PAYMENT), Fee_Type_API.Decode(newrec_.fee_type));
      END IF;
   END IF;
   currency_code_ := Company_Finance_API.Get_Currency_Code(newrec_.company);
   newrec_.tax_amt_limit := Currency_Amount_API.Get_Rounded_Amount(newrec_.company, currency_code_, newrec_.tax_amt_limit);
   newrec_.amount_not_taxable := Currency_Amount_API.Get_Rounded_Amount(newrec_.company, currency_code_, newrec_.amount_not_taxable);
   newrec_.min_withheld_amount := Currency_Amount_API.Get_Rounded_Amount(newrec_.company, currency_code_, newrec_.min_withheld_amount);
   newrec_.minimum_base_amount := Currency_Amount_API.Get_Rounded_Amount(newrec_.company, currency_code_, newrec_.minimum_base_amount);
   -- gelr:diot_report_data, begin
   IF (Company_Localization_Info_API.Get_Parameter_Value_Db(newrec_.company, 'DIOT_REPORT_DATA') = Fnd_Boolean_API.DB_TRUE) THEN
      IF (newrec_.tax_type_category IN ('IEPS', 'ISR') AND newrec_.diot_tax_classification != 'NONE') THEN
         Error_SYS.Appl_General(lu_name_, 'DIOTTAX_TAXTYPE: The DIOT Tax Classification should be None when the Tax Type Category is set to ISR or IEPS.');
      END IF;
   END IF;
   -- gelr:diot_report_data, end
   -- gelr:it_xml_invoice, begin
   IF (Company_Localization_Info_API.Get_Parameter_Value_Db(newrec_.company, 'IT_XML_INVOICE') = Fnd_Boolean_API.DB_TRUE) THEN
      IF (newrec_.stamp_duty = 'TRUE' AND (newrec_.fee_type != 'TAX' OR newrec_.fee_rate != 0)) THEN
         Error_SYS.Record_General( lu_name_, 'STAMPDUTYNOTAVAIL: Stamp Duty is available only for TAX type Tax Codes with 0% tax.');
      END IF;
   END IF;
   -- gelr:it_xml_invoice, end
   -- gelr:tax_char_on_invoice, begin
   IF (Company_Localization_Info_API.Get_Parameter_Value_Db(newrec_.company, 'TAX_CHAR_ON_INVOICE') = Fnd_Boolean_API.DB_TRUE) THEN
      IF (newrec_.fee_rate != 0) THEN
         IF (newrec_.tax_character != 'NORMAL') THEN
            Error_SYS.Record_General(lu_name_, 'NOTNORMAL: For tax rate different from 0, only Normal Tax Character is allowed');
         END IF;
      END IF;
      IF (newrec_.fee_type = 'NOTAX') THEN
         IF (newrec_.tax_character != 'NOTAX') THEN
            Error_SYS.Record_General(lu_name_, 'NOTAXNOTAX: For No Tax tax type only No Tax Tax Character is allowed');
         END IF;
      END IF;
   END IF;
   -- gelr:tax_char_on_invoice, begin
   -- gelr:round_tax_customs_documents, begin
    IF (Company_Localization_Info_API.Get_Parameter_Value_Db(newrec_.company, 'ROUND_TAX_CUSTOMS_DOCUMENTS') = Fnd_Boolean_API.DB_TRUE) THEN
      IF ((newrec_.fee_type != 'CALCTAX' OR newrec_.vat_received NOT IN (1, 2) OR newrec_.deductible != 100) AND newrec_.round_zero_decimal != 'FALSE') THEN
         Error_SYS.Record_General( lu_name_, 'ROUNDZERODECNOTALLOW: Round to 0 Decimals check box is only allowed to select for tax codes of type Calculated Tax with Tax Method Tax Received set to Invoice Entry or Final Posting and with Deductible (%) set to 100.');
      END IF;
   END IF;
   -- gelr:round_tax_customs_documents, end
END Check_Common___;


@Override
PROCEDURE Check_Insert___ (
   newrec_ IN OUT statutory_fee_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS   
   fee_type_db_   VARCHAR2(20);
BEGIN
   newrec_.tax_reporting_category      := NVL(newrec_.tax_reporting_category, 'NONE');
   fee_type_db_ := newrec_.fee_type;
   newrec_.tax_amount_at_inv_print     := NVL(newrec_.tax_amount_at_inv_print, 'SEPARATE');
   newrec_.use_withhold_amount_table   := NVL(newrec_.use_withhold_amount_table, 'FALSE');
   -- gelr:it_xml_invoice, begin
   newrec_.stamp_duty                  := NVL(newrec_.stamp_duty, 'FALSE');
   -- gelr:it_xml_invoice, end
   -- gelr:round_tax_customs_documents, begin
   newrec_.round_zero_decimal          := NVL(newrec_.round_zero_decimal, 'FALSE');
   -- gelr:round_tax_customs_documents, end
   super(newrec_, indrec_, attr_);
   Client_SYS.Add_To_Attr('FEE_TYPE_DB', fee_type_db_, attr_);
END Check_Insert___;


@Override
PROCEDURE Check_Update___ (
   oldrec_ IN     statutory_fee_tab%ROWTYPE,
   newrec_ IN OUT statutory_fee_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
BEGIN
   super(oldrec_, newrec_, indrec_, attr_);
   IF (newrec_.use_withhold_amount_table = 'TRUE') THEN
      IF (newrec_.fee_rate != 0) THEN
         Error_SYS.Appl_General(lu_name_,'INVALID_RATE2: Percentage must be 0 for a Tax Code with parameter Use Withholding Amount Table checked');
      ELSIF (newrec_.deductible != 100) THEN
         Error_SYS.Appl_General(lu_name_,'INVALID_DEDUCT2: Deductible % must be 100 for a Tax Code with parameter Use Withholding Amount Table checked');
      ELSIF (newrec_.vat_received != Vat_Method_API.DB_PAYMENT) THEN
         Error_SYS.Appl_General(lu_name_,'INVALID_VATREC: Tax Method Tax Received must be :P1 for a Tax Code with parameter Use Withholding Amount Table checked',Vat_Method_API.Decode('3'));
      ELSIF (newrec_.vat_disbursed != Vat_Method_API.DB_PAYMENT) THEN
         Error_SYS.Appl_General(lu_name_,'INVALID_VATDIS: Tax Method Tax Disbursed must be :P1 for a Tax Code with parameter Use Withholding Amount Table checked',Vat_Method_API.Decode('3'));
      END IF;
   END IF;
   IF (newrec_.tax_reporting_category IS NULL) THEN
      newrec_.tax_reporting_category := 'NONE';
   END IF;
   Validate_Modify___(newrec_, oldrec_);
END Check_Update___;


@Override
PROCEDURE Raise_Record_Exist___ (
   rec_ IN statutory_fee_tab%ROWTYPE )
IS   
BEGIN
   Error_SYS.Record_General(lu_name_, 'TAXCODEALREADYEXIST: The tax code :P1 already exist in company :P2.', rec_.fee_code, rec_.company);
   super(rec_);   
END Raise_Record_Exist___;


@Override
PROCEDURE Raise_Record_Not_Exist___ (
   company_  IN VARCHAR2,
   fee_code_ IN VARCHAR2 )
IS
BEGIN
   Error_SYS.Record_General(lu_name_, 'MISSINVTIME: The tax code :P1 does not exist in company :P2 or has invalid time interval.', fee_code_, company_);
   super(company_, fee_code_);
END Raise_Record_Not_Exist___;


PROCEDURE Update_Tax_Code_Rec___ (
   tax_rec_                     IN OUT Public_Rec,
   consider_calctax_percentage_ IN     VARCHAR2,
   consider_deduct_percentage_  IN     VARCHAR2 )
IS
BEGIN
   IF (consider_calctax_percentage_ = 'FALSE' AND tax_rec_.fee_type = Fee_Type_API.DB_CALCULATED_TAX) THEN
      tax_rec_.fee_rate := 0;
   END IF;
   IF (consider_deduct_percentage_ = 'FALSE') THEN
      tax_rec_.deductible := 100;
   END IF; 
END Update_Tax_Code_Rec___;


PROCEDURE Copy_To_Companies_For_Svc___ (
   source_company_      IN  VARCHAR2,
   target_company_list_ IN  VARCHAR2,
   fee_code_list_       IN  VARCHAR2,
   update_method_list_  IN  VARCHAR2,
   log_id_              IN  NUMBER,
   attr_                IN  VARCHAR2 DEFAULT NULL )
IS
   ptr_                    NUMBER;
   ptr1_                   NUMBER;
   ptr2_                   NUMBER;
   i_                      NUMBER;
   update_method_          VARCHAR2(20);
   value_                  VARCHAR2(2000);
   target_company_         statutory_fee_tab.company%TYPE;
   TYPE statutory_fee IS TABLE OF statutory_fee_tab.fee_code%TYPE 
                           INDEX BY BINARY_INTEGER;
   TYPE attr IS TABLE OF VARCHAR2 (32000) 
                           INDEX BY BINARY_INTEGER;                        
   ref_statutory_fee_      statutory_fee;
   ref_attr_               attr;
   attr_value_             VARCHAR2(32000) := NULL;
BEGIN
   ptr_  := NULL;
   ptr1_ := NULL;
   ptr2_ := NULL;
   i_    := 0;
   WHILE Copy_To_Company_Util_API.Get_Next_Record_Sep_Val(value_, ptr_, fee_code_list_) LOOP
      ref_statutory_fee_(i_):= value_;
      i_ := i_ + 1;
   END LOOP;
   i_    := 0;
   ptr_  := NULL;
   WHILE Copy_To_Company_Util_API.Get_Next_Record_Sep_Val(value_, ptr_, attr_) LOOP
      ref_attr_(i_) := value_;
      i_ := i_ + 1;
   END LOOP;
   WHILE Copy_To_Company_Util_API.Get_Next_Record_Sep_Val(target_company_, ptr1_, target_company_list_) LOOP      
      IF (Copy_To_Company_Util_API.Get_Next_Record_Sep_Val(update_method_, ptr2_, update_method_list_)) THEN
         FOR j_ IN ref_statutory_fee_.FIRST..ref_statutory_fee_.LAST LOOP
            IF (ref_attr_.FIRST IS NOT NULL) THEN
               attr_value_ := ref_attr_(j_);
            END IF;            
            Copy_To_Companies__(source_company_, target_company_, ref_statutory_fee_(j_), update_method_, log_id_, attr_value_);
         END LOOP;
      END IF;
   END LOOP;
END Copy_To_Companies_For_Svc___;


-- gelr:es_sii_reporting, begin
PROCEDURE Check_Business_Trans_Type_Cust_Ref___ (
   newrec_ IN OUT statutory_fee_tab%ROWTYPE )
IS
BEGIN
  $IF Component_Erep_SYS.INSTALLED $THEN
     Sii_Business_Trans_Type_API.Exist(newrec_.company, newrec_.business_trans_type_cust, Party_Type_API.DECODE(Party_Type_API.DB_CUSTOMER));
  $ELSE
     NULL;
  $END
END Check_Business_Trans_Type_Cust_Ref___;


PROCEDURE Check_Business_Trans_Type_Sup_Ref___ (
   newrec_ IN OUT statutory_fee_tab%ROWTYPE )
IS
BEGIN
   $IF Component_Erep_SYS.INSTALLED $THEN
      Sii_Business_Trans_Type_API.Exist(newrec_.company, newrec_.business_trans_type_sup, Party_Type_API.DECODE(Party_Type_API.DB_SUPPLIER));
   $ELSE
      NULL;
   $END
END Check_Business_Trans_Type_Sup_Ref___;
-- gelr:es_sii_reporting, end
             
-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------

PROCEDURE Copy_To_Companies__ (
   source_company_      IN VARCHAR2,
   target_company_      IN VARCHAR2,
   fee_code_            IN VARCHAR2,
   update_method_       IN VARCHAR2,
   log_id_              IN NUMBER,
   attr_                IN VARCHAR2 DEFAULT NULL )
IS
   source_rec_              statutory_fee_tab%ROWTYPE;
   target_rec_              statutory_fee_tab%ROWTYPE;
   old_target_rec_          statutory_fee_tab%ROWTYPE;
   log_key_                 VARCHAR2(2000);
   log_detail_status_       VARCHAR2(10);
   old_target_info_         VARCHAR2(2000);
   old_target_objid_        VARCHAR2(20);
   old_target_objversion_   VARCHAR2(100);   
BEGIN
   source_rec_ := Get_Object_By_Keys___(source_company_, fee_code_);
   target_rec_ := source_rec_;
   target_rec_.company := target_company_;
   App_Context_SYS.Set_Value(lu_name_||'.copy_to_company_', 'TRUE');
   old_target_rec_ := Get_Object_By_Keys___(target_company_, fee_code_);
   log_key_ := fee_code_;
   IF (source_rec_.rowversion IS NOT NULL AND old_target_rec_.rowversion IS NULL) THEN
      -- Source creates a new record which does not exist in the target company
      New___(target_rec_);
      log_detail_status_ := 'CREATED';
   ELSIF (source_rec_.rowversion IS NOT NULL AND old_target_rec_.rowversion IS NOT NULL AND update_method_ = 'UPDATE_ALL') THEN
      -- Source company adds or modifies a record, the same exists in the target company and the user wants to update the entire record in the target
      target_rec_.rowkey := old_target_rec_.rowkey;
      Modify___(target_rec_);
      log_detail_status_ := 'MODIFIED';    
   ELSIF (source_rec_.rowversion IS NULL AND old_target_rec_.rowversion IS NOT NULL) THEN
      -- Source removes a record, the same record is removed in the target company
      Get_Id_Version_By_Keys___(old_target_objid_, old_target_objversion_, target_company_, fee_code_);
      Remove__(old_target_info_, old_target_objid_, old_target_objversion_,'DO');      
      log_detail_status_ := 'REMOVED';      
   ELSIF (source_rec_.rowversion IS NULL AND old_target_rec_.rowversion IS NULL) THEN
      -- Source removes a record, the same record does not exist in the target company to be removed
      Raise_Record_Not_Exist___(target_company_, fee_code_);
   ELSIF (source_rec_.rowversion IS NOT NULL AND old_target_rec_.rowversion IS NOT NULL AND update_method_ = 'NO_UPDATE') THEN
      -- Source company adds or modifies a record, the same exists in the target company and the user does not wan to update records in the target
      Raise_Record_Exist___(target_rec_);
   END IF;
   IF (Company_Basic_Data_Window_API.Check_Copy_From_Source_Company(target_company_,source_company_, lu_name_)) THEN
      IF log_detail_status_ IN ('CREATED','MODIFIED') THEN
         Error_SYS.Record_General(lu_name_, 'NODIRECTINSERT: A record cannot be entered/modified as :P1 window has been set up for copying data only from source company in Basic Data Synchronization window.', Basic_Data_Window_API.Get_Window(lu_name_));
      ELSIF log_detail_status_ = 'REMOVED' THEN
         Error_SYS.Record_General(lu_name_, 'NODIRECTREMOVE: A record cannot be removed as :P1 window has been set up for copying data only from source company in Basic Data Synchronization window.', Basic_Data_Window_API.Get_Window(lu_name_));
      END IF;
   END IF;
   Enterp_Comp_Connect_V170_API.Copy_Comp_To_Comp_Trans(source_company_,
                                                        target_rec_.company,
                                                        module_,
                                                        lu_name_,
                                                        lu_name_,
                                                        fee_code_,
                                                        fee_code_);
   App_Context_SYS.Set_Value(lu_name_||'.copy_to_company_', 'FALSE');
   Copy_Basic_Data_Log_Detail_API.Create_New_Record(log_id_, target_company_, log_key_, log_detail_status_);
EXCEPTION
   WHEN OTHERS THEN
      log_detail_status_ := 'ERROR';
      Copy_Basic_Data_Log_Detail_API.Create_New_Record(log_id_, target_company_, log_key_, log_detail_status_, SQLERRM);
END Copy_To_Companies__;
   
-------------------- LU SPECIFIC PROTECTED METHODS --------------------------

PROCEDURE Copy_To_Companies_ (
   attr_ IN  VARCHAR2 )
IS
   ptr_                 NUMBER;
   name_                VARCHAR2(200);
   value_               VARCHAR2(32000);
   company_             VARCHAR2(100);
   fee_code_list_       VARCHAR2(32000);
   target_company_list_ VARCHAR2(32000);
   update_method_list_  VARCHAR2(32000);
   copy_type_           VARCHAR2(100);
   attr1_               VARCHAR2(32000);
BEGIN
   ptr_ := NULL;
   WHILE (Client_SYS.Get_Next_From_Attr(attr_, ptr_, name_, value_)) LOOP
      IF (name_ = 'SOURCE_COMPANY') THEN
         company_ := value_;
      ELSIF (name_ = 'TARGET_COMPANY_LIST') THEN
         target_company_list_ := value_;
      ELSIF (name_ = 'FEE_CODE_LIST') THEN
         fee_code_list_ := value_;
      ELSIF (name_ = 'UPDATE_METHOD_LIST') THEN
         update_method_list_ := value_;
      ELSIF (name_ = 'COPY_TYPE') THEN
         copy_type_ := value_;
      ELSIF (name_ = 'ATTR') THEN
         attr1_ := value_||CHR(30)||SUBSTR(attr_, ptr_,LENGTH(attr_)-1);
      END IF;
   END LOOP;
   Copy_To_Companies_(company_, target_company_list_, fee_code_list_, update_method_list_, copy_type_, attr1_);
END Copy_To_Companies_;


PROCEDURE Copy_To_Companies_ (
   source_company_      IN VARCHAR2,
   target_company_list_ IN VARCHAR2,
   fee_code_list_       IN VARCHAR2,
   update_method_list_  IN VARCHAR2,
   copy_type_           IN VARCHAR2,             
   attr_                IN VARCHAR2 DEFAULT NULL )
IS
   ptr_                    NUMBER;
   ptr1_                   NUMBER;
   ptr2_                   NUMBER;
   i_                      NUMBER;
   update_method_          VARCHAR2(20);
   value_                  VARCHAR2(2000);
   target_company_         statutory_fee_tab.company%TYPE;
   TYPE statutory_fee IS TABLE OF statutory_fee_tab.fee_code%TYPE 
                           INDEX BY BINARY_INTEGER;
   TYPE attr IS TABLE OF VARCHAR2 (32000) 
                           INDEX BY BINARY_INTEGER;                        
   ref_statutory_fee_      statutory_fee;
   ref_attr_               attr;
   log_id_                 NUMBER;
   attr_value_             VARCHAR2(32000) := NULL;
BEGIN
   ptr_  := NULL;
   ptr1_ := NULL;
   ptr2_ := NULL;
   i_    := 0;
   WHILE Copy_To_Company_Util_API.Get_Next_Record_Sep_Val(value_, ptr_, fee_code_list_) LOOP
      ref_statutory_fee_(i_):= value_;
      i_ := i_ + 1;
   END LOOP;
   i_    := 0;
   ptr_  := NULL;
   WHILE Copy_To_Company_Util_API.Get_Next_Record_Sep_Val(value_, ptr_, attr_) LOOP
      ref_attr_(i_) := value_;
      i_ := i_ + 1;
   END LOOP;
   IF (target_company_list_ IS NOT NULL) THEN
      Copy_Basic_Data_Log_API.Create_New_Record(log_id_, source_company_, copy_type_,lu_name_);
   END IF;
   WHILE Copy_To_Company_Util_API.Get_Next_Record_Sep_Val(target_company_, ptr1_, target_company_list_) LOOP      
      IF (Copy_To_Company_Util_API.Get_Next_Record_Sep_Val(update_method_, ptr2_, update_method_list_)) THEN
         FOR j_ IN ref_statutory_fee_.FIRST..ref_statutory_fee_.LAST LOOP
            IF (ref_attr_.FIRST IS NOT NULL) THEN
               attr_value_ := ref_attr_(j_);
            END IF;            
            Copy_To_Companies__(source_company_, target_company_, ref_statutory_fee_(j_), update_method_, log_id_, attr_value_);
         END LOOP;
      END IF;
   END LOOP;
   IF (target_company_list_ IS NOT NULL) THEN
      Copy_Basic_Data_Log_API.Update_Status(log_id_);
   END IF;
END Copy_To_Companies_;

-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

@UncheckedAccess
FUNCTION Get_Description (
   company_    IN VARCHAR2,
   fee_code_   IN VARCHAR2,
   valid_from_ IN DATE ,
   lang_code_  IN VARCHAR2 ) RETURN VARCHAR2
IS
   rec_     statutory_fee_tab%ROWTYPE;
   dummy_   VARCHAR2(100);
BEGIN
   dummy_ := NVL(SUBSTR(Enterp_Comp_Connect_V170_API.Get_Company_Translation(company_, 'ACCRUL', 'StatutoryFee', fee_code_, lang_code_), 1, 100), dummy_);
   IF (dummy_ IS NULL) THEN
      rec_ := Get_Object_By_Keys___(company_, fee_code_);
      dummy_ := rec_.description;
   END IF;
   RETURN dummy_;
END Get_Description;


-- This method returns the tax percentage from the table (without date validation)
@UncheckedAccess
FUNCTION Get_Tax_Percentage (
   company_  IN VARCHAR2,
   tax_code_ IN VARCHAR2 ) RETURN NUMBER
IS
   tax_rec_      Public_Rec;
BEGIN
   tax_rec_ := Fetch_Validate_Tax_Code_Rec(company_, tax_code_, NULL, 'TRUE', 'TRUE', 'FETCH_ALWAYS');   
   RETURN tax_rec_.fee_rate;
END Get_Tax_Percentage;


-- This method returns the tax percentage as 0% for calcultaded tax in the same time as date validation (SYSDATE) is done
@UncheckedAccess
FUNCTION Get_Percentage (
   company_  IN VARCHAR2,
   tax_code_ IN VARCHAR2 ) RETURN NUMBER
IS
   tax_rec_      Public_Rec;
BEGIN
   tax_rec_ := Fetch_Validate_Tax_Code_Rec(company_, tax_code_, TRUNC(SYSDATE), 'FALSE', 'TRUE', 'FETCH_IF_VALID');   
   RETURN tax_rec_.fee_rate;
END Get_Percentage;


-- This method returns the tax percentage as 0% for calculated tax (without date validation)
@Override
@UncheckedAccess
FUNCTION Get_Fee_Rate (
   company_  IN VARCHAR2,
   tax_code_ IN VARCHAR2 ) RETURN NUMBER
IS
   percent_       NUMBER;
BEGIN
   percent_ := super(company_, tax_code_);
   IF (Get_Fee_Type_Db(company_, tax_code_) = Fee_Type_API.DB_CALCULATED_TAX) THEN
      RETURN 0;
   ELSE
      RETURN percent_;
   END IF;
END Get_Fee_Rate;


PROCEDURE Get_Control_Type_Value_Desc (
   description_   OUT VARCHAR2,
   company_       IN VARCHAR2,
   fee_code_      IN VARCHAR2,
   valid_from_    IN DATE DEFAULT NULL )
IS
BEGIN
   description_ := Get_Description(company_, fee_code_, valid_from_, NULL);
END Get_Control_Type_Value_Desc;


PROCEDURE Copy_To_Companies_For_Svc (
   attr_              IN  VARCHAR2,
   run_in_background_ IN  BOOLEAN,
   log_id_            IN  NUMBER DEFAULT NULL )
IS
   ptr_                    NUMBER;
   name_                   VARCHAR2(200);
   value_                  VARCHAR2(32000);
   source_company_         VARCHAR2(100);
   fee_code_list_          VARCHAR2(2000);
   target_company_list_    VARCHAR2(2000);
   update_method_list_     VARCHAR2(2000);
   attr1_                  VARCHAR2(32000);
   run_in_background_attr_ VARCHAR2(32000);
BEGIN
   IF (run_in_background_) THEN
      run_in_background_attr_ := attr_;
      Transaction_SYS.Deferred_Call('Statutory_Fee_API.Copy_To_Companies_', run_in_background_attr_, Language_SYS.Translate_Constant(lu_name_, 'COPYDATA: Copy Basic Data')); 
   ELSE
      ptr_ := NULL;
      WHILE (Client_SYS.Get_Next_From_Attr(attr_, ptr_, name_, value_)) LOOP
         IF (name_ = 'SOURCE_COMPANY') THEN
            source_company_ := value_;
         ELSIF (name_ = 'TARGET_COMPANY_LIST') THEN
            target_company_list_ := value_;
         ELSIF (name_ = 'FEE_CODE_LIST') THEN
            fee_code_list_ := value_;
         ELSIF (name_ = 'UPDATE_METHOD_LIST') THEN
            update_method_list_ := value_;
         ELSIF (name_ = 'ATTR') THEN
            attr1_ := value_||CHR(30)||SUBSTR(attr_, ptr_, LENGTH(attr_)-1);
         END IF;
      END LOOP;
      Copy_To_Companies_For_Svc___(source_company_, target_company_list_, fee_code_list_, update_method_list_, log_id_, attr1_);
   END IF;
END Copy_To_Companies_For_Svc;


PROCEDURE Check_Tax_Codes (
   newrec_ IN statutory_fee_tab%ROWTYPE,
   oldrec_ IN statutory_fee_tab%ROWTYPE )
IS
   result_             VARCHAR2(5);
   allow_update_tax_   company_tax_control_tab.update_tax_percent%TYPE := 'FALSE';
BEGIN
   -- Tax percentage can be modified if the company parameter is checked along with the tax type 'TAX' or 'USE tax' and tax method 'invoice entry' or 'final posting'.  
   IF (newrec_.fee_type IN (Fee_Type_API.DB_TAX, Fee_Type_API.DB_USE_TAX) AND newrec_.vat_received IN (Vat_Method_API.DB_INVOICE_ENTRY, Vat_Method_API.DB_FINAL_POSTING) AND newrec_.vat_disbursed = Vat_Method_API.DB_INVOICE_ENTRY) THEN
      allow_update_tax_ := Company_Tax_Control_API.Get_Update_Tax_Percent_Db(newrec_.company);
   END IF;
   IF (newrec_.fee_type != oldrec_.fee_type) OR 
      (newrec_.fee_rate != oldrec_.fee_rate AND allow_update_tax_ = 'FALSE') OR 
      (newrec_.vat_received != oldrec_.vat_received) OR 
      (newrec_.vat_disbursed != oldrec_.vat_disbursed) OR 
      (newrec_.deductible != oldrec_.deductible) THEN
      -- Check if tax code exists in invoice in state 'Preliminary' (i.e., no voucher yet).
      $IF Component_Invoic_SYS.INSTALLED $THEN
         result_ := Source_Tax_Item_Invoic_API.Check_Tax_Code_In_Prel_Invoice(newrec_.company, newrec_.fee_code);               
         IF (result_ = 'TRUE') THEN
            Error_SYS.Record_General(lu_name_, 'NOTMODIFYPRELINV: You are not allowed to modify Tax Code :P1 since it is used in an invoice in preliminary state.', newrec_.fee_code);
         END IF;
      $END
      -- Check if tax code exist in Hold Table
      Voucher_Row_API.Tax_Code_In_Voucher_Row(result_, newrec_.company, newrec_.fee_code);
      IF (result_ = 'TRUE') THEN
         Error_Sys.Record_General(lu_name_,'NOTMODIFY: You are not allowed to modify Tax Code :P1 since it is used in the hold table.', newrec_.fee_code);
      END IF;
      -- Check if tax code exist in General Ledger
      $IF Component_Genled_SYS.INSTALLED $THEN
         Gen_Led_Voucher_Row_API.Tax_Code_In_Gl_Voucher_Row(newrec_.company, newrec_.fee_code);
      $END
   END IF;
END Check_Tax_Codes;


FUNCTION Fetch_Validate_Tax_Code_Rec (
   company_                     IN VARCHAR2,
   tax_code_                    IN VARCHAR2,
   date_                        IN DATE,
   consider_calctax_percentage_ IN VARCHAR2,
   consider_deduct_percentage_  IN VARCHAR2,
   fetch_validate_action_       IN VARCHAR2 ) RETURN Public_Rec
IS
   tax_rec_                     Public_Rec;   
BEGIN
   tax_rec_ := Get(company_, tax_code_);
   IF (fetch_validate_action_ = 'FETCH_AND_VALIDATE') THEN
      IF (TRUNC(date_) BETWEEN tax_rec_.valid_from AND tax_rec_.valid_until) THEN
         Update_Tax_Code_Rec___(tax_rec_, consider_calctax_percentage_, consider_deduct_percentage_);              
         RETURN tax_rec_;
      ELSE
         Raise_Record_Not_Exist___(company_, tax_code_);
      END IF;     
   ELSIF (fetch_validate_action_ = 'FETCH_IF_VALID') THEN
      IF (TRUNC(date_) BETWEEN tax_rec_.valid_from AND tax_rec_.valid_until) THEN
         Update_Tax_Code_Rec___(tax_rec_, consider_calctax_percentage_, consider_deduct_percentage_);        
         RETURN tax_rec_;
      ELSE
         RETURN NULL;
      END IF;     
   ELSIF (fetch_validate_action_ = 'FETCH_ALWAYS') THEN
      Update_Tax_Code_Rec___(tax_rec_, consider_calctax_percentage_, consider_deduct_percentage_);          
      RETURN tax_rec_;
   ELSE
      RETURN NULL;
   END IF;    
END Fetch_Validate_Tax_Code_Rec;


@UncheckedAccess
PROCEDURE Fetch_Validate_Tax_Code_Info (
   tax_percentage_              OUT NUMBER,
   deductible_percentage_       OUT NUMBER,
   tax_type_db_                 OUT VARCHAR2,
   tax_type_                    OUT VARCHAR2,
   tax_received_db_             OUT VARCHAR2,
   tax_received_                OUT VARCHAR2,
   tax_disbursed_db_            OUT VARCHAR2,
   tax_disbursed_               OUT VARCHAR2,
   description_                 OUT VARCHAR2,
   valid_from_                  OUT DATE,
   valid_until_                 OUT DATE,
   company_                     IN  VARCHAR2,
   tax_code_                    IN  VARCHAR2,
   date_                        IN  DATE,
   consider_calctax_percentage_ IN  VARCHAR2,
   consider_deduct_percentage_  IN  VARCHAR2,
   fetch_validate_action_       IN  VARCHAR2 )
IS
   tax_rec_                      Public_Rec;
BEGIN
   tax_rec_               := Fetch_Validate_Tax_Code_Rec(company_, tax_code_, TRUNC(NVL(date_, SYSDATE)), consider_calctax_percentage_, consider_deduct_percentage_, fetch_validate_action_);
   tax_percentage_        := tax_rec_.fee_rate;
   tax_type_db_           := tax_rec_.fee_type;
   tax_type_              := Fee_Type_API.Decode(tax_type_db_);
   deductible_percentage_ := tax_rec_.deductible;
   tax_received_db_       := tax_rec_.vat_received; 
   tax_received_          := Vat_Method_API.Decode(tax_rec_.vat_received); 
   tax_disbursed_db_      := tax_rec_.vat_disbursed;
   tax_disbursed_         := Vat_Method_API.Decode(tax_rec_.vat_disbursed);
   description_           := tax_rec_.description;
   valid_from_            := tax_rec_.valid_from;
   valid_until_           := tax_rec_.valid_until;
END Fetch_Validate_Tax_Code_Info;


PROCEDURE Validate_Tax_Code (
   company_  IN  VARCHAR2,
   tax_code_ IN  VARCHAR2,
   date_     IN  DATE )
IS 
   tax_rec_    Public_Rec;
BEGIN
   tax_rec_ := Fetch_Validate_Tax_Code_Rec(company_, tax_code_, TRUNC(NVL(date_, SYSDATE)), 'TRUE', 'TRUE', 'FETCH_AND_VALIDATE');
END Validate_Tax_Code;


-- gelr:round_tax_customs_documents, begin
PROCEDURE Clear_Round_Zero_Decimal (
   company_  IN VARCHAR2 )
IS
   rec_     statutory_fee_tab%ROWTYPE;
   CURSOR get_lines_to_mod IS
      SELECT fee_code
      FROM   statutory_fee_tab
      WHERE  company = company_
      AND    round_zero_decimal = 'TRUE';
BEGIN
   FOR lines_ IN get_lines_to_mod LOOP
      rec_ := Get_Object_By_Keys___(company_, lines_.fee_code);
      rec_.round_zero_decimal := 'FALSE'; 
      Modify___(rec_);   
   END LOOP;
END Clear_Round_Zero_Decimal;
-- gelr:round_tax_customs_documents, end
