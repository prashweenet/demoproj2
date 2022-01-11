-----------------------------------------------------------------------------
--
--  Logical unit: CombControlType
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  000214  SaCh     Created.
--  000314  SaCh     Corrected Bug # 36712.
--  000316  SaCh     Corrected Bug # 36724.
--  000329  SaCh     Corrected Bug # 70464.
--  000330  SaCh     Corrected Bug # 70484.
--  000512  Bren     Added procedure Validate_Comb_Control_Type__.
--  000912  HiMu     Added General_SYS.Init_Method
--  001004  prtilk   BUG # 15677  Checked General_SYS.Init_Method
--  010917  LiSv     Bug #21794 Corrected. Removed unused procedures and functions, Cct_Exist, Get_Ctrl_Type_Desc, Get_Module, Get_Company
--                      Is_Comb_Type_Allowed and Is_Cct.
--  020219  Shsalk   Add a check to see CCT is enabled.
--  020628  Hecolk   Bug 29068, Corrected. Added a new function Get_Comb_Control_Type_Desc
--  021008  Gawilk   Added new views COMB_CONTROL_TYPE_ECT and COMB_CONTROL_TYPE_PCT.
--                      Added procedures Make_Company, Copy___, Import___ and Export___.
--  040323  Gepelk   2004 SP1 Merge
--  040623  anpelk   FIPR338A2: Unicode Changes.
--  051017  nalslk   BUG #126895 Removed additional delete stmts from Delete___ mehtod.
--  060607  Rufelk   FIPL614A - Modified the places where hardcoded control types were used.
--  061215  GaDaLK   B140017 changed COMB_CONTROL_TYPE, Get_Comb_Type_Info()
--  131031  Umdolk   PBFI-1930, Refactoring
--  181823  Nudilk   Bug 143758, Corrected.
--  190522  Dakplk  Bug 147872, Modified Copy_To_Companies__.
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------

@Override
PROCEDURE Check_Delete___ (
   remrec_ IN COMB_CONTROL_TYPE_TAB%ROWTYPE )
IS
   check_flag_   VARCHAR2(5);
BEGIN
   IF (App_Context_Sys.Find_Value(lu_name_||'.copy_to_company_', 'FALSE') != 'TRUE') THEN
      IF (Company_Basic_Data_Window_API.Check_Copy_From_Company(remrec_.company, lu_name_)) THEN
         Error_SYS.Record_General(lu_name_, 'NODIRECTREMOVE: A record cannot be removed as :P1 window has been set up for copying data only from source company in Basic Data Synchronization window.', Basic_Data_Window_API.Get_Window(lu_name_));
      END IF;
   END IF;  
   check_flag_ := Posting_Ctrl_API.Is_Cct_Used(remrec_.company, remrec_.comb_control_type, remrec_.posting_type);
   IF (check_flag_ = 'TRUE') THEN
      Error_SYS.Record_General(lu_name_, 'CCTISUSED: Combination control type :P1 is used in posting type :P2 in posting control. First delete or change the posting type.', remrec_.comb_control_type, remrec_.posting_type);
   END IF;
   super(remrec_);
END Check_Delete___;

@Override
PROCEDURE Check_Common___ (
   oldrec_ IN     comb_control_type_tab%ROWTYPE,
   newrec_ IN OUT comb_control_type_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
   ctrl_type1_category_ VARCHAR2(20);
   ctrl_type2_category_ VARCHAR2(20);
BEGIN
   IF (App_Context_Sys.Find_Value(lu_name_||'.copy_to_company_', 'FALSE') != 'TRUE') THEN
      IF (Company_Basic_Data_Window_API.Check_Copy_From_Company(newrec_.company, lu_name_)) THEN
         Error_SYS.Record_General(lu_name_, 'NODIRECTINSERT: A record cannot be entered/modified as :P1 window has been set up for copying data only from source company in Basic Data Synchronization window.', Basic_Data_Window_API.Get_Window(lu_name_));
      END IF;
   END IF;   
   IF (indrec_.comb_module) THEN
      indrec_.comb_module := FALSE;
   END IF;   
   IF (indrec_.module1) THEN
      indrec_.module1 := FALSE;
   END IF; 
   IF (indrec_.module2) THEN
      indrec_.module2 := FALSE;
   END IF;   
   
   -- Get values if not in newrec_
   IF (newrec_.comb_module IS NULL) THEN
      newrec_.comb_module := Posting_Ctrl_Posting_Type_API.Get_Module(newrec_.posting_type);
   END IF;
   
   super(oldrec_, newrec_, indrec_, attr_);
   
   POSTING_CTRL_CONTROL_TYPE_API.Exist(newrec_.control_type1,newrec_.module1);
   POSTING_CTRL_CONTROL_TYPE_API.Exist(newrec_.control_type2,newrec_.module2);
   
   ctrl_type1_category_ := Posting_Ctrl_Control_Type_API.Get_Ctrl_Type_Category_Db(newrec_.control_type1, newrec_.module1);
   ctrl_type2_category_ := Posting_Ctrl_Control_Type_API.Get_Ctrl_Type_Category_Db(newrec_.control_type2, newrec_.module2);

   IF (NOT (ctrl_type1_category_ IN ('ORDINARY', 'SYSTEM_DEFINED') AND ctrl_type2_category_ IN ('ORDINARY', 'SYSTEM_DEFINED'))) THEN
      Error_SYS.Record_General(lu_name_, 'NOTALLOWED: Only the Control Types of :P1 and :P2 categories are allowed for combinations', Ctrl_Type_Category_API.Decode('ORDINARY'), Ctrl_Type_Category_API.Decode('SYSTEM_DEFINED'));
   END IF;
   
   
   Posting_Ctrl_Allowed_Comb_API.Check_Allowed_For_Ctrl_Type_(newrec_.posting_type , newrec_.control_type1 );
   Posting_Ctrl_Allowed_Comb_API.Check_Allowed_For_Ctrl_Type_(newrec_.posting_type , newrec_.control_type2 );
   
END Check_Common___;


@Override
PROCEDURE Check_Insert___ (
   newrec_ IN OUT comb_control_type_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS

   control_type1_       VARCHAR2(10);
   control_type2_       VARCHAR2(10);
   comb_type_exist_     VARCHAR2(10);
BEGIN   
   -- Get values if not in newrec_   
   IF (newrec_.module1 IS NULL) THEN
      newrec_.module1 := Posting_Ctrl_Control_Type_API.Get_Control_Type_Module(newrec_.control_type1);
   END IF;
   IF (newrec_.module2 IS NULL) THEN
      newrec_.module2 := Posting_Ctrl_Control_Type_API.Get_Control_Type_Module(newrec_.control_type2);
   END IF;   
   
   super(newrec_, indrec_, attr_);
   
   Validate_Comb_Control_Type__ (control_type1_, control_type2_, comb_type_exist_, newrec_.company, newrec_.comb_control_type);

   IF (comb_type_exist_ = 'YES') THEN
      IF (newrec_.control_type1 != control_type1_ ) THEN
         Error_SYS.Record_General(lu_name_, 'VALCTRTYPE1: Control Type 1 should be :P1 as Combination Control Type :P2 already exists',control_type1_,newrec_.comb_control_type);
      END IF;
      IF (newrec_.control_type2 != control_type2_ ) THEN
         Error_SYS.Record_General(lu_name_, 'VALCTRTYPE2: Control Type 2 should be :P1 as Combination Control Type :P2 already exists',control_type2_,newrec_.comb_control_type);
      END IF;
   END IF;

   IF (Posting_Ctrl_Control_Type_API.Check_Exist(newrec_.comb_control_type)) THEN
      Error_SYS.Record_General(lu_name_, 'COMBEXIST: Combination Control Type :P1 already exists as a Control Type.',newrec_.comb_control_type);
   END IF;

   IF (newrec_.control_type1 = newrec_.control_type2) THEN
      Error_SYS.Record_General(lu_name_, 'CTRTYPESEQUAL: Two different control types must be selected for combination');
   END IF;
       
   IF (Posting_Ctrl_Posting_Type_API.Cct_Enabled(newrec_.posting_type) = 'FALSE') THEN
      Error_SYS.Record_General(lu_name_, 'POSTYPNOTALO: Posting Type :P1 is not allowed to use in Combination Control Types', newrec_.posting_type);
   END IF;
END Check_Insert___;


@Override
PROCEDURE Check_Update___ (
   oldrec_ IN     comb_control_type_tab%ROWTYPE,
   newrec_ IN OUT comb_control_type_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
   check_flag_          VARCHAR2(5);
BEGIN  
   super(oldrec_, newrec_, indrec_, attr_);
      
   IF (oldrec_.control_type1 <> newrec_.control_type1) OR (oldrec_.control_type2 <> newrec_.control_type2) THEN
     check_flag_ := Posting_Ctrl_API.Is_Cct_Used(newrec_.company, newrec_.comb_control_type, newrec_.posting_type);
     IF (check_flag_ = 'TRUE') THEN
        Error_SYS.Record_General(lu_name_, 'CCTISUSED: Combination control type :P1 is used in posting type :P2 in posting control. First delete or change the posting type.', newrec_.comb_control_type, newrec_.posting_type);
     END IF;
   END IF;

   IF (newrec_.control_type1 = newrec_.control_type2) THEN
      Error_SYS.Record_General(lu_name_, 'CTRTYPESEQUAL: Two different control types must be selected for combination');
   END IF;

END Check_Update___;

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
   source_company_         IN VARCHAR2,
   target_company_list_    IN VARCHAR2,
   posting_type_list_      IN VARCHAR2,
   comb_control_type_list_ IN VARCHAR2,
   update_method_list_     IN VARCHAR2,
   log_id_                 IN  NUMBER,
   attr_                   IN VARCHAR2 DEFAULT NULL)
IS
   TYPE comb_control_type IS TABLE OF comb_control_type_tab%ROWTYPE INDEX BY BINARY_INTEGER;
   TYPE attr IS TABLE OF VARCHAR2 (32000) INDEX BY BINARY_INTEGER;                           
   ptr_                    NUMBER;
   ptr1_                   NUMBER;
   ptr2_                   NUMBER;
   i_                      NUMBER;
   update_method_          VARCHAR2(20);
   value_                  VARCHAR2(2000);
   target_company_         comb_control_type_tab.company%TYPE;
   ref_comb_control_type_  comb_control_type;
   ref_attr_               attr;
   attr_value_             VARCHAR2(32000) := NULL;
BEGIN
   ptr_  := NULL;
   ptr1_ := NULL;
   ptr2_ := NULL;

   i_    := 0;
   ptr_  := NULL;
   WHILE Copy_To_Company_Util_API.Get_Next_Record_Sep_Val(value_, ptr_, posting_type_list_) LOOP
      ref_comb_control_type_(i_).posting_type := value_;
      i_ := i_ + 1;
   END LOOP;
   
   i_    := 0;
   ptr_  := NULL;
   WHILE Copy_To_Company_Util_API.Get_Next_Record_Sep_Val(value_, ptr_, comb_control_type_list_) LOOP
      ref_comb_control_type_(i_).comb_control_type := value_;
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
         FOR j_ IN ref_comb_control_type_.FIRST..ref_comb_control_type_.LAST LOOP
            IF (ref_attr_.FIRST IS NOT NULL) THEN
               attr_value_ := ref_attr_(j_);
            END IF;            
            Copy_To_Companies__ (source_company_,  
                                 target_company_,
                                 ref_comb_control_type_(j_).posting_type,      
                                 ref_comb_control_type_(j_).comb_control_type,
                                 update_method_,
                                 log_id_,
                                 attr_value_);
         END LOOP;
      END IF;
   END LOOP;
END Copy_To_Companies_For_Svc___;

-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------

PROCEDURE Validate_Comb_Control_Type__ (
   control_type1_        OUT VARCHAR2,
   control_type2_        OUT VARCHAR2,
   comb_type_exist_      OUT VARCHAR2,
   company_              IN  VARCHAR2,
   comb_control_type_    IN  VARCHAR2 )
IS
   cct_        VARCHAR2(10);
   ct1_        VARCHAR2(10);
   ct2_        VARCHAR2(10);

   CURSOR Get_Control IS
      SELECT Comb_Control_Type, Control_Type1, Control_Type2
        FROM Comb_Control_Type_Tab
       WHERE Company = company_
         AND Comb_Control_Type = comb_control_type_;
BEGIN
   OPEN Get_Control;
   FETCH Get_Control INTO cct_, ct1_, ct2_;
   IF (Get_Control%FOUND) THEN
      comb_type_exist_ := 'YES';
      control_type1_ :=    ct1_;
      control_type2_ :=    ct2_;
   ELSE
      comb_type_exist_ := 'NO';
      control_type1_ :=    NULL;
      control_type2_ :=    NULL;
   END IF;
   CLOSE Get_Control;
END Validate_Comb_Control_Type__;


PROCEDURE Copy_To_Companies__ (
   source_company_    IN VARCHAR2,
   target_company_    IN VARCHAR2,
   posting_type_      IN VARCHAR2,
   comb_control_type_ IN VARCHAR2,
   update_method_     IN VARCHAR2,
   log_id_            IN NUMBER,
   attr_              IN VARCHAR2 DEFAULT NULL)
IS
   source_rec_              comb_control_type_tab%ROWTYPE;
   target_rec_              comb_control_type_tab%ROWTYPE;
   old_target_rec_          comb_control_type_tab%ROWTYPE;
   log_key_                 VARCHAR2(2000);
   log_detail_status_       VARCHAR2(10);  
BEGIN
   source_rec_ := Get_Object_By_Keys___(source_company_, posting_type_, comb_control_type_);
   target_rec_ := source_rec_;
   target_rec_.company := target_company_;
   App_Context_Sys.Set_Value(lu_name_||'.copy_to_company_', 'TRUE');
   old_target_rec_ := Get_Object_By_Keys___(target_company_, posting_type_, comb_control_type_);
   log_key_ := posting_type_ || '^' || comb_control_type_;
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
      Raise_Record_Not_Exist___(target_company_, posting_type_, comb_control_type_);
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
   ptr_                    NUMBER;
   name_                   VARCHAR2(200);
   value_                  VARCHAR2(32000);
   company_                VARCHAR2(100);
   target_company_list_    VARCHAR2(32000);
   posting_type_list_      VARCHAR2(32000);   
   comb_control_type_list_ VARCHAR2(32000);
   update_method_list_     VARCHAR2(32000);
   copy_type_              VARCHAR2(100);
   attr1_                  VARCHAR2(32000);
BEGIN
   ptr_ := NULL;
   WHILE (Client_SYS.Get_Next_From_Attr(attr_, ptr_, name_, value_)) LOOP
      IF (name_ = 'SOURCE_COMPANY') THEN
         company_ := value_;
      ELSIF (name_ = 'TARGET_COMPANY_LIST') THEN
         target_company_list_ := value_;
      ELSIF (name_ = 'POSTING_TYPE_LIST') THEN
         posting_type_list_ := value_;
      ELSIF (name_ = 'COMB_CONTROL_TYPE_LIST') THEN
         comb_control_type_list_ := value_;         
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
                      posting_type_list_,
                      comb_control_type_list_,
                      update_method_list_,
                      copy_type_,
                      attr1_);
END Copy_To_Companies_;

PROCEDURE Copy_To_Companies_ (
   source_company_         IN VARCHAR2,
   target_company_list_    IN VARCHAR2,
   posting_type_list_      IN VARCHAR2,
   comb_control_type_list_ IN VARCHAR2,
   update_method_list_     IN VARCHAR2,
   copy_type_              IN VARCHAR2,
   attr_                   IN VARCHAR2 DEFAULT NULL)
IS
   TYPE comb_control_type IS TABLE OF comb_control_type_tab%ROWTYPE INDEX BY BINARY_INTEGER;
   TYPE attr IS TABLE OF VARCHAR2 (32000) INDEX BY BINARY_INTEGER;                           
   ptr_                    NUMBER;
   ptr1_                   NUMBER;
   ptr2_                   NUMBER;
   i_                      NUMBER;
   update_method_          VARCHAR2(20);
   value_                  VARCHAR2(2000);
   target_company_         comb_control_type_tab.company%TYPE;
   ref_comb_control_type_  comb_control_type;
   ref_attr_               attr;
   log_id_                 NUMBER;
   attr_value_             VARCHAR2(32000) := NULL;
BEGIN
   ptr_  := NULL;
   ptr1_ := NULL;
   ptr2_ := NULL;

   i_    := 0;
   ptr_  := NULL;
   WHILE Copy_To_Company_Util_API.Get_Next_Record_Sep_Val(value_, ptr_, posting_type_list_) LOOP
      ref_comb_control_type_(i_).posting_type := value_;
      i_ := i_ + 1;
   END LOOP;
   
   i_    := 0;
   ptr_  := NULL;
   WHILE Copy_To_Company_Util_API.Get_Next_Record_Sep_Val(value_, ptr_, comb_control_type_list_) LOOP
      ref_comb_control_type_(i_).comb_control_type := value_;
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
         FOR j_ IN ref_comb_control_type_.FIRST..ref_comb_control_type_.LAST LOOP
            IF (ref_attr_.FIRST IS NOT NULL) THEN
               attr_value_ := ref_attr_(j_);
            END IF;            
            Copy_To_Companies__ (source_company_,  
                                 target_company_,
                                 ref_comb_control_type_(j_).posting_type,      
                                 ref_comb_control_type_(j_).comb_control_type,
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

PROCEDURE Get_Control_Type1_Type2 (
   control_type1_        OUT VARCHAR2,
   control_type2_        OUT VARCHAR2,
   company_              IN  VARCHAR2,
   posting_type_         IN  VARCHAR2,
   comb_control_type_    IN  VARCHAR2 )
IS
   CURSOR Get_Type IS
      SELECT control_type1, control_type2
        FROM Comb_Control_Type_Tab
       WHERE company = company_
         AND posting_type = posting_type_
         AND comb_control_type = comb_control_Type_;
BEGIN

   OPEN Get_Type;
   FETCH Get_Type INTO control_type1_, control_type2_;
   CLOSE Get_Type;
END Get_Control_Type1_Type2; 

FUNCTION Get_Control_Type1_Desc(
   company_              IN  VARCHAR2,
   posting_type_         IN  VARCHAR2,
   comb_control_type_    IN  VARCHAR2) RETURN VARCHAR2
IS
   control_type1_     VARCHAR2(10);
   module1_           VARCHAR2(10);
   
   CURSOR Get_Type1 IS
      SELECT control_type1,module1
        FROM Comb_Control_Type_Tab
       WHERE company             = company_
         AND posting_type        = posting_type_
         AND comb_control_type   = comb_control_Type_;
BEGIN
   OPEN Get_Type1;
   FETCH Get_Type1 INTO control_type1_,module1_;
   CLOSE Get_Type1; 
   
   RETURN Posting_Ctrl_Control_Type_API.Get_Description(control_type1_,module1_,company_);
END Get_Control_Type1_Desc;


FUNCTION Get_Control_Type2_Desc(
   company_              IN  VARCHAR2,
   posting_type_         IN  VARCHAR2,
   comb_control_type_    IN  VARCHAR2) RETURN VARCHAR2
IS
   control_type2_     VARCHAR2(10);
   module2_           VARCHAR2(10);
   
   CURSOR Get_Type1 IS
      SELECT control_type2,module2
        FROM Comb_Control_Type_Tab
       WHERE company             = company_
         AND posting_type        = posting_type_
         AND comb_control_type   = comb_control_Type_;
BEGIN
   OPEN Get_Type1;
   FETCH Get_Type1 INTO control_type2_,module2_;
   CLOSE Get_Type1; 
   
   RETURN Posting_Ctrl_Control_Type_API.Get_Description(control_type2_,module2_,company_);
END Get_Control_Type2_Desc;

@UncheckedAccess
PROCEDURE Get_Comb_Type_Info (
   control_type1_          OUT VARCHAR2,
   control_type2_          OUT VARCHAR2,
   control_type1_desc_     OUT VARCHAR2,
   control_type2_desc_     OUT VARCHAR2,
   control_type1_module_   OUT VARCHAR2,
   control_type2_module_   OUT VARCHAR2,
   company_                IN  VARCHAR2,
   posting_type_           IN  VARCHAR2,
   comb_control_type_      IN  VARCHAR2 )
IS
   CURSOR Comb_Type_Info_ IS
      SELECT   Control_Type1, Control_Type2, Module1, Module2
        FROM   Comb_Control_Type
       WHERE   company = company_
         AND   posting_type = posting_type_
         AND   comb_control_type = comb_control_Type_;

BEGIN
   OPEN Comb_Type_Info_;
   FETCH Comb_Type_Info_ INTO control_type1_, control_type2_, control_type1_module_, control_type2_module_;
   Posting_Ctrl_Control_Type_API.Get_Description(control_type1_desc_, control_type1_, control_type1_module_, company_);
   Posting_Ctrl_Control_Type_API.Get_Description(control_type2_desc_, control_type2_, control_type2_module_, company_);
   CLOSE Comb_Type_Info_;
END Get_Comb_Type_Info;


PROCEDURE Remove_Comb_Control_Type (
   company_                IN VARCHAR2,
   posting_type_           IN VARCHAR2,
   comb_control_type_      IN VARCHAR2 )
IS
   comb_ctrl_exist_        NUMBER;
   CURSOR check_rec IS
      SELECT 1
      FROM   comb_control_type_tab
      WHERE  company           = company_
      AND    posting_type      = posting_type_
      AND    comb_control_type = comb_control_type_;

BEGIN
   OPEN check_rec;
   FETCH check_rec INTO comb_ctrl_exist_;
   IF check_rec%FOUND THEN
      CLOSE check_rec;
      DELETE FROM comb_control_type_tab
      WHERE  company           = company_
      AND    posting_type      = posting_type_
      AND    comb_control_type = comb_control_type_;
   ELSE
      CLOSE check_rec;
   END IF;
END Remove_Comb_Control_Type;

PROCEDURE Copy_To_Companies_For_Svc (
   attr_              IN  VARCHAR2,
   run_in_background_ IN  BOOLEAN,
   log_id_            IN  NUMBER DEFAULT NULL)
IS
   ptr_                    NUMBER;
   name_                   VARCHAR2(200);
   value_                  VARCHAR2(32000);
   source_company_         VARCHAR2(100);
   posting_type_list_      VARCHAR2(2000);
   comb_control_type_list_ VARCHAR2(2000);
   target_company_list_    VARCHAR2(2000);
   update_method_list_     VARCHAR2(2000);
   attr1_                  VARCHAR2(32000);
   run_in_background_attr_ VARCHAR2(32000);
BEGIN
   IF (run_in_background_) THEN
      run_in_background_attr_ := attr_;
      Transaction_SYS.Deferred_Call('Comb_Control_Type_API.Copy_To_Companies_', run_in_background_attr_, Language_SYS.Translate_Constant(lu_name_, 'COPYDATA: Copy Basic Data')); 
   ELSE
      ptr_ := NULL;
      WHILE (Client_SYS.Get_Next_From_Attr(attr_, ptr_, name_, value_)) LOOP
         IF (name_ = 'SOURCE_COMPANY') THEN
            source_company_ := value_;
         ELSIF (name_ = 'TARGET_COMPANY_LIST') THEN
            target_company_list_ := value_;
         ELSIF (name_ = 'POSTING_TYPE_LIST') THEN
            posting_type_list_ := value_;
         ELSIF (name_ = 'COMB_CONTROL_TYPE_LIST') THEN
            comb_control_type_list_ := value_;         
         ELSIF (name_ = 'UPDATE_METHOD_LIST') THEN
            update_method_list_ := value_;
         ELSIF (name_ = 'ATTR') THEN
            attr1_ := value_||chr(30)||substr(attr_, ptr_,length(attr_)-1);
         END IF;
      END LOOP;
      Copy_To_Companies_For_Svc___(source_company_,
                                  target_company_list_,
                                  posting_type_list_,
                                  comb_control_type_list_,
                                  update_method_list_,
                                  log_id_,
                                  attr1_);
   END IF;
END Copy_To_Companies_For_Svc;

FUNCTION Get_Control_Type(
   company_              IN  VARCHAR2,
   posting_type_         IN  VARCHAR2,
   comb_control_type_    IN  VARCHAR2,
   control_type_no_      IN NUMBER) RETURN VARCHAR2
IS
   control_type1_    VARCHAR2(20);
   control_type2_    VARCHAR2(20);
   return_ctrl_type_ VARCHAR2(20);   
BEGIN
   Comb_Control_Type_API.Get_Control_Type1_Type2(  control_type1_,
                                                   control_type2_,
                                                   company_,
                                                   posting_type_,
                                                   comb_control_type_);
   IF (control_type_no_ = 1) THEN
      return_ctrl_type_ := control_type1_;
   ELSE
      return_ctrl_type_ := control_type2_;
   END IF;
   RETURN return_ctrl_type_;                                                   
END Get_Control_Type;

FUNCTION Get_Spec_Module(
   company_             IN  VARCHAR2,
   posting_type_        IN  VARCHAR2,
   comb_control_type_   IN  VARCHAR2,
   module_type_no_      IN  NUMBER) RETURN VARCHAR2
IS
   module1_   VARCHAR2(20);
   module2_   VARCHAR2(20);
   CURSOR get_module IS
      SELECT module1, module2
      FROM   comb_control_type
      WHERE  company           = company_
      AND    posting_type      = posting_type_
      AND    comb_control_type = comb_control_type_;   
BEGIN
   OPEN  get_module;
   FETCH get_module INTO module1_, module2_;
   CLOSE get_module;
   IF (module_type_no_ = 1) THEN
      RETURN module1_;
   ELSE 
      RETURN module2_;
   END IF;   
   RETURN NULL;
END Get_Spec_Module;
