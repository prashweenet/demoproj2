-----------------------------------------------------------------------------
--
--  Logical unit: VoucherTypeDetail
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  060600  Uma     Created.
--  050800  Uma     Added VIEW2.
--  000819  Uma     A536: Bug Id# 46395/ 46414
--  001005  prtilk  BUG # 15677  Checked General_SYS.Init_Method
--  001130  OVJOSE  For new Create Company concept added new view voucher_type_detail_ect and voucher_type_detail_pct.
--                  Added procedures Make_Company, Copy___, Import___ and Export___.
--  010221  ToOs    Bug # 20177 Added Global Lu constants for check for transaction_sys calls
--  010510  JeGu    Bug #21705 Implementation New Dummyinterface
--                  Changed Insert__ RETURNING rowid INTO objid_
--  010719  SUMALK  Bug 22932 Fixed.(Removed Dynamic Sql and added Execute Immediate).
--  010820  OVJOSE  Added Create Company translation method Create_Company_Translations___
--  010823  GAWILK  Bug # 23834. Changed the error message and checked the function group
--                  in Unpack_Check_Update___.
--  010822  Suumlk   Bug #18601 Fixed. Added a new check before inserting function groups.
--  010905  Suumlk   Bug #18601 Corrected error message.
--  010926  Brwelk  Bug #24705. Added view 3.
--  020102  THSRLK   IID 20001 Enhancement of Update Company. Changes inside make_company method
--                   Changed Import___, Export___ and Copy___ methods to use records
--  020207  ASODSE  Company Translations (MXL) Replaced Text Field Translation
--  020320  Mnisse   Copy__ changed FOUND -> NOTFOUND
--  020510  rakolk  Bug# 29588. Added function group 'D' in Is_Automatic_Allot_Required__.
--  021002  Nimalk   Removed usage of the view Company_Finance_Auth in viewes
--                   and replaced by view Company_Finance_Auth1 using EXISTS caluse instead of joins
--  021030  KuPelk  IID ESFI110N Year End Accounting.Added new view as YEAR_END_VOUCHER_TYPE_LOV.
--  021128  KuPelk  Bug# 91598 Corrected by changing the view YEAR_END_VOUCHER_TYPE_LOV .
--  030730  Nimalk  SP4 Merge
--  030826  Nimalk  Bug 100510 Changed Validate_Record__
--  031231  ArJalk  FIPR300A1 Enhanced Batch Scheduling functionality.
--  040623  anpelk   FIPR338A2: Unicode Changes.
--  050422  reanpl  FIME232, merged UK changes (Added Function Group AFP)
--  070222  Chhulk  FIPL633A, Added row_group_validation to VOUCHER_TYPE_DETAIL & VOUCHER_TYPE_DETAIL_QUERY, Changed Validate_Record__().
--  070329  GaDalk  B141933 FIPL633A Change of error message text
--  070417  Chhulk  B142136, Added reference_mandatory to VOUCHER_TYPE_DETAIL & VOUCHER_TYPE_DETAIL_QUERY.
--  070515  Surmlk  Added ifs_assert_safe comment
--  070517  Maaylk  Added method Vou_With_Row_Group_Id_Exists__
--  090717  ErFelk  Bug 83174, Replaced constant SIMVOUNOTOK with SIMUVOUNOTOK in Create_Voucher_Type_Detail_.
--  090824  AjPelk  Bug 83598, corrected.
--  091104  Jaralk  Bug 86478, corrected.check if the function group  has a User Group connected to Voucher Series in Check_Delete___()
--  110523  RUFELK  EASTONE-20636 - Modified Is_Automatic_Allot_Required__() to make Allotment mandatory for Function Group TI. 
--  111018  Shdilk   SFI-135, Conditional compilation.
---------------------SIZZLER-------------------------------------------------
--  110804  Ersruk  Added function group PC in Is_Automatic_Allot_Required__.
--  110822  NaSalk  Modified Validate_Record__ and Create_Voucher_Type_Detail_.
-------------------------------------------------------------------------------------------------
--  121123  Thpelk  Bug 106680 - Modified Conditional compilation to use single component package.
--  121210  Maaylk  PEPA-183, Removed global variables
---------------------CONVERGE-------------------------------------------------
--  130201  NaSalk  Modified Is_Automatic_Allot_Required__.
-------------------------------------------------------------------------------------------------
--  130717  CPriLK  BRZ-3774, Added function group 'MPR' for required locations.
--  131113  Umdolk  PBFI-2130, Refactoring
--  141218  PRatlk  PRFI-4132, Clearing attribute string inside loops.
--  151021  chiblk  RDFI-202, added rec_.voucher_approve_privilege to the method Create_Voucher_Type_Detail_
--                            override prepare insert
--  170331  Chwtlk  STRFI-4480, Modified Check_Insert___. Added validations to check for single function group.
--  170922  Savmlk  STRFI-9981, Removed the separate_user_approval parameter.
--  190107  Nudilk  Bug 146161, Corrected.
-----------------------------------------------------------------------------
--  250618  Jadulk  FIUXX-2550, Moved client validations to Check_Common___
--  290618  Jadulk  FIUXX-2550, Added procedure Change_Row_Group_Validation
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------

@SecurityCheck Company.UserExist(company_)
PROCEDURE Reset_Row_Group_Validation(
   company_              IN VARCHAR2,
   voucher_type_         IN VARCHAR2)
IS
   voucher_type_detail_rec_ voucher_type_detail_tab%ROWTYPE;
   CURSOR get_voucher_type_detail IS
      SELECT *
      FROM  voucher_type_detail_tab
      WHERE company = company_
      AND   voucher_type = voucher_type_;   
BEGIN
   FOR rec_ IN get_voucher_type_detail LOOP
      IF (rec_.row_group_validation = 'Y') THEN
         rec_.row_group_validation := 'N';
         voucher_type_detail_rec_ := rec_;
         Modify___(voucher_type_detail_rec_, true);
      END IF; 
   END LOOP;   
END Reset_Row_Group_Validation; 

-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------

@Override
PROCEDURE Prepare_Insert___ (
   attr_ IN OUT VARCHAR2 )
IS
BEGIN
   super(attr_);
   Client_SYS.Add_To_Attr('SEPARATE_USER_APPROVAL_DB', 'FALSE', attr_);
END Prepare_Insert___;
   
PROCEDURE Validat_For_Summery_Code___ (
   company_             IN VARCHAR2,
   voucher_type_        IN VARCHAR2,
   function_group_      IN VARCHAR2,
   validator_           IN VARCHAR2 )
IS
   validator_txt_       VARCHAR2(100);   
   function_group_rec_  Function_Group_API.Public_Rec := Function_Group_API.Get(function_group_);
   raise_error_         BOOLEAN := FALSE;
BEGIN   
   IF (validator_ = 'ROW_GRP_VAL') THEN
      validator_txt_ := Language_SYS.Translate_Constant(lu_name_, 'VOUTYPEVAL1: Voucher Row Group Validation');      
      IF (function_group_rec_.vou_row_grp_val_allowed = 'FALSE') THEN
         raise_error_ := TRUE;
      END IF;
   ELSE
      validator_txt_ := Language_SYS.Translate_Constant(lu_name_, 'VOUTYPEVAL2: Reference Mandatory');      
      IF (function_group_rec_.ref_mandatory_allowed = 'FALSE') THEN
         raise_error_ := TRUE;
      END IF;      
   END IF;

   IF (raise_error_) THEN   
      Error_SYS.Record_General(lu_name_,'FUNCGRPNOTALLOWED: :P1 can not be checked for Function Group :P2',
                               validator_txt_,
                               function_group_ );
   END IF;

   -- Validate for set up of Summery Parameter
   $IF Component_Genled_SYS.INSTALLED $THEN
      IF (Gen_Led_Update_Summery_API.Get_Summery_Code(company_, voucher_type_)) THEN
         Error_SYS.Record_General(lu_name_, 'SUMMPRMNOTALLOW: The voucher type is set-up for summarization in the GL update. This must be removed before Voucher :P1 is selected.',
                                  validator_txt_);
      END IF;
   $END
END Validat_For_Summery_Code___;


@Override
PROCEDURE Check_Common___ (
   oldrec_ IN     voucher_type_detail_tab%ROWTYPE,
   newrec_ IN OUT voucher_type_detail_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
   voucher_type_rec_       voucher_type_tab%ROWTYPE;
   fucntion_group_rec_     function_group_tab%ROWTYPE;
   CURSOR get_voucher_type_info IS
      SELECT *
      FROM  voucher_type_tab
      WHERE company = newrec_.company
      AND   voucher_type = newrec_.voucher_type;   
   CURSOR get_function_group_data IS
      SELECT *
      FROM  function_group_tab
      WHERE function_group = newrec_.function_group;   
BEGIN
   IF ((indrec_.automatic_allot) OR (newrec_.automatic_allot IS NULL)) THEN
      Is_Automatic_Allot_Required__(newrec_.automatic_allot, newrec_.function_group);
   END IF;
   IF ((indrec_.single_function_group) OR (newrec_.single_function_group IS NULL)) THEN
      Is_Single_Function_Required__(newrec_.single_function_group, newrec_.function_group);
   END IF;
   
   super(oldrec_, newrec_, indrec_, attr_);
   Validate_Record__(newrec_);
      
   OPEN get_voucher_type_info;
   FETCH get_voucher_type_info INTO voucher_type_rec_;
   CLOSE get_voucher_type_info;

   OPEN get_function_group_data;
   FETCH get_function_group_data INTO fucntion_group_rec_;
   CLOSE get_function_group_data;

   IF (indrec_.function_group) THEN
      IF (Function_Group_API.Exists(newrec_.function_group)) THEN
         IF (fucntion_group_rec_.store_original_mandatory = 'TRUE') THEN
            newrec_.store_original := 'Y';
         ELSE
            newrec_.store_original := 'N';
         END IF; 

         IF (fucntion_group_rec_.vou_row_grp_val_allowed != 'TRUE') THEN
            newrec_.row_group_validation := 'N';
         END IF;

         IF (fucntion_group_rec_.ref_mandatory_allowed != 'TRUE') THEN
            newrec_.reference_mandatory := 'N';
         END IF;

         IF (fucntion_group_rec_.automatic_allotment_req = 'TRUE') THEN
            newrec_.automatic_allot := 'Y';
         ELSE
            newrec_.automatic_allot := 'N';
         END IF;

         IF (fucntion_group_rec_.single_function_required = 'FALSE') THEN
            newrec_.single_function_group := 'N';
         ELSE
            newrec_.single_function_group := 'Y';
         END IF;  

         IF (newrec_.automatic_allot = 'Y') THEN
            IF (Voucher_Type_API.Get_Automatic_Allot(newrec_.company, newrec_.voucher_type) = 'No') THEN
               Error_SYS.Record_General(lu_name_, 'AUTOALLOTREQ: Automatic Allotment should be selected for Voucher Type :P1 in order to connect the selected function group.', newrec_.voucher_type);                 
            END IF;   
         END IF;   

         IF (newrec_.single_function_group = 'Y' AND Voucher_Type_API.Get_Single_Function_Group(newrec_.company, newrec_.voucher_type) = 'N') THEN
            IF (Voucher_Type_API.Get_Function_Group_Count(newrec_.company, newrec_.voucher_type) = 1) THEN
               Error_SYS.Record_General(lu_name_, 'SINGLEFUNCTIONREQ: Single Function Group is required.');
            END IF;   
         END IF; 
      END IF;

      Voucher_Type_API.Check_Voucher_Privilege_(voucher_type_rec_);
      Voucher_Type_API.Check_Voucher_Approval_(voucher_type_rec_);      
      
      IF (indrec_.row_group_validation) THEN
         IF (newrec_.row_group_validation = 'N') THEN
            IF (Vou_With_Row_Group_Id_Exists__(newrec_.company, newrec_.voucher_type) = 'TRUE') THEN
               Client_SYS.Add_Warning(lu_name_, 'REMOVEROWGRPID: There are vouchers of this type with Row Group ID in the Hold table. The Row Group ID will be removed.');
            END IF;   
         END IF;  
         
         IF (fucntion_group_rec_.vou_row_grp_val_allowed = 'FALSE') THEN
            newrec_.row_group_validation := 'N';
         END IF;           
      END IF; 
      
      IF (indrec_.reference_mandatory) THEN
         IF (fucntion_group_rec_.ref_mandatory_allowed = 'FALSE') THEN
            newrec_.reference_mandatory := 'N';
         END IF;   
      END IF;   
      
   END IF;
   
END Check_Common___;


@Override
PROCEDURE Check_Delete___ (
   remrec_ IN VOUCHER_TYPE_DETAIL_TAB%ROWTYPE )
IS
BEGIN
   Voucher_Type_User_Group_API.Function_Group_Delete_Allowed(remrec_.company, remrec_.function_group, remrec_.voucher_type);   
   super(remrec_);
END Check_Delete___;


@Override
PROCEDURE Check_Insert___ (
   newrec_ IN OUT voucher_type_detail_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2)
IS
   voucher_type_rec_       Voucher_Type_API.Public_Rec;
   name_                   VARCHAR2(30);
   value_                  VARCHAR2(4000);
BEGIN
   voucher_type_rec_ := Voucher_Type_API.Get(newrec_.company, newrec_.voucher_type);    
  
   IF (voucher_type_rec_.single_function_group = 'Y' AND Voucher_Type_API.Get_Function_Group_Count(newrec_.company, newrec_.voucher_type) = 1) THEN
      Error_SYS.Record_General(lu_name_,'NEWNOTALLOWED: It is not allowed to add more than one Function Group when the Single Function Group is checked for the Voucher Type :P1.', newrec_.voucher_type);
   END IF; 

   IF (indrec_.function_group) THEN
      IF (newrec_.single_function_group = 'Y' AND voucher_type_rec_.single_function_group = 'N') THEN
            IF (Voucher_Type_API.Get_Function_Group_Count(newrec_.company, newrec_.voucher_type) != 1) THEN
               Error_SYS.Record_General(lu_name_, 'FUNCTIONGRPNOTALLOWED: Only Function Groups B/G/M/N/U can be connected together.');
            END IF;   
         END IF;
   END IF;   
   super(newrec_, indrec_, attr_); 
   IF (newrec_.function_group = 'J') THEN
      IF (NVL(voucher_type_rec_.automatic_allot,'N') = 'Y') THEN
         $IF Component_Invoic_SYS.INSTALLED $THEN
            IF (Company_Invoice_Info_API.Is_Same_Voucher_No(newrec_.company) = 'TRUE') THEN
               Error_SYS.Record_General(lu_name_,'AUTOALL: It is not allowed to set automatic allotment for Function group J when same no. on prel. and final suppl. invoice voucher is checked.');
            END IF;
         $ELSE
            NULL;
         $END
      END IF;
   END IF;
EXCEPTION
   WHEN value_error THEN
      Error_SYS.Item_Format(lu_name_, name_, value_);
END Check_Insert___;


@Override
PROCEDURE Check_Update___ (
   oldrec_ IN     voucher_type_detail_tab%ROWTYPE,
   newrec_ IN OUT voucher_type_detail_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
   name_             VARCHAR2(30);
   value_            VARCHAR2(4000);
   exists_           VARCHAR2(10);
   attr2_            VARCHAR2(4000);
BEGIN
   IF (indrec_.function_group) THEN
      Voucher_Type_User_Group_API.Function_Group_Modify_Allowed(newrec_.company, oldrec_.function_group, newrec_.voucher_type);  
      Voucher_No_Serial_API.Check_series_group__ (exists_,newrec_.company,newrec_.voucher_type);
      Client_SYS.Clear_Attr(attr2_);
      Client_SYS.Add_To_Attr('COMPANY', newrec_.company, attr2_);
      Client_SYS.Add_To_Attr('VOUCHER_TYPE', newrec_.voucher_type, attr2_);
      Client_SYS.Add_To_Attr('ACTION', 'MODIFY', attr2_);
      IF (newrec_.automatic_allot <> 'N') THEN
         Voucher_API.Check_Voucher(attr2_);
         $IF Component_Genled_SYS.INSTALLED $THEN
            Gen_Led_Voucher_API.Check_Voucher ( attr2_ );
         $END
      END IF;
   END IF;  
   
   super(oldrec_, newrec_, indrec_, attr_);

   IF (newrec_.row_group_validation = 'N') THEN
      Clear_Row_Group_Ids__(newrec_.company, newrec_.voucher_type );
   END IF;
EXCEPTION
   WHEN value_error THEN
      Error_SYS.Item_Format(lu_name_, name_, value_);
END Check_Update___;

@Override
PROCEDURE Raise_Record_Not_Exist___ (
   company_ IN VARCHAR2,
   voucher_type_ IN VARCHAR2,
   function_group_ IN VARCHAR2 )
IS
BEGIN
   Error_SYS.Record_General(lu_name_, 'FUNCGROUPNOTCONN: Function Group :P1 does not belong to voucher type :P2', function_group_, voucher_type_);
   super(company_, voucher_type_, function_group_);
END Raise_Record_Not_Exist___;

PROCEDURE Validate_Function_Grp_Data___(
    rec_                      IN VOUCHER_TYPE_DETAIL_TAB%ROWTYPE,
    fgroup_basic_data_txt_    IN VARCHAR2)
IS
   function_group_rec_     Function_Group_API.Public_Rec;
   simulation_vou_         VARCHAR2(5);
   ledger_id_              VARCHAR2(10);
BEGIN
   function_group_rec_ := Function_Group_API.Get(rec_.function_group);   
   -- Validate Automatic Voucher Balance
   IF (function_group_rec_.automatic_voucher_balance = 'FALSE') THEN         
      IF (rec_.automatic_vou_balance = 'Y') THEN
         Error_SYS.Record_General(lu_name_,'OPTIONALAUTOBALNOTALLOWED: Optional Auto Balance can not be checked for Function Group :P1', rec_.function_group);         
      END IF;
   END IF;
   -- Validate Flag Store Original
   IF (function_group_rec_.store_original_allowed = 'FALSE') THEN        
      IF (rec_.store_original = 'Y') THEN
         Error_SYS.Record_General(lu_name_,'STOREORGNOTALLOWED: Store Original can not be checked for Function Group :P1',
                                  rec_.function_group);
      END IF;
   END IF;
   
   IF (function_group_rec_.store_original_mandatory = 'TRUE') THEN
      IF (rec_.store_original = 'N') THEN
         Error_SYS.Record_General(lu_name_,'STOREORGONLYALLOWED: Store Original should be checked for Function Group :P1',
                                            rec_.function_group);
      END IF;
   END IF;
   
   -- Validate Flag Single Function Group
   Is_Same_Voucher_No__(rec_.company, rec_.function_group, rec_.single_function_group);

   -- Check Simulation Voucher Flag
   simulation_vou_ := Voucher_Type_API.Get_Simulation_Voucher(rec_.company, rec_.voucher_type);
   IF ((simulation_vou_ = 'TRUE') AND (rec_.function_group IS NOT NULL)) THEN
      IF (function_group_rec_.simulation_voucher_allowed = 'FALSE') THEN                        
         Error_SYS.Record_General(lu_name_,'SIMUVOUNOTOK: Simulation Voucher cannot be checked for the Voucher Type using the selected Function Group(s). :P1',
                                  fgroup_basic_data_txt_);
      END IF;
   END IF;

   -- Validate Ledger
   ledger_id_ := Voucher_Type_API.Get_Ledger_Id(rec_.company, rec_.voucher_type);

   IF (ledger_id_ NOT IN ('*', '00')) THEN
      IF (function_group_rec_.internal_ledger_allowed = 'FALSE') THEN
         Error_SYS.Record_General(lu_name_,'INTNOTALLOW: Voucher Types connected to Function Group :P1 are not allowed in Internal Ledger. :P2',
                                  rec_.function_group,
                                  fgroup_basic_data_txt_);            
      END IF;
   END IF;

END Validate_Function_Grp_Data___;

PROCEDURE Export___ (
   crecomp_rec_ IN Enterp_Comp_Connect_V170_API.Crecomp_Lu_Public_Rec )
IS
   pub_rec_ Enterp_Comp_Connect_V170_API.Tem_Public_Rec;
   i_       NUMBER := 1;
   CURSOR get_data IS
      SELECT *
      FROM  voucher_type_detail_tab vtd
      WHERE company = crecomp_rec_.company      
      AND NVL((SELECT ledger_id
               FROM  voucher_type_tab vt
               WHERE vt.company      = vtd.company
               AND   vt.voucher_type = vtd.voucher_type),' ') IN ('00','*',' ');
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
   newrec_      voucher_type_detail_tab%ROWTYPE;
   empty_rec_   voucher_type_detail_tab%ROWTYPE;
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
                      FROM  voucher_type_detail_tab
                      WHERE company = crecomp_rec_.company
                      AND   voucher_type = src.c1
                      AND   function_group = src.c2);
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
               Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'VOUCHER_TYPE_DETAIL_API', 'Error', msg_);
         END;
      END LOOP;
      IF ( i_ = 0 ) THEN
         msg_ := Language_SYS.Translate_Constant(lu_name_, 'NODATAFOUND: No Data Found');
         Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'VOUCHER_TYPE_DETAIL_API', 'CreatedSuccessfully', msg_);
      ELSE
         IF msg_ IS NULL THEN
            Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'VOUCHER_TYPE_DETAIL_API', 'CreatedSuccessfully');
         ELSE
            Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'VOUCHER_TYPE_DETAIL_API', 'CreatedWithErrors');
         END IF;
      END IF;
   END IF;
   -- this statement is to add to the log that the Create company process for LUs is finished if
   -- run_crecomp_ are FALSE
   IF (NOT run_crecomp_) THEN
      Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'VOUCHER_TYPE_DETAIL_API', 'CreatedSuccessfully');
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      msg_ := SQLERRM;
      Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'VOUCHER_TYPE_DETAIL_API', 'Error', msg_);
      Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'VOUCHER_TYPE_DETAIL_API', 'CreatedWithErrors');
END Import___;

PROCEDURE Copy___ (
   crecomp_rec_ IN Enterp_Comp_Connect_V170_API.Crecomp_Lu_Public_Rec )
IS
   attr_        VARCHAR2(2000);
   objid_       VARCHAR2(2000);
   objversion_  VARCHAR2(2000);
   newrec_      voucher_type_detail_tab%ROWTYPE;
   empty_rec_   voucher_type_detail_tab%ROWTYPE;
   indrec_      Indicator_Rec;
   msg_         VARCHAR2(2000);
   i_           NUMBER := 0;
   run_crecomp_ BOOLEAN := FALSE;
   CURSOR get_data IS
      SELECT *
      FROM  voucher_type_detail_tab src
      WHERE company = crecomp_rec_.old_company      
      AND NVL((SELECT ledger_id
               FROM  voucher_type_tab vt
               WHERE vt.company      = src.company
               AND   vt.voucher_type = src.voucher_type),' ') IN ('00','*',' ')
      AND NOT EXISTS (SELECT 1
                      FROM  voucher_type_detail_tab
                      WHERE company = crecomp_rec_.company
                      AND   voucher_type = src.voucher_type
                      AND   function_group = src.function_group);
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
               Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'VOUCHER_TYPE_DETAIL_API', 'Error', msg_);
         END;
      END LOOP;
      IF ( i_ = 0 ) THEN
         msg_ := Language_SYS.Translate_Constant(lu_name_, 'NODATAFOUND: No Data Found');
         Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'VOUCHER_TYPE_DETAIL_API', 'CreatedSuccessfully', msg_);
      ELSE
         IF msg_ IS NULL THEN
            Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'VOUCHER_TYPE_DETAIL_API', 'CreatedSuccessfully');
         ELSE
            Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'VOUCHER_TYPE_DETAIL_API', 'CreatedWithErrors');
         END IF;
      END IF;
   END IF;
   -- this statement is to add to the log that the Create company process for LUs is finished if
   -- run_crecomp_ are FALSE
   IF ( NOT run_crecomp_ ) THEN
      Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'VOUCHER_TYPE_DETAIL_API', 'CreatedSuccessfully');
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      msg_ := SQLERRM;
      Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'VOUCHER_TYPE_DETAIL_API', 'Error', msg_);
      Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'VOUCHER_TYPE_DETAIL_API', 'CreatedWithErrors');
END Copy___;
-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------

PROCEDURE Is_Same_Voucher_No__ (
   company_             IN VARCHAR2,
   function_group_    IN VARCHAR2,
   single_function_group_ IN VARCHAR2 )
IS
BEGIN
   IF (single_function_group_ = 'N') AND (function_group_ = 'J') THEN
      $IF Component_Invoic_SYS.INSTALLED $THEN
         IF (Company_Invoice_Info_API.Is_Same_Voucher_No(company_) = 'TRUE') THEN
            Error_Sys.Record_General(lu_name_, 'NOUNCHECK: Single Function Group is required for Function Group J');
         END IF;
      $ELSE
         NULL;
      $END
   END IF;
END Is_Same_Voucher_No__;


PROCEDURE Is_Automatic_Allot_Required__ (
   auto_allotment_   IN OUT VARCHAR2,
   function_group_ IN     VARCHAR2 )
IS
   function_group_rec_  Function_Group_API.Public_Rec := Function_Group_API.Get(function_group_);
BEGIN
   IF (function_group_rec_.automatic_allotment_req = 'TRUE') THEN   
      auto_allotment_ := 'Y';
   ELSE
      auto_allotment_ := 'N';
   END IF;
END Is_Automatic_Allot_Required__;


PROCEDURE Is_Single_Function_Required__ (
   single_function_ IN OUT VARCHAR2,
   function_group_ IN VARCHAR2 )
IS
   function_group_rec_  Function_Group_API.Public_Rec := Function_Group_API.Get(function_group_);
BEGIN
   IF (function_group_rec_.single_function_required = 'FALSE') THEN      
      single_function_ := 'N';
   ELSE
      single_function_ := 'Y';
   END IF;
END Is_Single_Function_Required__;


PROCEDURE Validate_Record__ (
   newrec_ IN VOUCHER_TYPE_DETAIL_TAB%ROWTYPE )
IS
   ledger_id_            VARCHAR2(10);
   CURSOR get_count IS
      SELECT COUNT(*)
      FROM VOUCHER_TYPE_DETAIL_TAB
      WHERE company      = newrec_.company
      AND voucher_type   = newrec_.voucher_type
      AND function_group = newrec_.function_group;
   count_                  NUMBER;
   is_vou_connected_       VARCHAR2(5);
   il_project_accounting_  VARCHAR2(5);
   function_group_rec_     Function_Group_API.Public_Rec := Function_Group_API.Get(newrec_.function_group);
   fgroup_basic_data_txt_  VARCHAR2(200);
   voucher_type_rec_       Voucher_Type_API.Public_Rec;
BEGIN
   fgroup_basic_data_txt_ := Function_Group_API.Get_Basic_Data_Info_Text;
   -- Check Single Function Group Flag
   voucher_type_rec_ := Voucher_Type_API.Get(newrec_.company, newrec_.voucher_type);

   IF (voucher_type_rec_.single_function_group = 'Y') THEN
      OPEN get_count;
      FETCH get_count INTO count_;
      CLOSE get_count;
      IF (count_ > 1) THEN
         Error_SYS.Record_General(lu_name_,'NOTSINGFUNC: A single Function Group should be connected to Voucher Type :P1', newrec_.voucher_type);
      END IF;
   ELSE
      IF (function_group_rec_.conn_func_group_allowed = 'FALSE') THEN   
         Error_SYS.Record_General(lu_name_,'INVALFUNC: Function Group :P1 cannot be connected together with another function group. :P2',
                                  newrec_.function_group,
                                  fgroup_basic_data_txt_);
      END IF;
      IF (newrec_.function_group = 'M') THEN
         $IF Component_Payled_SYS.INSTALLED $THEN
            is_vou_connected_ := Cash_Account_API.Is_Voucher_Type_Connected(newrec_.company, newrec_.voucher_type);
         $END
         IF (is_vou_connected_ = 'TRUE') THEN
            Error_SYS.Record_General(lu_name_,'INVALCASH: Only B / G / N / U Function Groups can be connected together, when voucher type is connected to a cash account');
         END IF;
      END IF;
   END IF;   
   
   Validate_Function_Grp_Data___(newrec_, fgroup_basic_data_txt_);

   -- Validate Flag Single Function Group
   Is_Same_Voucher_No__(newrec_.company, newrec_.function_group, newrec_.single_function_group);

   -- Validate Row Group Validation
   IF (newrec_.row_group_validation = 'Y') THEN
      Validat_For_Summery_Code___(newrec_.company, newrec_.voucher_type, newrec_.function_group, 'ROW_GRP_VAL');
   END IF;

   -- Validate Reference Mandatory
   IF (newrec_.reference_mandatory = 'Y') THEN
      Validat_For_Summery_Code___(newrec_.company, newrec_.voucher_type, newrec_.function_group, 'REF_MAN');
   END IF;

   --Validate voucher types defined using function group PPC to have balance TRUE
   IF (voucher_type_rec_.balance = 'FALSE' AND newrec_.function_group = 'PPC') THEN      
      Error_SYS.Record_General(lu_name_,'VOUGRPPCBAL: Balance Mandatory check box should be selected if voucher type is connected to function group :P1',
                               newrec_.function_group);
   END IF;

   --should not be allowed to connect a "PPC" function group voucher type to a non-project IL
   IF (newrec_.function_group = 'PPC') AND (ledger_id_ NOT IN ('*', '00')) THEN
      $IF Component_Intled_SYS.INSTALLED $THEN
         il_project_accounting_ := Internal_Ledger_API.Get_Project_Accounting(newrec_.company, ledger_id_);
      $END       
      IF (nvl(il_project_accounting_, 'FALSE') = 'FALSE') THEN
         Error_SYS.Record_General(lu_name_,'PCPROJACCOUNTING: Not allow to connect a :P1 function group voucher type to a non-project IL.',
                                  newrec_.function_group);
      END IF;
   END IF;
END Validate_Record__;


PROCEDURE Check_Delete_Record__ (
   company_ IN VARCHAR2,
   voucher_type_ IN VARCHAR2,
   function_group_ IN VARCHAR2 )
IS
   attr_          VARCHAR2(2000);
BEGIN
   Client_SYS.Clear_Attr(attr_);
   Client_SYS.Add_To_Attr('COMPANY', company_, attr_);
   Client_SYS.Add_To_Attr('VOUCHER_TYPE', voucher_type_, attr_);
   Client_SYS.Add_To_Attr('FUNCTION_GROUP', function_group_, attr_);
   Voucher_Type_User_Group_API.Function_Group_Delete_Allowed( company_, function_group_, voucher_type_);
END Check_Delete_Record__;


PROCEDURE Clear_Row_Group_Ids__ (
   company_ IN VARCHAR2,
   voucher_type_ IN VARCHAR2 )
IS
   CURSOR get_voucher_ IS
      SELECT t.company,
             t.voucher_type,
             t.voucher_no,
             t.accounting_year
      FROM voucher_row_tab t
      WHERE t.company = company_
      AND t.voucher_type = voucher_type_ ;
BEGIN
   -- Check for vouchers with row_group_id
   IF (Vou_With_Row_Group_Id_Exists__( company_, voucher_type_) = 'TRUE' ) THEN
      FOR rec_ IN get_voucher_ LOOP
         Voucher_API.Clear_Row_Group_Ids__( rec_.company, rec_.accounting_year, rec_.voucher_type, rec_.voucher_no );
      END LOOP;
   END IF;
END Clear_Row_Group_Ids__;


@UncheckedAccess
FUNCTION Vou_With_Row_Group_Id_Exists__ (
   company_ IN VARCHAR2,
   voucher_type_ IN VARCHAR2 ) RETURN VARCHAR2
IS
   dummy_    NUMBER;

   CURSOR exist_vouchers IS
      SELECT 1
      FROM Voucher_Row_Tab t
      WHERE t.company = company_
         AND t.voucher_type = voucher_type_
         AND t.row_group_id IS NOT NULL;
BEGIN
    -- Check for vouchers with row_group_id
   OPEN exist_vouchers;
   FETCH exist_vouchers INTO dummy_;
   IF (exist_vouchers%FOUND) THEN
      CLOSE exist_vouchers;
      RETURN 'TRUE';
   END IF;
   CLOSE exist_vouchers;
   RETURN 'FALSE';
END Vou_With_Row_Group_Id_Exists__;


-------------------- LU SPECIFIC PROTECTED METHODS --------------------------

PROCEDURE Create_Voucher_Type_Detail_ (
   message_ IN VARCHAR2 )
IS
   count_                  INTEGER;
   names_                  message_sys.name_Table;
   values_                 message_sys.line_Table;
   scount_                 INTEGER;
   snames_                 message_sys.name_Table;
   svalues_                message_sys.line_Table;
   rec_                    VOUCHER_TYPE_DETAIL_TAB%ROWTYPE;
   objid_                  VOUCHER_TYPE_DETAIL.objid%TYPE;
   objversion_             VARCHAR2(2000);
   attr_                   VARCHAR2(32000);    
   fgroup_basic_data_txt_  VARCHAR2(200);
BEGIN
   fgroup_basic_data_txt_ := Function_Group_API.Get_Basic_Data_Info_Text;
   
   Message_SYS.Get_Attributes ( message_, count_, names_, values_ );
   FOR i_ IN 1..count_ LOOP
      Message_SYS.Get_Attributes ( values_(i_), scount_, snames_, svalues_ );
   END LOOP;
   FOR i_ IN 1..count_ LOOP
      Message_SYS.Get_Attributes ( values_(i_), scount_, snames_, svalues_ );
      rec_.company                     := svalues_(1);
      rec_.voucher_type                := svalues_(2);
      rec_.function_group              := svalues_(3);
      rec_.automatic_vou_balance       := svalues_(4);
      rec_.store_original              := svalues_(5);
      rec_.single_function_group       := svalues_(6);
      rec_.automatic_allot             := svalues_(7);
      rec_.row_group_validation        := svalues_(8);
      rec_.reference_mandatory         := svalues_(9);
   
      Validate_Function_Grp_Data___(rec_, fgroup_basic_data_txt_);
      Insert___(objid_, objversion_, rec_, attr_);
      Client_SYS.Clear_Attr(attr_);
   END LOOP;
END Create_Voucher_Type_Detail_;




-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

@UncheckedAccess
FUNCTION Get_Function_Group (
   company_ IN VARCHAR2,
   voucher_type_ IN VARCHAR2 ) RETURN VARCHAR2
IS
   CURSOR get_function_group IS
      SELECT function_group
      FROM VOUCHER_TYPE_DETAIL_TAB
      WHERE company      = company_
      AND   voucher_type = voucher_type_;

   temp_                 VOUCHER_TYPE_DETAIL_TAB.function_group%TYPE;
   single_function_      VARCHAR2(1);
BEGIN
   single_function_ := Voucher_Type_API.Get_Single_Function_Group(company_, voucher_type_);
   IF (single_function_ = 'Y') THEN
      OPEN get_function_group;
      FETCH get_function_group INTO temp_;
      CLOSE get_function_group;
   END IF;
   RETURN temp_;
END Get_Function_Group;


PROCEDURE Process_Message (
   message_ IN VARCHAR2,
   process_ IN VARCHAR2 )
IS
   print_desc_     VARCHAR2(50);
BEGIN
   IF (process_ = 'TRUE') THEN
      -- *Online Process*
      Create_Voucher_Type_Detail_(message_);
   ELSE
      -- *Batch Process*
      print_desc_ := Language_SYS.Translate_Constant(lu_name_,'CREVOUDET: Create Voucher Type Detail');
      Transaction_SYS.Deferred_Call('Voucher_Type_Detail_API.Create_Voucher_Type_Detail_', message_ ,print_desc_);
   END IF;
END Process_Message;
