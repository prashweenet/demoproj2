-----------------------------------------------------------------------------
--
--  Logical unit: VoucherType
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  960410  xxxx     Base Table to Logical Unit Generator 1.0A
--  961223  MaGu     Corrected message serie to series in proc Unpack_Check_Update___
--  970116  YoHe     Added function Check_Automatic
--  970224  YoHe     Added function Get_Automatic_Allot base on MIJO request
--  970304  AnDj     Transferred bug-correction 97-0009 from 8.1.0a
--  970319  AnDj     Fixed Support 385 (added checks and cursors in unpack_check_update
--                   columns Voucher Group and Automatic Allot)
--  970327  AnDj     Support 385, using Check_Voucher and Gen_Led_Check_Voucher
--  970404  MiJo     Added function get_voucher_type_reference to support 7.3.1.
--  970701  SLKO     Conversion to Foundation 1.2.2d
--  970714  PICZ     Added column STORE_ORIGINAL
--  970922  PICZ     Added function Get_Store_Original_Db; correcetd comment for
--                   store original column
--  971006  ANDJ     Disabled insert/update of store_original if VoucherGroup
--                   is not 'C', 'M', 'K' or 'Q'.
--  980204  MALR     Update of Default Data, added procedure ModifyDefDataVoutype__.
--  980212  MALR     Changed procedure ModifyDefDataVoutype__, UserGroup is also a parameter.
--  980306  ARBI     Added voucher group 'Z' to insert/update of store_orginal
--  980916  ToKu     Bug # 4973 (added Exist__)
--                   Also added General_SYS.Init_Method
--  980921  Bren     Master Slave Connection.
--                   Added Send_Vou_Type_Info___, Send_Vou_Type_Info_Delete___,
--                   Send_Vou_Type_Info_Mofify___, Receive_Vou_Type_Info.
--  980929  PRASI    Renamed procedure ModifyDefDataVoutype__ to Modify_Def_Data_Voutype__.
--  990217  ANDJ     Bug # 9124 fixed.
--  990412  JPS      Performed template changes. Foundation 2.2.1
--  991119  MAMI     Moved the view VOUCHER_TYPE_VOUCHER_GROUP definition from API because of
--                   installation problems with COMPANY_FINANCE_AUTH.
--  991213  SaCh     Removed function Get_Voucher_Type_Reference.
--  991227  SaCh     Removed public procedure Exist which supported 7.3.1
--  000106  SaCh     Added public procedures Get_Voucher_Type_Reference  Exist.
--  000309  Uma      Closed dynamic cursors in Exceptions.
--  000321  Bren     Added Create_Voucher_Type,  Create_Voucher_Type_Batch AND Change_Attr_To_Batch.
--  000414  SaCh     Added RAISE to exceptions.
--  000503  Uma      Added view VOUCHER_TYPE_FA.
--  000522  Uma      Fixed Bug Id #40060. Added voucher group 'Z' in Is_Automatic_Allot_Required__.
--  000601  SaCh     Added fields Ledger_Id AND Use_Manual to Voucher_Type_Tab AND Voucher_Type_Def_Tab
--                   AND altered the procedures AND functions accordingly.
--  000721  Uma      A536 - Journal Code
--                   Added Check_Automatic_Allot__
--                   Added Update_Single_Function_Group, Is_Voucher_Type_Connected__
--                   Changed Create_Voucher_Type, Create_Voucher_Type_Batch, Change_Attr_In_Batch with respect to A536
--  000801  Kumudu   Added new public function as Get_Balance_Value.
--  000803  Uma      Added VIEW4. Added FUNCTION Get_Function_Group_Count.
--  000804  Uma      Changed Create_Voucher_Type,  Create_Voucher_Type_Batch & Change_Attr_To_Batch
--                   with respect to A536.
--  000809  Uma      Did Changes in Unpack_Check_Insert and Unpack_Check_Update.
--  000817  Uma      Added voucher_group in insert___ and update___.
--  000819  Uma      A536: Added ledger validation in unpack_check_update.
--  000824  Uma      Corrected Error message in PROCEDURE Voucher_Type_Exists.
--  000825  SaCh     Corrected Bug # 47694.
--  000825  SaCh     Created view voucher_type_int in order to correct bug # 47692.
--  000830  SaCh     Corrected Bug # 46892.
--  000907  Uma      Corrected Bug # 48194.
--  000909  Uma      Added Is_Voucher_Type_Used_Internal
--  000912  Uma      Added VIEW9.
--  000919  Camk     Call #48966 Corrected. Balance flag always checked when new internal voutype is created
--  000922  Uma      Corrected BugId #48838. Changes in Change_Attr_In_Batch.
--  001005  prtilk   BUG # 15677  Checked General_SYS.Init_Method
--  001219  OVJOSE   For new Create Company concept added public procedure Make Company and added implementation
--                   procedures Import___, Copy___, Export___.
--  010113  ToOs     Bug #19980, changed calls from User_Group_Period_API.Get_Period/Is_Period_Open
--                   to User_Group_Period_API.Get_And_Validate_Period
--  010221  ToOs     Bug # 20177 Added Global Lu constants for check for transaction_sys calls
--  010308  ToOs     Bug # 20512 PL code in where clause, rewrite of VIEW5, VIEW6, VIEW7, VIEW10
--  010510  JeGu     Bug #21705 Implementation New Dummyinterface
--                   Changed Insert__ RETURNING rowid INTO objid_
--  010531  Bmekse   Removed methods used by the old way for transfer basic data from
--                   master to slave (nowdays is Replication used instead)
--  010719  SUMALK   Bug 22932 Fixed.(Removed Dynamic Sql and added Execute Immediate).
--  010816  OVJOSE   Added Create Company translation method Create_Company_Translations___
--  010821  JeGu     Bug #23726 Changed function get_voucher_group.
--  010822  Suumlk   Bug #18601 Fixed. Added a new check before updating automatic allotment.
--  010824  JeGu     Bug #23726 Changed View Voucher_Type for compatibility 2000
--                   New version of Get_Voucher_Group
--                   Removed handling of unused column voucher_group
--  010905  Suumlk   Bug #18601 Corrected error message.
--  010925  ArJalk   Bug # 24764 Corrected
--  011004  Uma      Corrected Bug# 25040.
--  020102  THSRLK   IID 20001 Enhancement of Update Company. Changes inside make_company method
--                   Changed Import___, Export___ and Copy___ methods to use records
--  020207  ASODSE   Company translations Handling (MXL), Replaced "Text Field Translation"
--  020319  Uma      Corrected Bug# 27896. Changed the view in the cursor.
--  020320  Mnisse   Copy__ changed FOUND -> NOTFOUND
--  020620  Brwelk   Bug# 29799. Removed changes made by bug 27896.
--  021002  Nimalk   Removed usage of the view Company_Finance_Auth in viewes
--                   and replaced by view Company_Finance_Auth1 using EXISTS caluse instead of joins
--  021107  MACHLK   IIDBEFI102E - BDR for Currency Revaluation. Added view VOUCHER_TYPE_FOR_H.
--  030730  Nimalk   SP4 Merge
--  031231  ArJalk   FIPR300A1 Enhanced Batch Scheduling functionality.
--  040623  anpelk   FIPR338A2: Unicode Changes.
--  051007  MAWELK   FIAD377: Added a view called Voucher_Type_For_P
--  051031  THPELK   Call Id B128282 Modified Voucher_Type_For_P View.
--  051103  GADALK   Bud #48427 Merged. Change in VIEW12-VOU_TYPE_MULTI_FUNC_GROUP
--  051118  WAPELK   Merged the Bug 52783. Correct the user group variable's width.
--  060310  Prdilk   LCS Merge 53204, Added FUNCTION Get_Voucher_Groups
--  070222  NuFilkk  FIPL609B, Modified method
--  070227  Chhulk   FIPL633A, Added new method Is_Row_Group_Validated().
--  070507  Chhulk   B143458 Modified VOUCHER_TYPE_VOUCHER_GROUP
--  070608  Vohelk   FIPL609B Modified Insert___().
--  070702  Iswalk   B146535, modified Unpack_Check_Update___.
--  070719  Vohelk   B146836, Removed Insert_Voucher_Il_Postings statements
--  070727  Vohelk   B146836 - Added Is_Voucher_Type_Excluded.
--  071019  cldase   IID 75DEV-Fin12 (Bug 68473) - Added method Get_Control_Type_Value_Desc()
--  080327  cldase   Bug 72680, Removing duplicate closing of cursor
--  090605  THPELK   Bug 82609 - Added missing UNDEFINE statements for VIEW13, VIEW14, VIEW15.
--  090717  ErFelk   Bug 83174, Added constants STOREORG and AUTOVOUBAL by replacing AUTOALLOTNOTALLOWED
--  090717           in Unpack_Check_Insert___ and Import___.
--  091026  Gawilk   Bug 85745. Removed LOV flag from VOUCHER_TYPE_VOUCHER_GROUP view.
--  091026  Mawelk   Bug 86703, Fixed
--  091221  HimRlk   Reverse engineering correction, Removed method call to Voucher_Type_User_Group_API.Voucher_Type_Delete_Allowed.
--  091224  MalLlk   Added reference to the column ledger_id in the view VOUCHER_TYPE. 
--  -------------------SIZZLER-------------------------------------------------
--  110804  Ersruk   Added view VOUCHER_TYPE_FOR_PC.
--  100401  Jaralk   bug 89240 corrected. Modified methods is_voucher_type_used and is_voucher_type_used_internal
--                   in order to change ledger type correctly
--  110415  Sacalk   EASTONE-15173, Modified the view VOUCHER_TYPE 
--  111018  Shdilk   SFI-135, Conditional compilation.
--  111020  Swralk   SFI-143, Added conditional compilation for the places that had called package INTLED_CONNECTION_V101_API and INTLED_CONNECTION_V140_API.
--  111113  Swralk   SFI-739, Removed General_SYS.Init_Method statement from FUNCTION Is_Row_Group_Validated and Is_Reference_Mandatory.
--  120406  Najylk   EASTRTM-9308, Added new procedure Get_Default_Voucher_Types
--------------------------------------------------------------------------------
--  120618  Thpelk   Bug 102809, Corrcted in Unpack_Check_Update___().
--  120806  Maaylk   Bug 101320, Introduced the micro_cache
--  121123  Thpelk  Bug 106680 - Modified Conditional compilation to use single component package.
--  121210  Maaylk  PEPA-183, Removed global variables
--  131115  Umdolk  PBFI-2129, Refactoring
--  151008  chiblk  STRFI-200, New__ changed to New___ in Create_Voucher_Type
--  151118  Bhhilk  STRFI-39, Modified LablePrint enumeration to FinanceYesNo.
--  151222  Chwtlk  STRFI-831, Merge of Bug-126216, Modified Is_Voucher_Type_Used_Internal()
--  160325  Savmlk  STRFI-1594, Merged Bug 128254.
--  170922  Savmlk  STRFI-9981, Added the separate_user_approval parameter.
--  190107  Nudilk  Bug 146161, Corrected.
--  190516  Basblk  Bug 146186, Modified Get_Default_Voucher_Types(). Added a new parameter validate_ to control validation part in the function. 
-----------------------------------------------------------------------------
--  060618  Jadulk  FIUXX-2550, Added the functions,Is_Approval_Workflow_Allowed and Is_Sep_User_Apporval_Allowed
--  070618  Jadulk  FIUXX-2550, Added function Is_Voucher_Type_Exist
--  190618  Jadulk  FIUXX-2550, Added the procedures, Check_Voucher_Approval and Check_Voucher_Privilege
--  200618  Jadulk  FIUXX-2550, Added the functions, Reset_Row_Group_Validation, Is_Il_Exist and Check_Auto_Allotment.
--  250618  Jadulk  FIUXX-2550, Moved client validations to Check_Common___
--  260618  Jadulk  FIUXX-2550, Added the functions, Is_Single_Function_Group_Required and Is_Auto_Allotment_Required___.
--  280618  Jadulk  FIUXX-2550, Added the function, Get_Ledger_Selection
--  050718  Jadulk  FIUXX-2550, Added the function, Get_Voucher_Selection
--  080818  Jadulk  FIUXX-2550, Added the function, Is_Intled_Installed
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------

-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------

@Override
@SecurityCheck Company.UserAuthorized(company_)
PROCEDURE Update_Cache___ (
   company_ IN VARCHAR2,
   voucher_type_ IN VARCHAR2 )
IS   
BEGIN
   super(company_, voucher_type_);
END Update_Cache___;

PROCEDURE Check_Ledger_Id_Ref___ (
   newrec_ IN OUT voucher_type_tab%ROWTYPE )
IS
BEGIN
   -- Validate Ledger_Id
   IF ((newrec_.ledger_id IS NOT NULL) AND (newrec_.ledger_id NOT IN ('*', '00' ))) THEN
      Validate_Ledger_Id__(newrec_.company, newrec_.ledger_id);
   END IF;
END Check_Ledger_Id_Ref___;

@Override
PROCEDURE Prepare_Insert___ (
   attr_ IN OUT VARCHAR2 )
IS
BEGIN
   super(attr_);
   Client_SYS.Add_To_Attr( 'LABLE_PRINT', Finance_Yes_No_API.Decode('N'), attr_ );
END Prepare_Insert___;


@Override
PROCEDURE Insert___ (
   objid_      OUT    VARCHAR2,
   objversion_ OUT    VARCHAR2,
   newrec_     IN OUT VOUCHER_TYPE_TAB%ROWTYPE,
   attr_       IN OUT VARCHAR2 )
IS
BEGIN
   super(objid_, objversion_, newrec_, attr_);
   Invalidate_Cache___;
END Insert___;

@Override
PROCEDURE Check_Common___ (
   oldrec_ IN     voucher_type_tab%ROWTYPE,
   newrec_ IN OUT voucher_type_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
   fgroup_basic_data_txt_  VARCHAR2(200);
BEGIN
   fgroup_basic_data_txt_ := Function_Group_API.Get_Basic_Data_Info_Text;   
   super(oldrec_, newrec_, indrec_, attr_);   
   IF (indrec_.ledger_id) THEN 
      IF (newrec_.ledger_id != '00' AND newrec_.ledger_id != '*') THEN
         IF (Is_Il_Exist___(newrec_.company, newrec_.ledger_id)= false) THEN
            Error_SYS.Record_General(lu_name_, 'LEDGERIDNOTEXT: The Internal Ledger :P1 does not exist.', newrec_.ledger_id);
         END IF;
      END IF;       
   END IF;
   IF (indrec_.single_function_group) THEN                  
      IF (newrec_.single_function_group = 'Y' AND Get_Function_Group_Count(newrec_.company, newrec_.voucher_type) > 1) THEN
         Error_SYS.Record_General(lu_name_, 'SINGLEFUNCTIONNOTALLOWED: Single Function Group is not allowed when more than one Function Groups are connected to the Voucher Type.');
      END IF; 
   END IF;    
   IF (indrec_.ledger_id) THEN  
      indrec_.ledger_id := FALSE; 
   END IF;
   IF (indrec_.automatic_allot) THEN
      IF NOT( newrec_.automatic_allot = 'Y' OR newrec_.automatic_allot = 'N') THEN
         Error_SYS.Record_General(lu_name_,'AUTOALLOTNOTALLOWED: Automatic Allotment can be only "Y" or "N" ');
      END IF;
   END IF;
   IF (indrec_.store_original) THEN
      IF NOT( newrec_.store_original = 'Y' OR newrec_.store_original = 'N') THEN
         Error_SYS.Record_General(lu_name_,'STOREORG: Store Original can be only "Y" or "N" ');
      END IF;
   END IF;   
   IF (indrec_.automatic_vou_balance) THEN
      IF (newrec_.automatic_vou_balance IS NOT NULL) THEN
         IF NOT( newrec_.automatic_vou_balance = 'Y' OR newrec_.automatic_vou_balance = 'N') THEN
            Error_SYS.Record_General(lu_name_,'AUTOVOUBAL: Automatic Vou Balance can be only "Y" or "N" ');
         END IF;
      END IF;
   END IF;   
   IF ((indrec_.single_function_group)) THEN
      Finance_Yes_No_API.Exist_Db(newrec_.single_function_group);
   END IF;
    -- Validate Single_Function_Group
   Check_Single_Function_Group__(newrec_.company, newrec_.voucher_type, newrec_.single_function_group);
            
   -- Check Simulation Voucher Flag
   IF NOT (Check_Simulation_Vou_Ok__(newrec_.voucher_type, newrec_.simulation_voucher, newrec_.company)) THEN      
      Error_SYS.Record_General(lu_name_,'SIMUVOUNOTOK: Simulation Voucher cannot be checked for the Voucher Type using the selected Function Group(s). :P1',
                               fgroup_basic_data_txt_);
   END IF;     
END Check_Common___;

@Override
PROCEDURE Check_Insert___ (
   newrec_ IN OUT voucher_type_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
BEGIN
   IF (newrec_.description IS NULL) THEN
      newrec_.description := newrec_.voucher_type;
   END IF;
   IF (newrec_.use_approval_workflow IS NULL) THEN
      newrec_.use_approval_workflow := 'FALSE';
   END IF;
   IF (newrec_.separate_user_approval IS NULL) THEN
      newrec_.separate_user_approval := 'FALSE';
   END IF;
   super(newrec_, indrec_, attr_);
   IF (indrec_.automatic_allot) THEN
      IF (newrec_.automatic_allot = 'N' AND Is_Auto_Allotment_Required___(newrec_.company, newrec_.voucher_type) = TRUE) THEN
         Error_SYS.Record_General(lu_name_, 'AUTOALLOTREQ: Automatic Allotment is required.');
      END IF; 
   END IF;
   IF (indrec_.single_function_group) THEN                  
      IF (newrec_.single_function_group = 'N' AND Is_Single_Function_Group_Required___(newrec_.company, newrec_.voucher_type)) THEN
         Error_SYS.Record_General(lu_name_, 'SINGLEFUNCTIONREQ: Single Function Group is required.');
      END IF; 
   END IF;   
END Check_Insert___;

@Override
PROCEDURE Check_Update___ (
   oldrec_ IN     voucher_type_tab%ROWTYPE,
   newrec_ IN OUT voucher_type_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
   attr2_                  VARCHAR2(2000);
   is_used_                VARCHAR2(5);
   ledger_id_              VARCHAR2(10);
   found_                  BOOLEAN := FALSE;
   exist_                  NUMBER;
   il_project_accounting_  VARCHAR2(5);
   is_used_vou_            VARCHAR2(5);
   function_group_rec_     Function_Group_API.Public_Rec;   
   fgroup_basic_data_txt_  VARCHAR2(200) := Function_Group_API.Get_Basic_Data_Info_Text;   
   CURSOR get_function_group IS   
      SELECT function_group
      FROM Voucher_Type_Detail_Tab
      WHERE company    = newrec_.company
      AND voucher_type = newrec_.voucher_type;

   CURSOR check_exist IS
     SELECT 1
     FROM voucher_type_user_group_tab
     WHERE company    = newrec_.company
     AND voucher_type = newrec_.voucher_type
     AND default_type = 'Y';
BEGIN
   ledger_id_ := Get_Ledger_Id(newrec_.company, newrec_.voucher_type);
   IF (ledger_id_ NOT IN ( '*','00')) THEN
      Is_Voucher_Type_Used_Internal(is_used_, newrec_.company, newrec_.voucher_type, ledger_id_);
      IF (is_used_ = 'FALSE') THEN
         $IF Component_Intled_SYS.INSTALLED $THEN
            is_used_ := Internal_Voucher_API.Is_Voucher_Type_Used(newrec_.company,newrec_.voucher_type, ledger_id_);
         $ELSE
            NULL;
         $END
      END IF;
      IF (is_used_ = 'TRUE') THEN
         Error_SYS.Record_General(lu_name_,'UPNOTALOW: Voucher Type :P1 cannot be modified '||
                             'since there are vouchers for the Voucher Type.', newrec_.voucher_type);
      END IF;
   END IF;
   
   IF (indrec_.automatic_allot) THEN      
      Check_Automatic_Allot__ (newrec_.company, newrec_.voucher_type, newrec_.automatic_allot);
      Client_SYS.Clear_Attr(attr2_);
      Client_SYS.Add_To_Attr('COMPANY', newrec_.company, attr2_);
      Client_SYS.Add_To_Attr('VOUCHER_TYPE', newrec_.voucher_type, attr2_);
      Client_SYS.Add_To_Attr('ACTION', 'MODIFY', attr2_);
      IF (newrec_.automatic_allot <> 'N') THEN
         is_used_vou_ := Voucher_API.Is_Voucher_Type_Used(newrec_.company, newrec_.voucher_type);
         IF (is_used_vou_ = 'TRUE') THEN            
            Error_SYS.Record_General(lu_name_,'UPNOTALOW: Voucher Type :P1 cannot be modified '||
                             'since there are vouchers for the Voucher Type.', newrec_.voucher_type);
         END IF;
         $IF Component_Genled_SYS.INSTALLED $THEN
            is_used_vou_ := Gen_Led_Voucher_API.Is_Voucher_Type_Used (newrec_.company, newrec_.voucher_type);
            IF (is_used_vou_ = 'TRUE') THEN
               Error_SYS.Record_General(lu_name_,'UPNOTALOW: Voucher Type :P1 cannot be modified '||
                             'since there are vouchers for the Voucher Type.', newrec_.voucher_type);
            END IF;
         $END
      END IF;
   END IF;
   IF indrec_.ledger_id THEN   
      $IF Component_Intled_SYS.INSTALLED $THEN
         IF (oldrec_.ledger_id = '*' AND newrec_.ledger_id <> '*') THEN
            Internal_Ledger_Util_Pub_API.Delete_Voucher_Il_Postings(newrec_.company, newrec_.voucher_type);
         END IF;
      $END
      IF (newrec_.ledger_id <> '*' ) THEN
         Is_Voucher_Type_Used ( is_used_, newrec_.company, newrec_.voucher_type,newrec_.ledger_id);
         IF (is_used_ = 'TRUE') THEN
            Error_SYS.Record_General(lu_name_,'LEDNOTALL: Ledger cannot be changed '||
               'since there are vouchers for Voucher Type :P1.', newrec_.voucher_type);
         END IF;
      END IF;
   END IF;
   
   IF indrec_.use_approval_workflow THEN   
      IF (Voucher_API.Is_Voucher_Type_Used(newrec_.company, newrec_.voucher_type) = 'TRUE') THEN
         Error_SYS.Record_General(lu_name_,'APPROVALWORKFLOWNOTCHANGE: Use Voucher Approval Workflow check box cannot be modified '||
            'since there are vouchers in the hold table for Voucher Type :P1.', newrec_.voucher_type);
      END IF;
   END IF;      
   IF (indrec_.ledger_id) THEN   
      IF (Ledger_API.Get_Ledger_DB(newrec_.ledger_id) = '01') THEN
         Voucher_Type_Detail_API.Reset_Row_Group_Validation(newrec_.company, newrec_.voucher_type);
      END IF; 
   END IF;
   IF (indrec_.automatic_allot) THEN
      IF (newrec_.automatic_allot = 'N' AND Is_Auto_Allotment_Required___(newrec_.company, newrec_.voucher_type) = TRUE) THEN
         Error_SYS.Record_General(lu_name_, 'AUTOALLOTREQ: Automatic Allotment is required.');
      END IF;
      IF (newrec_.automatic_allot = 'N') THEN
         Client_SYS.Add_Warning(lu_name_, 'AUTOALLOTRESET: You will not be able to reset Automatic Allotment if the voucher type is already being used.');            
      END IF;
   END IF;
   IF (indrec_.single_function_group) THEN                  
      IF (newrec_.single_function_group = 'N' AND Is_Single_Function_Group_Required___(newrec_.company, newrec_.voucher_type)) THEN
         Error_SYS.Record_General(lu_name_, 'SINGLEFUNCTIONREQ: Single Function Group is required.');
      END IF; 
      IF (Is_Sep_User_Apporval_Allowed(newrec_.company, newrec_.voucher_type, newrec_.single_function_group) = 'TRUE') THEN
         IF (indrec_.separate_user_approval) THEN 
            Error_SYS.Record_General(lu_name_, 'SEPUSERAPPROVALERR: You are not allowed to modify Seperate User Approval for Voucher Type :P1.', newrec_.voucher_type);
         END IF;
         IF (newrec_.separate_user_approval = 'TRUE')THEN
            newrec_.separate_user_approval := 'FALSE';
         END IF;
      END IF;
   END IF;
   IF (indrec_.single_function_group OR indrec_.ledger_id) THEN
      IF (Is_Approval_Workflow_Allowed(newrec_.company, newrec_.voucher_type, newrec_.ledger_id, newrec_.single_function_group) = 'TRUE') THEN                     
         IF (indrec_.use_approval_workflow) THEN
            Error_SYS.Record_General(lu_name_, 'USEAPPROVALERR: You are not allowed to modify Use Approval Workflow for voucher type :P1.', newrec_.voucher_type);
         END IF;
         IF(newrec_.use_approval_workflow = 'TRUE')THEN
            newrec_.use_approval_workflow := 'FALSE';
         END IF;
      END IF; 
   END IF;   
   super(oldrec_, newrec_, indrec_, attr_);      
   IF (indrec_.simulation_voucher) THEN      
      IF (newrec_.simulation_voucher IS NOT NULL) THEN
         Is_Voucher_Type_Used(is_used_, newrec_.company, newrec_.voucher_type,newrec_.ledger_id);
         IF (is_used_ = 'TRUE') THEN
            Error_SYS.Record_General(lu_name_,'SIMUVOUUNCHECKED: Simulation Voucher can not be changed '||
                  'since there are vouchers for Voucher Type :P1.', newrec_.voucher_type);
         END IF;
      END IF;
   END IF;

   -- Validate Ledger
   IF ((newrec_.ledger_id IS NOT NULL) AND (newrec_.ledger_id NOT IN ('*', '00' ))) THEN
      FOR rec_ IN get_function_group LOOP
         function_group_rec_ := Function_Group_API.Get(rec_.function_group);
         IF (function_group_rec_.internal_ledger_allowed = 'FALSE') THEN   
            Error_SYS.Record_General(lu_name_,'INTNOTALLOW: Voucher Types connected to Function Group :P1 are not allowed in Internal Ledger. :P2.',
                                     rec_.function_group,
                                     fgroup_basic_data_txt_);                           
         END IF;
         IF (rec_.function_group = 'PPC') THEN
            $IF Component_Intled_SYS.INSTALLED $THEN
               il_project_accounting_ := Internal_Ledger_API.Get_Project_Accounting(newrec_.company, newrec_.ledger_id);
            $END
            IF (nvl(il_project_accounting_, 'FALSE') = 'FALSE') THEN
               Error_SYS.Record_General(lu_name_,'PCPROJACCOUNTING: Not allow to connect a :P1 function group voucher type to a non-project IL.', rec_.function_group);
            END IF;
         END IF;         
      END LOOP;
   END IF;

   IF (newrec_.automatic_allot = 'Y') THEN
      IF (Voucher_Type_Detail_API.Get_Function_Group(newrec_.company, newrec_.voucher_type) = 'J') THEN
         $IF Component_Invoic_SYS.INSTALLED $THEN
            IF Company_Invoice_Info_API.Is_Same_Voucher_No(newrec_.company) = 'TRUE' THEN
               Error_SYS.Record_General(lu_name_,'AUTOALL: It is not allowed to set automatic allotment for Function group J when same no. on prel. and final suppl. invoice voucher is checked.');
            END IF;
         $ELSE
            NULL;
         $END
      END IF;
   END IF;

   IF ((newrec_.ledger_id IS NOT NULL) AND (newrec_.ledger_id != '*')) THEN
      FOR rec_ IN get_function_group LOOP
         IF (rec_.function_group = 'A') THEN
            OPEN check_exist;
            FETCH check_exist INTO exist_;
            IF (check_exist%FOUND) THEN
               found_ := TRUE;
            END IF;
            CLOSE check_exist;
         END IF;
      END LOOP;
      IF found_ THEN
         Error_SYS.Record_General(lu_name_, 'FUNLEDDEFVOTYERR: The default voucher type for user group in function group A must be ''GL, affect IL''.');
      END IF;
   END IF;

   --Validate voucher types defined using function group PPC to have balance set TRUE
   IF (newrec_.balance = 'FALSE' AND Get_Voucher_Group(newrec_.company, newrec_.voucher_type) = 'PPC') THEN
      Error_SYS.Record_General(lu_name_,'VOUGRPPCBAL: Balance Mandatory check box should be seleted if voucher type is connected to function group "PPC". ');
   END IF;
END Check_Update___;

PROCEDURE Export___ (
   crecomp_rec_ IN Enterp_Comp_Connect_V170_API.Crecomp_Lu_Public_Rec )
IS
   pub_rec_ Enterp_Comp_Connect_V170_API.Tem_Public_Rec;
   i_       NUMBER := 1;
   CURSOR get_data IS
      SELECT *
      FROM  voucher_type_tab
      WHERE company = crecomp_rec_.company
      AND ledger_id IN ('*','00');
BEGIN
   FOR exprec_ IN get_data LOOP
      pub_rec_.template_id := crecomp_rec_.template_id;
      pub_rec_.component   := module_;
      pub_rec_.version     := crecomp_rec_.version;
      pub_rec_.lu          := lu_name_;
      pub_rec_.item_id     := i_;
      Export_Assign___(pub_rec_, crecomp_rec_, exprec_);
      Enterp_Comp_Connect_V170_API.Tem_Insert_Detail_Data(pub_rec_);
      i_ := i_ + 1;
   END LOOP;   
END Export___;


PROCEDURE Import___ (
   crecomp_rec_ IN Enterp_Comp_Connect_V170_API.Crecomp_Lu_Public_Rec )
IS
   attr_        VARCHAR2(2000);
   objid_       VARCHAR2(2000);
   objversion_  VARCHAR2(2000);
   newrec_      voucher_type_tab%ROWTYPE;
   empty_rec_   voucher_type_tab%ROWTYPE;
   indrec_      Indicator_Rec;
   msg_         VARCHAR2(2000);
   i_           NUMBER := 0;
   run_crecomp_ BOOLEAN := FALSE;
   CURSOR get_data IS
      SELECT *
      FROM  Create_Company_Template_Pub src
      WHERE component   = module_
      AND   lu          = lu_name_
      AND   template_id = crecomp_rec_.template_id
      AND   version     = crecomp_rec_.version
      AND NOT EXISTS (SELECT 1
                      FROM  voucher_type_tab
                      WHERE company = crecomp_rec_.company
                      AND   voucher_type = src.c1);
BEGIN
   run_crecomp_ := Check_If_Do_Create_Company___(crecomp_rec_);
   IF (run_crecomp_) THEN
      FOR pub_rec_ IN get_data LOOP
         i_ := i_ + 1;
         @ApproveTransactionStatement(2019-01-01,nudilk)
         SAVEPOINT make_company_insert;
         BEGIN
            newrec_ := empty_rec_;
            Import_Assign___(newrec_, crecomp_rec_, pub_rec_);
            Client_SYS.Clear_Attr(attr_);
            indrec_ := Get_Indicator_Rec___(newrec_);
            Check_Insert___(newrec_, indrec_, attr_);
            Insert___(objid_, objversion_, newrec_, attr_);
         EXCEPTION
            WHEN OTHERS THEN
               msg_ := SQLERRM;
               @ApproveTransactionStatement(2019-01-01,nudilk)
               ROLLBACK TO make_company_insert;
               Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'VOUCHER_TYPE_API', 'Error', msg_);
         END;
      END LOOP;
      IF ( i_ = 0 ) THEN
         msg_ := Language_SYS.Translate_Constant(lu_name_, 'NODATAFOUND: No Data Found');
         Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'VOUCHER_TYPE_API', 'CreatedSuccessfully', msg_);
      ELSE
         IF msg_ IS NULL THEN
            Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'VOUCHER_TYPE_API', 'CreatedSuccessfully');
         ELSE
            Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'VOUCHER_TYPE_API', 'CreatedWithErrors');
         END IF;
      END IF;
   END IF;
   -- this statement is to add to the log that the Create company process for LUs is finished if
   -- run_crecomp_ are FALSE
   IF (NOT run_crecomp_) THEN
      Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'VOUCHER_TYPE_API', 'CreatedSuccessfully');
   END IF;
   EXCEPTION
      WHEN OTHERS THEN
         msg_ := SQLERRM;
         Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'VOUCHER_TYPE_API', 'Error', msg_);
         Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'VOUCHER_TYPE_API', 'CreatedWithErrors');

END Import___;

FUNCTION Is_Il_Exist___ (
   company_   IN VARCHAR2,
   ledger_id_ IN VARCHAR2 )RETURN BOOLEAN
IS    
BEGIN
   $IF Component_Intled_SYS.INSTALLED $THEN
      IF (Internal_Ledger_API.Check_Il_Exist(company_, ledger_id_)) THEN
         RETURN TRUE;
      END IF;  
   $END  
   NULL;
END Is_Il_Exist___;


FUNCTION Is_Auto_Allotment_Required___(
   company_      IN VARCHAR2,
   voucher_type_ IN VARCHAR2 ) RETURN BOOLEAN
IS
   CURSOR voucher_type_detail IS
      SELECT automatic_allot
      FROM   voucher_type_detail_tab
      WHERE  company = company_
      AND    voucher_type = voucher_type_;
BEGIN
   FOR rec_ IN voucher_type_detail LOOP
      IF (rec_.automatic_allot = 'Y') THEN
         RETURN TRUE;
      END IF;
   END LOOP; 
   RETURN FALSE;
END Is_Auto_Allotment_Required___;  


FUNCTION Is_Single_Function_Group_Required___(
	company_               IN VARCHAR2,
   voucher_type_          IN VARCHAR2) RETURN BOOLEAN
IS 
   temp_single_function_group_  voucher_type_detail.single_function_group%TYPE;    
   function_group_count_        NUMBER;
   
   CURSOR get_voucher_type_detail IS
      SELECT single_function_group
      FROM   voucher_type_detail_tab
      WHERE  company = company_
      AND    voucher_type = voucher_type_
      FETCH FIRST 1 rows only;
BEGIN 
   OPEN get_voucher_type_detail;
   FETCH get_voucher_type_detail INTO temp_single_function_group_;
   CLOSE get_voucher_type_detail;
   function_group_count_ := Get_Function_Group_Count(company_, voucher_type_);
   IF (temp_single_function_group_ = 'Y' AND function_group_count_ = 1) THEN
      RETURN TRUE;
   END IF;   
   RETURN FALSE;
END Is_Single_Function_Group_Required___; 
   
PROCEDURE Copy___ (
   crecomp_rec_ IN Enterp_Comp_Connect_V170_API.Crecomp_Lu_Public_Rec )
IS
   attr_        VARCHAR2(2000);
   objid_       VARCHAR2(2000);
   objversion_  VARCHAR2(2000);
   newrec_      voucher_type_tab%ROWTYPE;
   empty_rec_   voucher_type_tab%ROWTYPE;
   indrec_      Indicator_Rec;
   msg_         VARCHAR2(2000);
   i_           NUMBER := 0;
   run_crecomp_ BOOLEAN := FALSE;
   CURSOR get_data IS
      SELECT *
      FROM  voucher_type_tab src
      WHERE company = crecomp_rec_.old_company
      AND ledger_id IN ('*','00')
      AND NOT EXISTS (SELECT 1
                      FROM  voucher_type_tab
                      WHERE company = crecomp_rec_.company
                      AND   voucher_type = src.voucher_type);
BEGIN
   run_crecomp_ := Check_If_Do_Create_Company___(crecomp_rec_);
   IF (run_crecomp_) THEN
      FOR oldrec_ IN get_data LOOP
         i_ := i_ + 1;
         @ApproveTransactionStatement(2019-01-01,nudilk)
         SAVEPOINT make_company_insert;
         BEGIN
            newrec_ := empty_rec_;
            Copy_Assign___(newrec_, crecomp_rec_, oldrec_);
            Client_SYS.Clear_Attr(attr_);
            indrec_ := Get_Indicator_Rec___(newrec_);
            Check_Insert___(newrec_, indrec_, attr_);
            Insert___(objid_, objversion_, newrec_, attr_);
         EXCEPTION
            WHEN OTHERS THEN
               msg_ := SQLERRM;
               @ApproveTransactionStatement(2019-01-01,nudilk)
               ROLLBACK TO make_company_insert;
               Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'VOUCHER_TYPE_API', 'Error', msg_);
         END;
      END LOOP;
      IF ( i_ = 0 ) THEN
         msg_ := Language_SYS.Translate_Constant(lu_name_, 'NODATAFOUND: No Data Found');
         Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'VOUCHER_TYPE_API', 'CreatedSuccessfully', msg_);
      ELSE
         IF msg_ IS NULL THEN
            Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'VOUCHER_TYPE_API', 'CreatedSuccessfully');
         ELSE
            Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'VOUCHER_TYPE_API', 'CreatedWithErrors');
         END IF;
      END IF;
   END IF;
   -- this statement is to add to the log that the Create company process for LUs is finished if
   -- run_crecomp_ are FALSE
   IF ( NOT run_crecomp_ ) THEN
      Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'VOUCHER_TYPE_API', 'CreatedSuccessfully');
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      msg_ := SQLERRM;
      Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'VOUCHER_TYPE_API', 'Error', msg_);
      Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'VOUCHER_TYPE_API', 'CreatedWithErrors');
END Copy___;
-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------

PROCEDURE Check_Delete_Record__ (
   exists_           OUT VARCHAR2,
   company_       IN     VARCHAR2,
   voucher_type_  IN     VARCHAR2 )
IS
   attr_          VARCHAR2(2000);
BEGIN
   Client_SYS.Clear_Attr(attr_);
   Client_SYS.Add_To_Attr('COMPANY', company_, attr_);
   Client_SYS.Add_To_Attr('VOUCHER_TYPE', voucher_type_, attr_);
END Check_Delete_Record__;


PROCEDURE Exist__ (
   company_      IN VARCHAR2,
   voucher_type_ IN VARCHAR2 )
IS
BEGIN
   IF (NOT Check_Exist___(company_, voucher_type_)) THEN
      Error_SYS.Record_Not_Exist(lu_name_);
   END IF;
END Exist__;


FUNCTION Check_Simulation_Vou_Ok__ (
   voucher_type_       IN VARCHAR2,
   simulation_voucher_ IN VARCHAR2,
   company_            IN VARCHAR2 ) RETURN BOOLEAN
IS
   CURSOR get_vou_functions IS
      SELECT function_group
      FROM  VOUCHER_TYPE_DETAIL_TAB
      WHERE company      = company_
      AND   voucher_type = voucher_type_;
   flag_               BOOLEAN;
   function_group_rec_ Function_Group_API.Public_Rec;
BEGIN
   flag_ := TRUE;
   IF (simulation_voucher_ = 'TRUE') THEN
      FOR rec_ IN get_vou_functions LOOP
         function_group_rec_ := Function_Group_API.Get(rec_.function_group);
         IF (function_group_rec_.simulation_voucher_allowed = 'FALSE') THEN   
            flag_ := FALSE;
            EXIT;            
         END IF;
      END LOOP;
   END IF;
   RETURN flag_;
END Check_Simulation_Vou_Ok__;


PROCEDURE Check_Single_Function_Group__ (
   company_ IN VARCHAR2,
   voucher_type_ IN VARCHAR2,
   single_function_ IN VARCHAR2 )
IS
   CURSOR get_count IS
      SELECT COUNT(*)
      FROM VOUCHER_TYPE_DETAIL_TAB
      WHERE company      = company_
      AND voucher_type   = voucher_type_;
   count_               NUMBER;
   function_group_      VARCHAR2(10);
   function_group_rec_  Function_Group_API.Public_Rec;
BEGIN
   OPEN get_count;
   FETCH get_count INTO count_;
   CLOSE get_count;
   IF (count_ > 1) THEN
      IF (single_function_ = 'Y') THEN
         Error_SYS.Record_General(lu_name_,'NOTSINGALLOW: Single Function Group cannot be checked since more than one Function Group is connected to Voucher Type :P1', voucher_type_);
      END IF;
   ELSE
      function_group_ := Voucher_Type_Detail_API.Get_Function_Group(company_, voucher_type_);
      function_group_rec_ := Function_Group_API.Get(function_group_);
      IF (function_group_rec_.single_function_required = 'TRUE') THEN      
         IF (single_function_ <> 'Y') THEN
            Error_SYS.Record_General(lu_name_,'SINGFUNCREQ: Single Function Group is required ');
         END IF;
      END IF;
   END IF;
END Check_Single_Function_Group__;


PROCEDURE Validate_Ledger_Id__ (
   company_ IN VARCHAR2,
   ledger_id_ IN VARCHAR2 )
IS
BEGIN
   $IF Component_Intled_SYS.INSTALLED $THEN
      Internal_Ledger_API.Exist(company_,
                                ledger_id_);
   $ELSE
      Error_SYS.Record_General(lu_name_, 'NOTALLOWED: Ledger Id :P1 is not allowed since Internal Ledger is not active.', ledger_id_);
   $END
END Validate_Ledger_Id__;


FUNCTION Is_Voucher_Type_Connected__ (
   company_      IN VARCHAR2,
   voucher_type_ IN VARCHAR2 ) RETURN VARCHAR2
IS
   vou_connected_   VARCHAR2(5);
BEGIN
   $IF Component_Payled_SYS.INSTALLED $THEN
      vou_connected_ := Cash_Account_API.Is_Voucher_Type_Connected(company_,voucher_type_);
   $END
   RETURN vou_connected_;
END Is_Voucher_Type_Connected__;


PROCEDURE Check_Automatic_Allot__ (
   company_         IN VARCHAR2,
   voucher_type_    IN VARCHAR2,
   automatic_allot_ IN VARCHAR2,
   function_group_  IN VARCHAR2 DEFAULT NULL )
IS
   CURSOR get_function_group IS
      SELECT function_group
      FROM Voucher_Type_Detail_Tab
      WHERE company    = company_
      AND voucher_type = voucher_type_;
   auto_allot_          VARCHAR2(1);
BEGIN
   IF (function_group_ IS NULL) THEN
      FOR rec_ IN get_function_group LOOP
         Voucher_Type_Detail_API.Is_Automatic_Allot_Required__(auto_allot_, rec_.function_group);
         IF (auto_allot_ = 'Y') THEN
            EXIT;
         END IF;
      END LOOP;
   ELSE
      Voucher_Type_Detail_API.Is_Automatic_Allot_Required__(auto_allot_, function_group_);
   END IF;
   IF (auto_allot_ <> automatic_allot_) AND (auto_allot_ = 'Y') THEN
      Error_SYS.Record_General(lu_name_, 'AUTOREQ: Automatic Allotment is required');
   END IF;
END Check_Automatic_Allot__;


-------------------- LU SPECIFIC PROTECTED METHODS --------------------------

PROCEDURE Check_Automatic_ (
   automatic_        OUT VARCHAR2,
   company_       IN     VARCHAR2,
   voucher_type_  IN     VARCHAR2 )
IS
   CURSOR check_automatic IS
      SELECT  automatic_allot
      FROM    voucher_type_tab
      WHERE   company      = company_
      AND     voucher_type =  voucher_type_;

BEGIN
   OPEN  check_automatic;
   FETCH check_automatic INTO automatic_;
   CLOSE check_automatic;
END Check_Automatic_;


@SecurityCheck Company.UserExist(newrec_.company)
PROCEDURE Check_Voucher_Approval_(
   newrec_ IN OUT voucher_type_tab%ROWTYPE)
IS
BEGIN
   IF (Ledger_API.Get_Ledger_DB(newrec_.ledger_id) = '01' OR newrec_.single_function_group != 'Y') THEN
      IF (Voucher_Type_API.Get_Use_Approval_Workflow(newrec_.company, newrec_.voucher_type) = 'TRUE') THEN            
         newrec_.use_approval_workflow := 'FALSE';
         Modify___ (newrec_ , TRUE);
      END IF;                  
   END IF; 
END Check_Voucher_Approval_;  


@SecurityCheck Company.UserExist(newrec_.company)
PROCEDURE Check_Voucher_Privilege_(
   newrec_ IN OUT voucher_type_tab%ROWTYPE)
IS
BEGIN
   IF (newrec_.single_function_group != 'Y') THEN 
      IF (Voucher_Type_API.Get_Separate_User_Approval_Db(newrec_.company, newrec_.voucher_type) = 'TRUE') THEN
         newrec_.separate_user_approval := 'FALSE';
         Modify___ (newrec_ , TRUE);
      END IF; 
   END IF; 
END Check_Voucher_Privilege_;


-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

@UncheckedAccess
FUNCTION Get_Voucher_Group (
   company_       IN VARCHAR2,
   voucher_type_  IN VARCHAR2 ) RETURN VARCHAR2
IS
   temp_ VOUCHER_TYPE_DETAIL_TAB.function_group%TYPE;
   CURSOR get_single_function IS
      SELECT single_function_group
      FROM   voucher_type_tab
      WHERE  company      = company_
      AND    voucher_type = voucher_type_;
   CURSOR get_function_group IS
      SELECT function_group
      FROM VOUCHER_TYPE_DETAIL_TAB
      WHERE company      = company_
      AND   voucher_type = voucher_type_;
   CURSOR check_exist IS
      SELECT 1
      FROM VOUCHER_TYPE_DETAIL_TAB
      WHERE company      = company_
      AND voucher_type   = voucher_type_
      AND function_group = 'M';
   single_function_      VARCHAR2(1);
   result_               NUMBER;
BEGIN
   OPEN  get_single_function;
   FETCH get_single_function INTO single_function_;
   CLOSE get_single_function;

   IF (single_function_ = 'Y') THEN
      OPEN get_function_group;
      FETCH get_function_group INTO temp_;
      CLOSE get_function_group;
   ELSE
      OPEN check_exist;
      FETCH check_exist INTO result_;
      CLOSE check_exist;
      IF (result_ = 1) THEN
         temp_ := 'M';
      END IF;
   END IF;
   RETURN temp_;
END Get_Voucher_Group;


@UncheckedAccess
FUNCTION Get_Voucher_Group (
   company_         IN VARCHAR2,
   voucher_type_    IN VARCHAR2,
   single_function_ IN VARCHAR2 ) RETURN VARCHAR2
IS
   temp_ VOUCHER_TYPE_DETAIL_TAB.function_group%TYPE;
   CURSOR get_function_group IS
      SELECT function_group
      FROM VOUCHER_TYPE_DETAIL_TAB
      WHERE company      = company_
      AND   voucher_type = voucher_type_;
   CURSOR check_exist IS
      SELECT 1
      FROM VOUCHER_TYPE_DETAIL_TAB
      WHERE company      = company_
      AND voucher_type   = voucher_type_
      AND function_group = 'M';
   result_               NUMBER;
BEGIN
   IF (single_function_ = 'Y') THEN
      OPEN get_function_group;
      FETCH get_function_group INTO temp_;
      CLOSE get_function_group;
   ELSE
      OPEN check_exist;
      FETCH check_exist INTO result_;
      CLOSE check_exist;
      IF (result_ = 1) THEN
         temp_ := 'M';
      END IF;
   END IF;
   RETURN temp_;
END Get_Voucher_Group;


@UncheckedAccess
FUNCTION Get_Voucher_Groups (
   company_       IN VARCHAR2,
   voucher_type_  IN VARCHAR2 ) RETURN VARCHAR2
IS
   ret_string_    VARCHAR2(50);
   CURSOR get_function_group IS
      SELECT function_group
      FROM   voucher_type_detail_tab
      WHERE  company        = company_
      AND    voucher_type   = voucher_type_;
BEGIN
   FOR rec_ IN get_function_group LOOP
      IF (ret_string_ IS NULL) THEN
         ret_string_ := rec_.function_group;
      ELSE
         ret_string_ := ret_string_||','||rec_.function_group;
      END IF;
   END LOOP;
   RETURN ret_string_;
END Get_Voucher_Groups;


@UncheckedAccess
@SecurityCheck Company.UserAuthorized(company_)
FUNCTION Get_Min_Voucher_Type (
   company_       IN VARCHAR2 ) RETURN VARCHAR2
IS
   voucher_type_  voucher_type_tab.voucher_type%TYPE;
   
   CURSOR get_rec IS       
      SELECT MIN(voucher_type)
      FROM   voucher_type_tab
      WHERE  company = company_;
      
BEGIN
   OPEN get_rec;
   FETCH get_rec INTO voucher_type_;
   CLOSE get_rec;
   RETURN voucher_type_;
END Get_Min_Voucher_Type;

@UncheckedAccess
@SecurityCheck Company.UserAuthorized(company_)
FUNCTION Get_Max_Voucher_Type (
   company_       IN VARCHAR2 ) RETURN VARCHAR2
IS
   voucher_type_  voucher_type_tab.voucher_type%TYPE;
   
   CURSOR get_rec IS       
      SELECT MAX(voucher_type)
      FROM   voucher_type_tab
      WHERE  company = company_;
      
BEGIN
   OPEN get_rec;
   FETCH get_rec INTO voucher_type_;
   CLOSE get_rec;
   RETURN voucher_type_;
END Get_Max_Voucher_Type;

@UncheckedAccess
@SecurityCheck Company.UserAuthorized(company_)
FUNCTION Get_Voucher_Type_Reference (
   company_       IN      VARCHAR2,
   voucher_type_  IN      VARCHAR2,
   year_          IN      NUMBER ) RETURN VARCHAR2
IS
   reference_   VARCHAR2(20);

  CURSOR get_voucher_type_reference is
     SELECT  function_group
     FROM    VOUCHER_TYPE_DETAIL_TAB
     WHERE   company      = company_
     AND     voucher_type =  voucher_type_;
BEGIN
   OPEN get_voucher_type_reference;
   FETCH get_voucher_type_reference INTO reference_;
   IF (get_voucher_type_reference%NOTFOUND) THEN      
      reference_ := NULL;
   END IF;
   CLOSE get_voucher_type_reference;
   RETURN reference_;
END Get_Voucher_Type_Reference;


@UncheckedAccess
FUNCTION Get_Pca_Voucher_Type (
   company_ IN VARCHAR2,
   ledger_id_ IN VARCHAR2 ) RETURN VARCHAR2
IS
   CURSOR get_vou_type IS
      SELECT v.voucher_type
      FROM Voucher_Type_Tab v, Voucher_Type_Detail_Tab vd
      WHERE v.company = company_
      AND v.voucher_type = vd.voucher_type
      AND vd.function_group = 'Z'
      AND v.ledger_id = ledger_id_;

   vou_type_ VARCHAR2(3);
BEGIN
   OPEN  get_vou_type ;
   FETCH get_vou_type INTO vou_type_;
   CLOSE get_vou_type;
   RETURN vou_type_;
END Get_Pca_Voucher_Type;


@UncheckedAccess
@SecurityCheck Company.UserAuthorized(company_)
FUNCTION Check_Automatic (
   company_       IN VARCHAR2,
   voucher_type_  IN VARCHAR2 ) RETURN VARCHAR2
IS
   automatic_        VARCHAR2(1);
   CURSOR check_automatic_ IS
      SELECT  automatic_allot
      FROM    VOUCHER_TYPE_TAB
      WHERE   company      = company_
      AND     voucher_type =  voucher_type_;
BEGIN
   OPEN  check_automatic_;
   FETCH check_automatic_ INTO automatic_;
   CLOSE check_automatic_;
   RETURN nvl(automatic_, 'N');
END Check_Automatic;


PROCEDURE Is_Voucher_Type_Used (
   is_used_       OUT VARCHAR2,
   company_       IN  VARCHAR2,
   voucher_type_  IN  VARCHAR2,
   new_ledger_id_ IN  VARCHAR2 DEFAULT NULL )
IS
   is_used1_          VARCHAR2(10);
BEGIN
   is_used_ := 'FALSE';

   IF NOT(new_ledger_id_ = '00' OR new_ledger_id_ IS NULL ) THEN
      $IF Component_Genled_SYS.INSTALLED $THEN
         is_used1_ := Voucher_API.Is_Voucher_Type_Used(company_, voucher_type_);
         IF (is_used1_ = 'FALSE') THEN
            is_used1_ := Gen_Led_Voucher_API.Is_Voucher_Type_Used(company_, voucher_type_);
         END IF;                                                             
      $ELSE
         NULL;
      $END
   END IF;
   
   IF (new_ledger_id_ = '00' OR new_ledger_id_ IS NULL) THEN
      $IF Component_Intled_SYS.INSTALLED $THEN
         Is_Voucher_Type_Used_Internal(is_used1_, company_, voucher_type_);         
         IF (is_used1_ = 'FALSE') THEN
            is_used1_ := Internal_Voucher_API.Is_Voucher_Type_Used(company_, voucher_type_);
         END IF;
      $ELSE
         NULL;
      $END
   END IF;

   IF (is_used1_ = 'TRUE') THEN
      is_used_ := 'TRUE';
   ELSE
      is_used_ := 'FALSE';
   END IF;
END Is_Voucher_Type_Used;


PROCEDURE Is_Voucher_Type_Used_Internal (
   is_used_       OUT VARCHAR2,
   company_       IN  VARCHAR2,
   voucher_type_  IN  VARCHAR2,
   ledger_id_     IN  VARCHAR2 DEFAULT NULL,  
   accounting_year_ IN  NUMBER DEFAULT NULL)
IS
BEGIN
   is_used_ := 'FALSE';
   $IF Component_Intled_SYS.INSTALLED $THEN
      is_used_ := Internal_Hold_Voucher_API.Is_Voucher_Type_Used ( company_,
                                                                   voucher_type_,
                                                                   ledger_id_,
                                                                   accounting_year_ );
   $END
END Is_Voucher_Type_Used_Internal;


@SecurityCheck Company.UserAuthorized(company_)
PROCEDURE Validate_Vou_Type_Vou_Grp (
   company_        IN VARCHAR2,
   voucher_type_   IN VARCHAR2,
   voucher_group_  IN VARCHAR2 )
IS
   dummy_          VARCHAR2(1);
   CURSOR check_voucher_type IS
      SELECT '*'
      FROM   VOUCHER_TYPE_DETAIL_TAB
      WHERE  company        = company_
      AND    voucher_type   = voucher_type_
      AND    function_group = voucher_group_;

BEGIN
   OPEN check_voucher_type;
   FETCH check_voucher_type INTO dummy_;
   IF (check_voucher_type%NOTFOUND) THEN
      CLOSE check_voucher_type;
      Error_SYS.Record_General(lu_name_,
                               'VOUTYPNOTCONN: Voucher Type :P1 does not belong to Function Group :P2',
                               voucher_type_ ,
                               voucher_group_);
   ELSE
      CLOSE check_voucher_type;
   END IF;
END Validate_Vou_Type_Vou_Grp;


PROCEDURE Get_Voucher_Types (
   voucher_types_         OUT VARCHAR2,
   default_voucher_type_  OUT VARCHAR2,
   company_               IN  VARCHAR2,
   voucher_date_          IN  DATE,
   user_group_            IN  VARCHAR2,
   voucher_group_         IN  VARCHAR2 )
IS
   user_name_             VARCHAR2(30);
   user_group_temp_       user_group_member_finance_tab.user_group%type;
   accounting_year_       NUMBER;
   accounting_period_     NUMBER;
   dummy_vou_type_        VARCHAR2(10);
   chk_exist_             NUMBER;

   CURSOR vou_types IS
      SELECT voucher_type
      FROM  VOUCHER_TYPE_USER_GROUP_TAB
      WHERE function_group     = voucher_group_
      AND   user_group         = user_group_temp_
      AND   accounting_year    = accounting_year_
      AND   company            = company_ ;
BEGIN
   voucher_types_   := CHR(31);
   user_name_       := User_Finance_API.User_Id;
   user_group_temp_ := user_group_;
   User_Group_Period_API.Get_And_Validate_Period( accounting_year_,
                                                  accounting_period_,
                                                  company_,
                                                  user_group_temp_,
                                                  voucher_date_ );

   FOR vou_ IN vou_types LOOP
     chk_exist_      := 0;
     dummy_vou_type_ := NULL;
     dummy_vou_type_ := CHR(31)||vou_.voucher_type||CHR(31);
     --  Select repeating voucher_types
     SELECT INSTR(voucher_types_, dummy_vou_type_, 1, 1)
     INTO chk_exist_
     FROM DUAL;

     IF (chk_exist_ = 0 ) THEN
        voucher_types_:= voucher_types_||vou_.voucher_type||CHR(31);
     END IF;
  END LOOP;

  user_group_temp_ := user_group_;
  Voucher_Type_User_Group_API.Get_Default_Voucher_Type( default_voucher_type_,
                                                        company_,
                                                        user_group_temp_,
                                                        accounting_year_,
                                                        voucher_group_);
END Get_Voucher_Types;


PROCEDURE Voucher_Type_Exists (
   company_ IN VARCHAR2,
   voucher_type_ IN VARCHAR2 )
IS
BEGIN
   IF Check_Exist___(company_, voucher_type_) THEN
      Error_SYS.Record_General(lu_name_,'VOUTYPEXIST: Voucher type :P1 exists in company :P2', voucher_type_, company_);
   END IF;
END Voucher_Type_Exists;


PROCEDURE Create_Voucher_Type (
   company_               IN VARCHAR2,
   voucher_type_          IN VARCHAR2,
   vou_type_desc_         IN VARCHAR2,
   automatic_allotment_   IN VARCHAR2,
   optional_auto_bal_     IN VARCHAR2,
   store_original_        IN VARCHAR2,
   default_               IN VARCHAR2,
   single_function_group_ IN VARCHAR2,
   simulation_voucher_    IN VARCHAR2,
   use_manual_            IN VARCHAR2,
   ledger_id_             IN VARCHAR2,
   balance_               IN VARCHAR2,
   use_approval_workflow_ IN VARCHAR2,
   seperate_vou_approval_ IN VARCHAR2)

IS
   newrec_              voucher_type_tab%ROWTYPE;
   lable_print_         VARCHAR2(3);
   automatic_           VARCHAR2(1);
   single_              VARCHAR2(1);
   manual_              VARCHAR2(5);
   bal_                 VARCHAR2(5);
   simulation_          VARCHAR2(5);
BEGIN
   lable_print_ := 'N';
   IF (automatic_allotment_ = '1') THEN
      automatic_ := 'Y';
   ELSIF (automatic_allotment_ = '0') THEN
      automatic_ := 'N';
   ELSE
      automatic_ := automatic_allotment_;
   END IF;
   IF (single_function_group_ = '1') THEN
      single_ := 'Y';
   ELSIF (single_function_group_ = '0') THEN
      single_ := 'N';
   ELSE
      single_ := single_function_group_;
   END IF;
   IF (use_manual_ = '1') THEN
      manual_ := 'TRUE';
   ELSIF (use_manual_ = '0') THEN
      manual_ := 'FALSE';
   ELSE
      manual_ := use_manual_;
   END IF;
   IF (simulation_voucher_ = '1') THEN
      simulation_ := 'TRUE';
   ELSIF (simulation_voucher_ = '0') THEN
      simulation_ := 'FALSE';
   ELSE
      simulation_ := simulation_voucher_;
   END IF;
   IF (balance_ = '1') THEN
      bal_ := 'TRUE';
   ELSIF (balance_ = '0') THEN
      bal_ := 'FALSE';
   ELSE
      bal_ := balance_;
   END IF;  
   
   newrec_.company               := company_;
   newrec_.voucher_type          := voucher_type_;
   newrec_.description           := vou_type_desc_;
   newrec_.lable_print           := lable_print_;
   newrec_.automatic_allot       := automatic_;
   newrec_.automatic_vou_balance := optional_auto_bal_;
   newrec_.store_original        := store_original_;
   newrec_.single_function_group := single_;
   newrec_.ledger_id             := ledger_id_;
   newrec_.use_manual            := manual_;
   newrec_.simulation_voucher    := simulation_;
   newrec_.balance               := bal_;
   newrec_.use_approval_workflow := use_approval_workflow_;
   newrec_.separate_user_approval:=seperate_vou_approval_;

   New___(newrec_);
END Create_Voucher_Type;


PROCEDURE Create_Voucher_Type_Batch (
   company_               IN VARCHAR2,
   voucher_type_          IN VARCHAR2,
   vou_type_desc_         IN VARCHAR2,
   automatic_allotment_   IN VARCHAR2,
   optional_auto_bal_     IN VARCHAR2,
   store_original_        IN VARCHAR2,
   default_               IN VARCHAR2,
   single_function_group_ IN VARCHAR2,
   simulation_voucher_    IN VARCHAR2,
   ledger_id_             IN VARCHAR2,
   use_manual_            IN VARCHAR2,
   balance_               IN VARCHAR2 )
IS
   attr_                VARCHAR2(2000);
   print_desc_          VARCHAR2(50);
BEGIN
   Client_SYS.Add_To_Attr('COMPANY', company_, attr_);
   Client_SYS.Add_To_Attr('VOUCHER_TYPE', voucher_type_, attr_);
   Client_SYS.Add_To_Attr('DESCRIPTION', vou_type_desc_, attr_);
   Client_SYS.Add_To_Attr('AUTOMATIC_ALLOT_DB', automatic_allotment_, attr_);
   Client_SYS.Add_To_Attr('AUTOMATIC_VOU_BALANCE_DB', optional_auto_bal_, attr_);
   Client_SYS.Add_To_Attr('STORE_ORIGINAL', store_original_, attr_);
   Client_SYS.Add_To_Attr('DEFAULT', default_, attr_);
   Client_SYS.Add_To_Attr('SINGLE_FUNCTION_GROUP', single_function_group_ , attr_);
   Client_SYS.Add_To_Attr('LEDGER_ID', ledger_id_, attr_);
   Client_SYS.Add_To_Attr('USE_MANUAL', use_manual_, attr_);
   Client_SYS.Add_To_Attr('SIMULATION_VOUCHER', simulation_voucher_, attr_);
   Client_SYS.Add_To_Attr('BALANCE', balance_, attr_);
   print_desc_ := Language_SYS.Translate_Constant(lu_name_,'CREVOUTYP: Create Voucher Type');
   Transaction_SYS.Deferred_Call('VOUCHER_TYPE_API.Change_Attr_In_Batch', attr_ ,print_desc_);
END Create_Voucher_Type_Batch;


PROCEDURE Change_Attr_In_Batch (
   attr_ IN VARCHAR2 )
IS
   company_             VARCHAR2(20);
   voucher_type_        VARCHAR2(20);
   vou_type_desc_       VARCHAR2(100);
   automatic_allotment_ VARCHAR2(3);
   optional_auto_bal_   VARCHAR2(3);
   store_original_      VARCHAR2(3);
   default_             VARCHAR2(3);
   ledger_id_           VARCHAR2(10);
   use_manual_          VARCHAR2(5);
   simulation_voucher_  VARCHAR2(5);
   single_function_group_ VARCHAR2(1);
   balance_             VARCHAR2(5);
   ptr_                 NUMBER ;
   name_                VARCHAR2(60);
   value_               VARCHAR2(2000);
BEGIN
   ptr_ := NULL;
   WHILE (Client_SYS.Get_Next_From_Attr(attr_, ptr_, name_, value_)) LOOP
      IF (name_ = 'COMPANY') THEN
         company_ := value_;
      ELSIF (name_ = 'VOUCHER_TYPE') THEN
         voucher_type_ := value_;
      ELSIF (name_ = 'DESCRIPTION') THEN
         vou_type_desc_ := value_;
      ELSIF (name_ = 'AUTOMATIC_ALLOT_DB') THEN
         automatic_allotment_ := value_;
      ELSIF (name_ = 'AUTOMATIC_VOU_BALANCE_DB') THEN
         optional_auto_bal_ := value_;
      ELSIF (name_ = 'STORE_ORIGINAL') THEN
         store_original_ := value_;
      ELSIF (name_ = 'DEFAULT') THEN
         default_ := value_;
      ELSIF (name_ = 'SINGLE_FUNCTION_GROUP') THEN
         single_function_group_ := value_;
      ELSIF (name_ = 'LEDGER_ID') THEN
         ledger_id_ := value_;
      ELSIF (name_ = 'USE_MANUAL') THEN
         use_manual_ := value_;
      ELSIF (name_ = 'SIMULATION_VOUCHER') THEN
         simulation_voucher_ := value_;
      ELSIF (name_ = 'BALANCE') THEN
         balance_ := value_;
      END IF;
   END LOOP;
   Create_Voucher_Type(company_, voucher_type_,
                       vou_type_desc_,
                       automatic_allotment_,
                       optional_auto_bal_,
                       store_original_,
                       default_,
                       single_function_group_,
                       simulation_voucher_,
                       use_manual_,
                       ledger_id_,
                       balance_,
                       'FALSE',
                       'FALSE');
END Change_Attr_In_Batch;


@SecurityCheck Company.UserExist(company_)
PROCEDURE Update_Single_Function_Group (
   company_               IN VARCHAR2,
   voucher_type_          IN VARCHAR2,
   single_function_group_ IN VARCHAR2 )
IS
BEGIN
   UPDATE VOUCHER_TYPE_TAB
      SET single_function_group = single_function_group_
      WHERE company    = company_
      AND voucher_type = voucher_type_;
END Update_Single_Function_Group;


@SecurityCheck Company.UserAuthorized(company_)
FUNCTION Validate_Vou_Type_Function_Grp (
   company_ IN VARCHAR2,
   voucher_type_ IN VARCHAR2,
   function_group_ IN VARCHAR2 ) RETURN VARCHAR2
IS
   CURSOR check_voucher_type IS
      SELECT '*'
      FROM   VOUCHER_TYPE_DETAIL_TAB
      WHERE  company        = company_
        AND  voucher_type   = voucher_type_
        AND  function_group = function_group_;
   dummy_                     VARCHAR2(1);
   found_                     VARCHAR2(5);
BEGIN
   OPEN  check_voucher_type;
   FETCH check_voucher_type INTO dummy_;
   IF (check_voucher_type%NOTFOUND) THEN      
      found_ := 'FALSE';
   ELSE      
      found_ := 'TRUE';
   END IF;
   CLOSE check_voucher_type;
   RETURN found_;
END Validate_Vou_Type_Function_Grp;


FUNCTION Get_Balance_Value (
   company_ IN VARCHAR2,
   voucher_type_ IN VARCHAR2,
   ledger_id_ IN VARCHAR2 ) RETURN VARCHAR2
IS
   CURSOR get_bal  IS
    SELECT balance
    FROM   VOUCHER_TYPE_TAB
    WHERE  company      = company_
    AND    voucher_type = voucher_type_
    AND    ledger_id    = ledger_id_;

    get_bal_             VARCHAR2(5);
BEGIN
   OPEN get_bal;
   FETCH get_bal INTO get_bal_ ;
   CLOSE get_bal;
   RETURN get_bal_ ;
END Get_Balance_Value;


FUNCTION Get_Function_Group_Count (
   company_ IN VARCHAR2,
   voucher_type_ IN VARCHAR2 ) RETURN NUMBER
IS
   CURSOR get_count IS
      SELECT count(*)
      FROM VOUCHER_TYPE_DETAIL_TAB
      WHERE company    = company_
      AND voucher_type = voucher_type_;
   count_       NUMBER;
BEGIN
   count_ := 0;
   OPEN get_count;
   FETCH get_count INTO count_;
   CLOSE get_count;
   RETURN count_;
END Get_Function_Group_Count;


PROCEDURE Validate_Vou_Type_All_Gen (
   company_      IN VARCHAR2,
   voucher_type_ IN VARCHAR2 )
IS
   dummy_         NUMBER;
   CURSOR voutype_exist IS
      SELECT 1
      FROM   VOUCHER_TYPE_GEN
      WHERE  company       = company_
      AND    voucher_type  = voucher_type_;
BEGIN
   OPEN  voutype_exist;
   FETCH voutype_exist INTO dummy_;
   IF (voutype_exist%NOTFOUND) THEN
      CLOSE voutype_exist;
      Error_SYS.Record_General(lu_name_, 'ALLGENNOTEXISTT: Voucher Type :P1 is only allowed for Internal Ledger', voucher_type_);
   END IF;
   CLOSE voutype_exist;
END Validate_Vou_Type_All_Gen;


FUNCTION Is_Vou_Type_All_Ledger (
   company_      IN VARCHAR2,
   voucher_type_ IN VARCHAR2 ) RETURN VARCHAR2
IS
   dummy_         NUMBER;
   CURSOR voutype_exist IS
      SELECT 1
      FROM   VOUCHER_TYPE_ALL_LEDGER
      WHERE  company       = company_
      AND    voucher_type  = voucher_type_;

BEGIN
   OPEN  voutype_exist;
   FETCH voutype_exist INTO dummy_;
   IF (voutype_exist%FOUND) THEN
      CLOSE voutype_exist;
      RETURN 'TRUE';
   END IF;
   CLOSE voutype_exist;
   RETURN 'FALSE';
END Is_Vou_Type_All_Ledger;


@UncheckedAccess
FUNCTION Is_Row_Group_Validated (
   company_      IN VARCHAR2,
   voucher_type_ IN VARCHAR2 ) RETURN VARCHAR2
IS
   dummy_        NUMBER;
   CURSOR get_vou_detail IS
      SELECT 1
      FROM voucher_type_detail_tab t
      WHERE t.company = company_
      AND t.voucher_type = voucher_type_
      AND t.row_group_validation = 'Y';
BEGIN
   OPEN  get_vou_detail;
   FETCH get_vou_detail INTO dummy_;
   IF (get_vou_detail%FOUND) THEN
      CLOSE get_vou_detail;
      RETURN 'Y';
   END IF;
   CLOSE get_vou_detail;
   RETURN 'N';
END Is_Row_Group_Validated;


@UncheckedAccess
FUNCTION Is_Reference_Mandatory (
   company_      IN VARCHAR2,
   voucher_type_ IN VARCHAR2 ) RETURN VARCHAR2
IS
   dummy_        NUMBER;

   CURSOR get_vou_detail IS
      SELECT 1
      FROM voucher_type_detail_tab t
      WHERE t.company = company_
      AND t.voucher_type = voucher_type_
      AND t.reference_mandatory = 'Y';

BEGIN
   OPEN  get_vou_detail;
   FETCH get_vou_detail INTO dummy_;
   IF (get_vou_detail%FOUND) THEN
      CLOSE get_vou_detail;
      RETURN 'Y';
   END IF;
   CLOSE get_vou_detail;
   RETURN 'N';
END Is_Reference_Mandatory;


@UncheckedAccess
FUNCTION Is_Voucher_Type_Excluded (
   company_ IN VARCHAR2,
   voucher_type_ IN VARCHAR2 ) RETURN VARCHAR2
IS
   out_  VARCHAR2(5) := 'FALSE';
BEGIN
   $IF Component_Intled_SYS.INSTALLED $THEN
      out_ := Gl_Voucher_Il_Posting_Api.Is_Voucher_Type_Excluded(company_, voucher_type_);
   $END
   RETURN out_;
END Is_Voucher_Type_Excluded;


PROCEDURE Exist_For_B (
   company_      IN VARCHAR2,
   user_group_   IN VARCHAR2,
   voucher_type_ IN VARCHAR2 )
IS
   dummy_ NUMBER;

   CURSOR check_exist IS
      SELECT 1
      FROM   voucher_type_tab v,
             voucher_type_user_group_tab u      
      WHERE  v.company = company_
      AND    u.company = company_
      AND    v.voucher_type = voucher_type_
      AND    u.voucher_type = voucher_type_
      AND    u.user_group = user_group_
      AND    v.ledger_id IN ('*', '00')
      AND    u.function_group = 'B';
BEGIN
   OPEN check_exist;
   FETCH check_exist INTO dummy_;
   IF (check_exist%NOTFOUND) THEN
      CLOSE check_exist;
      Error_SYS.Record_General(lu_name_, 'VOUTYPEBNOTEXT: Voucher Type :P1 is not connected with Funtion Group B and User Group :P2.',
                                         voucher_type_, user_group_);
   END IF;
   CLOSE check_exist;
END Exist_For_B;


PROCEDURE Exist_For_U (
   company_      IN VARCHAR2,
   user_group_   IN VARCHAR2,
   voucher_type_ IN VARCHAR2 )
IS
   dummy_ NUMBER;

   CURSOR check_exist IS
      SELECT 1
      FROM   voucher_type_tab v,
             voucher_type_user_group_tab u      
      WHERE  v.company = company_
      AND    u.company = company_
      AND    v.voucher_type = voucher_type_
      AND    u.voucher_type = voucher_type_
      AND    u.user_group = user_group_
      AND    v.ledger_id IN ('*', '00')
      AND    u.function_group = 'U';
BEGIN
   OPEN check_exist;
   FETCH check_exist INTO dummy_;
   IF (check_exist%NOTFOUND) THEN
      CLOSE check_exist;
      Error_SYS.Record_General(lu_name_, 'VOUTYPEUNOTEXT: Voucher Type :P1 is not connected with Funtion Group U and User Group :P2.',
                                         voucher_type_, user_group_);
   END IF;
   CLOSE check_exist;
END Exist_For_U;


PROCEDURE Get_Control_Type_Value_Desc (
   description_   OUT VARCHAR2,
   company_       IN VARCHAR2,
   voucher_type_  IN VARCHAR2 )
IS
BEGIN
   description_ := Get_Description( company_, voucher_type_ );
END Get_Control_Type_Value_Desc;

PROCEDURE Get_Default_Voucher_Types (
   default_voucher_type_  OUT VARCHAR2,
   company_               IN  VARCHAR2,
   voucher_date_          IN  DATE,
   user_group_            IN  VARCHAR2,
   voucher_group_         IN  VARCHAR2,
   validate_              IN  BOOLEAN DEFAULT TRUE)

IS
   user_group_temp_       user_group_member_finance_tab.user_group%type;
   accounting_year_       NUMBER;
   accounting_period_     NUMBER;
BEGIN
   user_group_temp_ := user_group_;
   IF (validate_) THEN
      User_Group_Period_Api.Get_And_Validate_Period( accounting_year_,
                                                     accounting_period_,
                                                     company_,
                                                     user_group_temp_,
                                                     voucher_date_ );
   ELSE
      User_Group_Period_API.Get_Period(accounting_year_, 
                                       accounting_period_, 
                                       company_, 
                                       user_group_, 
                                       voucher_date_);
   END IF;
   user_group_temp_ := user_group_;
   Voucher_Type_User_Group_API.Get_Default_Voucher_Type( default_voucher_type_,
                                                         company_,
                                                         user_group_temp_,
                                                         accounting_year_,
                                                         voucher_group_);
END Get_Default_Voucher_Types;

@Override
@SecurityCheckIfNotNull Company.UserAuthorized(company_)
FUNCTION Get_Automatic_Vou_Balance (
   company_         IN VARCHAR2,
   voucher_type_    IN VARCHAR2 ) RETURN VARCHAR2
IS
BEGIN
   RETURN super(company_,voucher_type_);
END Get_Automatic_Vou_Balance;

-- Exist
--   Checks if given pointer (e.g. primary key) to an instance of this
--   logical unit exists. If not an exception will be raised.
@UncheckedAccess
PROCEDURE Exist (
   company_      IN VARCHAR2,
   voucher_type_ IN VARCHAR2,
   year_         IN NUMBER )
IS
BEGIN
   Exist(voucher_type_, company_);
END Exist;


PROCEDURE Check_Access_Privilege(
   seperate_approval_db_   OUT VARCHAR2, 
   company_                IN VARCHAR2,
   voucher_type_           IN VARCHAR2 )
IS
   function_group_         voucher_type_detail_tab.function_group%TYPE;
   function_group_rec_     Function_Group_API.Public_Rec;      
BEGIN
   function_group_ := Voucher_Type_Detail_API.Get_Function_Group(company_,
                                                                 voucher_type_);                                         
   function_group_rec_ := Function_Group_API.Get(function_group_);
   
   IF (function_group_rec_.sep_user_approval_allowed = 'TRUE') THEN      
      seperate_approval_db_ := Get_Separate_User_Approval_Db(company_,
                                                             voucher_type_);
   ELSE
      seperate_approval_db_ := 'FALSE';
   END IF;
END Check_Access_Privilege;


FUNCTION Is_Approval_Workflow_Allowed(
   company_                IN VARCHAR2,
   voucher_type_           IN VARCHAR2,
   ledger_                 IN VARCHAR2,
   single_function_group_  IN VARCHAR2 ) RETURN VARCHAR2
IS
   function_group_   voucher_type_detail.function_group%TYPE;
   
   CURSOR get_voucher_type_detail IS
      SELECT function_group
      FROM   voucher_type_detail_tab
      WHERE  company = company_
      AND    voucher_type = voucher_type_
      FETCH FIRST 1 rows only;
BEGIN 
   IF (ledger_ != '01' AND single_function_group_ = 'Y') THEN
      OPEN get_voucher_type_detail;
      FETCH get_voucher_type_detail INTO function_group_;  
      IF (get_voucher_type_detail%NOTFOUND) THEN      
         function_group_ := NULL;
      END IF;
      CLOSE get_voucher_type_detail;

      IF (function_group_ IS NOT NULL AND Function_Group_API.Get_Sep_User_Approval_Allow_Db(function_group_) = 'TRUE') THEN               
         RETURN 'TRUE';
      END IF;           
   END IF;    
   RETURN 'FALSE';
END Is_Approval_Workflow_Allowed;  


FUNCTION Is_Sep_User_Apporval_Allowed (
   company_                IN VARCHAR2,
   voucher_type_           IN VARCHAR2,
   single_function_group_  IN VARCHAR2 ) RETURN VARCHAR2
IS
   function_group_   voucher_type_detail.function_group%TYPE;
   
   CURSOR get_voucher_type_detail IS
      SELECT function_group
      FROM   voucher_type_detail_tab
      WHERE  company = company_
      AND    voucher_type = voucher_type_
      FETCH FIRST 1 rows only;
BEGIN
   IF (single_function_group_ = 'Y') THEN 
      OPEN get_voucher_type_detail;
      FETCH get_voucher_type_detail INTO function_group_;
      IF (get_voucher_type_detail%NOTFOUND) THEN      
         function_group_ := NULL;
      END IF;
      CLOSE get_voucher_type_detail;
      IF (function_group_ IS NOT NULL AND Function_Group_API.Get_Sep_User_Approval_Allow_Db(function_group_) = 'TRUE') THEN               
         RETURN 'TRUE';
      END IF;          
   END IF;
   RETURN 'FALSE';
END Is_Sep_User_Apporval_Allowed;
