-----------------------------------------------------------------------------
--
--  Logical unit: PostingCtrl
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  960313  MIJO    Created.
--  970306  MiJo    Added procedure for insert default data into posting control.
--  970404  MiJo    Added procedure Get_code_part.
--  970604  MiJo    Added procedure for modify the module code for one control type.
--  970604  MiJo    Added procedure for remove exiting posting.
--  970625  MiJo    Changed attribute in procedure Modify_Posting_Control.
--  970627  SLKO    Converted to Foundation1 1.2.2d
--  971012  MiJo    Fixed bug 97-0062.
--  971203  JoTh    Bug # 2512 fixed.
--  970627  SLKO    Converted to Foundation1 1.2.2d
--  980204  MALR    Update of Default Data, added procedure ModifyDefDataPostctrl__
--                  and added code in Generate_Default_Data_.
--  980429  THUS    Added one new procedure to validate if account exists
--  981104  JPS     Added new public procedure Get_Control_Type.
--  990416  JPS     Performed Template Changes.(Foundation 2.2.1)
--  990601  JOHW    Extended variable controle_value_ in Build_Codestr_Rec to 50.
--  991220  SaCh    Changed private procedure Load_Codepart_Value.
--  991227  Sach    Removed public procedure Get_Code_Part which supported 7.3.1
--  991227  SaCh    Removed public procedure Get_Control_Type which had parameters
--                  control_type_lu_tab_ IN OUT Ac_Am_Br_API.CtrlTypProdTab,
--                  control_type_tab_    IN OUT Ac_Am_Br_API.CtrlTypTab ...
--  991227  SaCh    Removed public procedure Build_Codestr_Rec which supported 7.3.1
--  000105  SaCh    Added public procedures Get_Code_Part,Get_Control_Type & Build_Codestr_Rec
--  000329  SaCh    Added function Is_Cct_Used in order to correct bug # 70464.
--  000705  LeKa    A521: Added tax_flag.
--  000914  HiMu    Added General_SYS.Init_Method
--  001005  prtilk  BUG # 15677  Checked General_SYS.Init_Method
--  010102  ToOs    Bug # 19003, Added new method Get_Control_Type_Key
--  010417  AjRolk  Bug ID 21343, Added view comment for column Company in ACCRUED_COST_REVENUE(VIEW2)
--  010504  ovjose  Changed call Post_Ctrl_Detail_Def_Api.Override_Default_Data to Posting_Ctrl_Detail_Api.Override_Default_
--                  due to Post_Ctrl_Detail_Def_Api package is obsolete.
--  010531  Bmekse  Removed methods used by the old way for transfer basic data from
--                  master to slave (nowdays is Replication used instead)
--  010611  LiSv    Changes according to new create company concept.
--  010706  LiSv    Removed control of details_exist in Insert_posting_control_detail.
--  011508  SHSALK  Bug # 20886 Fixed, Modified Get_Control_Type to first check the posting_type
--  010912  LiSv    Bug #21794 Corrected. Added combined_control_type.
--  010928  Assalk  Bug # 24853, Moved the check for the details in side the loop.
--  011011  SHSALK  Bug # 25189 Corrected. Added view comments for company in VIEW2.
--  020115  samblk  Bug # 25041 Added VIEW3 and it's view comments. This view was Originally in postctrl.api
--  020128  ovjose  Changed call in views for get descriptions, removed use of create_company_reg_api
--  020208  Asodse  IID 21003 Company Transaltion, Replaced "Text Field Translation"
--  020218  Shsalk  CCT changers Added Set_Cct_Enabled.
--  020523  SUMALK  Bug 29021 Fixed.Changed the length of code_name from 10 to 20.
--  020628  Hecolk  Bug 29068, Corrected. In view POSTING_CTRL_MASTER
--  020705  Jakalk  Bug# 29272 Fixed. Changed the error message to show the control type value.
--  020827  SACHLK  Bug # 32029 - Corrected.
--  021002  Nimalk  Removed usage of the view Company_Finance_Auth in POSTING_CTRL_MASTER,ACCRUED_COST_REVENUE
--                   and POSTING_CTRL view and replaced by view Company_Finance_Auth1 using EXISTS caluse instead of joins
--  021127  ovjose  Glob06. Changed call to get code_name in posting_ctrl_master.
--  030122  GEPELK  BEFI102EC - Added currev_flag attribute in procedure Insert_Posting_Type
--  030815  mgutse  Call 101178 corrected for IID ITFI127N.
--  040329  Gepelk  2004 SP1 Merge.
--  040414  ShSaLk  Touch Down Merge (Bank Reconciliation). 
--  040726  UmDolk  Merged LCS Bug 43962.
--  041109  ShSaLk  Remove of Sync730.api/apy.
--  041217  ASHELK  LCS Bug 47793, Merged.
--  050120  Jakalk  FITH351.Added method Get_Code_Part_Value. 
--  050523  reanpl  FIAD376 Actual Costing - added pc_valid_from column
--  050923  nalslk  Bug 126895, Modify Is_Cct_Used to check only the combined control types.
--  050926  chajlk  LCS merge (52669)
--  060208  Rufelk  LCS-52669 Merge. Removed the PC_VALID_FROM value from the attribute string
--  060208          in the Prepare_Insert___ procedure.
--  060218  Gawilk  Added NOCHECK to view3.
--  060608  Iswalk  FIPL614A, Added ctrl_type_category and removed combined_control_type.
--  060609  Iswalk  FIPL614A, Removed Get_Combined___ and introduced Get_Ctrl_Type_Category___.
--  060612  Iswalk  FIPL614A, Replaced hard coded values AC1, AC2 and C58 with control_type category.
--  060619  Rufelk  FIPL614A - Removed allowed_default and used ctrl_type_category instead.
--  060821  Samwlk  DIPL204A, Added new method Copy_Details_Set_Up.
--  060925  THAYLK  LCS Merge Bug 59300, Added functions Is_Led_Account_Used and Is_Tax_Account_Used
--  061027  Amdilk  LCS Merge 58765, Modified Get_Code_Part to return code_parts only if it's the max date record for
--  061027          the relevent posting type.
--  061208  GaDaLK  B140017 Changes to POSTING_CTRL_MASTER
--  061218  Ranflk  LCS Merge - 61860.  Corrected.
--  070124  Shsalk  Lcs Merge 61873. Added NOCHECK for default_value in POSTING_CTRL_MASTER
--  070321  Shsalk  Lcs Merge 63645, Corrected.Modified Account_Exist.Checked for default_value_no_ct
--  070409  Machlk  Merged Bug 64020, Added new method Get_Default_Value.
--  070416  Shsalk  Lcs Merge 63660, Corrected.Added a new method
--  070507  anpelk  B143263, see the Bug 56554, Added new method Posting_Event_Curr_Rev only for currency revaluation thing
--  070516  Surmlk  Added ifs_assert_safe comment
--  070606  Shsalk  LCS Merge 65575, Corrected. NOCHECK for a view comment on default_value_no_ct in POSTING_CTRL_MASTER.
--  070713  reanpl  Posting_Event_Curr_Rev modified
--  070912  Shsalk  B148647 Made an error message more descriptive.
--  080425  Nirplk  Bug 56554, Corrected the GP9 posting for currency revaluation.
--  080722  Thpelk  Thpelk  Bug 73882, Corrected in Check_Account_Valid_Date___() to raise the error for other posting types.
--  090224  Maaylk  Bug 80804, Removed unnecessary Order By clause
--  090717  ErFelk  Bug 83174, Replaced constant NOCONTRTYP with NOCTRLT in Get_Codepart_Tab__.
--  090810  LaPrlk  Bug 79846, Removed the precisions defined for NUMBER type variables.
--  100215  Jaralk  bug 87618, Corrected. Added new functionality in copy posting control set up,in order to enable users to copy details
--                  from a posting type to another posting type which has a valid from date different to the source posting type
--  110916  Ersruk  Added Get_Control_Type_Key_For_Date() and Posting_Type_Exist_For_Date().
--  100317  AsHelk  EAFH-2555, Removed Method Generate_Default_Data_ since it refers obsolete table Posting_Ctrl_Def_Tab.
--  100423  SaFalk  Modified REF for control_type in POSTING_CTRL and POSTING_CTRL_MASTER.
--  100716  Umdolk  EANE-2936, Reverse engineering - Changed delete_ procedure.
--  110325  DIFELK   RAVEN-1918, modified procedures Get_Override_Rec and Get_Override_Rec_
--  110518  Nudilk   EASTONE-18439, Merged 94453.
--  110523  RUFELK  EASTONE-20712 - Modified Validate_Record___() to use proper validation method for Combination Control types.
--  110805  THPELK  FIDEAGLE-318 : LCS Merge (Bug 95556), Corrected in Modify_Posting_Control() and Remove_Posting_Control().
--  111020  ovjose  Modification to make use of the no_code_part_value attribute on detail levels
--  111123  Swralk  SFI-895, Removed General_SYS.Init statement from FUNCTION Exist_Comb_In_Detail.
--  120228  Pratlk  SFI-2466,New method Remove_Posting_Control_Details added
--  120514  SALIDE   EDEL-698, Added VIEW_AUDIT
--  130425  Ersruk   Bug 108452, added parameter pc_valid_from_  in Get_Code_Part()
--  140303  Mawelk  PBFI-5116 (Lcs Bug Id 114586)
--  140512  PRatlk  PBFI-7439 Sent Correct parameter to Check_Update__.
--  150512  Pimalk  Bug 121560, Added new method Get_Control_Type_For_Date()
--  150609  ShaJLK  Bug 122951, Added new function Check_Control_Type_For_Date
--  151007  chiblk  STRFI-200, New__ changed to New___ in Insert_Posting_Control
--  151007  chiblk  STRFI-200, removed overriden new__ and added overriden insert__
--  151010  chiblk  STRFI-200, changed Get_Ctrl_Type_Category___ return value from client value to database value
--  160704  Savmlk  STRFI-2174, Added Get_Code_Part_Exist___() and removed the sub method Get_Code_Part_Exist_().
--  161017  Chwtlk  STRFI-3528, Merged LCS Bug 131415, Fixed. Added Get_Override_Rec____ and Get_Override_Rec.
--  170104  Maaylk  STRFI-4305, Bug 133001, Added new method called Modify_Postin_Type_Comb_Module() to handle updating of values of comb_module and added 'COMBINATION' in Modify_Posting_Control
--  171003  Chwtlk  STRFI-9971, Merged Bug 137719, Introduced a new method to check whether the Posting Control exists (checked for the Control Type).
--  181823  Nudilk  Bug 143758, Corrected.
--  190205  Bhhilk  Bug 145169, Corrected.
--  190522  Dakplk  Bug 147872, Modified Copy_To_Companies__.
--  190802  Nudilk  Bug 149273, Provided overloaded methods to handle security based on project acess.
--  200701  Tkavlk  Bug 154601, Added Remove_company
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------

TYPE CodePartTab IS TABLE OF VARCHAR2(10)
      INDEX BY BINARY_INTEGER;

TYPE CtrlTypTab IS TABLE OF VARCHAR2(10)
      INDEX BY BINARY_INTEGER;

TYPE CtrlTypLuTab IS TABLE OF VARCHAR2(100)
      INDEX BY BINARY_INTEGER;

TYPE CtrlVALTab IS TABLE OF VARCHAR2(50)
      INDEX BY BINARY_INTEGER;

TYPE ControlTypeTab IS TABLE OF VARCHAR2(10)
      INDEX BY BINARY_INTEGER;

TYPE ControlTypeValueTab IS TABLE OF VARCHAR2(100)
      INDEX BY BINARY_INTEGER;


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------

@Override
PROCEDURE Insert___ (
   objid_         OUT VARCHAR2,
   objversion_    OUT VARCHAR2,
   newrec_     IN OUT posting_ctrl_tab%ROWTYPE,
   attr_       IN OUT VARCHAR2 )
IS
BEGIN

   super(objid_, objversion_, newrec_, attr_);
   Client_SYS.Add_To_Attr('CTRL_TYPE_CATEGORY_DB',newrec_.ctrl_type_category, attr_); 
END Insert___;



PROCEDURE Validate_Record___ (
   newrec_ IN POSTING_CTRL_TAB%ROWTYPE )
IS
   description_     VARCHAR2(200);
   module_          VARCHAR2(20);
   ledg_flag_       VARCHAR2(1);
   tax_flag_        VARCHAR2(1); -- A521
   default_value_   VARCHAR2(20);
BEGIN
   --First validate the control_type
   IF (newrec_.ctrl_type_category = 'COMBINATION') THEN
      Comb_Control_Type_API.Exist(newrec_.company, newrec_.posting_type, newrec_.control_type);
   ELSE
      Posting_Ctrl_Control_Type_API.Exist(newrec_.control_type, newrec_.module);
   END IF;

   IF (newrec_.default_value IS NULL) THEN
      IF (newrec_.ctrl_type_category = 'FIXED') THEN
         Error_SYS.Record_General(lu_name_, 'NO1: Default value must be entered.');
      END IF;
   ELSE
      IF (newrec_.ctrl_type_category = 'PREPOSTING') THEN
         Error_SYS.Record_General(lu_name_, 'NO2: It is not valid to enter default value.');
      END IF;
   END IF;
--

   Posting_Ctrl_Posting_Type_API.Get_Posting_Type_Attri_( description_, module_, ledg_flag_, tax_flag_, newrec_.posting_type );
   
   FOR i_ IN 1..2 LOOP
      IF (i_ = 1) THEN
         default_value_ := newrec_.default_value;
      ELSE
         default_value_ := newrec_.default_value_no_ct;
      END IF;

      IF (default_value_ IS NOT NULL) THEN
         IF (Accounting_Code_Part_Value_API.Is_Budget_Code_Part(newrec_.company, newrec_.code_part, default_value_)) THEN
            IF(newrec_.code_part ='A') THEN
               Account_API.Exist(newrec_.company, default_value_);
               Error_SYS.Record_General(lu_name_, 'BUDACCNT: :P1 is a budget account and not valid for posting type :P2', default_value_,newrec_.posting_type);
            ELSE
               Error_SYS.Record_General(lu_name_, 'BUDCODEPART: :P1 is a Budget/Planning Only code part value and cannot be used in Posting Control.', default_value_);
            END IF;
         END IF;
         IF (newrec_.code_part = 'A') THEN
            IF (ledg_flag_ = 'Y') THEN
               IF (NOT Account_API.Is_Ledger_Account( newrec_.company, default_value_ )) THEN               
                  Error_SYS.Record_General(lu_name_, 'SPECNOLEDGACCNT: :P1 is no ledger account and not valid for posting type :P2', default_value_,newrec_.posting_type);
               END IF;
            ELSIF (tax_flag_ = 'Y') THEN
               IF (NOT Account_API.Is_Tax_Account( newrec_.company, default_value_ )) THEN
                  Error_SYS.Record_General(lu_name_, 'SPECNOTAXACCNT: Account :P1 is no tax account and not valid for posting type :P2', default_value_,newrec_.posting_type);
               END IF;
            ELSIF (Account_API.Is_Stat_Account(newrec_.company, default_value_ )) = 'TRUE' THEN
               Error_SYS.Record_General(lu_name_, 'SPECSTATACC: :P1 is a statistical account and not valid for posting type :P2', default_value_,newrec_.posting_type);
            END IF;
            $IF Component_Fixass_SYS.INSTALLED $THEN
            IF (newrec_.posting_type IN ('FAP74', 'FAP91') AND NOT Acquisition_Account_API.Is_Acquisition_Account(newrec_.company, default_value_)) THEN
               Error_SYS.Record_General(lu_name_, 'NOTACQACCNT: Account :P1 is not an acquisition account and not valid for posting type :P2.', default_value_, newrec_.posting_type);
            END IF;
            $END
         ELSE
            Accounting_Code_Part_Value_API.Exist(newrec_.company, newrec_.code_part, default_value_);
                    
         END IF;
      END IF;
   END LOOP;
END Validate_Record___;


FUNCTION Get_Max_Date___ (
   company_      IN VARCHAR2,
   posting_type_ IN VARCHAR2,
   code_part_    IN VARCHAR2,
   date_         IN DATE ) RETURN DATE
IS
   max_date_            DATE;
   CURSOR get_max_date IS
      SELECT MAX(pc_valid_from)
      FROM   POSTING_CTRL_TAB
      WHERE  company = company_
      AND    posting_type = posting_type_
      AND    code_part = code_part_
      AND    pc_valid_from <= date_;
BEGIN
   OPEN  get_max_date;
   FETCH get_max_date INTO max_date_;
   CLOSE get_max_date;

   RETURN max_date_;
END Get_Max_Date___;


FUNCTION Get_Ctrl_Type_Category___(
   company_        IN VARCHAR2,
   posting_type_   IN VARCHAR2,
   control_type_   IN VARCHAR2,
   code_part_      IN VARCHAR2 ) RETURN VARCHAR2
IS
   CURSOR get_ctrl_type IS
      SELECT ctrl_type_category_db
      FROM   CTRL_TYPE_ALLOWED_VALUE 
      WHERE  company      = company_
      AND    posting_type = posting_type_
      AND    control_type = control_type_
      AND    code_part    = code_part_;
   temp_    VARCHAR2(50);
BEGIN
   OPEN  get_ctrl_type;
   FETCH get_ctrl_type INTO temp_;
   CLOSE get_ctrl_type;
   RETURN temp_;
END Get_Ctrl_Type_Category___;


PROCEDURE Check_Account_Valid_Date___ (
   codestring_rec_ IN OUT Accounting_Codestr_API.CodestrRec,
   company_        IN     VARCHAR2,
   posting_type_   IN     VARCHAR2,
   voucher_date_   IN     DATE )
IS   
   posting_valid_date_ POSTING_CTRL_TAB.pc_valid_from%TYPE;
   
   CURSOR get_valid_date IS 
      SELECT MIN(pc_valid_from)
      FROM POSTING_CTRL_TAB
      WHERE company    = company_
      AND code_part    = 'A'
      AND posting_type = posting_type_;
BEGIN
   IF (codestring_rec_.code_a IS NULL) THEN
      OPEN get_valid_date;
      FETCH get_valid_date INTO posting_valid_date_;
      IF (posting_valid_date_ IS NOT NULL AND posting_valid_date_ > voucher_date_ ) THEN
         CLOSE get_valid_date;
         Error_SYS.Record_General(lu_name_, 'ACCNTNOTVALID: Posting Control Type :P1 has an invalid time interval in company :P2', posting_type_,company_);
      END IF;
      CLOSE get_valid_date;
   END IF;
END Check_Account_Valid_Date___;


@Override
PROCEDURE Prepare_Insert___ (
   attr_ IN OUT VARCHAR2 )
IS
BEGIN
   super(attr_);
   Client_SYS.Add_To_Attr( 'OVERRIDE', Fin_Allowed_API.Decode('N'), attr_ );
   Client_SYS.Add_To_Attr( 'PC_VALID_FROM', SYSDATE, attr_ );   
END Prepare_Insert___;


@Override
PROCEDURE Delete___ (
   objid_  IN VARCHAR2,
   remrec_ IN POSTING_CTRL_TAB%ROWTYPE )
IS
   info_ VARCHAR2(100);
BEGIN
   Posting_Ctrl_Comb_Detail_API.Delete_Comb_Detail( info_, remrec_.company, remrec_.posting_type, remrec_.code_part, remrec_.pc_valid_from );
   super(objid_, remrec_);
END Delete___;


@Override
PROCEDURE Check_Common___ (
   oldrec_ IN     posting_ctrl_tab%ROWTYPE,
   newrec_ IN OUT posting_ctrl_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
BEGIN
   IF (App_Context_SYS.Find_Value(lu_name_||'.copy_to_company_', 'FALSE') != 'TRUE') THEN
      IF (Company_Basic_Data_Window_API.Check_Copy_From_Company(newrec_.company, lu_name_)) THEN
         Error_SYS.Record_General(lu_name_, 'NODIRECTINSERT: A record cannot be entered/modified as :P1 window has been set up for copying data only from source company in Basic Data Synchronization window.', Basic_Data_Window_API.Get_Window(lu_name_));
      END IF;
   END IF;   
   indrec_.control_type := FALSE;
   indrec_.default_value := FALSE;
   indrec_.default_value_no_ct := FALSE;
   
   super(oldrec_, newrec_, indrec_, attr_);
END Check_Common___;


@Override
PROCEDURE Check_Insert___ (
   newrec_ IN OUT posting_ctrl_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
   name_                   VARCHAR2(30);
   value_                  VARCHAR2(4000);
   code_name_              VARCHAR2(20);
   code_part_              VARCHAR2(1);
   ctrl_type_category_     VARCHAR2(2000);
   dummy_                  VARCHAR2(2000);
   code_part_function_     VARCHAR2(100);
   code_part_function_db_  VARCHAR2(20);
   code_name_flag_         BOOLEAN := FALSE;
   b_flag_                 BOOLEAN;
BEGIN
   IF (Client_SYS.Item_Exist('CODE_NAME',attr_)) THEN
      code_name_:= substr(Client_SYS.Cut_Item_Value('CODE_NAME',attr_),1,10); 
      code_name_flag_:= TRUE;
   END IF;
   
   super(newrec_, indrec_, attr_);
   IF newrec_.override = 'Y' AND (newrec_.ctrl_type_category = 'PREPOSTING') THEN      
      code_part_function_db_ := Accounting_Code_Parts_API.Get_Code_Part_Function_Db(newrec_.company,newrec_.code_part);      
      IF ((code_part_function_db_ = 'PRACC') OR (code_part_function_db_ = 'FAACC')) THEN
         code_part_function_ := Accounting_Code_Part_Fu_API.Decode(code_part_function_db_);        
         Error_SYS.Record_General(lu_name_, 'NOALLOWED: Override is not allowed for code part :P1 connected to code part function :P2.', code_name_,code_part_function_);
      END IF;
   END IF;    

   IF (code_name_flag_) THEN
      code_part_ := Accounting_Code_Parts_API.Encode(newrec_.company, code_name_); 
   END IF;
   IF (newrec_.code_part IS NULL) AND (code_name_ IS NOT NULL) THEN
      Accounting_Code_Parts_API.Get_Code_Part(newrec_.code_part, newrec_.company, code_name_);
   END IF;
   IF (newrec_.default_value IS NOT NULL) THEN
      IF (code_part_ = 'A') THEN
         Account_API.Exist(newrec_.company, newrec_.default_value);
      ELSE
         Accounting_Code_Part_Value_API.Exist(newrec_.company, newrec_.code_part, newrec_.default_value);
      END IF;
   END IF;
   IF (newrec_.default_value_no_ct IS NOT NULL) THEN
      IF (code_part_ = 'A') THEN
         Account_API.Exist(newrec_.company, newrec_.default_value_no_ct);
      ELSE
         Accounting_Code_Part_Value_API.Exist(newrec_.company, newrec_.code_part, newrec_.default_value_no_ct);
      END IF;
   END IF;

   IF ((newrec_.module IS NULL) OR ( newrec_.ctrl_type_category IS NULL)) THEN
      Posting_Ctrl_Control_Type_API.Get_Allowed_Info(newrec_.module,
                                                     ctrl_type_category_,
                                                     dummy_,
                                                     newrec_.company,
                                                     newrec_.code_part,
                                                     newrec_.posting_type,
                                                     newrec_.control_type,
                                                     NULL);
   
      newrec_.ctrl_type_category := Ctrl_Type_Category_API.Encode(ctrl_type_category_);
      IF (ctrl_type_category_ IS NOT NULL) THEN
         Ctrl_Type_Category_API.Exist(ctrl_type_category_);
      END IF;
   END IF;   
   ------------------------------------------------------------------------
   -- Specific validation befor insert.
   -- Made by MJ.
   ------------------------------------------------------------------------
   Validate_Record___(newrec_);
   b_flag_ := Ctrl_Type_Allowed_Value_API.Validate_Allowed_Comb__(newrec_.company, 
                                                                  newrec_.posting_type, 
                                                                  newrec_.module, 
                                                                  newrec_.control_type, 
                                                                  newrec_.code_part, 
                                                                  Ctrl_Type_Category_API.Decode(newrec_.ctrl_type_category));
   
   IF (NOT b_flag_) THEN
      Error_SYS.Record_General(lu_name_, 
                               'INVCOMB: Invalid combination for posting type :P1 code part :P2 and control type :P3',
                               newrec_.posting_type, 
                               newrec_.code_part, 
                               newrec_.control_type);
   END IF;
   
   -- it's not allowed to set "default value no CT value" for fixed value and pre-posting
   IF ((newrec_.default_value_no_ct IS NOT NULL) AND (newrec_.ctrl_type_category IN ('FIXED','PREPOSTING'))) THEN
      newrec_.default_value_no_ct := NULL;
   END IF;
EXCEPTION
   WHEN value_error THEN
      Error_SYS.Item_Format(lu_name_, name_, value_);
END Check_Insert___;


@Override
PROCEDURE Check_Update___ (
   oldrec_ IN     posting_ctrl_tab%ROWTYPE,
   newrec_ IN OUT posting_ctrl_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
   name_                   VARCHAR2(30);
   value_                  VARCHAR2(4000);
   code_name_              VARCHAR2(20);
   code_part_function_     VARCHAR2(100);
   code_part_function_db_  VARCHAR2(20);
BEGIN
   IF (Client_SYS.Item_Exist('CODE_NAME',attr_)) THEN
      Error_SYS.Item_Update(lu_name_, 'CODE_NAME');
   END IF;
   code_name_ := Accounting_Code_Parts_API.Get_Name(newrec_.company, newrec_.code_part);

   super(oldrec_, newrec_, indrec_, attr_);
   
   IF newrec_.override = 'Y' AND (newrec_.ctrl_type_category = 'PREPOSTING') THEN
      code_part_function_    := Accounting_Code_Parts_API.Get_Code_Part_Function_Db(newrec_.company,newrec_.code_part);      
      IF ((code_part_function_db_ = 'PRACC') OR (code_part_function_db_ = 'FAACC')) THEN
         code_part_function_ := Accounting_Code_Part_Fu_API.Decode(code_part_function_db_);
         Error_SYS.Record_General(lu_name_, 'NOALLOWED: Override is not allowed for code part :P1 connected to code part function :P2.', code_name_,code_part_function_);
      END IF;
   END IF; 
   
   IF (newrec_.default_value IS NOT NULL) THEN
      IF (newrec_.code_part = 'A') THEN
         Account_API.Exist(newrec_.company, newrec_.default_value);
      ELSE
         Accounting_Code_Part_Value_API.Exist(newrec_.company, newrec_.code_part, newrec_.default_value);
      END IF;
   END IF;  

   IF newrec_.default_value_no_ct IS NOT NULL THEN
      -- Bug Id 123117 Begin Change the default_value to default_value_no_ct 
      IF (newrec_.code_part = 'A') THEN
         Account_API.Exist(newrec_.company, newrec_.default_value_no_ct);
      ELSE
         Accounting_Code_Part_Value_API.Exist(newrec_.company, newrec_.code_part, newrec_.default_value_no_ct);
      END IF;
      -- Bug Id 123117 End
   END IF;      
   
   IF (newrec_.code_part IS NULL AND code_name_ IS NOT NULL) THEN
      Accounting_Code_Parts_API.Get_Code_Part(newrec_.code_part, newrec_.company, code_name_);
   END IF;

   ------------------------------------------------------------------------
   -- Specific validation befor update.
   -- Made by MJ.
   ------------------------------------------------------------------------
   Validate_Record___(newrec_);
EXCEPTION
   WHEN value_error THEN
      Error_SYS.Item_Format(lu_name_, name_, value_);
END Check_Update___;


@Override
PROCEDURE Check_Delete___ (
   remrec_ IN posting_ctrl_tab%ROWTYPE )
IS
BEGIN
   IF (App_Context_Sys.Find_Value(lu_name_||'.copy_to_company_', 'FALSE') != 'TRUE') THEN
      IF (Company_Basic_Data_Window_API.Check_Copy_From_Company(remrec_.company, lu_name_)) THEN
         Error_SYS.Record_General(lu_name_, 'NODIRECTREMOVE: A record cannot be removed as :P1 window has been set up for copying data only from source company in Basic Data Synchronization window.', Basic_Data_Window_API.Get_Window(lu_name_));
      END IF;
   END IF;
   super(remrec_);
END Check_Delete___;

@Override
PROCEDURE Update___ (
   objid_      IN     VARCHAR2,
   oldrec_     IN     posting_ctrl_tab%ROWTYPE,
   newrec_     IN OUT posting_ctrl_tab%ROWTYPE,
   attr_       IN OUT VARCHAR2,
   objversion_ IN OUT VARCHAR2,
   by_keys_    IN     BOOLEAN DEFAULT FALSE )
IS
BEGIN
   --Add pre-processing code here
   super(objid_, oldrec_, newrec_, attr_, objversion_, by_keys_);
   --Add post-processing code here
   Client_SYS.Add_To_Attr('CTRL_TYPE_CATEGORY_DB', newrec_.ctrl_type_category, attr_);   
   IF (oldrec_.pc_valid_from != newrec_.pc_valid_from) THEN
      Posting_Ctrl_Detail_API.Update_Pc_Valid_From_ (oldrec_.company,
                                                     oldrec_.posting_type,
                                                     oldrec_.code_part,
                                                     oldrec_.pc_valid_from,
                                                     newrec_.pc_valid_from);

      Posting_Ctrl_Comb_Detail_API.Update_Pc_Valid_From_
                                                    (oldrec_.company,
                                                     oldrec_.posting_type,
                                                     oldrec_.code_part,
                                                     oldrec_.pc_valid_from,
                                                     newrec_.pc_valid_from);
   END IF;      
END Update___;

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

PROCEDURE Get_Override_Rec____ (
   override_rec_     IN OUT Accounting_Codestr_API.CodestrRec,
   company_          IN     VARCHAR2,
   posting_type_     IN     VARCHAR2,
   date_             IN     DATE DEFAULT sysdate,
   client_val_out_   IN     BOOLEAN)
IS
   override_      VARCHAR2(200);
   allow_cl_      VARCHAR2(200) := Fin_Allowed_API.Decode('Y');
   not_allow_cl_  VARCHAR2(200) := Fin_Allowed_API.Decode('N');
   --
   CURSOR override IS
    SELECT  code_part, override
    FROM    POSTING_CTRL_TAB
    WHERE   company       = company_
    AND     posting_type  = posting_type_
    AND     pc_valid_from <= date_
    ORDER BY pc_valid_from asc;
  --
BEGIN
   FOR cursor_rec IN override LOOP
      IF (client_val_out_) THEN         
         IF (cursor_rec.override = 'Y') THEN
            override_ := allow_cl_;
         ELSE 
            override_ := not_allow_cl_;
         END IF;         
      ELSE
         override_ := cursor_rec.override;
      END IF;      
      Accounting_Codestr_API.Set_Code_Part_Val_In_Rec(override_rec_,
                                                      cursor_rec.code_part,
                                                      override_);
   END LOOP;
END Get_Override_Rec____;


FUNCTION Get_Default_Value___ (
   company_       IN VARCHAR2,
   posting_type_  IN VARCHAR2,
   code_part_     IN VARCHAR2,
   in_date_       IN DATE) RETURN VARCHAR2
IS
   default_value_    POSTING_CTRL_TAB.default_value%TYPE;
   date_             DATE := Trunc(NVL(in_date_, SYSDATE));
   
   CURSOR get_default_value IS
      SELECT default_value
      FROM   POSTING_CTRL_TAB
      WHERE  company        = company_
      AND    posting_type   = posting_type_
      AND    code_part      = code_part_
      AND    pc_valid_from <= date_
      ORDER BY pc_valid_from DESC;
BEGIN
   OPEN get_default_value;
   FETCH get_default_value INTO default_value_;
   CLOSE get_default_value;
   
   RETURN default_value_;
END Get_Default_Value___;


      
FUNCTION Get_Code_Part_Exist___ (
   company_        IN     VARCHAR2,
   posting_type_   IN     VARCHAR2,
   code_part_      IN     VARCHAR2,
   control_type_   IN     VARCHAR2,
   pc_valid_from_  IN     DATE DEFAULT NULL) RETURN NUMBER
IS
   max_date_              DATE;
   max_date_control_type_ POSTING_CTRL_TAB.control_type%TYPE;
BEGIN
   IF control_type_ IS NULL THEN
      RETURN 1;
   ELSE
      max_date_ := Get_Max_Date___(company_, posting_type_, code_part_, nvl(pc_valid_from_, TRUNC(SYSDATE)));
      max_date_control_type_ := Get_Control_Type_Key(company_, posting_type_, code_part_, max_date_);
      IF (max_date_control_type_ = control_type_) THEN
         RETURN 1;
      END IF;
   END IF;
   RETURN 0;
END Get_Code_Part_Exist___;

PROCEDURE Get_Override_Rec____ (
   override_rec_     IN OUT NOCOPY Accounting_Codestr_API.CodestrRec,
   no_code_part_rec_ IN OUT NOCOPY Accounting_Codestr_API.CodestrRec,
   company_          IN     VARCHAR2,
   posting_type_     IN     VARCHAR2,
   date_             IN     DATE DEFAULT sysdate)
IS
   CURSOR get_rec IS
      SELECT  code_part, override, control_type
      FROM    POSTING_CTRL_TAB 
      WHERE   company       = company_
      AND     posting_type  = posting_type_
      AND     pc_valid_from <= date_
      ORDER BY pc_valid_from asc;
BEGIN
   FOR cursor_rec IN get_rec LOOP
      Accounting_Codestr_API.Set_Code_Part_Val_In_Rec(override_rec_,
                                                      cursor_rec.code_part,
                                                      cursor_rec.override);
      IF (cursor_rec.control_type NOT IN ('AC1', 'AC2')) THEN
         Accounting_Codestr_API.Set_Code_Part_Val_In_Rec(no_code_part_rec_,
                                                       cursor_rec.code_part,
                                                      'Y');
      END IF;
   END LOOP;
END Get_Override_Rec____;


PROCEDURE Copy_To_Companies_For_Svc___ (
   source_company_       IN  VARCHAR2,
   target_company_list_  IN  VARCHAR2,
   code_part_list_       IN  VARCHAR2,
   posting_type_list_    IN  VARCHAR2,
   pc_valid_from_list_   IN  VARCHAR2,  
   update_method_list_   IN  VARCHAR2,
   log_id_               IN  NUMBER,
   attr_                 IN  VARCHAR2 DEFAULT NULL)
IS
   TYPE posting_control IS TABLE OF posting_ctrl_tab%ROWTYPE INDEX BY BINARY_INTEGER;
   TYPE attr IS TABLE OF VARCHAR2 (32000) INDEX BY BINARY_INTEGER;   
   ptr_                    NUMBER;
   ptr1_                   NUMBER;
   ptr2_                   NUMBER;
   i_                      NUMBER;
   update_method_          VARCHAR2(20);
   value_                  VARCHAR2(2000);
   target_company_         accounting_attribute_con_tab.company%TYPE;
   ref_posting_control_    posting_control;
   ref_attr_               attr;
   attr_value_             VARCHAR2(32000) := NULL;   
BEGIN
   ptr1_ := NULL;
   ptr2_ := NULL;
   
   i_    := 0;
   ptr_  := NULL;
   WHILE Copy_To_Company_Util_API.Get_Next_Record_Sep_Val(value_, ptr_, code_part_list_) LOOP
      ref_posting_control_(i_).code_part := value_;
      i_ := i_ + 1;
   END LOOP;
   
   i_    := 0;
   ptr_  := NULL;
   WHILE Copy_To_Company_Util_API.Get_Next_Record_Sep_Val(value_, ptr_, posting_type_list_) LOOP
      ref_posting_control_(i_).posting_type := value_;
      i_ := i_ + 1;
   END LOOP;
   
   i_    := 0;
   ptr_  := NULL;
   WHILE Copy_To_Company_Util_API.Get_Next_Record_Sep_Val(value_, ptr_, pc_valid_from_list_) LOOP
      ref_posting_control_(i_).pc_valid_from := Client_SYS.Attr_Value_To_Date(value_);
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
         FOR j_ IN ref_posting_control_.FIRST..ref_posting_control_.LAST LOOP
            IF (ref_attr_.FIRST IS NOT NULL) THEN
               attr_value_ := ref_attr_(j_);
            END IF;
            Copy_To_Companies__ (source_company_,  
                                 target_company_,
                                 ref_posting_control_(j_).code_part,
                                 ref_posting_control_(j_).posting_type,
                                 ref_posting_control_(j_).pc_valid_from,
                                 update_method_,
                                 log_id_,
                                 attr_value_);
         END LOOP;
      END IF;
   END LOOP;
END Copy_To_Companies_For_Svc___;

PROCEDURE Posting_Event___ (
   codestring_rec_    OUT Accounting_Codestr_API.CodestrRec,
   company_           IN  VARCHAR2,
   posting_type_      IN  VARCHAR2,
   date_              IN  DATE,
   control_type_attr_ IN  VARCHAR2,
   project_id_        IN  VARCHAR2)
IS
   ptr_                       NUMBER;
   name_                      VARCHAR2(30);
   value_                     VARCHAR2(100);
   control_type_value_table_  Posting_Ctrl_Public_API.control_type_value_table;
   dummy_                     NUMBER;
   CURSOR get_all_control_type IS
      SELECT 1
      FROM   POSTING_CTRL_TAB
      WHERE  company      = company_
      AND    posting_type = posting_type_;
BEGIN
   OPEN get_all_control_type;
   FETCH get_all_control_type INTO dummy_;
   IF (get_all_control_type%NOTFOUND) THEN
      CLOSE get_all_control_type;      
      Error_SYS.Appl_General(lu_name_, 'NOCOMPANYPOSTINGTYPE: Posting type :P1 is missing in Posting Control in company :P2.', posting_type_,company_);
   END IF;   
   CLOSE get_all_control_type;

   ptr_ := NULL;
   WHILE (Client_SYS.Get_Next_From_Attr(control_type_attr_, ptr_, name_, value_)) LOOP
      IF (name_ IS NOT NULL) THEN
         control_type_value_table_(name_) := value_;
      END IF;
   END LOOP;   

   Posting_Ctrl_Public_API.Build_Codestring_Rec(codestring_rec_,
                                                control_type_value_table_,
                                                date_,
                                                posting_type_,
                                                company_);

   Accounting_Codestr_API.Complete_Codestring_Proj(codestring_rec_,
                                                   company_,
                                                   posting_type_,
                                                   date_,
                                                   project_id_);

   Check_Account_Valid_Date___(codestring_rec_,
                               company_,
                               posting_type_,
                               date_);
END Posting_Event___;

FUNCTION Exist_Posting_Control___ (
   company_       IN VARCHAR2,
   posting_type_  IN VARCHAR2,
   control_type_  IN VARCHAR2,
   code_part_     IN VARCHAR2 ) RETURN BOOLEAN
IS
   CURSOR checkpost IS
     SELECT 1
     FROM   POSTING_CTRL_TAB
     WHERE  company = company_
     AND    posting_type = decode(posting_type_, NULL, posting_type, posting_type_)
     AND    control_type = control_type_
     AND    code_part = decode(code_part_, NULL, code_part, code_part_);
   dummy_    NUMBER;
BEGIN
   OPEN checkpost;
   FETCH checkpost INTO dummy_;
   IF (checkpost%NOTFOUND) THEN
      CLOSE checkpost;
      RETURN FALSE;
   ELSE
      CLOSE checkpost;
      RETURN TRUE;
   END IF;
END Exist_Posting_Control___;

PROCEDURE Get_Code_Part___ (
   codestring_rec_ IN OUT VARCHAR2,
   company_        IN     VARCHAR2,
   posting_type_   IN     VARCHAR2,
   control_type_   IN     VARCHAR2,
   pc_valid_from_  IN     DATE )
IS
   code_part_  VARCHAR2(1);
   account_    NUMBER;
   code_b_     NUMBER;
   code_c_     NUMBER;
   code_d_     NUMBER;
   code_e_     NUMBER;
   code_f_     NUMBER;
   code_g_     NUMBER;
   code_h_     NUMBER;
   code_i_     NUMBER;
   code_j_     NUMBER;
   
   CURSOR fetch_code_part IS
      SELECT DISTINCT code_part
      FROM   POSTING_CTRL_TAB
      WHERE  company      = company_
      AND    posting_type = posting_type_
      AND    control_type LIKE nvl(control_type_, '%')
      ORDER BY code_part;
   
BEGIN
   account_ := 0;
   code_b_ := 0;
   code_c_ := 0;
   code_d_ := 0;
   code_e_ := 0;
   code_f_ := 0;
   code_g_ := 0;
   code_h_ := 0;
   code_i_ := 0;
   code_j_ := 0;
   OPEN fetch_code_part;
   WHILE(TRUE) LOOP
      FETCH fetch_code_part INTO code_part_;
      EXIT WHEN fetch_code_part%NOTFOUND;
      IF code_part_ = 'A' THEN
         account_ := Get_Code_Part_Exist___(company_, posting_type_, code_part_, control_type_, pc_valid_from_);
      ELSIF code_part_ = 'B' THEN
        code_b_  := Get_Code_Part_Exist___(company_, posting_type_, code_part_, control_type_, pc_valid_from_);
      ELSIF code_part_ = 'C' THEN
         code_c_ := Get_Code_Part_Exist___(company_, posting_type_, code_part_, control_type_, pc_valid_from_);
      ELSIF code_part_ = 'D' THEN
        code_d_  := Get_Code_Part_Exist___(company_, posting_type_, code_part_, control_type_, pc_valid_from_);
      ELSIF code_part_ = 'E' THEN
        code_e_  := Get_Code_Part_Exist___(company_, posting_type_, code_part_, control_type_, pc_valid_from_);
      ELSIF code_part_ = 'F' THEN
         code_f_ := Get_Code_Part_Exist___(company_, posting_type_, code_part_, control_type_, pc_valid_from_);
      ELSIF code_part_ = 'G' THEN
         code_g_ := Get_Code_Part_Exist___(company_, posting_type_, code_part_, control_type_, pc_valid_from_);
      ELSIF code_part_ = 'H' THEN
         code_h_ := Get_Code_Part_Exist___(company_, posting_type_, code_part_, control_type_, pc_valid_from_);
      ELSIF code_part_ = 'I' THEN
         code_i_ := Get_Code_Part_Exist___(company_, posting_type_, code_part_, control_type_, pc_valid_from_);
      ELSIF code_part_ = 'J' THEN
         code_j_ := Get_Code_Part_Exist___(company_, posting_type_, code_part_, control_type_, pc_valid_from_);
      END IF;
   END LOOP;
   CLOSE fetch_code_part;
   Client_SYS.Clear_Attr(codestring_rec_);
   Client_SYS.Add_To_Attr('ACCOUNT', account_, codestring_rec_);
   Client_SYS.Add_To_Attr('CODE_B', code_b_, codestring_rec_);
   Client_SYS.Add_To_Attr('CODE_C', code_c_, codestring_rec_);
   Client_SYS.Add_To_Attr('CODE_D', code_d_, codestring_rec_);
   Client_SYS.Add_To_Attr('CODE_E', code_e_, codestring_rec_);
   Client_SYS.Add_To_Attr('CODE_F', code_f_, codestring_rec_);
   Client_SYS.Add_To_Attr('CODE_G', code_g_, codestring_rec_);
   Client_SYS.Add_To_Attr('CODE_H', code_h_, codestring_rec_);
   Client_SYS.Add_To_Attr('CODE_I', code_i_, codestring_rec_);
   Client_SYS.Add_To_Attr('CODE_J', code_j_, codestring_rec_);
END Get_Code_Part___;
-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------

@SecurityCheck Company.UserAuthorized(company_)
PROCEDURE Get_Control_Type__ (
   control_type_tab_       OUT    ControlTypeTab,
   control_type_value_tab_ OUT    ControlTypeValueTab,
   row_                    IN OUT NUMBER,
   company_                IN     VARCHAR2,
   posting_type_           IN     VARCHAR2,
   control_type_attr_      IN     VARCHAR2 )
IS
   CURSOR get_all_control_type IS
      SELECT control_type
      FROM   POSTING_CTRL_TAB t1
      WHERE  company      = company_
      AND    posting_type = posting_type_
      ORDER BY control_type;
   ptr_           NUMBER;
   name_          VARCHAR2(100);
   value_         VARCHAR2(2000);
   control_type_  VARCHAR2(10);
BEGIN
   row_ := 0;
   OPEN get_all_control_type;
   FETCH get_all_control_type INTO control_type_;
   IF (get_all_control_type%NOTFOUND) THEN
      Error_SYS.appl_general(lu_name_, 'NOPOSTINGTYPE: Posting type :P1 is missing in Posting Control', posting_type_);
   END IF;
   LOOP
      row_ := row_ + 1;
      ptr_ := NULL;
      WHILE (Client_SYS.Get_Next_From_Attr(control_type_attr_, ptr_, name_, value_)) LOOP
         IF (name_ = control_type_) THEN
            control_type_tab_(row_) := control_type_;
            control_type_value_tab_(row_) := value_;
         END IF;
      END LOOP;
      FETCH get_all_control_type INTO control_type_;
      EXIT WHEN get_all_control_type%NOTFOUND;
   END LOOP;
   CLOSE get_all_control_type;
END Get_Control_Type__;


PROCEDURE Build_Codestring__ (
   codestring_rec_         OUT Accounting_Codestr_API.CodestrRec,
   company_                IN  VARCHAR2,
   posting_type_           IN  VARCHAR2,
   date_                   IN  DATE,
   control_type_tab_       IN  ControlTypeTab,
   control_type_value_tab_ IN  ControlTypeValueTab,
   row_                    IN  NUMBER )
IS
   control_type_           VARCHAR2(10);
   control_type_value_     VARCHAR2(100);
   code_part_              VARCHAR2(1);
   code_part_value_        VARCHAR2(20);
   code_part_value2_       VARCHAR2(20);
   no_row_                 NUMBER := 1;
   module_                 VARCHAR2(20);
   ctrl_type_category_     VARCHAR2(50);   
   codestr_tab_            Accounting_Codestr_API.Code_part_value_tab;
   no_code_part_value_     VARCHAR2(5);

   CURSOR defaultvalue IS
      SELECT default_value, code_part, module, ctrl_type_category
      FROM   POSTING_CTRL_TAB
      WHERE  company = company_
      AND    posting_type = posting_type_
      AND    control_type = control_type_;
BEGIN
   WHILE (no_row_ <= row_) LOOP
      control_type_       := control_type_tab_(no_row_);
      control_type_value_ := control_type_value_tab_(no_row_);
      OPEN defaultvalue;
      WHILE (TRUE) LOOP
         FETCH defaultvalue INTO code_part_value2_, code_part_, module_, ctrl_type_category_;
         EXIT WHEN defaultvalue%NOTFOUND;
         IF (ctrl_type_category_ IN ('FIXED','PREPOSTING')) THEN

            codestr_tab_ := Accounting_Codestr_API.Get_Code_Part_Val_Tab(codestring_rec_);

            IF (ctrl_type_category_ = 'PREPOSTING') THEN
               Accounting_Codestr_API.Set_Code_Part_Val_In_Rec(codestring_rec_,
                                                               code_part_,
                                                               chr(0));
            ELSE
               Accounting_Codestr_API.Set_Code_Part_Val_In_Rec(codestring_rec_,
                                                               code_part_,
                                                               code_part_value2_);
            END IF;
         ELSE
            Posting_Ctrl_Detail_API.Get_Code_Part_Value_Ex_(code_part_value_, 
                                                            no_code_part_value_,
                                                            module_,
                                                            company_, 
                                                            posting_type_, 
                                                            code_part_, 
                                                            date_,
                                                            control_type_, 
                                                            control_type_value_);

            no_code_part_value_ := NVL(no_code_part_value_, 'FALSE');
            codestr_tab_ := Accounting_Codestr_API.Get_Code_Part_Val_Tab(codestring_rec_);
            
            IF (no_code_part_value_ = 'FALSE') THEN
               code_part_value_ := NVL(code_part_value_, code_part_value2_);
            END IF;
            Accounting_Codestr_API.Set_Code_Part_Val_In_Rec(codestring_rec_,
                                                            code_part_,
                                                            code_part_value_);
         END IF;
         
         IF (ctrl_type_category_ != 'PREPOSTING') THEN
            IF (code_part_ IS NULL) OR ( (code_part_value2_ IS NULL) AND (code_part_value_ IS NULL) ) THEN
               IF (control_type_ = 'IC7') THEN
                  control_type_value_ := Income_Type_API.Get_Income_Type_Id(control_type_value_);
               ELSIF (control_type_ = 'IC8') THEN
                  $IF Component_Invoic_SYS.INSTALLED $THEN
                     control_type_value_ := Type1099_API.Get_Irs1099_Type_Id(control_type_value_); 
                  $ELSE
                     NULL;
                  $END                     
               END IF;
               Error_SYS.Appl_General(lu_name_, 'NOCTRLTYPE: Control type value :P1 is missing for Posting type :P2 and Code part :P3',
                                      control_type_value_, posting_type_, code_part_);
            END IF;
         END IF;
      END LOOP;
      CLOSE defaultvalue;
      no_row_ := no_row_ + 1;
   END LOOP;
EXCEPTION
   WHEN no_data_found THEN
      Error_SYS.appl_general(lu_name_, 'NOCTRLVALUE: Control type value is missing for Posting type :P1', posting_type_);
END Build_Codestring__;


@SecurityCheck Company.UserAuthorized(company_)
PROCEDURE Get_Codepart_Tab__ (
   codepart_tab_ IN OUT CodePartTab,
   company_      IN     VARCHAR2,
   posting_type_ IN     VARCHAR2,
   module_       IN     VARCHAR2,
   control_type_ IN     VARCHAR2 )
IS
   empty_tab_            Posting_Ctrl_API.CodePartTab;
   no_code_part          EXCEPTION;
   rows_                 NUMBER := 1;
   
   CURSOR cs_posting_ctrl IS
      SELECT *
      FROM   POSTING_CTRL_TAB
      WHERE  company      = company_
      AND    posting_type = posting_type_
      AND    module       = module_
      AND    control_type = control_type_;
BEGIN
   codepart_tab_ := empty_tab_;
   FOR codepart_rec IN cs_posting_ctrl LOOP
      codepart_tab_(rows_) := codepart_rec.code_part;
      rows_ := rows_ + 1;
   END LOOP;
   IF (codepart_tab_(1) IS NULL) THEN
      RAISE no_code_part;
   END IF;
EXCEPTION
   WHEN no_code_part THEN
      Error_SYS.Appl_General(lu_name_, 'NOCTRLT: Control types is missing for posting type :P1', posting_type_);
END Get_Codepart_Tab__;


PROCEDURE Load_Codepart_Value__ (
   code_string_       IN OUT Accounting_Codestr_API.CodestrRec,
   code_part_tab_     IN     CodePartTab,
   date_              IN     DATE,
   company_           IN     VARCHAR2,
   posting_type_      IN     VARCHAR2,
   control_value_     IN     VARCHAR2,
   module_            IN     VARCHAR2,
   control_type_      IN     VARCHAR2 )
IS
   --
   rows_                NUMBER := 1;
   code_part_           VARCHAR2(20);
   code_part_value_     VARCHAR2(20);
   no_code_part_value_  VARCHAR2(5);
   codestr_tab_         Accounting_Codestr_API.Code_part_value_tab;
   --
BEGIN
   LOOP
      code_part_ := code_part_tab_(rows_);

      Posting_Ctrl_Detail_API.Get_Code_Part_Value_Ex_(code_part_value_, no_code_part_value_, module_,
                                                      company_, posting_type_,
                                                      code_part_, date_ ,
                                                      control_type_, control_value_ );
      -- no_code_part_value is mandatory but if user is not authorized or details not found the method could return null so therefore this NVL statement
      no_code_part_value_ := NVL(no_code_part_value_, 'FALSE');
      
      IF (code_part_value_ IS NULL) THEN
         IF (no_code_part_value_ = 'FALSE') THEN
            Get_Default_Value_( code_part_value_,
                                company_,
                                posting_type_,
                                code_part_,
                                control_type_ );
         END IF;
      END IF;

      codestr_tab_ := Accounting_Codestr_API.Get_Code_Part_Val_Tab(code_string_);

      IF (codestr_tab_(code_part_) IS NULL) THEN
         Accounting_Codestr_API.Set_Code_Part_Val_In_Rec(code_string_,
                                                         code_part_,
                                                         code_part_value_);
      END IF;

      rows_ := rows_ + 1;
   END LOOP;
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      NULL;
END Load_Codepart_Value__;


@SecurityCheck Company.UserAuthorized(company_)
PROCEDURE Get_Comb_Control_Type__ (
   control_type_tab_              OUT ControlTypeTab,
   control_type_value_tab_        OUT ControlTypeValueTab,
   row_                        IN OUT NUMBER,
   company_                    IN     VARCHAR2,
   posting_type_               IN     VARCHAR2,
   control_type_attr_          IN     VARCHAR2 )
IS

   CURSOR get_all_control_type IS
      SELECT control_type
      FROM   POSTING_CTRL_TAB
      WHERE  company      = company_
      AND    posting_type = posting_type_
      ORDER BY control_type;
   ptr_                NUMBER;
   name_               VARCHAR2(100);
   value_              VARCHAR2(2000);
   control_type_       VARCHAR2(10);

BEGIN
   row_ := 0;
   OPEN get_all_control_type;
   FETCH get_all_control_type INTO control_type_;
   IF (get_all_control_type%NOTFOUND) THEN
      Error_SYS.Appl_General(lu_name_, 'NOPOSTINGTYPE: Posting type :P1 is missing in Posting Control', posting_type_);
   END IF;
   LOOP
      row_ := row_ + 1;
      ptr_ := NULL;

      IF Posting_Ctrl_Comb_Detail_API.Is_Control_Type_CCT(company_, posting_type_, control_type_ ) THEN
         control_type_tab_(row_)       := control_type_;
         control_type_value_tab_(row_) := 'CONTROL_TYPE_IS_CCT';
      ELSE
         WHILE (Client_SYS.Get_Next_From_Attr(control_type_attr_, ptr_, name_, value_)) LOOP
            IF (name_ = control_type_ ) THEN
                control_type_tab_(row_)       := control_type_;
                control_type_value_tab_(row_) := value_;
            END IF;
         END LOOP;
      END IF;
      FETCH get_all_control_type INTO control_type_;
      EXIT WHEN get_all_control_type%NOTFOUND;
   END LOOP;
   CLOSE get_all_control_type;
END Get_Comb_Control_Type__;


PROCEDURE Build_Comb_Codestring__ (
   codestring_rec_              OUT Accounting_Codestr_API.CodestrRec,
   company_                     IN  VARCHAR2,
   posting_type_                IN  VARCHAR2,
   date_                        IN  DATE,
   control_type_tab_            IN  ControlTypeTab,
   control_type_value_tab_      IN  ControlTypeValueTab,
   row_                         IN  NUMBER,
   control_type_attr_           IN  VARCHAR2 )
IS
   no_row_                      NUMBER := 1;
   control_type_                VARCHAR2(10);
   control_type_value_          VARCHAR2(100);
   code_part_                   VARCHAR2(1);
   module_                      VARCHAR2(20);
   control_type_codestring_rec_ Accounting_Codestr_API.CodestrRec;
   control_type_tab1_           Posting_Ctrl_API.ControlTypeTab;
   control_type_value_tab1_     Posting_Ctrl_API.ControlTypeValueTab;
   code_part_value_             VARCHAR2(20);
   code_part_value2_            VARCHAR2(20);
   ctrl_type_category_          VARCHAR2(50);

   no_code_part_value_          VARCHAR2(5);
   codestr_tab_                 Accounting_Codestr_API.Code_part_value_tab;

   CURSOR defaultvalue IS
      SELECT default_value, code_part, module, ctrl_type_category
      FROM   POSTING_CTRL_TAB
      WHERE  company      = company_
      AND    posting_type = posting_type_
      AND    control_type = control_type_;

BEGIN
   WHILE (no_row_ <= row_) LOOP
      control_type_ := control_type_tab_(no_row_);
      control_type_value_ := control_type_value_tab_(no_row_);

      -- Set no_code_part_value_ to FALSE when starting a new row
      no_code_part_value_ := 'FALSE';

    --Check if control type is CCT
      IF control_type_value_ = 'CONTROL_TYPE_IS_CCT' THEN
         OPEN defaultvalue;
         WHILE (TRUE) LOOP
            FETCH defaultvalue INTO code_part_value2_, code_part_, module_, ctrl_type_category_;
            EXIT WHEN defaultvalue%NOTFOUND;
            Posting_Ctrl_Comb_Detail_API.Get_Code_Part_Value_Ex_(code_part_value_, 
                                                                 no_code_part_value_,
                                                                 company_, 
                                                                 module_,
                                                                 posting_type_, 
                                                                 code_part_, 
                                                                 date_,
                                                                 control_type_, 
                                                                 control_type_attr_);
            no_code_part_value_ := NVL(no_code_part_value_, 'FALSE');
            codestr_tab_ := Accounting_Codestr_API.Get_Code_Part_Val_Tab(codestring_rec_);

            IF (no_code_part_value_ = 'FALSE') THEN
               code_part_value_ := NVL(code_part_value_, code_part_value2_);
            END IF;

            Accounting_Codestr_API.Set_Code_Part_Val_In_Rec(codestring_rec_,
                                                            code_part_,
                                                            code_part_value_);
         END LOOP;
         
         CLOSE defaultvalue;

         IF (ctrl_type_category_ != 'PREPOSTING') THEN
            IF (code_part_ IS NULL) OR ( (code_part_value2_ IS NULL) AND (code_part_value_ IS NULL) ) THEN
               Error_SYS.Appl_General(lu_name_, 'CTRLTYMISSING: Control type value is missing for Posting type :P1 and Code part :P2',
                                       posting_type_, code_part_);
            END IF;
         END IF;
      ELSE
         -- Perform same action as in Build_CodeString__
         control_type_tab1_(1)      := control_type_;
         control_type_value_tab1_(1):= control_type_value_;
         Build_CodeString__(control_type_codestring_rec_, company_, posting_type_,
                              date_, control_type_tab1_, control_type_value_tab1_, 1);
      END IF;

      -- if no_code_part_value_ is FALSE then apply NVL handling otherwise (when TRUE) then the setting has defined that
      -- a null value is ok
      IF (no_code_part_value_ = 'FALSE') THEN
         codestring_rec_.code_a := NVL(codestring_rec_.code_a, control_type_codestring_rec_.code_a);
         codestring_rec_.code_b := NVL(codestring_rec_.code_b, control_type_codestring_rec_.code_b);
         codestring_rec_.code_c := NVL(codestring_rec_.code_c, control_type_codestring_rec_.code_c);
         codestring_rec_.code_d := NVL(codestring_rec_.code_d, control_type_codestring_rec_.code_d);
         codestring_rec_.code_e := NVL(codestring_rec_.code_e, control_type_codestring_rec_.code_e);
         codestring_rec_.code_f := NVL(codestring_rec_.code_f, control_type_codestring_rec_.code_f);
         codestring_rec_.code_g := NVL(codestring_rec_.code_g, control_type_codestring_rec_.code_g);
         codestring_rec_.code_h := NVL(codestring_rec_.code_h, control_type_codestring_rec_.code_h);
         codestring_rec_.code_i := NVL(codestring_rec_.code_i, control_type_codestring_rec_.code_i);
         codestring_rec_.code_j := NVL(codestring_rec_.code_j, control_type_codestring_rec_.code_j);
      END IF;
      no_row_ := no_row_ + 1;
   END LOOP;
EXCEPTION
   WHEN no_data_found THEN
      Error_SYS.Appl_General(lu_name_, 'NOCTRLVALUE: Control type value is missing for Posting type :P1', posting_type_);
END Build_Comb_Codestring__;


@UncheckedAccess
FUNCTION Cct_Included__ (
   company_          IN     VARCHAR2,
   posting_type_     IN     VARCHAR2 ) RETURN BOOLEAN
IS
   CURSOR getctrltype IS
   SELECT control_type
     FROM POSTING_CTRL_TAB
    WHERE company      = company_
      AND posting_type = posting_type_;

BEGIN
   FOR ctrl_type_ IN getctrltype LOOP
      -- Check if control type is a CCT
      IF Posting_Ctrl_Comb_Detail_API.Is_Control_Type_CCT(company_, posting_type_, ctrl_type_.control_type ) THEN
         RETURN TRUE;
      END IF;
   END LOOP;
   RETURN FALSE;
END Cct_Included__;


PROCEDURE Copy_To_Companies__ (
   source_company_ IN VARCHAR2,
   target_company_ IN VARCHAR2,
   code_part_      IN VARCHAR2,
   posting_type_   IN VARCHAR2,
   pc_valid_from_  IN DATE,
   update_method_  IN VARCHAR2,
   log_id_         IN NUMBER,
   attr_           IN VARCHAR2 DEFAULT NULL)
IS
   source_rec_              posting_ctrl_tab%ROWTYPE;
   target_rec_              posting_ctrl_tab%ROWTYPE;
   old_target_rec_          posting_ctrl_tab%ROWTYPE;
   log_key_                 VARCHAR2(2000);
   log_detail_status_       VARCHAR2(10);  
BEGIN
   source_rec_ := Get_Object_By_Keys___(source_company_, code_part_, posting_type_, pc_valid_from_);
   target_rec_ := source_rec_;
   target_rec_.company := target_company_;
   App_Context_SYS.Set_Value(lu_name_||'.copy_to_company_', 'TRUE');
   old_target_rec_ := Get_Object_By_Keys___(target_company_, code_part_, posting_type_, pc_valid_from_);
   log_key_ := code_part_ || '^' || posting_type_ || '^' || TO_CHAR(pc_valid_from_);
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
      Raise_Record_Not_Exist___(target_company_, code_part_, posting_type_, pc_valid_from_);
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
   App_Context_SYS.Set_Value(lu_name_||'.copy_to_company_', 'FALSE');
   Copy_Basic_Data_Log_Detail_API.Create_New_Record(log_id_, target_company_, log_key_, log_detail_status_);
EXCEPTION
   WHEN OTHERS THEN
      log_detail_status_ := 'ERROR';
      Copy_Basic_Data_Log_Detail_API.Create_New_Record(log_id_, target_company_, log_key_, log_detail_status_, SQLERRM);
END Copy_To_Companies__;

FUNCTION Check_Exist__ (
   company_       IN VARCHAR2,
   code_part_     IN VARCHAR2,
   posting_type_  IN VARCHAR2,
   control_type_  IN VARCHAR2,
   pc_valid_from_ IN DATE ) RETURN BOOLEAN
IS
   dummy_ NUMBER;
BEGIN
   SELECT 1
     INTO dummy_
     FROM posting_ctrl_tab
    WHERE company   = company_
      AND code_part = code_part_
      AND control_type = control_type_
      AND posting_type = posting_type_
      AND pc_valid_from = pc_valid_from_;
      RETURN TRUE;
EXCEPTION
   WHEN OTHERS THEN
      RETURN FALSE;
END Check_Exist__; 
   
-------------------- LU SPECIFIC PROTECTED METHODS --------------------------

-- The returned values (override flag) in the code string record return client values
@SecurityCheck Company.UserAuthorized(company_)
PROCEDURE Get_Override_Rec_ (
   override_rec_  IN OUT Accounting_Codestr_API.CodestrRec,
   company_       IN     VARCHAR2,
   posting_type_  IN     VARCHAR2,
   date_          IN     DATE DEFAULT SYSDATE )
IS
BEGIN
   Get_Override_Rec____(override_rec_,
                        company_,
                        posting_type_,
                        date_,
                        TRUE);
END Get_Override_Rec_;


PROCEDURE Get_Default_Value_ (
   default_value_     IN OUT VARCHAR2,
   company_           IN     VARCHAR2,
   posting_type_      IN     VARCHAR2,
   code_part_         IN     VARCHAR2,
   control_type_      IN     VARCHAR2,
   in_date_           IN     DATE DEFAULT SYSDATE)
IS
   date_       DATE := Trunc(NVL(in_date_, SYSDATE));
BEGIN
   default_value_ := NULL;   
   default_value_ := Get_Default_Value___(company_, posting_type_, code_part_, date_);
   
   IF (default_value_ IS NULL) THEN      
      Error_SYS.Appl_General(lu_name_, 'NOCTRVALUE: Value is missing or has an invalid time interval for posting type :P1 control type :P2 code part :P3',
                             posting_type_, control_type_, code_part_ );
   END IF;
END Get_Default_Value_;

PROCEDURE Override_Default_ (
   company_       IN VARCHAR2,
   posting_type_  IN VARCHAR2,
   code_part_     IN VARCHAR2,
   control_type_  IN VARCHAR2,
   module_        IN VARCHAR2,
   override_      IN VARCHAR2,
   default_value_ IN VARCHAR2)
IS
BEGIN
   INSERT
      INTO posting_ctrl_tab(
         company,
         code_part,
         posting_type,
         pc_valid_from,
         control_type,
         module,
         override,
         default_value,
         ctrl_type_category,
         rowversion)
      VALUES(
         company_,
         code_part_,
         posting_type_,
         TRUNC(SYSDATE),
         control_type_,
         module_,
         override_,
         default_value_,
         Posting_Ctrl_Control_Type_API.Get_Ctrl_Type_Category_Db(control_type_, module_),
         sysdate);
END Override_Default_;


PROCEDURE Copy_To_Companies_ (
   attr_ IN  VARCHAR2 )
IS
   ptr_                 NUMBER;
   name_                VARCHAR2(200);
   value_               VARCHAR2(32000);
   source_company_      VARCHAR2(100);
   target_company_list_ VARCHAR2(32000);
   code_part_list_      VARCHAR2(32000);
   posting_type_list_   VARCHAR2(32000);
   pc_valid_from_list_  VARCHAR2(32000);
   update_method_list_  VARCHAR2(32000);
   copy_type_           VARCHAR2(100);
   attr1_               VARCHAR2(32000);
BEGIN
   ptr_ := NULL;
   WHILE (Client_SYS.Get_Next_From_Attr(attr_, ptr_, name_, value_)) LOOP
      IF (name_ = 'SOURCE_COMPANY') THEN
         source_company_ := value_;
      ELSIF (name_ = 'TARGET_COMPANY_LIST') THEN
         target_company_list_ := value_;
      ELSIF (name_ = 'CODE_PART_LIST') THEN
         code_part_list_ := value_;
      ELSIF (name_ = 'POSTING_TYPE_LIST') THEN
         posting_type_list_ := value_;
      ELSIF (name_ = 'PC_VALID_FROM_LIST') THEN
         pc_valid_from_list_ := value_;         
      ELSIF (name_ = 'UPDATE_METHOD_LIST') THEN
         update_method_list_ := value_;
      ELSIF (name_ = 'COPY_TYPE') THEN
         copy_type_ := value_;
      ELSIF (name_ = 'ATTR') THEN
         attr1_ := value_||chr(30)||substr(attr_, ptr_,length(attr_)-1);
      END IF;
   END LOOP;
   Copy_To_Companies_(source_company_,
                      target_company_list_,
                      code_part_list_,
                      posting_type_list_,
                      pc_valid_from_list_,
                      update_method_list_,
                      copy_type_,
                      attr1_);
END Copy_To_Companies_;


PROCEDURE Copy_To_Companies_ (
   source_company_      IN  VARCHAR2,
   target_company_list_ IN  VARCHAR2,
   code_part_list_      IN  VARCHAR2,
   posting_type_list_   IN  VARCHAR2,
   pc_valid_from_list_  IN  VARCHAR2,
   update_method_list_  IN  VARCHAR2,
   copy_type_           IN  VARCHAR2,
   attr_                IN  VARCHAR2 DEFAULT NULL)
IS
   TYPE posting_control IS TABLE OF posting_ctrl_tab%ROWTYPE INDEX BY BINARY_INTEGER;
   TYPE attr IS TABLE OF VARCHAR2 (32000) INDEX BY BINARY_INTEGER;   
   ptr_                    NUMBER;
   ptr1_                   NUMBER;
   ptr2_                   NUMBER;
   i_                      NUMBER;
   update_method_          VARCHAR2(20);
   value_                  VARCHAR2(2000);
   target_company_         posting_ctrl_tab.company%TYPE;
   ref_posting_control_    posting_control;
   ref_attr_               attr;
   log_id_                 NUMBER;
   attr_value_             VARCHAR2(32000) := NULL;   
BEGIN
   ptr1_ := NULL;
   ptr2_ := NULL;
   
   i_    := 0;
   ptr_  := NULL;
   WHILE Copy_To_Company_Util_API.Get_Next_Record_Sep_Val(value_, ptr_, code_part_list_) LOOP
      ref_posting_control_(i_).code_part := value_;
      i_ := i_ + 1;
   END LOOP;
   
   i_    := 0;
   ptr_  := NULL;
   WHILE Copy_To_Company_Util_API.Get_Next_Record_Sep_Val(value_, ptr_, posting_type_list_) LOOP
      ref_posting_control_(i_).posting_type := value_;
      i_ := i_ + 1;
   END LOOP;
   
   i_    := 0;
   ptr_  := NULL;
   WHILE Copy_To_Company_Util_API.Get_Next_Record_Sep_Val(value_, ptr_, pc_valid_from_list_) LOOP
      ref_posting_control_(i_).pc_valid_from := Client_SYS.Attr_Value_To_Date(value_);
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
         FOR j_ IN ref_posting_control_.FIRST..ref_posting_control_.LAST LOOP
            IF (ref_attr_.FIRST IS NOT NULL) THEN
               attr_value_ := ref_attr_(j_);
            END IF;
            Copy_To_Companies__ (source_company_,  
                                 target_company_,
                                 ref_posting_control_(j_).code_part,
                                 ref_posting_control_(j_).posting_type,
                                 ref_posting_control_(j_).pc_valid_from,
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

PROCEDURE Get_Control_Type (
   control_type_lu_tab_ IN OUT CtrlTypLuTab,
   control_type_tab_    IN OUT CtrlTypTab,
   module_              IN OUT VARCHAR2,
   rows_                IN OUT NUMBER,
   company_             IN     VARCHAR2,
   posting_type_        IN     VARCHAR2 )
IS
   no_control_type      EXCEPTION;
   dummy_ NUMBER;                       
    
   CURSOR cs_control_type IS
      SELECT DISTINCT control_type, module, ctrl_type_category
      FROM  posting_ctrl_tab
      WHERE company = company_
      AND   posting_type = posting_type_;

   CURSOR cs_posting_type IS
      SELECT 1
      FROM  posting_ctrl_tab
      WHERE company = company_
      AND   posting_type = posting_type_;

BEGIN
   rows_ := 0;
   
   OPEN cs_posting_type;
   FETCH cs_posting_type INTO dummy_;
   IF (cs_posting_type%NOTFOUND) THEN
      CLOSE cs_posting_type;
      Error_SYS.Appl_General(lu_name_, 'NOPOSTINGTYPE: Posting type :P1 is missing in Posting Control', posting_type_);
   END IF;
   CLOSE cs_posting_type;

   FOR control_type_rec IN cs_control_type LOOP
      rows_ := rows_ + 1;
      control_type_tab_(rows_)      := control_type_rec.control_type;
      control_type_lu_tab_(rows_)   := control_type_rec.module;
   END LOOP;

   Posting_Ctrl_Posting_Type_API.Get_Module_(module_, posting_type_);
EXCEPTION
   WHEN no_control_type THEN
      Error_SYS.Appl_General(lu_name_, 'NOCTRLT: Control types is missing for posting type :P1', posting_type_);
END Get_Control_Type;


@SecurityCheck Company.UserAuthorized(company_)
PROCEDURE Get_Control_Type (
   control_type_attr_ OUT VARCHAR2,
   company_           IN  VARCHAR2,
   posting_type_      IN  VARCHAR2 )
IS
   CURSOR get_controltype_and_module IS
      SELECT control_type, module
      FROM   POSTING_CTRL_TAB
      WHERE  company = company_
      AND    posting_type = posting_type_
      ORDER BY control_type;
   control_type_   POSTING_CTRL_TAB.control_type%TYPE;
   module_         POSTING_CTRL_TAB.module%TYPE;
   temp_attr_      VARCHAR2(5200);
BEGIN
   OPEN get_controltype_and_module;
   temp_attr_ := NULL;
   LOOP
      FETCH get_controltype_and_module INTO control_type_, module_;
      EXIT WHEN get_controltype_and_module%NOTFOUND;
      Client_SYS.Add_To_Attr('CONTROL_TYPE', control_type_, temp_attr_);
      Client_SYS.Add_To_Attr('MODULE', module_, temp_attr_);
   END LOOP;
   CLOSE get_controltype_and_module;
   control_type_attr_ := temp_attr_;
END Get_Control_Type;


@UncheckedAccess
FUNCTION Get_Control_Type (
   company_          IN     VARCHAR2,
   posting_type_     IN     VARCHAR2 ) RETURN VARCHAR2
IS
   con_type_          VARCHAR2(10);

   CURSOR getctrltype IS
      SELECT control_type 
      FROM POSTING_CTRL_TAB
      WHERE  company      = company_
      AND    posting_type = posting_type_;

BEGIN
   OPEN   getctrltype;
   FETCH  getctrltype INTO con_type_;
   CLOSE  getctrltype;
   RETURN con_type_;

END Get_Control_Type;


PROCEDURE Build_Codestr_Rec (
   codestring_rec_      IN OUT Accounting_Codestr_API.CodestrRec,
   date_                IN     DATE,
   company_             IN     VARCHAR2,
   posting_type_        IN     VARCHAR2,
   control_type_lu_tab_ IN     CtrlTypLuTab,
   control_type_tab_    IN     CtrlTypTab,
   control_value_tab_   IN     CtrlValTab )
IS
   rows_               NUMBER := 1;
   control_value_      VARCHAR2(50);
   control_type_       VARCHAR2(10);
   module_             VARCHAR2(20);
   code_part_tab_      Posting_Ctrl_API.CodePartTab;
   
BEGIN
   codestring_rec_.code_a := NULL;
   codestring_rec_.code_b := NULL;
   codestring_rec_.code_c := NULL;
   codestring_rec_.code_d := NULL;
   codestring_rec_.code_e := NULL;
   codestring_rec_.code_f := NULL;
   codestring_rec_.code_g := NULL;
   codestring_rec_.code_h := NULL;
   codestring_rec_.code_i := NULL;
   codestring_rec_.code_j := NULL;
   LOOP
      module_           := control_type_lu_tab_(rows_);
      control_type_     := control_type_tab_(rows_);
      control_value_    := control_value_tab_(rows_);
      Get_Codepart_Tab__( code_part_tab_,
                          company_,
                          posting_type_,
                          module_,
                          control_type_);
      Load_Codepart_Value__( codestring_rec_, code_part_tab_, date_, company_,
                  posting_type_, control_value_, module_, control_type_);
      rows_ := rows_ + 1;
   END LOOP;
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      NULL;
END Build_Codestr_Rec;

@SecurityCheck Company.UserAuthorized(company_)
PROCEDURE Posting_Event (
   codestring_rec_    OUT Accounting_Codestr_API.CodestrRec,
   company_           IN  VARCHAR2,
   posting_type_      IN  VARCHAR2,
   date_              IN  DATE,
   control_type_attr_ IN  VARCHAR2 )
IS
BEGIN
   Posting_Event___(codestring_rec_, company_, posting_type_, date_, control_type_attr_, NULL);
END Posting_Event;

-- Note: Please use this method only when project_id is not null and Project_Access_API.Has_User_Project_Access check is essential. 
--       Try to use overloaded method with company security check if possible. 
--       Calling this method can skip company security check in certain conditions.
@ServerOnlyAccess
PROCEDURE Posting_Event (
   codestring_rec_    OUT Accounting_Codestr_API.CodestrRec,
   company_           IN  VARCHAR2,
   posting_type_      IN  VARCHAR2,
   date_              IN  DATE,
   control_type_attr_ IN  VARCHAR2,
   project_id_        IN  VARCHAR2)
IS
   check_company_security_ BOOLEAN := FALSE;
BEGIN
   IF project_id_ IS NOT NULL THEN 
      $IF Component_Proj_SYS.INSTALLED $THEN
         IF Project_Access_API.Has_User_Project_Access(project_id_) = 1 THEN
            -- Note: by pass the company security check in this senario.
            check_company_security_ := FALSE;
         ELSE
            check_company_security_ := TRUE;
         END IF;
      $ELSE
         check_company_security_ := TRUE;
      $END
   ELSE
      check_company_security_ := TRUE;
   END IF;
   IF check_company_security_ THEN
      Posting_Event(codestring_rec_, company_, posting_type_, date_, control_type_attr_);
   ELSE
      Posting_Event___(codestring_rec_, company_, posting_type_, date_, control_type_attr_, project_id_);
   END IF;
END Posting_Event;

@SecurityCheck Company.UserAuthorized(company_)
PROCEDURE Posting_Event_Curr_Rev (
   codestring_rec_    OUT Accounting_Codestr_API.CodestrRec,
   company_           IN VARCHAR2,
   posting_type_      IN VARCHAR2,
   date_              IN DATE,
   control_type_attr_ IN VARCHAR2,
   account_method_    IN VARCHAR2,
   code_part_method_  IN VARCHAR2,
   gain_loss_method_  IN VARCHAR2 )
IS
   ptr_                       NUMBER;
   name_                      VARCHAR2(30);
   value_                     VARCHAR2(100);
   control_type_value_table_  Posting_Ctrl_Public_API.control_type_value_table;
   dummy_                     NUMBER;
   CURSOR get_all_control_type IS
      SELECT 1
      FROM   POSTING_CTRL_TAB
      WHERE  company      = company_
      AND    posting_type = posting_type_;
BEGIN
   OPEN get_all_control_type;
   FETCH get_all_control_type INTO dummy_;

   IF (get_all_control_type%NOTFOUND) THEN
      IF (posting_type_='GP9' AND account_method_ = 'ORIGINAL' AND code_part_method_ = 'POSTCTRL') THEN
         NULL;
      ELSIF (posting_type_='GP19' AND account_method_ = 'ORIGINAL' AND code_part_method_ = 'POSTCTRL') THEN
         NULL;         
      ELSE
         CLOSE get_all_control_type;      
         Error_SYS.Appl_General(lu_name_, 'NOPOSTINGTYPE: Posting type :P1 is missing in Posting Control', posting_type_);
      END IF;
   END IF;
   CLOSE get_all_control_type;

   ptr_ := NULL;
   WHILE (Client_SYS.Get_Next_From_Attr(control_type_attr_, ptr_, name_, value_)) LOOP
      IF (name_ IS NOT NULL) THEN
         control_type_value_table_(name_) := value_;
      END IF;
   END LOOP;   

   Posting_Ctrl_Public_API.Build_Codestring_Rec(codestring_rec_,
                                                control_type_value_table_,
                                                date_,
                                                posting_type_,
                                                company_,
                                                account_method_,
                                                code_part_method_,
                                                gain_loss_method_ );

   Accounting_Codestr_API.Complete_Codestring(codestring_rec_,
                                              company_,
                                              posting_type_,
                                              date_);

   Check_Account_Valid_Date___(codestring_rec_,
                               company_,
                               posting_type_,
                               date_);

   IF (codestring_rec_.code_a IS NULL) THEN
      IF ((posting_type_ = 'GP9' AND account_method_ = 'POSTCTRL') OR posting_type_ IN ('GP10','GP11') OR
          (posting_type_ = 'GP19' AND account_method_ = 'POSTCTRL') OR posting_type_ IN ('GP20','GP21')) THEN
         Error_SYS.Record_General(lu_name_, 'NULLACCOUNT: Account not found. :P1Please check definition of posting type :P2 for code part A.', CHR(13) , posting_type_);
      END IF;
   END IF;
END Posting_Event_Curr_Rev;


PROCEDURE Build_Codestring (
   codestring_     OUT VARCHAR2,
   codestring_rec_ IN  Accounting_Codestr_API.CodestrRec )
IS
BEGIN
   codestring_ := codestring_rec_.code_a||'!A!'||
                  codestring_rec_.code_b||'!B!'||
                  codestring_rec_.code_c||'!C!'||
                  codestring_rec_.code_d||'!D!'||
                  codestring_rec_.code_e||'!E!'||
                  codestring_rec_.code_f||'!F!'||
                  codestring_rec_.code_g||'!G!'||
                  codestring_rec_.code_h||'!H!'||
                  codestring_rec_.code_i||'!I!'||
                  codestring_rec_.code_j||'!J!';
END Build_Codestring;


@SecurityCheck Company.UserAuthorized(company_)
FUNCTION Code_Part_Exist (
   company_         IN VARCHAR2,
   code_part_       IN VARCHAR2,
   code_part_value_ IN VARCHAR2 ) RETURN BOOLEAN
IS
   exist_       NUMBER;
   
   CURSOR exist_in_master IS
      SELECT 1
      FROM  POSTING_CTRL_TAB
      WHERE company       = company_
      AND   code_part     = code_part_
      AND   default_value = code_part_value_;
   
   CURSOR exist_in_detail IS
      SELECT 1
      FROM  POSTING_CTRL_DETAIL_TAB
      WHERE company         = company_
      AND   code_part       = code_part_
      AND   code_part_value = code_part_value_;
   
    
   CURSOR exist_in_spec IS
      SELECT 1
      FROM  POSTING_CTRL_DETAIL_SPEC_TAB
      WHERE company         = company_
      AND   code_part       = code_part_
      AND   code_part_value = code_part_value_;
       
   CURSOR exist_in_comb_spec IS 
      SELECT 1
      FROM  POSTING_CTRL_COMB_DET_SPEC_TAB
      WHERE company          = company_
      AND   code_part        = code_part_
      AND   code_part_value  = code_part_value_;
    
    
   CURSOR exist_in_comb_detail IS
      SELECT 1
      FROM  POSTING_CTRL_COMB_DETAIL_TAB
      WHERE company          = company_
      AND   code_part        = code_part_
      AND   code_part_value  = code_part_value_;
      
   
BEGIN
   OPEN exist_in_master;
   FETCH exist_in_master INTO exist_;
   IF (exist_in_master%FOUND) THEN
      CLOSE exist_in_master;
      RETURN(TRUE);
   ELSE
      CLOSE exist_in_master;
      OPEN exist_in_detail;
      FETCH exist_in_detail INTO exist_;
      IF (exist_in_detail%FOUND) THEN
         CLOSE exist_in_detail;
         RETURN(TRUE);
      END IF;
      
      --posting_ctrl_detail_spec_tab
      OPEN exist_in_spec;
      FETCH exist_in_spec INTO exist_;
      IF (exist_in_spec%FOUND) THEN
         CLOSE exist_in_detail;
         RETURN(TRUE);
      END IF;
      
      --posting_ctrl_comb_det_spec_tab
      OPEN exist_in_comb_spec;
      FETCH exist_in_comb_spec INTO exist_;
      IF (exist_in_comb_spec%FOUND) THEN
         CLOSE exist_in_comb_spec;
         RETURN(TRUE);
      END IF;
      
      --posting_ctrl_comb_detail_tab
      OPEN exist_in_comb_detail;
      FETCH exist_in_comb_detail INTO exist_;
      IF (exist_in_comb_detail%FOUND) THEN
         CLOSE exist_in_comb_detail;
         RETURN(TRUE);
      END IF;
      
      CLOSE exist_in_detail;
      CLOSE exist_in_spec;
      CLOSE exist_in_comb_spec;
      CLOSE exist_in_comb_detail;  
         
   END IF;
   RETURN(FALSE);
END Code_Part_Exist;


PROCEDURE Insert_Posting_Type (
   posting_type_        IN VARCHAR2,
   description_         IN VARCHAR2,
   module_              IN VARCHAR2,
   ledg_flag_           IN VARCHAR2,
   tax_flag_            IN VARCHAR2 DEFAULT NULL,
   currev_flag_         IN VARCHAR2 DEFAULT NULL,
   logical_unit_        IN VARCHAR2 DEFAULT NULL, 
   sort_order_          IN NUMBER   DEFAULT NULL,
   allow_prepost_det_   IN VARCHAR2 DEFAULT NULL)
IS
BEGIN
   Posting_Ctrl_Posting_Type_API.Insert_Posting_Type_(posting_type_, description_,
                                                      module_, ledg_flag_, tax_flag_, 
                                                      currev_flag_, logical_unit_, sort_order_,
                                                      allow_prepost_det_); 
END Insert_Posting_Type;


PROCEDURE Remove_Posting_Type (
   posting_type_  IN VARCHAR2 )
IS
BEGIN
   Posting_Ctrl_Posting_Type_API.Remove_Posting_Type_(posting_type_);
END Remove_Posting_Type;


PROCEDURE Modify_Posting_Type (
   posting_type_  IN VARCHAR2,
   description_   IN VARCHAR2,
   module_        IN VARCHAR2 )
IS
BEGIN
   Posting_Ctrl_Posting_Type_API.Modify_Posting_Type_(posting_type_,
                                                      description_,
                                                      module_);
END Modify_Posting_Type;


PROCEDURE Insert_Control_Type (
   control_type_        IN VARCHAR2,
   module_              IN VARCHAR2,
   description_         IN VARCHAR2,
   ctrl_type_category_  IN VARCHAR2,
   view_name_           IN VARCHAR2,
   pkg_name_            IN VARCHAR2,
   logical_unit_        IN VARCHAR2 DEFAULT NULL )
IS
BEGIN
   Posting_Ctrl_Control_Type_API.Insert_Control_Type_(control_type_,
                                                      module_,
                                                      description_,
                                                      ctrl_type_category_,
                                                      view_name_,
                                                      pkg_name_,
                                                      logical_unit_ );
END Insert_Control_Type;


PROCEDURE Remove_Control_Type (
   control_type_     IN VARCHAR2,
   module_           IN VARCHAR2 )
IS
BEGIN
   Posting_Ctrl_Control_Type_API.Remove_Control_Type_(control_type_, module_);
END Remove_Control_Type;


PROCEDURE Modify_Control_Type (
   control_type_        IN VARCHAR2,
   module_              IN VARCHAR2,
   description_         IN VARCHAR2,
   ctrl_type_category_  IN VARCHAR2,
   view_name_           IN VARCHAR2,
   pkg_name_            IN VARCHAR2 )
IS
BEGIN
   Posting_Ctrl_Control_Type_API.Modify_Control_Type_(control_type_,
                                                      module_,
                                                      description_,
                                                      ctrl_type_category_,
                                                      view_name_,
                                                      pkg_name_ );
END Modify_Control_Type;


PROCEDURE Insert_Allowed_Comb (
   posting_type_     IN VARCHAR2,
   control_type_     IN VARCHAR2,
   module_           IN VARCHAR2,
   code_part_        IN VARCHAR2 )
IS
BEGIN
   Posting_Ctrl_Allowed_Comb_API.Insert_Allowed_Comb_(posting_type_, 
                                                      control_type_,
                                                      module_, 
                                                      code_part_);
END Insert_Allowed_Comb;


PROCEDURE Remove_Allowed_Comb(
   posting_type_  IN VARCHAR2,
   control_type_  IN VARCHAR2,
   module_        IN VARCHAR2,
   code_part_     IN VARCHAR2)
IS
BEGIN
   Posting_Ctrl_Allowed_Comb_API.Remove_Allowed_Comb_(posting_type_, 
                                                      control_type_,
                                                      module_, 
                                                      code_part_);
END Remove_Allowed_Comb;


-- The returned values (override flag) in the code string record return db values
@SecurityCheck Company.UserAuthorized(company_)
PROCEDURE Get_Override_Rec (
   override_rec_ IN OUT Accounting_Codestr_API.CodestrRec,
   company_      IN     VARCHAR2,
   posting_type_ IN     VARCHAR2,
   date_         IN     DATE DEFAULT SYSDATE )
IS
BEGIN
   Get_Override_Rec____(override_rec_,
                        company_,
                        posting_type_,
                        date_,
                        FALSE);
END Get_Override_Rec;

PROCEDURE Get_Override_Rec (
   override_rec_     IN OUT NOCOPY Accounting_Codestr_API.CodestrRec,
   no_code_part_rec_ IN OUT NOCOPY Accounting_Codestr_API.CodestrRec,
   company_          IN     VARCHAR2,
   posting_type_     IN     VARCHAR2,
   date_             IN     DATE DEFAULT SYSDATE )
IS   
BEGIN
   Get_Override_Rec____(override_rec_,
                        no_code_part_rec_,
                        company_,
                        posting_type_,
                        date_);
END Get_Override_Rec;

@SecurityCheck Company.UserAuthorized(company_)
PROCEDURE Get_Code_Part (
   codestring_rec_ IN OUT VARCHAR2,
   company_        IN     VARCHAR2,
   posting_type_   IN     VARCHAR2,
   control_type_   IN     VARCHAR2,
   module_         IN     VARCHAR2,
   pc_valid_from_  IN     DATE DEFAULT NULL )
IS
   
BEGIN
   Get_Code_Part___(codestring_rec_, company_, posting_type_, control_type_, pc_valid_from_);
END Get_Code_Part;

-- Note: Please use this method only when project_id is not null and Project_Access_API.Has_User_Project_Access check is essential. 
--       Try to use overloaded method with company security check if possible. 
--       Calling this method can skip company security check in certain conditions.
@ServerOnlyAccess
PROCEDURE Get_Code_Part (
   codestring_rec_ IN OUT VARCHAR2,
   company_        IN     VARCHAR2,
   posting_type_   IN     VARCHAR2,
   control_type_   IN     VARCHAR2,
   module_         IN     VARCHAR2,
   project_id_     IN     VARCHAR2,
   pc_valid_from_  IN     DATE DEFAULT NULL)
IS
   check_company_security_ BOOLEAN := FALSE;   
BEGIN
   IF project_id_ IS NOT NULL THEN 
      $IF Component_Proj_SYS.INSTALLED $THEN
         IF Project_Access_API.Has_User_Project_Access(project_id_) = 1 THEN
            -- Note: by pass the company security check in this senario.
            check_company_security_ := FALSE;
         ELSE
            check_company_security_ := TRUE;
         END IF;
      $ELSE
         check_company_security_ := TRUE;
      $END
   ELSE
      check_company_security_ := TRUE;
   END IF;
   IF check_company_security_ THEN
      Get_Code_Part(codestring_rec_, company_, posting_type_, control_type_, module_, pc_valid_from_);
   ELSE
      Get_Code_Part___(codestring_rec_, company_, posting_type_, control_type_, pc_valid_from_);
   END IF;
END Get_Code_Part;

PROCEDURE Get_Code_Part (
   code_a_            OUT VARCHAR2,
   code_b_            OUT VARCHAR2,
   code_c_            OUT VARCHAR2,
   code_d_            OUT VARCHAR2,
   code_e_            OUT VARCHAR2,
   code_f_            OUT VARCHAR2,
   code_g_            OUT VARCHAR2,
   code_h_            OUT VARCHAR2,
   code_i_            OUT VARCHAR2,
   code_j_            OUT VARCHAR2,
   product_            IN VARCHAR2,
   company_            IN VARCHAR2,
   str_code_           IN VARCHAR2,
   control_type_       IN VARCHAR2 )
IS
   code_part_ VARCHAR2(1);
   --
   CURSOR get_codeparts_1 IS
     SELECT code_part
     FROM   POSTING_CTRL_TAB
     WHERE  company       = company_
     AND    posting_type  = str_code_
     ORDER BY code_part;
   --
   CURSOR get_codeparts_2 IS
     SELECT code_part
     FROM   POSTING_CTRL_TAB
     WHERE  company       = company_
     AND    posting_type  = str_code_
     AND    control_type  = control_type_
     ORDER BY code_part;
BEGIN
   IF (control_type_ IS NULL) THEN
      OPEN get_codeparts_1;
      WHILE(TRUE) LOOP
         FETCH get_codeparts_1 INTO code_part_;
         IF code_part_ = 'A' THEN
            code_a_ := code_part_;
         END IF;
         IF code_part_ = 'B' THEN
            code_b_ := code_part_;
         END IF;
         IF code_part_ = 'C' THEN
            code_c_ := code_part_;
         END IF;
         IF code_part_ = 'D' THEN
            code_d_ := code_part_;
         END IF;
         IF code_part_ = 'E' THEN
            code_e_ := code_part_;
         END IF;
         IF code_part_ = 'F' THEN
            code_f_ := code_part_;
         END IF;
         IF code_part_ = 'G' THEN
            code_g_ := code_part_;
         END IF;
         IF code_part_ = 'H' THEN
            code_h_ := code_part_;
         END IF;
         IF code_part_ = 'I' THEN
            code_i_ := code_part_;
         END IF;
         IF code_part_ = 'J' THEN
            code_j_ := code_part_;
         END IF;
         EXIT WHEN get_codeparts_1%NOTFOUND;
      END LOOP;
      CLOSE get_codeparts_1;
   ELSE
      OPEN  get_codeparts_2;
      WHILE(TRUE) LOOP
         FETCH get_codeparts_2 INTO code_part_;
         IF code_part_ = 'A' THEN
            code_a_ := code_part_;
         END IF;
         IF code_part_ = 'B' THEN
            code_b_ := code_part_;
         END IF;
         IF code_part_ = 'C' THEN
            code_c_ := code_part_;
         END IF;
         IF code_part_ = 'D' THEN
            code_d_ := code_part_;
         END IF;
         IF code_part_ = 'E' THEN
            code_e_ := code_part_;
         END IF;
         IF code_part_ = 'F' THEN
            code_f_ := code_part_;
         END IF;
         IF code_part_ = 'G' THEN
            code_g_ := code_part_;
         END IF;
         IF code_part_ = 'H' THEN
            code_h_ := code_part_;
         END IF;
         IF code_part_ = 'I' THEN
            code_i_ := code_part_;
         END IF;
         IF code_part_ = 'J' THEN
            code_j_ := code_part_;
         END IF;
         EXIT WHEN get_codeparts_2%NOTFOUND;
      END LOOP;
      CLOSE get_codeparts_2;
   END IF;
END Get_Code_Part;


@UncheckedAccess
FUNCTION Get_Code_Part_Value (
   company_        IN     VARCHAR2,
   posting_type_   IN     VARCHAR2,
   control_type_   IN     VARCHAR2,
   code_part_      IN     VARCHAR2,
   module_         IN     VARCHAR2,
   in_date_        IN     DATE DEFAULT SYSDATE) RETURN VARCHAR2 
IS 
   code_value_    VARCHAR2(30);
   date_          DATE := Trunc(NVL(in_date_, SYSDATE));
   CURSOR get_codeparts_value IS
     SELECT default_value
     FROM   POSTING_CTRL_TAB
     WHERE  company       = company_
     AND    posting_type  = posting_type_
     AND    control_type  = control_type_
     AND    module        = module_
     AND    code_part     = code_part_
     AND    pc_valid_from <= date_
     ORDER BY pc_valid_from desc;
BEGIN
   OPEN get_codeparts_value;
   FETCH get_codeparts_value INTO code_value_;
   CLOSE get_codeparts_value;
   RETURN code_value_;
END Get_Code_Part_Value;


@UncheckedAccess
FUNCTION Get_Default_Value (
   company_       IN VARCHAR2,
   posting_type_  IN VARCHAR2,
   code_part_     IN VARCHAR2,
   in_date_       IN DATE DEFAULT SYSDATE) RETURN VARCHAR2
IS   
   date_       DATE := Trunc(NVL(in_date_, SYSDATE));
BEGIN
   RETURN Get_Default_Value___(company_, posting_type_, code_part_, date_);
END Get_Default_Value;


PROCEDURE Get_Default_Value (
   default_value_ IN OUT VARCHAR2,
   company_       IN VARCHAR2,
   posting_type_  IN VARCHAR2,
   code_part_     IN VARCHAR2,
   in_date_       IN DATE DEFAULT SYSDATE)
IS
   date_       DATE := Trunc(NVL(in_date_, SYSDATE));
BEGIN
   default_value_ := NULL;
   default_value_ := Get_Default_Value___(company_, posting_type_, code_part_, date_);
END Get_Default_Value;


@UncheckedAccess
FUNCTION Get_Posting_Type_Desc (
   company_       IN VARCHAR2,
   posting_type_  IN VARCHAR2 ) RETURN VARCHAR2
IS   
   description_   VARCHAR2(200);  
BEGIN    
    description_ := Posting_Ctrl_Posting_Type_API.Get_Description(posting_type_);
    RETURN description_;
END Get_Posting_Type_Desc;

@SecurityCheck Company.UserAuthorized(company_)
FUNCTION Exist_Posting_Control (
   company_       IN VARCHAR2,
   posting_type_  IN VARCHAR2,
   control_type_  IN VARCHAR2,
   code_part_     IN VARCHAR2 ) RETURN BOOLEAN
IS
BEGIN
   RETURN Exist_Posting_Control___(company_, posting_type_, control_type_, code_part_);
END Exist_Posting_Control;

-- Note: Please use this method only when project_id is not null and Project_Access_API.Has_User_Project_Access check is essential. 
--       Try to use overloaded method with company security check if possible. 
--       Calling this method can skip company security check in certain conditions.
@ServerOnlyAccess
FUNCTION Exist_Posting_Control (
   company_       IN VARCHAR2,
   posting_type_  IN VARCHAR2,
   control_type_  IN VARCHAR2,
   code_part_     IN VARCHAR2,
   project_id_    IN VARCHAR2) RETURN BOOLEAN
IS
   check_company_security_ BOOLEAN := FALSE;
BEGIN
   IF project_id_ IS NOT NULL THEN 
      $IF Component_Proj_SYS.INSTALLED $THEN
         IF Project_Access_API.Has_User_Project_Access(project_id_) = 1 THEN
            -- Note: by pass the company security check in this senario.
            check_company_security_ := FALSE;
         ELSE
            check_company_security_ := TRUE;
         END IF;
      $ELSE
         check_company_security_ := TRUE;
      $END
   ELSE
      check_company_security_ := TRUE;
   END IF;
   IF check_company_security_ THEN 
      RETURN Exist_Posting_Control(company_, posting_type_, control_type_, code_part_);
   ELSE
      RETURN Exist_Posting_Control___(company_, posting_type_, control_type_, code_part_);
   END IF;
END Exist_Posting_Control;

@SecurityCheck Company.UserAuthorized(company_)
PROCEDURE Insert_Posting_Control (
   company_             IN VARCHAR2,
   posting_type_        IN VARCHAR2,
   code_part_           IN VARCHAR2,
   control_type_        IN VARCHAR2,
   module_              IN VARCHAR2,
   override_            IN VARCHAR2,
   default_value_       IN VARCHAR2,
   default_value_no_ct_ IN VARCHAR2 DEFAULT NULL,
   pc_valid_from_       IN DATE     DEFAULT NULL)
IS
   newrec_        posting_ctrl_tab%ROWTYPE;
   exist_         VARCHAR2(1);
   tmp_pc_valid_from_    DATE;
   CURSOR get_posting IS
      SELECT 'X'
      FROM   POSTING_CTRL_TAB
      WHERE  company = company_
      AND    posting_type = posting_type_
      AND    code_part = code_part_
      AND    pc_valid_from = tmp_pc_valid_from_;
BEGIN
   tmp_pc_valid_from_ := nvl(pc_valid_from_, Company_Finance_API.Get_Valid_From(company_));
   OPEN get_posting;
   FETCH get_posting INTO exist_;
   IF (get_posting%NOTFOUND) THEN
      newrec_.company               := company_;
      newrec_.posting_type          := posting_type_;
      newrec_.code_part             := code_part_;
      newrec_.pc_valid_from         := trunc(tmp_pc_valid_from_);
      newrec_.control_type          := control_type_;
      newrec_.module                := module_;
      newrec_.override              := override_;
      newrec_.default_value         := default_value_;
      newrec_.default_value_no_ct   := default_value_no_ct_;
      newrec_.ctrl_type_category    := Get_Ctrl_Type_Category___(company_,
                                                                 posting_type_,
                                                                 control_type_,
                                                                 code_part_);
      New___(newrec_);                                                 
   END IF;
   CLOSE get_posting;
END Insert_Posting_Control;


PROCEDURE Insert_Posting_Control_Detail (
   company_             IN VARCHAR2,
   posting_type_        IN VARCHAR2,
   code_part_           IN VARCHAR2,
   code_part_value_     IN VARCHAR2,
   control_type_        IN VARCHAR2,
   control_type_value_  IN VARCHAR2,
   module_              IN VARCHAR2,
   valid_from_          IN DATE,
   pc_valid_from_       IN DATE     DEFAULT NULL,
   spec_control_type_   IN VARCHAR2 DEFAULT NULL,
   spec_module_         IN VARCHAR2 DEFAULT NULL,
   spec_default_value_  IN VARCHAR2 DEFAULT NULL,
   spec_default_value_no_ct_ IN VARCHAR2 DEFAULT NULL,
   no_code_part_value_db_  IN VARCHAR2 DEFAULT 'FALSE')
IS
   objid_               VARCHAR2(100);
   attr_                VARCHAR2(2000);
   info_                VARCHAR2(2000);
   objversion_          VARCHAR2(2000);
   tmp_pc_valid_from_   DATE;
BEGIN
   tmp_pc_valid_from_ := nvl(pc_valid_from_, Company_Finance_API.Get_Valid_From(company_));

   -- don't insert details if master doesn't exist
   IF NOT Check_Exist__(company_, code_part_, posting_type_, control_type_, tmp_pc_valid_from_) THEN
      RETURN;
   END IF;

   IF (Company_Finance_API.Is_User_Authorized(company_ )) THEN
      Client_SYS.Clear_Attr(attr_);
      Client_SYS.Add_To_Attr( 'COMPANY', company_, attr_);
      Client_SYS.Add_To_Attr( 'POSTING_TYPE', posting_type_, attr_);
      Client_SYS.Add_To_Attr( 'PC_VALID_FROM', trunc(tmp_pc_valid_from_), attr_);
      Client_SYS.Add_To_Attr( 'CODE_PART', code_part_, attr_);
      Client_SYS.Add_To_Attr( 'CODE_PART_VALUE', code_part_value_, attr_);
      Client_SYS.Add_To_Attr( 'CONTROL_TYPE', control_type_, attr_);
      Client_SYS.Add_To_Attr( 'CONTROL_TYPE_VALUE', control_type_value_, attr_);
      Client_SYS.Add_To_Attr( 'MODULE', module_, attr_);
      Client_SYS.Add_To_Attr( 'VALID_FROM', valid_from_, attr_);
      Client_SYS.Add_To_Attr( 'SPEC_CONTROL_TYPE', spec_control_type_, attr_);
      Client_SYS.Add_To_Attr( 'SPEC_MODULE', spec_module_, attr_);
      Client_SYS.Add_To_Attr( 'SPEC_DEFAULT_VALUE', spec_default_value_, attr_);
      Client_SYS.Add_To_Attr( 'SPEC_DEFAULT_VALUE_NO_CT', spec_default_value_no_ct_, attr_);
      IF (spec_control_type_ IS NOT NULL) THEN
         Client_SYS.Add_To_Attr('SPEC_CTRL_TYPE_CATEGORY_DB',
                                Get_Ctrl_Type_Category___(company_, 
                                                          posting_type_, 
                                                          spec_control_type_, 
                                                          code_part_), 
                                attr_);
      END IF;
      Client_SYS.Add_To_Attr( 'NO_CODE_PART_VALUE_DB', no_code_part_value_db_, attr_);
      Posting_Ctrl_Detail_API.New__( info_, objid_, objversion_, attr_, 'DO' );
   END IF;
END Insert_Posting_Control_Detail;


PROCEDURE Modify_Posting_Control (
   posting_type_     IN VARCHAR2,
   old_control_type_ IN VARCHAR2,
   new_control_type_ IN VARCHAR2,
   old_module_       IN VARCHAR2,
   new_module_       IN VARCHAR2 )
IS
BEGIN   
   --posting_ctrl_tab
   UPDATE posting_ctrl_tab
      SET   module = new_module_,
            control_type = new_control_type_
      WHERE posting_type = posting_type_
      AND   control_type = old_control_type_
      AND   module = old_module_;
   
   -- posting_ctrl_detail_tab
   UPDATE posting_ctrl_detail_tab
      SET   module             = DECODE(control_type, old_control_type_, new_module_,module), 
            control_type       = DECODE(control_type, old_control_type_, new_control_type_,control_type),
            spec_module        = DECODE(spec_control_type, old_control_type_, new_module_,spec_module), 
            spec_control_type  = DECODE(spec_control_type, old_control_type_,new_control_type_,spec_control_type)
      WHERE posting_type       = posting_type_
      AND   ((control_type     = old_control_type_ AND module = old_module_)
      OR    (spec_control_type = old_control_type_ AND spec_module = old_module_ AND (spec_ctrl_type_category IN ( 'ORDINARY', 'SYSTEM_DEFINED', 'COMBINATION'))));
   
   --posting_ctrl_detail_spec_tab
   UPDATE posting_ctrl_detail_spec_tab
      SET   spec_module       = new_module_,
            spec_control_type = new_control_type_
      WHERE posting_type      = posting_type_
      AND   spec_control_type = old_control_type_
      AND   spec_module       = old_module_;

   --comb_control_type_tab
   UPDATE comb_control_type_tab
      SET   module1         = DECODE(control_type1, old_control_type_, new_module_,module1), 
            control_type1   = DECODE(control_type1, old_control_type_, new_control_type_, control_type1),
            module2         = DECODE(control_type2, old_control_type_, new_module_, module2),
            control_type2   = DECODE(control_type2, old_control_type_, new_control_type_, control_type2)
      WHERE posting_type    = posting_type_
      AND   ((control_type1 = old_control_type_ AND   module1 = old_module_)
      OR    ( control_type2 = old_control_type_ AND   module2 = old_module_));

   --   posting_ctrl_comb_det_spec_tab
   UPDATE posting_ctrl_comb_det_spec_tab
      SET   spec_module1       = DECODE(spec_control_type1,old_control_type_, new_module_, spec_module1),
            spec_control_type1 = DECODE(spec_control_type1,old_control_type_, new_control_type_, spec_control_type1),
            spec_module2       = DECODE(spec_control_type2,old_control_type_, new_module_,spec_module2),
            spec_control_type2 = DECODE(spec_control_type2,old_control_type_, new_control_type_, spec_control_type2)
      WHERE posting_type       = posting_type_
      AND   ((spec_control_type1 = old_control_type_ AND spec_module1 = old_module_)
      OR   (spec_control_type2  = old_control_type_ AND spec_module2 = old_module_));

   -- posting_ctrl_comb_detail_tab
   UPDATE posting_ctrl_comb_detail_tab
      SET   module1       = DECODE(control_type1, old_control_type_,new_module_ , module1),
            control_type1 = DECODE(control_type1, old_control_type_,new_control_type_, control_type1),
            module2       = DECODE(control_type2, old_control_type_,new_module_, module2),
            control_type2 = DECODE(control_type2, old_control_type_,new_control_type_, control_type2)
      WHERE posting_type  = posting_type_
      AND   ((control_type1 = old_control_type_ AND module1 = old_module_)
      OR    (control_type2  = old_control_type_ AND module2 = old_module_));
   
END Modify_Posting_Control;

PROCEDURE Modify_Postin_Type_Comb_Module (
   posting_type_     IN VARCHAR2,
   old_module_       IN VARCHAR2,
   new_module_       IN VARCHAR2 )
IS
BEGIN
   --comb_control_type_tab
   UPDATE comb_control_type_tab
      SET   comb_module       = new_module_
      WHERE posting_type      = posting_type_
      AND   comb_module       = old_module_;

   -- posting_ctrl_comb_detail_tab
   UPDATE posting_ctrl_comb_detail_tab
      SET   comb_module      = new_module_
      WHERE posting_type    = posting_type_
      AND   comb_module     = old_module_;
END Modify_Postin_Type_Comb_Module;

PROCEDURE Remove_Posting_Control_Details (
   company_       IN VARCHAR2,
   code_part_     IN VARCHAR2,
   posting_type_  IN VARCHAR2,
   pc_valid_from_ IN DATE )
IS
   CURSOR getrec_rowid IS
      SELECT *
      FROM  POSTING_CTRL_DETAIL_TAB
      WHERE company       = company_
      AND   code_part     = code_part_
      AND   posting_type  = posting_type_
      AND   pc_valid_from = pc_valid_from_;
BEGIN
   FOR rec_counter IN getrec_rowid LOOP
      Posting_Ctrl_Detail_API.Remove_Posting_Control_Detail(rec_counter.company,
                                                            rec_counter.code_part,
                                                            rec_counter.posting_type,
                                                            rec_counter.pc_valid_from,
                                                            rec_counter.control_type_value,
                                                            rec_counter.valid_from,
                                                            rec_counter.code_part_value);
   END LOOP;
END Remove_Posting_Control_Details;


PROCEDURE Remove_Posting_Control (
   company_      IN VARCHAR2,
   posting_type_ IN VARCHAR2,
   code_part_    IN VARCHAR2,
   control_type_ IN VARCHAR2,
   module_       IN VARCHAR2 )
IS
BEGIN
   -- posting_ctrl_detail_spec_tab
   DELETE 
      FROM posting_ctrl_detail_spec_tab t		
      WHERE company = decode(company_, NULL, company, company_)
      AND   posting_type = posting_type_
      AND   code_part    = decode(code_part_, NULL, code_part, code_part_)
      AND   EXISTS (SELECT 1
                    FROM  Posting_Ctrl_Detail_Tab t2
                    WHERE t.company       = t2.company
                    AND   t.posting_type  = t2.posting_type
                    AND   t.code_part     = t2.code_part
                    AND   t.pc_valid_from = t2.pc_valid_from
                    AND   t2.control_type = control_type_
                    AND   t2.module       = module_);

    -- posting_ctrl_comb_det_spec_tab
   DELETE 
      FROM posting_ctrl_comb_det_spec_tab t
      WHERE  company = decode(company_, NULL, company, company_)
      AND    posting_type = posting_type_
      AND    code_part = decode(code_part_, NULL, code_part, code_part_)
      AND    EXISTS (SELECT 1
                     FROM  Posting_Ctrl_Detail_Tab t2
                     WHERE t.company       = t2.company
                     AND   t.posting_type  = t2.posting_type
                     AND   t.code_part     = t2.code_part
                     AND   t.pc_valid_from = t2.pc_valid_from
                     AND   t2.control_type = control_type_
                     AND   t2.module       = module_);

    -- posting_ctrl_detail_tab
   DELETE 
      FROM posting_ctrl_detail_tab
      WHERE company = decode(company_, NULL, company, company_)
      AND   posting_type = posting_type_
      AND   code_part = decode(code_part_, NULL, code_part, code_part_)
      AND   control_type = control_type_
      AND   module = module_;

   -- posting_ctrl_comb_detail_tab
   DELETE 
      FROM posting_ctrl_comb_detail_tab t
      WHERE company      = decode(company_, NULL, company, company_)
      AND   posting_type = posting_type_
      AND   code_part    = decode(code_part_, NULL, code_part, code_part_)
      AND   EXISTS (SELECT 1                        
                    FROM  Posting_Ctrl_Tab t2
                    WHERE t.company       = t2.company
                    AND   t.posting_type  = t2.posting_type
                    AND   t.code_part     = t2.code_part
                    AND   t.pc_valid_from = t2.pc_valid_from
                    AND   t2.control_type = control_type_
                    AND   t2.module       = module_);

   -- posting_ctrl_tab
   DELETE 
      FROM posting_ctrl_tab
      WHERE company = decode(company_, NULL, company, company_)
      AND   posting_type = posting_type_
      AND   code_part = decode(code_part_, NULL, code_part, code_part_)
      AND   control_type = control_type_
      AND   module = module_;
END Remove_Posting_Control;


@SecurityCheck Company.UserAuthorized(company_)
PROCEDURE Account_Exist (
   company_ IN VARCHAR2,
   account_ IN VARCHAR2 )
IS
   postings_   NUMBER;
   CURSOR check_account IS
      SELECT 1
      FROM   POSTING_CTRL_TAB
      WHERE  (default_value = account_ OR default_value_no_ct = account_)
      AND    company = company_
      AND    code_part = 'A';
BEGIN
   OPEN check_account;
   FETCH check_account INTO postings_;
   IF (check_account%FOUND) THEN
      CLOSE check_account;
      Error_SYS.Record_General('PostingCtrl', 'ACCNTEXISTS: The account :P1 exists in posting control ', account_);
   END IF;
   CLOSE check_account;
END Account_Exist;


@UncheckedAccess
FUNCTION Posting_Type_Exist (
   company_      IN VARCHAR2,
   code_part_    IN VARCHAR2,
   posting_type_ IN VARCHAR2 ) RETURN BOOLEAN
IS
   max_date_     DATE;
BEGIN
   max_date_ := Get_Max_Date___(company_, posting_type_, code_part_, TRUNC(SYSDATE));
   RETURN Check_Exist___(company_, code_part_, posting_type_, max_date_);
END Posting_Type_Exist;


@UncheckedAccess
FUNCTION Posting_Type_Exist (
   company_      IN VARCHAR2,
   posting_type_ IN VARCHAR2 ) RETURN BOOLEAN
IS
   dummy_ NUMBER;
   CURSOR exist_control IS
      SELECT 1
      FROM   POSTING_CTRL_TAB
      WHERE  company = company_
      AND    posting_type = posting_type_;
BEGIN
   OPEN exist_control;
   FETCH exist_control INTO dummy_;
   IF (exist_control%FOUND) THEN
      CLOSE exist_control;
      RETURN(TRUE);
   END IF;
   CLOSE exist_control;
   RETURN(FALSE);
END Posting_Type_Exist;


@UncheckedAccess
FUNCTION Get_Control_Type_Key (
   company_          IN     VARCHAR2,
   posting_type_     IN     VARCHAR2,
   code_part_        IN     VARCHAR2 ) RETURN VARCHAR2

IS
   con_type_          VARCHAR2(10);

   CURSOR getctrltype IS
      SELECT control_type 
      FROM POSTING_CTRL_TAB
      WHERE  company      = company_
      AND    posting_type = posting_type_
      AND    code_part    = code_part_;
BEGIN
   OPEN   getctrltype;
   FETCH  getctrltype INTO con_type_;
   CLOSE  getctrltype;
   RETURN con_type_;
END Get_Control_Type_Key;


@UncheckedAccess
FUNCTION Get_Control_Type_Key (
   company_          IN     VARCHAR2,
   posting_type_     IN     VARCHAR2,
   code_part_        IN     VARCHAR2,
   pc_valid_from_    IN     DATE ) RETURN VARCHAR2
IS
   control_type_   VARCHAR2(10);

   CURSOR get_ctrl_type IS
      SELECT control_type 
      FROM POSTING_CTRL_TAB
      WHERE company     = company_
      AND posting_type  = posting_type_
      AND code_part     = code_part_
      AND pc_valid_from = pc_valid_from_;
BEGIN
   OPEN   get_ctrl_type;
   FETCH  get_ctrl_type INTO control_type_;
   CLOSE  get_ctrl_type;
   RETURN control_type_;
END Get_Control_Type_Key;   


@UncheckedAccess
FUNCTION Get_Current_Control_Type (
   company_          IN     VARCHAR2,
   posting_type_     IN     VARCHAR2,
   code_part_        IN     VARCHAR2 ) RETURN VARCHAR2
IS
   count_          NUMBER;
   control_type_   VARCHAR2(10);

   CURSOR get_count IS
      SELECT count(*)
      FROM POSTING_CTRL_TAB
      WHERE company     = company_
      AND posting_type  = posting_type_
      AND code_part     = code_part_;
   
   CURSOR get_ctrl_type IS
      SELECT control_type 
      FROM POSTING_CTRL_TAB
      WHERE company       = company_
        AND posting_type  = posting_type_
        AND code_part     = code_part_;
BEGIN
   -- if there is only one row - return ctrl type
   -- if there are more rows - return '*'
   OPEN get_count;
   FETCH get_count INTO count_;
   CLOSE get_count;

   IF (count_ = 1) THEN
      OPEN  get_ctrl_type;
      FETCH get_ctrl_type INTO control_type_;
      CLOSE get_ctrl_type;
   ELSIF (count_ > 1) THEN
      control_type_ := '*';
   END IF;
   
   RETURN control_type_;
END Get_Current_Control_Type;   


@UncheckedAccess
FUNCTION Is_Detail_Spec (
   company_          IN     VARCHAR2,
   posting_type_     IN     VARCHAR2,
   code_part_        IN     VARCHAR2 ) RETURN VARCHAR2
IS
   dummy_  NUMBER;
   
   CURSOR spec_exist IS
      SELECT 1 
      FROM posting_ctrl_detail_spec_tab
      WHERE company      = company_
      AND posting_type   = posting_type_
      AND code_part      = code_part_;
BEGIN
   OPEN   spec_exist;
   FETCH  spec_exist INTO dummy_;
   IF (spec_exist%FOUND) THEN
      CLOSE  spec_exist;
      RETURN 'TRUE';
   ELSE
      CLOSE  spec_exist;
      RETURN 'FALSE';
   END IF;
END Is_Detail_Spec;   


@UncheckedAccess
FUNCTION Is_Cct_Used (
   company_             IN VARCHAR2,
   comb_control_type_   IN VARCHAR2,
   posting_type_        IN VARCHAR2 ) RETURN VARCHAR2
IS
   ctrl_type_           NUMBER;
   cct_flag_            VARCHAR2(5);

   CURSOR iscmbtypeused IS
      SELECT 1 
      FROM   POSTING_CTRL_TAB
      WHERE  company            = company_
      AND    control_type       = comb_control_type_
      AND    posting_type       = posting_type_
      AND    ctrl_type_category = 'COMBINATION';
BEGIN
   cct_flag_ := 'FALSE';
   OPEN  iscmbtypeused;
   FETCH iscmbtypeused INTO ctrl_type_;
   IF (iscmbtypeused%FOUND) THEN
      cct_flag_ := 'TRUE';
   END IF;
   CLOSE iscmbtypeused;
   RETURN cct_flag_;
END Is_Cct_Used;


PROCEDURE Copy_Details_Set_Up (
   company_          IN VARCHAR2,
   posting_type_     IN VARCHAR2,
   new_posting_type_ IN VARCHAR2 )  
IS
   max_date_          DATE;
   exist_             BOOLEAN;
   new_pc_valid_from_ DATE;
   code_part_         VARCHAR2(1);
BEGIN
   FOR i_ IN 1..10 LOOP
      code_part_ := CHR(64+i_);
      max_date_ := Get_Max_Date___(company_,
                                   posting_type_,
                                   code_part_,
                                   TRUNC(SYSDATE));
      IF ((NVL(Get_Ctrl_Type_Category_Db(company_, code_part_, posting_type_, max_date_),'COMBINATION') != 'COMBINATION') AND
          (Exist_Comb_In_Detail(company_, posting_type_, code_part_, max_date_) != 'TRUE')) THEN
                                 
         exist_ := Check_Exist___(company_,
                                  code_part_,
                                  new_posting_type_,
                                  max_date_);
         IF NOT (exist_) THEN
            Copy_Details_Set_Up(company_,
                                posting_type_,
                                code_part_,    
                                max_date_,    
                                new_posting_type_,
                                'FALSE',
                                new_pc_valid_from_);
         END IF;
      END IF;
   END LOOP;
END Copy_Details_Set_Up;


PROCEDURE Copy_Details_Set_Up (
   company_           IN VARCHAR2,
   posting_type_      IN VARCHAR2,
   code_part_         IN VARCHAR2,
   pc_valid_from_     IN DATE,
   new_posting_type_  IN VARCHAR2,
   overwrite_         IN VARCHAR2, 
   new_pc_valid_from_ IN DATE DEFAULT NULL)
IS
   objid_              VARCHAR2(20);
   objversion_         VARCHAR2(20);
   info_               VARCHAR2(100);
   attr_               VARCHAR2(2000);
   pc_valid_from_new_  DATE;
   master_             posting_ctrl_tab%ROWTYPE;
   control_type_value_ posting_ctrl_tab.control_type%TYPE;
   p_ctrl_comb_det_spec_rec_  posting_ctrl_comb_det_spec_tab%ROWTYPE;

   CURSOR check_removal IS
      SELECT objid, objversion
      FROM posting_ctrl
      WHERE company = company_
        AND posting_type = new_posting_type_
        AND code_part = code_part_
        AND pc_valid_from = pc_valid_from_new_;

   CURSOR get_master IS
      SELECT *
      FROM   posting_ctrl_tab
      WHERE  company       = company_
        AND  posting_type  = posting_type_
        AND  code_part     = code_part_
        AND  pc_valid_from = pc_valid_from_;

   CURSOR get_detail IS
      SELECT *
      FROM   posting_ctrl_detail_tab
      WHERE  company       = company_
        AND  posting_type  = posting_type_
        AND  code_part     = code_part_
        AND  pc_valid_from = pc_valid_from_;

   CURSOR get_spec IS
      SELECT *
      FROM posting_ctrl_detail_spec_tab
      WHERE company = company_
        AND posting_type = posting_type_
        AND code_part = code_part_
        AND pc_valid_from = pc_valid_from_;
   
   CURSOR get_comb_spec IS
      SELECT *
      FROM posting_ctrl_comb_det_spec_tab
      WHERE company       = company_
        AND posting_type  = posting_type_
        AND code_part     = code_part_
        AND pc_valid_from = pc_valid_from_;
BEGIN
   IF (new_pc_valid_from_ IS NULL) THEN
      pc_valid_from_new_ := pc_valid_from_;
   ELSE
      pc_valid_from_new_ := new_pc_valid_from_;
   END IF;

   -- MASTER
   OPEN check_removal;
   FETCH check_removal INTO objid_, objversion_;
   IF (check_removal%FOUND) THEN
      CLOSE check_removal;
      IF (overwrite_ = 'TRUE') THEN
         Posting_Ctrl_API.Remove__(info_, objid_, objversion_, 'DO');
      ELSE
         Error_SYS.Record_Removed(lu_name_);
      END IF;
   ELSE
      CLOSE check_removal;
   END IF;

   OPEN get_master;
   FETCH get_master INTO master_;
   IF (get_master%FOUND) THEN
      CLOSE get_master;
      info_ := NULL;

      Client_SYS.Add_To_Attr('POSTING_TYPE',          new_posting_type_,           attr_);
      Client_SYS.Add_To_Attr('COMPANY',               master_.company,             attr_);
      Client_SYS.Add_To_Attr('CODE_PART',             master_.code_part,           attr_);
      Client_SYS.Add_To_Attr('PC_VALID_FROM',         pc_valid_from_new_,          attr_);
      Client_SYS.Add_To_Attr('CONTROL_TYPE',          master_.control_type,        attr_);
      Client_SYS.Add_To_Attr('MODULE',                master_.module,              attr_);
      Client_SYS.Add_To_Attr('OVERRIDE_DB',           master_.override,            attr_);
      Client_SYS.Add_To_Attr('DEFAULT_VALUE',         master_.default_value,       attr_);
      Client_SYS.Add_To_Attr('DEFAULT_VALUE_NO_CT',   master_.default_value_no_ct, attr_);
      Client_SYS.Add_To_Attr('CTRL_TYPE_CATEGORY_DB', master_.ctrl_type_category,  attr_);
      
      Posting_Ctrl_API.New__(info_, objid_, objversion_, attr_, 'DO');
   ELSE
      CLOSE get_master;
      Error_SYS.Record_Removed(lu_name_);
   END IF;

   --DETAIL
   FOR detail_ IN get_detail LOOP
      attr_ := NULL;
      info_ := NULL; 
        
      IF NOT ( pc_valid_from_ = pc_valid_from_new_ ) THEN
         IF ( control_type_value_ = detail_.control_type_value) THEN
            Error_SYS.Record_General(lu_name_, 'DUPVALUE: More than one record which currently have differing Valid From dates are selected to be updated with the same Valid From date for :P1 posting type. IFS Applications cannot proceed with the copy',
            new_posting_type_);
         END IF;
         control_type_value_ := detail_.control_type_value;
         Client_SYS.Add_To_Attr('VALID_FROM',              pc_valid_from_new_,               attr_);
      ELSE
         Client_SYS.Add_To_Attr('VALID_FROM',              detail_.valid_from,               attr_);
      END IF;

      Client_SYS.Add_To_Attr('POSTING_TYPE',               new_posting_type_,                attr_);

      Client_SYS.Add_To_Attr('COMPANY',                    detail_.company,                  attr_);
      Client_SYS.Add_To_Attr('CODE_PART',                  detail_.code_part,                attr_);
      Client_SYS.Add_To_Attr('PC_VALID_FROM',              pc_valid_from_new_,               attr_);
      Client_SYS.Add_To_Attr('CONTROL_TYPE_VALUE',         detail_.control_type_value,       attr_);
      Client_SYS.Add_To_Attr('CONTROL_TYPE',               detail_.control_type,             attr_);
      Client_SYS.Add_To_Attr('MODULE',                     detail_.module,                   attr_);
      Client_SYS.Add_To_Attr('CODE_PART_VALUE',            detail_.code_part_value,          attr_);
      Client_SYS.Add_To_Attr('SPEC_CONTROL_TYPE',          detail_.spec_control_type,        attr_);
      Client_SYS.Add_To_Attr('SPEC_MODULE',                detail_.spec_module,              attr_);
      Client_SYS.Add_To_Attr('SPEC_CTRL_TYPE_CATEGORY_DB', detail_.spec_ctrl_type_category,  attr_);
      Client_SYS.Add_To_Attr('SPEC_DEFAULT_VALUE',         detail_.spec_default_value,       attr_);
      Client_SYS.Add_To_Attr('SPEC_DEFAULT_VALUE_NO_CT',   detail_.spec_default_value_no_ct, attr_);
      Client_SYS.Add_To_Attr('NO_CODE_PART_VALUE_DB',      detail_.no_code_part_value, attr_);
         
      Posting_Ctrl_Detail_API.New__(info_, objid_, objversion_, attr_, 'DO');
   END LOOP;

   --SPEC
   FOR spec_ IN get_spec LOOP
      control_type_value_ := '';
      attr_ := NULL;
      info_ := NULL;

      IF NOT ( pc_valid_from_ = pc_valid_from_new_ ) THEN
         Client_SYS.Add_To_Attr('VALID_FROM',           pc_valid_from_new_,             attr_);
      ELSE
         Client_SYS.Add_To_Attr('VALID_FROM',           spec_.valid_from,               attr_);
      END IF;

      Client_SYS.Add_To_Attr('POSTING_TYPE',            new_posting_type_,              attr_);
      Client_SYS.Add_To_Attr('COMPANY',                 spec_.company,                  attr_);
      Client_SYS.Add_To_Attr('CODE_PART',               spec_.code_part,                attr_);
      Client_SYS.Add_To_Attr('PC_VALID_FROM',           pc_valid_from_new_,             attr_);
      Client_SYS.Add_To_Attr('CONTROL_TYPE_VALUE',      spec_.control_type_value,       attr_);
      Client_SYS.Add_To_Attr('SPEC_CONTROL_TYPE_VALUE', spec_.spec_control_type_value,  attr_);
      Client_SYS.Add_To_Attr('SPEC_CONTROL_TYPE',       spec_.spec_control_type,        attr_);
      Client_SYS.Add_To_Attr('SPEC_MODULE',             spec_.spec_module,              attr_);
      Client_SYS.Add_To_Attr('CODE_PART_VALUE',         spec_.code_part_value,          attr_);
      Client_SYS.Add_To_Attr('NO_CODE_PART_VALUE_DB',   spec_.no_code_part_value,       attr_);

      Posting_Ctrl_Detail_Spec_API.New__(info_, objid_, objversion_, attr_, 'DO');
   END LOOP;
   
   -- Combination specification control.   
   FOR comb_spec_ IN get_comb_spec LOOP            
      IF NOT ( pc_valid_from_ = pc_valid_from_new_ ) THEN
         p_ctrl_comb_det_spec_rec_.valid_from := pc_valid_from_new_;
      ELSE
         p_ctrl_comb_det_spec_rec_.valid_from := comb_spec_.valid_from;
      END IF;

      p_ctrl_comb_det_spec_rec_.posting_type             := new_posting_type_;
      p_ctrl_comb_det_spec_rec_.company                  := comb_spec_.company;
      p_ctrl_comb_det_spec_rec_.code_part                := comb_spec_.code_part;
      p_ctrl_comb_det_spec_rec_.pc_valid_from            := pc_valid_from_new_;
      p_ctrl_comb_det_spec_rec_.control_type_value       := comb_spec_.control_type_value;
      p_ctrl_comb_det_spec_rec_.spec_comb_control_type   := comb_spec_.spec_comb_control_type;
      p_ctrl_comb_det_spec_rec_.spec_control_type1       := comb_spec_.spec_control_type1;
      p_ctrl_comb_det_spec_rec_.spec_control_type1_value := comb_spec_.spec_control_type1_value;
      p_ctrl_comb_det_spec_rec_.spec_module1             := comb_spec_.spec_module1;
      p_ctrl_comb_det_spec_rec_.spec_control_type2       := comb_spec_.spec_control_type2;
      p_ctrl_comb_det_spec_rec_.spec_control_type2_value := comb_spec_.spec_control_type2_value;
      p_ctrl_comb_det_spec_rec_.spec_module2             := comb_spec_.spec_module2;
      p_ctrl_comb_det_spec_rec_.code_part_value          := comb_spec_.code_part_value;
      p_ctrl_comb_det_spec_rec_.no_code_part_value       := comb_spec_.no_code_part_value;

      Posting_Ctrl_Comb_Det_Spec_API.New_Rec(p_ctrl_comb_det_spec_rec_);
   END LOOP;
END Copy_Details_Set_Up;


PROCEDURE Set_Cct_Enabled (
   posting_type_ IN VARCHAR2 )
IS
BEGIN
   Posting_Ctrl_Posting_Type_API.Set_Cct_Enabled(posting_type_);
END Set_Cct_Enabled;


@UncheckedAccess
FUNCTION Exist_Comb_In_Detail (
   company_       IN VARCHAR2,
   posting_type_  IN VARCHAR2,
   code_part_     IN VARCHAR2,
   pc_valid_from_ IN DATE ) RETURN VARCHAR2
IS
   dummy_   NUMBER;
   
   CURSOR check_for_comb IS
      SELECT 1
      FROM posting_ctrl_detail_tab d,
           comb_control_type_tab c
      WHERE d.company = company_
        AND c.company = company_
        AND d.posting_type = posting_type_
        AND c.posting_type = posting_type_
        AND d.code_part = code_part_
        AND d.pc_valid_from = pc_valid_from_
        AND d.spec_control_type = c.comb_control_type;
BEGIN
   OPEN check_for_comb;
   FETCH check_for_comb INTO dummy_;
   IF (check_for_comb%FOUND) THEN
      CLOSE check_for_comb;
      RETURN 'TRUE';
   ELSE
      CLOSE check_for_comb;
      RETURN 'FALSE';   
   END IF;
END Exist_Comb_In_Detail;


FUNCTION Check_Copy_Replace (
   company_           IN VARCHAR2,
   posting_type_      IN VARCHAR2,
   code_part_         IN VARCHAR2,
   pc_valid_from_     IN DATE,
   new_posting_type_  IN VARCHAR2) RETURN VARCHAR2
IS
   dummy_    NUMBER;
   
   CURSOR check_master IS
      SELECT 1
      FROM posting_ctrl_tab  
      WHERE company = company_
      AND posting_type = new_posting_type_
      AND code_part = code_part_
      AND pc_valid_from = pc_valid_from_;      
BEGIN   
   OPEN check_master;
   FETCH check_master INTO dummy_;
   IF (check_master%FOUND) THEN
      CLOSE check_master;
      RETURN 'TRUE';
   ELSE
      CLOSE check_master;
      RETURN 'FALSE';      
   END IF;
END Check_Copy_Replace;


@UncheckedAccess
FUNCTION Is_Led_Account_Used (
   company_ IN VARCHAR2,
   account_ IN VARCHAR2 ) RETURN VARCHAR2
IS
   ledger_account_is_used_   NUMBER;
   CURSOR check_ledger_used IS
      SELECT 1 
      FROM   posting_ctrl_tab  pct, posting_ctrl_posting_type_tab pcpt
      WHERE  code_part         = 'A' 
      AND    default_value     = account_
      AND    company           = company_
      AND    pcpt.ledg_flag    = 'Y'
      AND    pcpt.posting_type = pct.posting_type;
BEGIN      
   OPEN check_ledger_used;
   FETCH check_ledger_used INTO ledger_account_is_used_;
   IF (check_ledger_used%FOUND) THEN
      CLOSE check_ledger_used;  
      RETURN 'TRUE';
   END IF;
   CLOSE check_ledger_used;  
   RETURN 'FALSE';
END Is_Led_Account_Used;


@UncheckedAccess
FUNCTION Is_Tax_Account_Used (
   company_ IN VARCHAR2,
   account_ IN VARCHAR2 ) RETURN VARCHAR2
IS
   tax_account_is_used_   NUMBER;
   CURSOR check_tax_used IS
      SELECT 1 
      FROM   posting_ctrl_tab  pct, posting_ctrl_posting_type_tab pcpt
      WHERE  code_part         = 'A' 
      AND    default_value     = account_
      AND    company           = company_
      AND    pcpt.tax_flag     = 'Y'
      AND    pcpt.posting_type = pct.posting_type;
BEGIN      
   OPEN  check_tax_used;
   FETCH check_tax_used INTO tax_account_is_used_;
   IF (check_tax_used%FOUND) THEN
      CLOSE check_tax_used;  
      RETURN 'TRUE';
   END IF;
   CLOSE check_tax_used;  
   RETURN 'FALSE';
END Is_Tax_Account_Used;


@UncheckedAccess
FUNCTION Get_Control_Type_Key_For_Date (
   company_          IN     VARCHAR2,
   code_part_        IN     VARCHAR2,
   posting_type_     IN     VARCHAR2,
   pc_valid_from_    IN     DATE ) RETURN VARCHAR2
IS
   max_date_         DATE;
BEGIN
   max_date_ := Get_Max_Date___(company_, posting_type_, code_part_, pc_valid_from_);
   RETURN Get_Control_Type_Key(company_, posting_type_, code_part_, max_date_);
END Get_Control_Type_Key_For_Date;

@UncheckedAccess
FUNCTION Get_Control_Type_For_Date (
   company_          IN     VARCHAR2,
   code_part_        IN     VARCHAR2,
   posting_type_     IN     VARCHAR2,
   date_             IN     DATE ) RETURN VARCHAR2
IS   
   control_type_   VARCHAR2(10);
   CURSOR get_control_type IS  
      SELECT   control_type 
      FROM     POSTING_CTRL_TAB 
      WHERE    company      = company_ 
      AND      posting_type = posting_type_ 
      AND      code_part    = code_part_ 
      AND      pc_valid_from <= date_
      AND      ROWNUM       = 1
      ORDER BY pc_valid_from DESC;
BEGIN
   OPEN  get_control_type;
   FETCH get_control_type INTO control_type_;
   CLOSE get_control_type;
   RETURN control_type_;
END Get_Control_Type_For_Date;

@UncheckedAccess
FUNCTION Check_Control_Type_For_Date (
   company_      IN VARCHAR2,
   posting_type_ IN VARCHAR2,
   control_type_ IN VARCHAR2, 
   date_         IN DATE ) RETURN BOOLEAN
IS   
   control_type_exist_ NUMBER;

   CURSOR get_control_type IS  
      SELECT 1 
      FROM   posting_ctrl_tab 
      WHERE  company        = company_      
      AND    posting_type   = posting_type_ 
      AND    control_type   = control_type_
      AND    pc_valid_from <= date_;      
BEGIN
   OPEN get_control_type;
   FETCH get_control_type INTO control_type_exist_;
   IF (get_control_type%FOUND) THEN
      CLOSE get_control_type;  
      RETURN TRUE;
   END IF;
   CLOSE get_control_type;
   RETURN FALSE;
END Check_Control_Type_For_Date;
@UncheckedAccess
FUNCTION Posting_Type_Exist_For_Date (
   company_          IN     VARCHAR2,
   code_part_        IN     VARCHAR2,
   posting_type_     IN     VARCHAR2,
   pc_valid_from_    IN     DATE ) RETURN VARCHAR2
IS
   max_date_     DATE;
BEGIN
   max_date_ := Get_Max_Date___(company_, posting_type_, code_part_, pc_valid_from_);
   IF (Check_Exist___(company_, code_part_, posting_type_, max_date_)) THEN
      RETURN 'TRUE';
   ELSE
      RETURN 'FALSE';
   END IF;
END Posting_Type_Exist_For_Date;


@UncheckedAccess
FUNCTION Get_Posting_Type_Description (
   company_       IN VARCHAR2,
   posting_type_  IN VARCHAR2 ) RETURN VARCHAR2
IS
   description_   VARCHAR2(200);
BEGIN
   IF (Posting_Type_Exist(company_, posting_type_)) THEN
      description_ := Posting_Ctrl_Posting_Type_API.Get_Description(posting_type_);      
      RETURN description_;
   ELSE
      RETURN NULL;
   END IF;
END Get_Posting_Type_Description;

PROCEDURE Copy_To_Companies_For_Svc (
   attr_              IN  VARCHAR2,
   run_in_background_ IN  BOOLEAN,
   log_id_            IN  NUMBER DEFAULT NULL)
IS
   ptr_                    NUMBER;
   name_                   VARCHAR2(200);
   value_                  VARCHAR2(32000);
   source_company_         VARCHAR2(100);
   code_part_list_         VARCHAR2(2000);
   posting_type_list_      VARCHAR2(2000);
   pc_valid_from_list_     VARCHAR2(2000);
   target_company_list_    VARCHAR2(2000);
   update_method_list_     VARCHAR2(2000);
   attr1_                  VARCHAR2(32000);
   run_in_background_attr_ VARCHAR2(32000);
BEGIN
   IF (run_in_background_) THEN
      run_in_background_attr_ := attr_;
      Transaction_SYS.Deferred_Call('Posting_Ctrl_API.Copy_To_Companies_', run_in_background_attr_, Language_SYS.Translate_Constant(lu_name_, 'COPYDATA: Copy Basic Data')); 
   ELSE
      ptr_ := NULL;
      WHILE (Client_SYS.Get_Next_From_Attr(attr_, ptr_, name_, value_)) LOOP
         IF (name_ = 'SOURCE_COMPANY') THEN
            source_company_ := value_;
         ELSIF (name_ = 'TARGET_COMPANY_LIST') THEN
            target_company_list_ := value_;
         ELSIF (name_ = 'CODE_PART_LIST') THEN
            code_part_list_ := value_;
         ELSIF (name_ = 'POSTING_TYPE_LIST') THEN
            posting_type_list_ := value_;
         ELSIF (name_ = 'PC_VALID_FROM_LIST') THEN
            pc_valid_from_list_ := value_;         
         ELSIF (name_ = 'UPDATE_METHOD_LIST') THEN
            update_method_list_ := value_;
         ELSIF (name_ = 'ATTR') THEN
            attr1_ := value_||chr(30)||substr(attr_, ptr_,length(attr_)-1);
         END IF;
      END LOOP;
      Copy_To_Companies_For_Svc___(source_company_,
                                  target_company_list_,
                                  code_part_list_,
                                  posting_type_list_,
                                  pc_valid_from_list_,
                                  update_method_list_,
                                  log_id_,
                                  attr1_);
   END IF;
END Copy_To_Companies_For_Svc;

-- DO NOT CHANGE OR USE THIS METHOD FOR OTHER PURPOSES. 
-- Note: This method only used from Remove Company functionality in Remove_Company_API.Start_Remove_Company__.
@ServerOnlyAccess 
PROCEDURE Remove_Company (
   company_    IN VARCHAR2)
IS
BEGIN 
   IF Company_API.Remove_Company_Allowed(company_) = 'TRUE' THEN 
      DELETE 
         FROM POSTING_CTRL_TAB
         WHERE company = company_;
   END IF;    
END Remove_Company;
