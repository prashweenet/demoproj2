-----------------------------------------------------------------------------
--
--  Logical unit: AccountGroup
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  960327  MIJO     Created.
--  970623  SLKO     Converted to Foundation 1.2.2d
--  970625  PICZ     Added CONS_COMPANY to VIEW; added validation for consolidation
--                   account
--  970723  PICZ     Fixed problem with validation of default consolidation account
--                   in Unpack_Check_Insert___ and in Unpack_Check_Update___
--  970910  PICZ     Aded description (column) for default consolidation account
--  971003  ANDJ     Removed mandatory flag on description (column) for default
--                   consolidation account to enable insert of new account groups.
--  980921  Bren     Master Slave Connection
--                   Send_Account_Info___, Send_Account_Info_Delete___,
--                   Send_Account_Info_Modify___, Receive_Account_Info___ .
--  990416  Ruwan    Modified with respect to new template
--  000908  Himu     Added General_SYS.Init_Method
--  001006  prtilk   BUG # 15677  Checked General_SYS.Init_Method
--  001130  OVJOSE   For new Create Company concept added new view account_group_ect and account_group_pct. 
--                   Added procedures Make_Company, Copy___, Import___ and Export___.
--  010531  Bmekse   Removed methods used by the old way for transfer basic data from
--                   master to slave (nowdays is Replication used instead)
--  010816  OVJOSE   Added Create Company translation method Create_Company_Translations___
--  011207  OVJOSE   IID 20001 Enhancement of Update Company. Changes inside make_company method
--                   Changed Import___, Export___ and Copy___ methods to use records
--  020206  MaNi     Text_Field_Translation changed to Company_Translation
--  020320  Mnisse   Copy__ changed FOUND -> NOTFOUND
--  021001  Nimalk   Remove usage of the view Company_Finance_Auth in ACCOUNT_GROUP view 
--                   and replaced by view Company_Finance_Auth1 using EXISTS caluse instead of joins
--  021031  ovjose   IID Glob06. Added column description to Table.
--
--  040617  sachlk   FIPR338A2: Unicode Changes.
--  090724  WAPELK   Bug Id 84476, Assign null to parent code parts when creating a new company/template 
--                   from consolidated company
--  120514  SALIDE   EDEL-698, Added VIEW_AUDI
--  151117  Bhhilk   STRFI-12, Removed annotation from public get methords.
--  181823  Nudilk   Bug 143758, Corrected.
--  190522  Dakplk   Bug 147872, Modified Copy_To_Companies__. 
--  200904  Jadulk   FISPRING20-6695, Removed CONACC related obsolete component logic.
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------

-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------

PROCEDURE Pre_Delete___ (
   remrec_    IN ACCOUNT_GROUP_TAB%ROWTYPE )
IS
   exists_    VARCHAR2(10);
BEGIN
   Accounting_Code_Part_A_API.Check_Delete_Group_(exists_, remrec_.company, remrec_.accnt_group);
   IF (exists_ = 'TRUE') THEN
      Error_SYS.Record_General('AccountGroup', 'ISUSED: The Account Group Is Being Used, Cannot be Deleted');
   END IF;
END Pre_Delete___;


PROCEDURE Check_Group_Account___ (
   company_             IN VARCHAR2,
   default_group_accnt_ IN VARCHAR2 )
IS
   master_compay_             Company_Finance_Tab.master_company%TYPE;
   acc_exists_                BOOLEAN;
   no_accnt_in_cons           EXCEPTION;
BEGIN
   master_compay_ := Company_Finance_API.Get_Master_Company(company_);
   acc_exists_ := Accounting_Code_Part_A_API.Exist(master_compay_,
                                                   'A',
                                                   default_group_accnt_);
   IF (NOT acc_exists_) THEN
      RAISE no_accnt_in_cons;
   END IF;
EXCEPTION
   WHEN no_accnt_in_cons THEN
      Error_SYS.Record_General(lu_name_,
                               'ACCNTNOTEXIST: Account :P1 does not exist in master company :P2',
                               default_group_accnt_,
                               master_compay_);
END Check_Group_Account___;

@Override
PROCEDURE Import_Assign___ (
   newrec_      IN OUT account_group_tab%ROWTYPE,
   crecomp_rec_ IN     Enterp_Comp_Connect_V170_API.Crecomp_Lu_Public_Rec,
   pub_rec_     IN     Create_Company_Template_Pub%ROWTYPE )
IS
BEGIN
   super(newrec_, crecomp_rec_, pub_rec_);

   IF (newrec_.description IS NULL) THEN
      newrec_.description := newrec_.accnt_group;
   END IF;
END Import_Assign___;
   
@Override
PROCEDURE Copy_Assign___ (
   newrec_      IN OUT account_group_tab%ROWTYPE,
   crecomp_rec_ IN     Enterp_Comp_Connect_V170_API.Crecomp_Lu_Public_Rec,
   oldrec_      IN     account_group_tab%ROWTYPE )
IS
BEGIN
   super(newrec_, crecomp_rec_, oldrec_);

END Copy_Assign___;


@Override
PROCEDURE Prepare_Insert___ (
   attr_  IN OUT VARCHAR2 )
IS
   company_      ACCOUNT_GROUP_TAB.company%TYPE;
BEGIN
   company_      := Client_SYS.Get_Item_Value('COMPANY', attr_);

   super(attr_);
END Prepare_Insert___;


@Override
PROCEDURE Check_Delete___ (
   remrec_      IN ACCOUNT_GROUP_TAB%ROWTYPE )
IS
BEGIN
   IF (App_Context_Sys.Find_Value(lu_name_||'.copy_to_company_', 'FALSE') != 'TRUE') THEN
      IF (Company_Basic_Data_Window_API.Check_Copy_From_Company(remrec_.company, lu_name_)) THEN
         Error_SYS.Record_General(lu_name_, 'NODIRECTREMOVE: A record cannot be removed as :P1 window has been set up for copying data only from source company in Basic Data Synchronization window.', Basic_Data_Window_API.Get_Window(lu_name_));
      END IF;
   END IF;
   super(remrec_);
   Pre_Delete___( remrec_);
END Check_Delete___;


@Override
PROCEDURE Check_Common___ (
   oldrec_ IN     account_group_tab%ROWTYPE,
   newrec_ IN OUT account_group_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
   check_val_ VARCHAR2(5) := 'TRUE';
BEGIN
   IF (App_Context_Sys.Find_Value(lu_name_||'.copy_to_company_', 'FALSE') != 'TRUE') THEN
      IF (Company_Basic_Data_Window_API.Check_Copy_From_Company(newrec_.company, lu_name_)) THEN
         Error_SYS.Record_General(lu_name_, 'NODIRECTINSERT: A record cannot be entered/modified as :P1 window has been set up for copying data only from source company in Basic Data Synchronization window.', Basic_Data_Window_API.Get_Window(lu_name_));
      END IF;
   END IF;
   super(oldrec_, newrec_, indrec_, attr_);
   
   IF (newrec_.def_master_company_accnt IS NOT NULL) THEN
      Check_Group_Account___( newrec_.company, newrec_.def_master_company_accnt );
   END IF;   
   check_val_ := Account_Group_API.Check_Curr_Ball_Exist(newrec_.company);
   IF (check_val_ = 'FALSE') THEN 
      IF ((newrec_.def_currency_balance = 'TRUE')) THEN
         Error_SYS.Appl_General(lu_name_, 'CURRBALINVALID: Default currency balance can not be enabled when the currency balance for the company :P1 is not defined.',newrec_.company);
      END IF;
   END IF;   
END Check_Common___;

@Override
PROCEDURE Check_Insert___ (
   newrec_ IN OUT account_group_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
BEGIN
   newrec_.def_currency_balance := NVL(newrec_.def_currency_balance,'FALSE');
   super(newrec_, indrec_, attr_);
   --Add post-processing code here
END Check_Insert___;

-- Note: Use Copy_To_Company_Util_API.Get_Next_Record_Sep_Val method instead.
@Deprecated
FUNCTION Get_Next_Record_Sep_Val___ (
   value_ IN OUT VARCHAR2,
   ptr_   IN OUT NUMBER,  
   attr_  IN     VARCHAR2 ) RETURN BOOLEAN
IS
BEGIN
   RETURN Copy_To_Company_Util_API.Get_Next_Record_Sep_Val(value_, ptr_, attr_);
END Get_Next_Record_Sep_Val___; 
PROCEDURE Copy_To_Companies_For_Svc___ (
   source_company_      IN  VARCHAR2,
   target_company_list_ IN  VARCHAR2,
   account_group_list_  IN  VARCHAR2,
   update_method_list_  IN  VARCHAR2,
   log_id_              IN  NUMBER,
   attr_                IN  VARCHAR2 DEFAULT NULL)
IS
   TYPE account_group IS TABLE OF account_group_tab.accnt_group%TYPE INDEX BY BINARY_INTEGER;
   TYPE attr IS TABLE OF VARCHAR2 (32000) INDEX BY BINARY_INTEGER;                           
   ptr_                    NUMBER;
   ptr1_                   NUMBER;
   ptr2_                   NUMBER;
   i_                      NUMBER;
   update_method_          VARCHAR2(20);
   value_                  VARCHAR2(2000);
   target_company_         account_group_tab.company%TYPE;
   ref_account_group_      account_group;
   ref_attr_               attr;
   attr_value_             VARCHAR2(32000) := NULL;
BEGIN
   ptr_  := NULL;
   ptr1_ := NULL;
   ptr2_ := NULL;

   i_    := 0;
   WHILE Copy_To_Company_Util_API.Get_Next_Record_Sep_Val(value_, ptr_, account_group_list_) LOOP
      ref_account_group_(i_):= value_;
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
         FOR j_ IN ref_account_group_.FIRST..ref_account_group_.LAST LOOP
            IF (ref_attr_.FIRST IS NOT NULL) THEN
               attr_value_ := ref_attr_(j_);
            END IF;            
            Copy_To_Companies__ (source_company_, target_company_, ref_account_group_(j_), update_method_, log_id_, attr_value_);
         END LOOP;
      END IF;
   END LOOP;
END Copy_To_Companies_For_Svc___;

-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------

PROCEDURE Copy_To_Companies__ (
   source_company_      IN VARCHAR2,
   target_company_      IN VARCHAR2,
   accnt_group_         IN VARCHAR2,
   update_method_       IN VARCHAR2,
   log_id_              IN NUMBER,
   attr_                IN VARCHAR2 DEFAULT NULL)
IS
   source_rec_              account_group_tab%ROWTYPE;
   target_rec_              account_group_tab%ROWTYPE;
   old_target_rec_          account_group_tab%ROWTYPE;
   log_key_                 VARCHAR2(2000);
   log_detail_status_       VARCHAR2(10);  
BEGIN
   source_rec_ := Get_Object_By_Keys___(source_company_, accnt_group_);
   target_rec_ := source_rec_;
   target_rec_.company := target_company_;
   App_Context_Sys.Set_Value(lu_name_||'.copy_to_company_', 'TRUE');
   old_target_rec_ := Get_Object_By_Keys___(target_company_, accnt_group_);
   log_key_ := accnt_group_;

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
      Remove___(old_target_rec_);      
      log_detail_status_ := 'REMOVED';      
   ELSIF (source_rec_.rowversion IS NULL AND old_target_rec_.rowversion IS NULL) THEN
      -- Source removes a record, the same record does not exist in the target company to be removed
      Raise_Record_Not_Exist___(target_company_, accnt_group_);
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
                                                        accnt_group_,
                                                        accnt_group_);
   App_Context_Sys.Set_Value(lu_name_||'.copy_to_company_', 'FALSE');
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
   account_group_list_  VARCHAR2(32000);
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
      ELSIF (name_ = 'ACCOUNT_GROUP_LIST') THEN
         account_group_list_ := value_;
      ELSIF (name_ = 'ACCNT_GROUP_LIST') THEN
         account_group_list_ := value_;
      ELSIF (name_ = 'UPDATE_METHOD_LIST') THEN
         update_method_list_ := value_;
      ELSIF (name_ = 'COPY_TYPE') THEN
         copy_type_ := value_;
      ELSIF (name_ = 'ATTR') THEN
         attr1_ := value_||chr(30)||substr(attr_, ptr_,length(attr_)-1);
      END IF;
   END LOOP;
   Copy_To_Companies_(company_,
                      target_company_list_,
                      account_group_list_,
                      update_method_list_,
                      copy_type_,
                      attr1_);
END Copy_To_Companies_;

PROCEDURE Copy_To_Companies_ (
   source_company_      IN  VARCHAR2,
   target_company_list_ IN  VARCHAR2,
   account_group_list_  IN  VARCHAR2,
   update_method_list_  IN  VARCHAR2,
   copy_type_           IN  VARCHAR2,
   attr_                IN  VARCHAR2 DEFAULT NULL)
IS
   TYPE account_group IS TABLE OF account_group_tab.accnt_group%TYPE INDEX BY BINARY_INTEGER;
   TYPE attr IS TABLE OF VARCHAR2 (32000) INDEX BY BINARY_INTEGER;                           
   ptr_                    NUMBER;
   ptr1_                   NUMBER;
   ptr2_                   NUMBER;
   i_                      NUMBER;
   update_method_          VARCHAR2(20);
   value_                  VARCHAR2(2000);
   target_company_         account_group_tab.company%TYPE;
   ref_account_group_      account_group;
   ref_attr_               attr;
   log_id_                 NUMBER;
   attr_value_             VARCHAR2(32000) := NULL;
BEGIN
   ptr_  := NULL;
   ptr1_ := NULL;
   ptr2_ := NULL;

   i_    := 0;
   WHILE Copy_To_Company_Util_API.Get_Next_Record_Sep_Val(value_, ptr_, account_group_list_) LOOP
      ref_account_group_(i_):= value_;
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
         FOR j_ IN ref_account_group_.FIRST..ref_account_group_.LAST LOOP
            IF (ref_attr_.FIRST IS NOT NULL) THEN
               attr_value_ := ref_attr_(j_);
            END IF;            
            Copy_To_Companies__ (source_company_,  
                                 target_company_,
                                 ref_account_group_(j_),      
                                 update_method_,
                                 log_id_,
                                 attr_value_);
         END LOOP;
      END IF;
   END LOOP;
   IF (target_company_list_ IS NOT NULL) THEN
      Copy_Basic_Data_Log_API.Update_Status(log_id_);
   END IF;
END Copy_To_Companies_;

-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

PROCEDURE Get_Control_Type_Value_Desc (
   description_          OUT VARCHAR2,
   company_           IN     VARCHAR2,
   accnt_group_       IN     VARCHAR2 )
IS
BEGIN
   description_ := Get_Description( company_, accnt_group_ );
END Get_Control_Type_Value_Desc;


PROCEDURE Copy_To_Companies_For_Svc (
   attr_              IN  VARCHAR2,
   run_in_background_ IN  BOOLEAN,
   log_id_            IN  NUMBER DEFAULT NULL)
IS
   ptr_                    NUMBER;
   name_                   VARCHAR2(200);
   value_                  VARCHAR2(32000);
   source_company_         VARCHAR2(100);
   account_group_list_     VARCHAR2(2000);
   target_company_list_    VARCHAR2(2000);
   update_method_list_     VARCHAR2(2000);
   attr1_                  VARCHAR2(32000);
   run_in_background_attr_ VARCHAR2(32000);
BEGIN
   IF (run_in_background_) THEN
      run_in_background_attr_ := attr_;
      Transaction_SYS.Deferred_Call('Account_Group_API.Copy_To_Companies_', run_in_background_attr_, Language_SYS.Translate_Constant(lu_name_, 'COPYDATA: Copy Basic Data')); 
   ELSE
      ptr_ := NULL;
      WHILE (Client_SYS.Get_Next_From_Attr(attr_, ptr_, name_, value_)) LOOP
         IF (name_ = 'SOURCE_COMPANY') THEN
            source_company_ := value_;
         ELSIF (name_ = 'TARGET_COMPANY_LIST') THEN
            target_company_list_ := value_;
         ELSIF (name_ = 'ACCNT_GROUP_LIST') THEN
            account_group_list_ := value_;
         ELSIF (name_ = 'UPDATE_METHOD_LIST') THEN
            update_method_list_ := value_;
         ELSIF (name_ = 'ATTR') THEN
            attr1_ := value_||chr(30)||substr(attr_, ptr_,length(attr_)-1);
         END IF;
      END LOOP;
      Copy_To_Companies_For_Svc___(source_company_,
                                    target_company_list_,
                                    account_group_list_,
                                    update_method_list_,
                                    log_id_,
                                    attr1_);
   END IF;
END Copy_To_Companies_For_Svc;

PROCEDURE Update_Master_Com_Code_Part(
   company_            IN VARCHAR2,
   code_part_          IN VARCHAR2,
   group_account_list_ IN VARCHAR2,
   selected_option_    IN NUMBER)
IS
   item_list_        Utility_SYS.STRING_TABLE;
   item_count_       NUMBER :=0;
   item_index_       NUMBER :=0;
   group_id_         VARCHAR2(20);
   code_part_value_  VARCHAR2(20);
   
   CURSOR get_upd_accnt(group_id_ VARCHAR2) IS
      SELECT *
         FROM account
         WHERE company   = company_
         AND code_part   = code_part_
         AND accnt_group = group_id_
         AND ((selected_option_ IS NOT NULL) AND 
               ((selected_option_ = 1 AND master_com_code_part_value IS NULL) OR (selected_option_ = 2)));   
BEGIN   
   Utility_SYS.Tokenize(group_account_list_, ';', item_list_, item_count_);
   
   IF (group_account_list_ IS NOT NULL) THEN
      WHILE (item_index_ < item_count_) LOOP
         item_index_ := item_index_+1;
         
         group_id_         := SUBSTR(item_list_(item_index_),1,Instr(item_list_(item_index_),'^')-1);
         code_part_value_  := SUBSTR(item_list_(item_index_),Instr(item_list_(item_index_),'^')+1); 
         
         IF (code_part_value_ IS NOT NULL) THEN 
            FOR rec_ IN get_upd_accnt(group_id_) LOOP
               Account_API.Upd_Master_Company_Account( rec_.company, rec_.account, code_part_value_);
            END LOOP;
         END IF;
      END LOOP;   
   END IF;
END Update_Master_Com_Code_Part;

PROCEDURE Remove_Mc_Account(
   company_ IN VARCHAR2)
IS    
   CURSOR get_groups IS
      SELECT * 
      FROM account_group_tab
      WHERE company = company_;
BEGIN
   FOR newrec_ IN get_groups LOOP
      newrec_.def_master_company_accnt := NULL;
      Modify___(newrec_);
   END LOOP;   
END Remove_Mc_Account;

FUNCTION Check_Curr_Ball_Exist(
   company_ IN VARCHAR2) RETURN VARCHAR2
IS
   temp_       NUMBER;
   check_val_  VARCHAR2(5) := 'TRUE';
   CURSOR check_curr_bal IS
      SELECT 1 
      FROM   accounting_code_part_tab 
      WHERE  company         = company_
      AND code_part_function = 'CURR';
BEGIN
   OPEN check_curr_bal;
   FETCH check_curr_bal INTO temp_;
   IF(check_curr_bal%NOTFOUND)THEN
      CLOSE check_curr_bal;
      check_val_ := 'FALSE';
      RETURN check_val_;
   END IF;
   
   CLOSE check_curr_bal;
   RETURN check_val_;  
END Check_Curr_Ball_Exist;

