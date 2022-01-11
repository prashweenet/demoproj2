-----------------------------------------------------------------------------
--
--  Logical unit: CodeI
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  960404  MIJO   Created.
--  980708  Kanchi Modified to accomadate codepart 'I' functionality  through
--                 this LU.
--                 Views from Accounting_code_Part_Value were copied. And as for the start
--                 only the public, private, protected, implementation functions/procedures
--                 were copied from accounting_code_part_Value.
--                 Function calls to functions/procedures of  accounting_code_part_Value are
--                 directed to this CodeI LU:s copied functions/procedures.
--  980916  Ruwan  Removed the Get_Description overloaded function(Bug ID:4973)
--  980921  Bren   Master Slave Connection
--                 Added Send_Code_i_Info___, Send_Code_i_Info_Delete___,
--                 Send_Code_i_Info_Modify___, Receive_Code_i_Info___
--  990713  Uma    Modified with respect to new template
--  000119  Uma    Global Date Definition.
--  000908  HiMu   Added General_SYS.Init_Method
--  001004  prtilk BUG # 15677  Checked General_SYS.Init_Method
--  010221  ToOs   Bug # 20177 Added Global Lu constants for check for transaction_sys calls
--  010410  JeGu   Bug #21018 Changed some functions/procedures wich are common to all codepart-LU's
--                 This functions/procedures now calls Accounting_Code_Part_Value_API
--  010510  JeGu   Bug #21705 Implementation New Dummyinterface
--                 Changed Insert__ RETURNING rowid INTO objid_
--  010531  Bmekse Removed methods used by the old way for transfer basic data from
--                 master to slave (nowdays is Replication used instead)
--  010619  LiSv   For new Create Company concept added new view code_i_ect and code_i_pct.
--                 Added procedures Make_Company, Copy___, Import___, Export___
--  020102  THSRLK IID 20001 Enhancement of Update Company. Changes inside make_company method
--                 Changed Import___, Export___ and Copy___ methods to use records
--  020208  MaNi   Company Translation ( Enterp_Comp_Connect_V160_API )
--  020309  Shsalk Call Id 76915 Corrected.
--  021002  Nimalk Removed usage of the view Company_Finance_Auth in CODE_I,CODE_I_PCT view
--                 and replaced by view Company_Finance_Auth1 using EXISTS caluse instead of joins
--  021031  ovjose IID Glob06. Added column description to accounting_code_part_value_tab.
--  030102  dagalk Merge bugs from SP3 .
--  030731  prdilk SP4 Merge.
--  030901  Brwelk Patch Merge. LCS Bug 38625. Changed Check_Delete_Allowed.
--  040623  anpelk FIPR338A2: Unicode Changes.
--  040723  Gawilk FIPR307A: Added view CODE_I_LOV
--  050228  nsillk Merged Bug 42667.
--  050321  upunlk  LCS Merge 47814 - Changed the valid_until date of the method Copy().
--  051013  Shsalk Removed the view CODE_I_LOV.
--  051024  Nsillk LCS Merge 52983,Recorrected.
--  051229  Nsillk LCS Merge (54796/54798)
--  060208  Maselk B132592 - Modified Unpack_Check_Insert___(),import___().
--  060213  Nugalk LCS Bug 55795, Merged.
--  060215  Nsillk Changed the size of sort_value to 20 in view comments.
--  060218  Gawilk Modified the key string to AccountingCodePartValue
--  061019  GaDaLK FIPL659 Added Get_Control_Type_Value_Desc
--  090727  WAPELK   Bug Id 84476, Assign null to parent code parts when creating a new company/template 
--                   from consolidated company. corrected in import___() and copy___() methods.
--  090810  Nirplk Bug 83061, Corrected in Modify_Code_Part_Value 
--  091022  AJPELK EAST-218 , in ref, code_part replaced with cons_code_part since code_part doest exist
--  100304  Nsillk EAFH-2371, Modified method Copy
--  110322  DIFELK RAVEN-1930, modifications done to Check_Delete___ and removed unused procedure Check_Delete_Allowed_Parent___
--  110826  MAAYLK FIDEAGLE-306 LCS Merge 95982, Allowed to import and export codeparts as long as they are not connected to Project Accounting or Fixass Accounting.
--  120219  GAWILK SFI-1578, Applied the patch 100077.
--  121204   Maaylk PEPA-183, Removed global variables
--  121224  Mawelk   Bug Id 106985 Fixed.
--  131205  Janblk PBFI-1987, Refactoring and Split  CodeH.entit
--  140904  Mawelk  PRFI-1768  (LCS Bug Id 117967) Fixed
--  150119  PRatlk  PRFI-4482  Added validation to check for '^' sign value.
--  190522  Dakplk  Bug 147872, Modified Copy_To_Companies__.
--  200904  Jadulk  FISPRING20-6695, Removed CONACC related obsolete component logic.
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------

pc_code_part_             CONSTANT VARCHAR2(1)  := 'I';


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------
@Override
PROCEDURE Raise_Record_Not_Exist___ (
   company_ IN VARCHAR2,
   code_i_ IN VARCHAR2 )
IS
   code_part_name_      Accounting_Code_Part_Tab.description%TYPE;
BEGIN
   code_part_name_ := Accounting_Code_Parts_API.Get_Name(company_, 'I');
   Error_SYS.Record_General('CodeB','NOTEXTCODEB: The :P2 code part value :P1 does not exists.', code_i_ ,code_part_name_ );
   super(company_, code_i_);

END Raise_Record_Not_Exist___;


@Override
PROCEDURE Import___ (
   crecomp_rec_ IN     Enterp_Comp_Connect_V170_API.Crecomp_Lu_Public_Rec )
IS
   msg_                    VARCHAR2(2000);
   code_part_function_db_  VARCHAR2(6);
   run_crecomp_            BOOLEAN := FALSE;
   records_exists_         BOOLEAN := FALSE;

   CURSOR get_data IS
      SELECT C1, D1, D2, N1,
             C2, C3, C4
      FROM   create_company_template_pub src
      WHERE  component = 'ACCRUL'
      AND    lu    = lu_name_
      AND    template_id = crecomp_rec_.template_id
      AND    version     = crecomp_rec_.version
      AND NOT EXISTS (SELECT 1
                      FROM ACCOUNTING_CODE_PART_VALUE_TAB dest
                      WHERE dest.company = crecomp_rec_.company
                      AND dest.code_part = pc_code_part_
                      AND dest.code_part_value = src.c2);
BEGIN
   run_crecomp_ := Check_If_Do_Create_Company___(crecomp_rec_);

   -- Check if the code_part in new company is using some code part function.
   code_part_function_db_ := Accounting_Code_Part_Value_API.Get_Code_Part_Function__(crecomp_rec_.company,pc_code_part_);

   IF ( run_crecomp_ ) THEN
      FOR rec_ IN get_data LOOP
         records_exists_ := TRUE;
         EXIT;
      END LOOP;
      IF records_exists_ AND code_part_function_db_ NOT IN ('CURR', 'ELIM', 'INTERN', 'NOFUNC') THEN
         Error_SYS.Record_General('CodeI','FUNCUSED: Can not insert values for Code part :P1 since the code '||
                                  'part has code part values', pc_code_part_);
      ELSIF NOT records_exists_ THEN
         msg_ := language_sys.translate_constant(lu_name_, 'NODATAFOUND: No Data Found');
         Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'CODE_I_API', 'CreatedSuccessfully', msg_);
      ELSE
         super(crecomp_rec_);
      END IF;
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      msg_ := SQLERRM;
      Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'CODE_I_API', 'Error', msg_);
      Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'CODE_I_API', 'CreatedWithErrors');
END Import___;

@Override
PROCEDURE Import_Assign___ (
   newrec_      IN OUT accounting_code_part_value_tab%ROWTYPE,
   crecomp_rec_ IN     Enterp_Comp_Connect_V170_API.Crecomp_Lu_Public_Rec,
   pub_rec_     IN     Create_Company_Template_Pub%ROWTYPE )
IS
BEGIN
   super(newrec_, crecomp_rec_, pub_rec_);
   newrec_.code_part             := pc_code_part_;
   newrec_.valid_from            := crecomp_rec_.valid_from;
   IF ( newrec_.description IS NULL ) THEN
      newrec_.description := newrec_.code_part_value;
   END IF;
END Import_Assign___;

@Override
PROCEDURE Copy___ (
   crecomp_rec_ IN     Enterp_Comp_Connect_V170_API.Crecomp_Lu_Public_Rec )
IS
   msg_                    VARCHAR2(2000);
   code_part_function_db1_ VARCHAR2(6);
   code_part_function_db2_ VARCHAR2(6);
   run_crecomp_            BOOLEAN := FALSE;
   records_exists_         BOOLEAN := FALSE;
 
   CURSOR get_data IS
      SELECT code_part, code_part_value, valid_until, accounting_text_id, text, description
      FROM   ACCOUNTING_CODE_PART_VALUE_TAB src
      WHERE  company = crecomp_rec_.old_company
      AND    code_part = pc_code_part_
      AND NOT EXISTS (SELECT 1
                      FROM ACCOUNTING_CODE_PART_VALUE_TAB dest
                      WHERE dest.company = crecomp_rec_.company
                      AND dest.code_part = pc_code_part_
                      AND dest.code_part_value = src.code_part_value);
BEGIN
   run_crecomp_ := Check_If_Do_Create_Company___(crecomp_rec_);

   -- Check if the code_part from company which copying from is using some code part function.
   code_part_function_db1_ := Accounting_Code_Part_Value_API.Get_Code_Part_Function__(crecomp_rec_.old_company, pc_code_part_);
   -- Check if the code_part in new company is using some code part function.
   code_part_function_db2_ := Accounting_Code_Part_Value_API.Get_Code_Part_Function__(crecomp_rec_.company, pc_code_part_);

   IF ( run_crecomp_ ) THEN
      FOR rec_ IN get_data LOOP
         records_exists_ := TRUE;
         EXIT;
      END LOOP;
      IF records_exists_ AND code_part_function_db1_ NOT IN ('CURR', 'ELIM', 'INTERN', 'NOFUNC') THEN
         Error_SYS.Record_General('CodeI','FUNCUSED1: Can not copy Code part :P1 since the code part in the source company :P2'||
                                  ' has code part values',
                                 pc_code_part_, crecomp_rec_.old_company);
      ELSIF  records_exists_ AND code_part_function_db2_ NOT IN ('CURR', 'ELIM', 'INTERN', 'NOFUNC') THEN
         Error_SYS.Record_General('CodeI','FUNCUSED2: Can not copy Code part :P1 since the code part in company :P2'||
                                  ' has code part values',
                                 pc_code_part_, crecomp_rec_.company);
      ELSE
         super(crecomp_rec_);
      END IF;
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      msg_ := SQLERRM;
      Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'CODE_I_API', 'Error', msg_);
      Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'CODE_I_API', 'CreatedWithErrors');
END Copy___;

@Override
PROCEDURE Copy_Assign___ (
   newrec_      IN OUT accounting_code_part_value_tab%ROWTYPE,
   crecomp_rec_ IN     Enterp_Comp_Connect_V170_API.Crecomp_Lu_Public_Rec,
   oldrec_      IN     accounting_code_part_value_tab%ROWTYPE )
IS
BEGIN
   --Add pre-processing code here
   super(newrec_, crecomp_rec_, oldrec_);
   newrec_.code_part             := pc_code_part_;
   newrec_.valid_from            := crecomp_rec_.valid_from;
END Copy_Assign___;

@Override
PROCEDURE Export___ (
   crecomp_rec_ IN     Enterp_Comp_Connect_V170_API.Crecomp_Lu_Public_Rec )
IS
   code_part_function_db_  VARCHAR2(6);
   records_exists_         BOOLEAN := FALSE;

   CURSOR get_data IS
      SELECT text, valid_from, valid_until, accounting_text_id, code_part_value, description
      FROM   ACCOUNTING_CODE_PART_VALUE_TAB
      WHERE  company = crecomp_rec_.company
      AND    code_part = 'I';
BEGIN
   -- Check if the code_part is using some code part function.
   code_part_function_db_ := Accounting_Code_Part_Value_API.Get_Code_Part_Function__(crecomp_rec_.company,pc_code_part_);

   FOR rec_ IN get_data LOOP
      records_exists_ := TRUE;
      EXIT;
   END LOOP;
   IF records_exists_ AND code_part_function_db_ NOT IN ('CURR', 'ELIM', 'INTERN', 'NOFUNC') THEN
      Error_SYS.Record_General('CodeI','FUNCUSED3: Can not export Code part :P1 since the code part in the company :P2'||
                               '  has code part values', pc_code_part_, crecomp_rec_.company);
   ELSE
      super(crecomp_rec_);
   END IF;
END Export___;

@Override
PROCEDURE Prepare_Insert___ (
   attr_  IN OUT VARCHAR2 )
IS
   company_          ACCOUNTING_CODE_PART_VALUE_TAB.company%TYPE;
   valid_until_      Accrul_Attribute_Tab.attribute_value%TYPE;
BEGIN
   company_        := Client_SYS.Get_Item_Value( 'COMPANY', attr_ );
   valid_until_    := Accrul_Attribute_API.Get_Attribute_Value('DEFAULT_VALID_TO');
   super(attr_);
   Client_SYS.Add_To_Attr( 'VALID_FROM',trunc(SYSDATE), attr_);
   Client_SYS.Add_To_Attr( 'VALID_UNTIL',trunc(to_date(valid_until_, 'YYYYMMDD')), attr_);
   Client_SYS.Add_To_Attr( 'CODE_PART','I', attr_ );
END Prepare_Insert___;

@Override
PROCEDURE Delete___ (
   objid_  IN VARCHAR2,
   remrec_ IN ACCOUNTING_CODE_PART_VALUE_TAB%ROWTYPE )
IS
BEGIN
   super(objid_,remrec_);
   -- Remove Structure items
   $IF Component_Genled_SYS.INSTALLED $THEN
      Accounting_Structure_Item_API.Remove_Structure_Items(remrec_.company, remrec_.code_part, remrec_.code_part_value); 
   $END   
END Delete___;


@Override
PROCEDURE Check_Delete___ (
   remrec_   IN ACCOUNTING_CODE_PART_VALUE_TAB%ROWTYPE )
IS
BEGIN
   Accounting_Code_Part_Value_API.Check_Delete(remrec_.company, remrec_.code_part, remrec_.code_part_value);

   super(remrec_);
END Check_Delete___;

@Override
PROCEDURE Unpack___ (
   newrec_ IN OUT accounting_code_part_value_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
BEGIN
   --Add pre-processing code here
   super(newrec_, indrec_, attr_);
   --Add post-processing code here
   -- to support old versions where the code part value was sent in CODE_PART_VALUE
   -- if CODE_E has been unpacked then do not get value from CODE_PART_VALUE since 
   -- it is then passed in CODE_E.
   IF NOT (indrec_.code_part_value) THEN
      IF (Client_SYS.Item_Exist('CODE_PART_VALUE', attr_)) THEN
         newrec_.code_part_value := Client_SYS.Get_Item_Value('CODE_PART_VALUE', attr_);
         indrec_.code_part_value := TRUE;
      END IF;
   END IF;
END Unpack___;

@Override
PROCEDURE Check_Insert___ (
   newrec_ IN OUT accounting_code_part_value_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
   dummy_number_     NUMBER;
BEGIN
   super(newrec_, indrec_, attr_);
   newrec_.code_part := pc_code_part_;
   newrec_.rowtype := 'Code' || pc_code_part_;
   newrec_.sort_value := Accounting_Code_Part_Value_API.Generate_Sort_Value(newrec_.code_part_value);

   Accounting_Code_Parts_API.Get_Max_Number_Of_Char(dummy_number_,
                                                    newrec_.company,
                                                    pc_code_part_);
   IF (Finance_Lib_API.Fin_Length( newrec_.code_part_value) > dummy_number_) THEN
      Error_SYS.Record_General(lu_name_, 'TOOMANYCHARS: Too many characters in code part value');
   END IF;
   
   IF ( Accounting_Code_Parts_API.Is_Code_Used(newrec_.company, pc_code_part_) = 'FALSE') THEN
      Error_SYS.Record_General(lu_name_,
                               'ISNOTUSED: Code part :P1 is not used in define codestring',
                               pc_code_part_);
   END IF;
END Check_Insert___;

@Override 
PROCEDURE Check_Update___ (
   oldrec_ IN     accounting_code_part_value_tab%ROWTYPE,
   newrec_ IN OUT accounting_code_part_value_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
BEGIN
   --Add pre-processing code here
   super(oldrec_, newrec_, indrec_, attr_);
   IF ( Validate_SYS.Is_Changed(NVL(oldrec_.bud_account,'N'), newrec_.bud_account)) THEN
      Accounting_Code_Part_Value_API.Validate_Budget_Value(newrec_);
   END IF;
   --Add post-processing code here
END Check_Update___;

@Override
PROCEDURE Check_Common___ (
   oldrec_ IN     accounting_code_part_value_tab%ROWTYPE,
   newrec_ IN OUT accounting_code_part_value_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
BEGIN
   IF (App_Context_Sys.Find_Value(lu_name_||'.copy_to_company_', 'FALSE') != 'TRUE') THEN
      IF (Company_Basic_Data_Window_API.Check_Copy_From_Company(newrec_.company, lu_name_)) THEN
         Error_SYS.Record_General(lu_name_, 'NODIRECTINSERT: A record cannot be entered/modified as :P1 window has been set up for copying data only from source company in Basic Data Synchronization window.', Basic_Data_Window_API.Get_Window(lu_name_));
      END IF;
   END IF;   
   IF ((INSTR( newrec_.code_part_value,'&') > 0) OR (INSTR( newrec_.code_part_value,'^') > 0) OR (INSTR( newrec_.code_part_value,'''') > 0)) THEN
      Error_SYS.Record_General('CodeI', 'INVCHARACTORS: You have entered an invalid character in this field');
   END IF;
   IF newrec_.bud_account IS NULL THEN
      newrec_.bud_account := 'N';
   END IF;
   super(oldrec_, newrec_, indrec_, attr_);
   
   Check_Valid_From_To(newrec_.company, newrec_.code_part_value, newrec_.valid_from, newrec_.valid_until);

END Check_Common___;

-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------

PROCEDURE Copy_To_Companies__ (
   source_company_ IN VARCHAR2,
   target_company_ IN VARCHAR2,
   code_i_         IN VARCHAR2,
   update_method_  IN VARCHAR2,
   log_id_         IN NUMBER,
   attr_           IN VARCHAR2 DEFAULT NULL)
IS
   source_rec_              accounting_code_part_value_tab%ROWTYPE;
   target_rec_              accounting_code_part_value_tab%ROWTYPE;
   old_target_rec_          accounting_code_part_value_tab%ROWTYPE;
   log_key_                 VARCHAR2(2000);  
   log_detail_status_       VARCHAR2(10);
BEGIN
   log_key_ := code_i_;   
   Accounting_Code_Part_Value_API.Check_Copy_Code_Part_Function(target_company_, 'I');
   source_rec_ := Get_Object_By_Keys___(source_company_, code_i_);
   target_rec_ := source_rec_;
   target_rec_.company := target_company_;
   App_Context_Sys.Set_Value(lu_name_||'.copy_to_company_', 'TRUE');
   old_target_rec_ := Get_Object_By_Keys___(target_company_, code_i_);
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
      Raise_Record_Not_Exist___(target_company_, code_i_);
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
                                                        code_i_,
                                                        code_i_);
   App_Context_Sys.Set_Value(lu_name_||'.copy_to_company_', 'FALSE');
   Copy_Basic_Data_Log_Detail_API.Create_New_Record(log_id_, target_company_, log_key_, log_detail_status_);
EXCEPTION
   WHEN OTHERS THEN
      log_detail_status_ := 'ERROR';
      Copy_Basic_Data_Log_Detail_API.Create_New_Record(log_id_, target_company_, log_key_, log_detail_status_, SQLERRM);
END Copy_To_Companies__;

-------------------- LU SPECIFIC PROTECTED METHODS --------------------------

FUNCTION Validate_Code_Part_ (
   company_ IN VARCHAR2,
   code_i_ IN VARCHAR2,
   date_ IN DATE ) RETURN VARCHAR2
IS
   result_      VARCHAR2(6);
BEGIN
   Validate_Code_Part(result_,company_, code_i_,date_);
   RETURN result_;
END Validate_Code_Part_;


-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

PROCEDURE Check_Delete_Allowed (
   company_     IN VARCHAR2,
   code_i_      IN VARCHAR2 )
IS
BEGIN
   Accounting_Code_Part_Value_API.Check_Delete_Allowed2 (company_,code_i_,'I');
END Check_Delete_Allowed;


PROCEDURE Check_Valid_From_To (
   company_           IN VARCHAR2,
   code_i_            IN VARCHAR2,
   valid_from_        IN DATE,
   valid_to_          IN DATE )
IS
BEGIN
   Accounting_Code_Part_Value_API.Check_Valid_From_To (company_,
                                                       'I',
                                                       code_i_,
                                                       valid_from_,
                                                       valid_to_);
END Check_Valid_From_To;


@UncheckedAccess
FUNCTION Exist_Code_Part_Value (
   company_    IN VARCHAR2 ) RETURN BOOLEAN
IS
BEGIN
   RETURN Accounting_Code_Part_Value_API.Exist_Code_Part_Value (company_,'J');
END Exist_Code_Part_Value;


PROCEDURE Modify_Code_Part_Value (
   attr_  IN VARCHAR2 )
IS
   ptr_              NUMBER;
   name_             VARCHAR2(2000);
   value_            VARCHAR2(2000);
   info_             VARCHAR2(2000);
   new_attr_         VARCHAR2(4000);
   company_          VARCHAR2(20);
   code_part_value_  VARCHAR2(20);
   objid_            VARCHAR2(2000);
   objversion_       VARCHAR2(2000);
   code_part_        Accounting_Code_Part_Value_Tab.code_part%TYPE;   
BEGIN
   Client_SYS.Clear_Attr(new_attr_);
   ptr_ := NULL;
   WHILE (Client_SYS.Get_Next_From_Attr(attr_, ptr_, name_, value_)) LOOP
      IF (name_ = 'COMPANY') THEN
         company_ := value_;
      ELSIF (name_ = 'CODE_PART_VALUE') THEN         -- to be removed [ Move code parts ]
         code_part_value_ := value_;
      ELSIF (name_ = 'CODE_PART') THEN
         code_part_ := value_;
      ELSE
         Client_SYS.Add_To_Attr(name_,value_,new_attr_);
      END IF;
   END LOOP;
   Get_Id_Version_By_Keys___ ( objid_, objversion_, company_, code_part_value_);
   Modify__(info_,objid_,objversion_,new_attr_,'DO');
END Modify_Code_Part_Value;


PROCEDURE New_Code_Part_Value (
   attr_  IN VARCHAR2 )
IS
   info_       VARCHAR2(2000);
   objid_      ROWID;
   objversion_ VARCHAR2(2000);
   new_attr_   VARCHAR2(4000);
BEGIN
   new_attr_ := attr_;
   New__(info_,objid_,objversion_,new_attr_,'DO');
END New_Code_Part_Value;


@UncheckedAccess
FUNCTION Code_Part_Value_Exist (
   company_   IN VARCHAR2,
   code_i_    IN VARCHAR2 ) RETURN VARCHAR2
IS
BEGIN
   RETURN Accounting_Code_Part_Value_API.Code_Part_Value_Exist (company_,'I',code_i_);
END Code_Part_Value_Exist;


PROCEDURE Remove_Code_Part_Value (
   attr_  IN  VARCHAR2 )
IS
   ptr_              NUMBER;
   name_             VARCHAR2(2000);
   value_            VARCHAR2(2000);
   info_             VARCHAR2(2000);
   company_          VARCHAR2(20);
   code_part_value_  VARCHAR2(20);
   objid_            VARCHAR2(2000);
   objversion_       VARCHAR2(2000);
BEGIN
   ptr_ := NULL;
   WHILE (Client_SYS.Get_Next_From_Attr(attr_, ptr_, name_, value_)) LOOP
      IF (name_ = 'COMPANY') THEN
         company_ := value_;
      ELSIF (name_ = 'CODE_PART') THEN
         code_part_value_ := value_;
      ELSIF (name_ = 'CODE_PART_VALUE') THEN      -- to be removed [ Move code parts ]
         code_part_value_ := value_;
      END IF;
   END LOOP;
   Get_Id_Version_By_Keys___ ( objid_, objversion_, company_, code_part_value_);
   Remove__(info_, objid_, objversion_, 'DO');
END Remove_Code_Part_Value;


PROCEDURE Validate_Code_Part (
   result_         OUT VARCHAR2,
   company_     IN     VARCHAR2,
   code_i_      IN     VARCHAR2,
   date_        IN     DATE )
IS
   dummy_              BOOLEAN;
BEGIN
   dummy_ := Validate_Code_Part(company_, code_i_, date_ );
   IF ( dummy_ ) THEN
      result_ := 'TRUE' ;
   ELSE
      result_ := 'FALSE' ;
   END IF;
END  Validate_Code_Part;


@UncheckedAccess
FUNCTION Validate_Code_Part (
   company_       IN VARCHAR2,
   code_i_        IN VARCHAR2,
   date_          IN DATE ) RETURN BOOLEAN
IS
BEGIN
   RETURN Accounting_Code_Part_Value_API.Validate_Code_Part (company_,'I',code_i_,date_);
END Validate_Code_Part;

   
PROCEDURE Get_Control_Type_Value_Desc (
   description_   OUT VARCHAR2,
   company_       IN  VARCHAR2,
   code_part_val_ IN  VARCHAR2)
IS
BEGIN
   description_ := CODE_I_API.Get_Description(company_, code_part_val_);
END Get_Control_Type_Value_Desc;


@UncheckedAccess
FUNCTION Get_Description (
   company_   IN VARCHAR2,
   code_i_    IN VARCHAR2,
   lang_code_ IN VARCHAR2 ) RETURN VARCHAR2
IS
   desc_  VARCHAR2(100);
   CURSOR get_desc IS
      SELECT description
      FROM ACCOUNTING_CODE_PART_VALUE_TAB
      WHERE company = company_
      AND   code_part = 'I'
      AND   code_part_value = code_i_;
BEGIN
   desc_ := substr(Text_Field_Translation_API.Get_Text ( company_, 'CODEI',code_i_, lang_code_),1, 100);
   IF ( desc_ IS NULL ) THEN
      OPEN get_desc;
      FETCH get_desc INTO desc_;
      IF (get_desc%NOTFOUND) THEN
         CLOSE get_desc;
         RETURN (NULL);
      ELSE
         CLOSE get_desc;
         RETURN (desc_ );
      END IF;
   ELSE
      RETURN desc_;
   END IF;
END Get_Description;


PROCEDURE Get_Description (
   description_        IN OUT VARCHAR2,
   company_            IN     VARCHAR2,
   code_i_             IN     VARCHAR2,
   lang_code_          IN     VARCHAR2 DEFAULT NULL) 
IS   
BEGIN
   description_ := Get_Description(company_, code_i_, lang_code_);   
END Get_Description;

PROCEDURE Copy_To_Companies_For_Svc (
   attr_              IN  VARCHAR2,
   run_in_background_ IN  BOOLEAN,
   log_id_            IN  NUMBER DEFAULT NULL)
IS
   new_attr_               VARCHAR2(32000);
   code_part_value_list_   VARCHAR2(2000);
BEGIN
   new_attr_ := attr_;
   Client_SYS.Add_To_Attr('CODE_PART', 'I', new_attr_);
   code_part_value_list_ := Client_SYS.Cut_Item_Value('CODE_I_LIST',  new_attr_);
   Client_SYS.Add_To_Attr('CODE_PART_VALUE_LIST', code_part_value_list_, new_attr_);
   Accounting_Code_Part_Value_API.Copy_To_Companies_For_Svc(new_attr_,run_in_background_,log_id_);
END Copy_To_Companies_For_Svc;
