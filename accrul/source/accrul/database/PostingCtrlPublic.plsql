-----------------------------------------------------------------------------
--
--  Logical unit: PostingCtrlPublic
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  020111  PPerse  Created
--  050614  reanpl  FIAD376 Actual Costing modifications
--  060106  DiAmlk  Bug ID:130676 - Modified the method Build_Codestring_Rec.
--  060614  Iswalk  replaced combined_control_type with ctrl_type_category.
--  080722  Thpelk  Bug 73882, Channged the error messages to reflect the invalid time interval.
--  120223  Nsillk  RAVEN-1717, Added method Get_Current_Control_Type
--  111020  ovjose  Modification to make use of the no_code_part_value attribute on detail levels
--  120103  AmThLK  SFI-409, Modified function Is_Ctrl_Type_Used_On_Post_Type() to check each code part uses Specified Control_Type for specific Posting_type
--  120326  Paralk  EASTRTM-6637, Bug Corrected in Build_Codestring_Rec()
--  120521  SALIDE  EDEL-604, Modified the error message that occured for the validation of posting type
--   121210   Maaylk  PEPA-183, Removed global variables
--  130816  Clstlk  Bug 111218, Fixed General_SYS.Init_Method issue
--  150811  Thpelk  Bug Id 123238 Fixed 
--  161017  Chwtlk  STRFI-3528, Merged LCS Bug 131415, Rollbacked changes done by 123238.
--  200123  Chwtlk  Bug 151340, Modified Get_Control_Type.
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------

TYPE CONTROL_TYPE_VALUE IS RECORD (
   control_type VARCHAR2(10),
   value        VARCHAR2(100)
   );
TYPE CONTROL_TYPE_VALUE_LIST IS TABLE OF CONTROL_TYPE_VALUE INDEX BY
BINARY_INTEGER;
TYPE control_type_value_table IS TABLE OF VARCHAR2(100) INDEX BY VARCHAR2(20);

-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------

FUNCTION Raise_Error___ (
   posting_type_            IN VARCHAR2,
   code_part_               IN VARCHAR2,
   currev_account_method_   IN VARCHAR2,
   currev_code_part_method_ IN VARCHAR2,
   currev_gain_loss_method_ IN VARCHAR2) RETURN BOOLEAN
IS
BEGIN
   -- do not raise error if Original postings are used for Currency Revaluation
   IF (posting_type_ = 'GP9' AND code_part_  = 'A' AND currev_account_method_   = 'ORIGINAL') OR
      (posting_type_ = 'GP9' AND code_part_ != 'A' AND currev_code_part_method_ = 'ORIGINAL') OR
      (posting_type_ IN ('GP10','GP11') AND code_part_ != 'A' AND currev_gain_loss_method_ = 'ORIGINAL')
   THEN
      RETURN FALSE;
   -- do not raise error if Original postings are used for Currency Revaluation
   ELSIF (posting_type_ = 'GP19' AND code_part_  = 'A' AND currev_account_method_   = 'ORIGINAL') OR
      (posting_type_ = 'GP19' AND code_part_ != 'A' AND currev_code_part_method_ = 'ORIGINAL') OR
      (posting_type_ IN ('GP20','GP21') AND code_part_ != 'A' AND currev_gain_loss_method_ = 'ORIGINAL')
   THEN
      RETURN FALSE;      
   ELSE
      RETURN TRUE;
   END IF;
END Raise_Error___;


PROCEDURE Get_Comb_Detail_Val___(
   value_               OUT VARCHAR2,
   no_code_part_value_  OUT VARCHAR2,
   company_             IN  VARCHAR2,
   posting_type_        IN  VARCHAR2,
   date_                IN  DATE,
   code_part_           IN  VARCHAR2,
   pc_valid_from_       IN  DATE,
   comb_control_type_   IN  VARCHAR2,
   control_type1_       IN  VARCHAR2,
   ct_value1_           IN  VARCHAR2,   
   control_type2_       IN  VARCHAR2,
   ct_value2_           IN  VARCHAR2 )
IS
-- Rules for fetching code_part_value:
--   the first control type have priority over the second control type
--   specific value has priority over wildcard
-- ORDER BY clause: will place % sign on the last position, so specific values will be fetched first
   CURSOR get_val IS
      SELECT code_part_value, no_code_part_value
      FROM   posting_ctrl_comb_detail_tab
      WHERE company = company_
      AND   posting_type = posting_type_
      AND   pc_valid_from = pc_valid_from_
      AND   comb_control_type = comb_control_type_
      AND   control_type1 = control_type1_
      AND  (control_type1_value = ct_value1_ OR control_type1_value = '%')
      AND   control_type2 = control_type2_
      AND  (control_type2_value = ct_value2_ OR control_type2_value = '%')
      AND   code_part = code_part_
      AND   valid_from = (SELECT MAX(valid_from)
                          FROM   posting_ctrl_comb_detail_tab
                          WHERE  company      = company_
                          AND    posting_type = posting_type_
                          AND    pc_valid_from = pc_valid_from_
                          AND    comb_control_type = comb_control_type_
                          AND    control_type1 = control_type1_
                          AND   (control_type1_value = ct_value1_ OR control_type1_value = '%')
                          AND    control_type2 = control_type2_
                          AND   (control_type2_value = ct_value2_ OR control_type2_value = '%')
                          AND    code_part = code_part_
                          AND    valid_from  <= date_)
      ORDER BY control_type1_value DESC, control_type2_value DESC;

   rec_  get_val%ROWTYPE;
BEGIN
   OPEN get_val;
   FETCH get_val INTO rec_;
   CLOSE get_val;
   value_ := rec_.code_part_value;
   no_code_part_value_ := rec_.no_code_part_value;
END Get_Comb_Detail_Val___;


PROCEDURE Get_Values___(
   value_                   OUT VARCHAR2,
   no_code_part_value_      OUT VARCHAR2,
   ct_value_tbl_            IN control_type_value_table,
   company_                 IN  VARCHAR2,
   posting_type_            IN  VARCHAR2,
   code_part_               IN  VARCHAR2,
   pc_valid_from_           IN  DATE,
   control_type_            IN  VARCHAR2,
   ct_value_                IN  VARCHAR2,
   date_                    IN  DATE,
   currev_account_method_   IN VARCHAR2,
   currev_code_part_method_ IN VARCHAR2,
   currev_gain_loss_method_ IN VARCHAR2)
IS
   error_msg_  VARCHAR2(2000);
   CURSOR get_val IS
      SELECT code_part_value,
             spec_control_type,
             spec_ctrl_type_category,
             spec_default_value,
             spec_default_value_no_ct,
             valid_from,
             no_code_part_value
      FROM   posting_ctrl_detail_tab
      WHERE company = company_
      AND   posting_type = posting_type_
      AND   code_part = code_part_
      AND   pc_valid_from = pc_valid_from_
      AND   control_type = control_type_
      AND   control_type_value = ct_value_
      AND   valid_from = (SELECT MAX(valid_from)
                          FROM   posting_ctrl_detail_tab
                          WHERE  company      = company_
                          AND    posting_type = posting_type_
                          AND    code_part    = code_part_
                          AND    pc_valid_from = pc_valid_from_
                          AND    control_type = control_type_
                          AND    control_type_value = ct_value_
                          AND    valid_from  <= date_);
   rec_     get_val%ROWTYPE;

   CURSOR get_spec_val (valid_from_ IN DATE, spec_ct_value_ IN VARCHAR2) IS
      SELECT code_part_value, no_code_part_value
      FROM   posting_ctrl_detail_spec_tab
      WHERE company = company_
      AND   posting_type = posting_type_
      AND   code_part = code_part_
      AND   pc_valid_from = pc_valid_from_
      AND   control_type_value = ct_value_
      AND   valid_from = valid_from_
      AND   spec_control_type_value = spec_ct_value_;

-- Rules for fetching code_part_value:
--   the first control type have priority over the second control type
--   specific value has priority over wildcard
-- ORDER BY clause: will place % sign on the last position, so specific values will be fetched first
   CURSOR get_comb_spec_val (valid_from_ IN DATE, spec_ct_ IN VARCHAR2, spec_ct1_value_ IN VARCHAR2, spec_ct2_value_ IN VARCHAR2) IS
      SELECT code_part_value, no_code_part_value
      FROM   posting_ctrl_comb_det_spec_tab
      WHERE company = company_
      AND   posting_type = posting_type_
      AND   code_part = code_part_
      AND   pc_valid_from = pc_valid_from_
      AND   control_type_value = ct_value_
      AND   valid_from = valid_from_
      AND   spec_comb_control_type = spec_ct_ 
      AND  (spec_control_type1_value = spec_ct1_value_ OR spec_control_type1_value = '%')
      AND  (spec_control_type2_value = spec_ct2_value_ OR spec_control_type2_value = '%')
      ORDER BY spec_control_type1_value DESC, spec_control_type2_value DESC;
   
   spec_ct1_         VARCHAR2(10);
   spec_ct2_         VARCHAR2(10);
   spec_ct_value_    VARCHAR2(100);
   spec_ct1_value_   VARCHAR2(100);
   spec_ct2_value_   VARCHAR2(100);
BEGIN
   OPEN  get_val;
   FETCH get_val INTO rec_;
   no_code_part_value_ := rec_.no_code_part_value;
   value_ := rec_.code_part_value;
   IF (get_val%NOTFOUND) THEN
      value_ := NULL;
   ELSIF (rec_.code_part_value IS NOT NULL) THEN
      value_ := rec_.code_part_value;
   ELSIF (rec_.spec_control_type IS NOT NULL) THEN
   -- find specification level
      IF (rec_.spec_ctrl_type_category != 'COMBINATION') THEN

         IF (ct_value_tbl_.EXISTS(rec_.spec_control_type)) THEN
            spec_ct_value_ := ct_value_tbl_(rec_.spec_control_type);
         END IF;
                  
         OPEN  get_spec_val(rec_.valid_from, spec_ct_value_);
         FETCH get_spec_val INTO value_, no_code_part_value_;
         CLOSE get_spec_val;
         no_code_part_value_ := NVL(no_code_part_value_, 'FALSE');
         IF (value_ IS NULL AND no_code_part_value_ = 'FALSE') THEN
            IF ( (spec_ct_value_ IS NOT NULL) OR (rec_.spec_ctrl_type_category IN ('FIXED', 'PREPOSTING')) ) THEN
               value_ := rec_.spec_default_value;
            ELSE
               value_ := rec_.spec_default_value_no_ct;
            END IF;
         END IF;

         IF value_ IS NULL AND no_code_part_value_ = 'FALSE' AND Raise_Error___(posting_type_, code_part_, currev_account_method_, currev_code_part_method_, currev_gain_loss_method_) THEN            
            IF (rec_.spec_ctrl_type_category = 'PREPOSTING') THEN               
               value_ := chr(0);   
            ELSE                                          
               CLOSE get_val;
               error_msg_ := Language_SYS.Translate_Constant(lu_name_, 'NOCTRLSPECVALUE: Value is missing or has an invalid time interval for posting type :P1 specification control type :P2 code part :P3 in company :P4.',
                                                             NULL, posting_type_, rec_.spec_control_type, code_part_);
               error_msg_ := REPLACE(error_msg_, ':P4', company_);
               Error_SYS.Appl_General(lu_name_, 'POSTERRMSG: :P1', error_msg_ );
            END IF;
         END IF;
      ELSE
      -- combined control type
         Comb_Control_Type_API.Get_Control_Type1_Type2(spec_ct1_, spec_ct2_, company_, posting_type_, rec_.spec_control_type);
         IF (ct_value_tbl_.EXISTS(spec_ct1_)) THEN
            spec_ct1_value_ := ct_value_tbl_(spec_ct1_);
         END IF;
                  
         IF (ct_value_tbl_.EXISTS(spec_ct2_)) THEN
            spec_ct2_value_ := ct_value_tbl_(spec_ct2_);
         END IF;

         OPEN  get_comb_spec_val (rec_.valid_from, rec_.spec_control_type, spec_ct1_value_, spec_ct2_value_);
         FETCH get_comb_spec_val INTO value_, no_code_part_value_;
         CLOSE get_comb_spec_val;
         no_code_part_value_ := NVL(no_code_part_value_, 'FALSE');

         IF value_ IS NULL AND no_code_part_value_ = 'FALSE' THEN
            IF spec_ct1_value_ IS NULL AND spec_ct2_value_ IS NULL THEN
               value_ := rec_.spec_default_value;
            ELSIF spec_ct1_value_ IS NULL OR spec_ct2_value_ IS NULL THEN
               value_ := rec_.spec_default_value_no_ct;
            ELSE
               value_ := rec_.spec_default_value;
            END IF;
         END IF;
         
         IF value_ IS NULL AND no_code_part_value_ = 'FALSE' AND Raise_Error___(posting_type_, code_part_, currev_account_method_, currev_code_part_method_, currev_gain_loss_method_) THEN
            CLOSE get_val;
            error_msg_ := Language_SYS.Translate_Constant(lu_name_, 'NOCTRLSPECVALUE2: Value is missing for posting type :P1 combined specification control type :P2 code part :P3 in company :P4.',
                                                          NULL, posting_type_, rec_.spec_control_type, code_part_);
            error_msg_ := REPLACE(error_msg_, ':P4', company_);
            Error_SYS.Appl_General(lu_name_, 'POSTERRMSG: :P1', error_msg_ );
         END IF;      
      END IF;
   END IF;
   CLOSE get_val;
END Get_Values___;


-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------

-------------------- LU SPECIFIC PROTECTED METHODS --------------------------

-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

PROCEDURE Get_Control_Type (
   ct_value_tbl_ OUT CONTROL_TYPE_VALUE_TABLE,
   posting_type_ IN  VARCHAR2,
   company_      IN  VARCHAR2,
   date_         IN  DATE )
IS
   CURSOR get_ctrl_type IS
      SELECT DISTINCT(control_type), ctrl_type_category cct
      FROM   posting_ctrl_tab t1
      WHERE  company        = company_
      AND    posting_type   = posting_type_
      AND    pc_valid_from  = (SELECT MAX(pc_valid_from)
                               FROM   posting_ctrl_tab t2
                               WHERE  t2.company        = company_
                               AND    t2.posting_type   = posting_type_
                               AND    t2.code_part      = t1.code_part
                               AND    t2.pc_valid_from <= date_)
    UNION
      SELECT DISTINCT(spec_control_type) ct, spec_ctrl_type_category cct
      FROM   posting_ctrl_detail_tab t1
      WHERE  company       = company_
      AND    posting_type  = posting_type_
      AND    pc_valid_from = (SELECT MAX(pc_valid_from)
                              FROM   posting_ctrl_tab t2
                              WHERE  t2.company        = company_
                              AND    t2.posting_type   = posting_type_
                              AND    t2.code_part      = t1.code_part
                              AND    t2.pc_valid_from <= date_)
      AND    valid_from    = (SELECT MAX(valid_from)
                              FROM   posting_ctrl_detail_tab t2
                              WHERE  t2.company        = company_
                              AND    t2.posting_type   = posting_type_
                              AND    t2.code_part      = t1.code_part
                              AND    t2.pc_valid_from      = t1.pc_valid_from
                              AND    t2.control_type_value = t1.control_type_value
                              AND    t2.valid_from    <= date_)
      AND    spec_control_type IS NOT NULL;
--
   CURSOR get_cc_types( master_type_ IN VARCHAR2 ) IS
      SELECT control_type1 ct1, control_type2 ct2
      FROM   comb_control_type
      WHERE  company           = company_
      AND    posting_type      = posting_type_
      AND    comb_control_type = master_type_;
BEGIN
   FOR rec_ IN get_ctrl_type LOOP 
      IF (rec_.cct <> 'COMBINATION') THEN
         ct_value_tbl_(rec_.control_type) := rec_.control_type;         
      ELSE
         FOR crec_ IN get_cc_types(rec_.control_type) LOOP
            ct_value_tbl_(crec_.ct1) := crec_.ct1;                  
            ct_value_tbl_(crec_.ct2) := crec_.ct2;                           
         END LOOP;
      END IF;
   END LOOP;
END Get_Control_Type;

PROCEDURE Build_Codestring_Rec (
   crec_             OUT ACCOUNTING_CODESTR_API.CODESTRREC,
   ct_value_tbl_     IN  CONTROL_TYPE_VALUE_TABLE,
   date_             IN  DATE,
   posting_type_     IN  VARCHAR2,
   company_          IN  VARCHAR2,
   account_method_   IN VARCHAR2 DEFAULT NULL,
   code_part_method_ IN VARCHAR2 DEFAULT NULL,
   gain_loss_method_ IN VARCHAR2 DEFAULT NULL,
   codestr_compl_req_ IN VARCHAR2 DEFAULT 'TRUE')
IS
   ct_value_      VARCHAR2(100);
   ct1_value_     VARCHAR2(100);
   ct2_value_     VARCHAR2(100);
   ct1_           VARCHAR2(10);
   ct2_           VARCHAR2(10);
   value_         VARCHAR2(200);
   
   currev_account_method_   VARCHAR2(20);
   currev_code_part_method_ VARCHAR2(20);
   currev_gain_loss_method_ VARCHAR2(20);

   no_code_part_value_  VARCHAR2(5) := 'FALSE';
   codestr_tab_         Accounting_Codestr_API.Code_part_value_tab;
   error_msg_           VARCHAR2(2000);
   --
   CURSOR pct_master IS
      SELECT code_part              code_part,
             pc_valid_from          pc_valid_from,
             control_type           control_type,
             default_value          default_value,
             default_value_no_ct    default_value_no_ct,
             ctrl_type_category     cct
      FROM   posting_ctrl_tab t1
      WHERE  company = company_
      AND    posting_type = posting_type_
      AND    pc_valid_from = (SELECT MAX(pc_valid_from)
                              FROM   posting_ctrl_tab t2
                              WHERE  t2.company = company_
                              AND    t2.posting_type = posting_type_
                              AND    t2.code_part = t1.code_part
                              AND    t2.pc_valid_from <= date_)
      ORDER BY code_part;

BEGIN

   -- parameters used only by Currency Revaluation
   currev_account_method_   := nvl(account_method_  , Database_SYS.string_Null_);
   currev_code_part_method_ := nvl(code_part_method_, Database_SYS.string_Null_);
   currev_gain_loss_method_ := nvl(gain_loss_method_, Database_SYS.string_Null_);

   FOR mr_ IN pct_master LOOP
      value_ := NULL;
      IF (mr_.cct != 'COMBINATION') THEN
         IF (ct_value_tbl_.EXISTS(mr_.control_type)) THEN
            ct_value_ := ct_value_tbl_(mr_.control_type);
         END IF;         

         Get_Values___( value_,
                        no_code_part_value_,
                        ct_value_tbl_,
                        company_,
                        posting_type_,
                        mr_.code_part,
                        mr_.pc_valid_from,
                        mr_.control_type,
                        ct_value_,
                        date_,
                        currev_account_method_,
                        currev_code_part_method_,
                        currev_gain_loss_method_ );

         no_code_part_value_ := NVL(no_code_part_value_, 'FALSE');
      ELSE
         Comb_Control_Type_API.Get_Control_Type1_Type2(ct1_, ct2_, company_, posting_type_, mr_.control_type);

         IF (ct_value_tbl_.EXISTS(ct1_)) THEN
            ct1_value_ := ct_value_tbl_(ct1_);
         END IF;
         
         IF (ct_value_tbl_.EXISTS(ct2_)) THEN
            ct2_value_ := ct_value_tbl_(ct2_);
         END IF;
         
         Get_Comb_Detail_Val___( value_,
                                 no_code_part_value_,
                                 company_,
                                 posting_type_,
                                 date_,
                                 mr_.code_part,
                                 mr_.pc_valid_from,
                                 mr_.control_type,
                                 ct1_,
                                 ct1_value_,
                                 ct2_,
                                 ct2_value_ );

         no_code_part_value_ := NVL(no_code_part_value_, 'FALSE');
      END IF;
      --
      IF (value_ IS NULL AND no_code_part_value_ = 'FALSE') THEN
         IF (mr_.cct != 'COMBINATION') THEN
         -- if control type value is not null, use "Default Value No Details" else use "Default Value No CT Value"
            IF ((ct_value_ IS NOT NULL) OR (mr_.cct IN ('FIXED', 'PREPOSTING'))) THEN
               value_ := mr_.default_value;
            ELSE
               value_ := mr_.default_value_no_ct;
            END IF;
         ELSE
         -- if both control type values are NULL, use "Default Value No Details"
         -- use "Default Value No CT Value" if either one of the two control types has NULL as control type value
            IF ct1_value_ IS NULL AND ct2_value_ IS NULL THEN
               value_ := mr_.default_value;
            ELSIF ct1_value_ IS NULL OR ct2_value_ IS NULL THEN
               value_ := mr_.default_value_no_ct;
            ELSE
               value_ := mr_.default_value;
            END IF;
         END IF;
      END IF;
      
      IF (value_ IS NULL AND no_code_part_value_ = 'FALSE' AND Raise_Error___(posting_type_, mr_.code_part, currev_account_method_, currev_code_part_method_, currev_gain_loss_method_)) THEN
         IF mr_.cct = 'PREPOSTING' THEN
            value_ := chr(0);   
         ELSE
            IF (mr_.cct != 'COMBINATION') THEN      
               error_msg_ := Language_SYS.Translate_Constant(lu_name_, 'NOCTRVALUE: Value is missing or has an invalid time interval for posting type :P1 control type :P2 code part :P3 in company :P4.',
                                                             NULL, posting_type_, mr_.control_type, mr_.code_part);
               error_msg_ := REPLACE(error_msg_, ':P4', company_);
               Error_SYS.Appl_General(lu_name_, 'POSTERRMSG: :P1', error_msg_ );
            ELSE
               error_msg_ := Language_SYS.Translate_Constant(lu_name_, 'NOCTRVALUE2: Value is missing for posting type :P1 combined control type :P2 code part :P3 in company :P4.',
                                                             NULL, posting_type_, mr_.control_type, mr_.code_part);
               error_msg_ := REPLACE(error_msg_, ':P4', company_);
               Error_SYS.Appl_General(lu_name_, 'POSTERRMSG: :P1', error_msg_ );
            END IF;    
         END IF;
      END IF;      

      codestr_tab_ := Accounting_Codestr_API.Get_Code_Part_Val_Tab(crec_);

      -- Check if the code part is A-J
      IF (ASCII(mr_.code_part) BETWEEN 65 AND 74) THEN
         value_ := NVL(codestr_tab_(mr_.code_part), value_);
         Accounting_Codestr_API.Set_Code_Part_Val_In_Rec(crec_,
                                                         mr_.code_part,
                                                         value_);
      ELSE
         -- Change this error to something better...
         Error_SYS.Record_General(lu_name_,'PCP01: Invalid assignment');
      END IF;
   END LOOP;
END Build_Codestring_Rec;


FUNCTION Is_Ctrl_Type_Used_On_Post_Type (
   company_       IN VARCHAR2,                                        
   posting_type_  IN VARCHAR2,
   control_type_  IN VARCHAR2,
   date_          IN DATE,
   code_part_     IN VARCHAR2 DEFAULT NULL )  RETURN BOOLEAN
IS
   CURSOR get_posting_ctrl IS 
      SELECT code_part, control_type, ctrl_type_category, pc_valid_from
      FROM   posting_ctrl_tab t1
      WHERE  company       = company_
      AND    code_part     LIKE NVL(code_part_,'%')
      AND    posting_type  = posting_type_
      AND    pc_valid_from = (SELECT MAX(pc_valid_from)
                              FROM   posting_ctrl_tab t2
                              WHERE  t2.company        =  t1.company
                              AND    t2.posting_type   =  t1.posting_type
                              AND    t2.code_part      =  t1.code_part
                              AND    t2.pc_valid_from  <= date_);

   CURSOR get_post_ctrl_det (code_part_ IN VARCHAR2, pc_valid_from_ IN DATE) IS
      SELECT spec_control_type, spec_ctrl_type_category
      FROM   posting_ctrl_detail_tab t1
      WHERE  company       = company_
      AND    posting_type  = posting_type_
      AND    code_part     = code_part_
      AND    pc_valid_from = pc_valid_from_
      AND    spec_control_type IS NOT NULL
      AND    valid_from = (SELECT MAX(valid_from)
                           FROM   posting_ctrl_detail_tab t2
                           WHERE  company       = company_
                           AND    posting_type  = posting_type_
                           AND    code_part     = code_part_
                           AND    pc_valid_from = pc_valid_from_
                           AND    t1.control_type_value = t2.control_type_value
                           AND    valid_from  <= date_);

   ct1_  VARCHAR2(20);
   ct2_  VARCHAR2(20);
BEGIN

   -- Loop through all records for posting type with the valid date
   FOR rec_ IN get_posting_ctrl LOOP
      IF (rec_.control_type = control_type_) THEN
         -- Control Type is used in valid posting ctrl 
         RETURN TRUE;
      ELSIF (rec_.ctrl_type_category = 'COMBINATION') THEN
         Comb_Control_Type_API.Get_Control_Type1_Type2(ct1_, ct2_, company_, posting_type_, rec_.control_type);
         IF (ct1_ = control_type_) OR (ct2_ = control_type_) THEN
            -- Control Type is used in valid posting ctrl comb 
            RETURN TRUE;
         END IF;
      END IF;

      FOR det_ IN get_post_ctrl_det (NVL(code_part_,rec_.code_part), rec_.pc_valid_from) LOOP
         IF det_.spec_control_type = control_type_ THEN
            RETURN TRUE;
         END IF;
         IF (det_.spec_ctrl_type_category = 'COMBINATION') THEN
            Comb_Control_Type_API.Get_Control_Type1_Type2(ct1_, ct2_, company_, posting_type_, det_.spec_control_type);
            IF (ct1_ = control_type_) OR (ct2_ = control_type_) THEN
               RETURN TRUE;
            END IF;
         END IF;
      END LOOP;
   END LOOP;

   -- Control type is not used for posting type with valid date
   RETURN FALSE;
END Is_Ctrl_Type_Used_On_Post_Type;


FUNCTION Ctrl_Type_Used_On_Post_Type (
   company_       IN VARCHAR2,                                        
   posting_type_  IN VARCHAR2,
   control_type_  IN VARCHAR2,
   date_          IN DATE )  RETURN VARCHAR2
IS
BEGIN

   IF Is_Ctrl_Type_Used_On_Post_Type(company_, posting_type_, control_type_, date_) THEN
      RETURN 'TRUE';
   ELSE
      RETURN 'FALSE';
   END IF;
END Ctrl_Type_Used_On_Post_Type;


FUNCTION Get_Current_Control_Type (
   company_       IN VARCHAR2,
   posting_type_  IN VARCHAR2,
   code_part_     IN VARCHAR2,
   date_          IN DATE ) RETURN VARCHAR2
IS
   curr_ctrl_type_ posting_ctrl_tab.control_type%TYPE;
   CURSOR get_curr_ctrl_type IS
      SELECT control_type
        FROM posting_ctrl_tab t1
       WHERE company       = company_
         AND posting_type  = posting_type_
         AND code_part     = code_part_
         AND pc_valid_from = (SELECT MAX(pc_valid_from)
                                FROM posting_ctrl_tab t2
                               WHERE t2.company       = t1.company
                                 AND t2.posting_type  = t1.posting_type
                                 AND t2.code_part     = t1.code_part
                                 AND t2.pc_valid_from <= date_);
BEGIN
   OPEN get_curr_ctrl_type;
   FETCH get_curr_ctrl_type INTO curr_ctrl_type_;
   CLOSE get_curr_ctrl_type;
   RETURN curr_ctrl_type_;
END Get_Current_Control_Type;


PROCEDURE Remove_Postingctrls_Per_Module (
   module_       IN VARCHAR2 )
IS
   CURSOR get_posting_ctrls IS
      SELECT company, posting_type, code_part, control_type
      FROM   posting_ctrl_tab
      WHERE  module = UPPER(module_);

BEGIN
   FOR rec_ IN get_posting_ctrls LOOP
      Posting_Ctrl_API.Remove_Posting_Control(rec_.company,
                                              rec_.posting_type,
                                              rec_.code_part,
                                              rec_.control_type,
                                              UPPER(module_));
   END LOOP;
END Remove_Postingctrls_Per_Module;


PROCEDURE Remove_Allowed_Comb_Per_Module (
   module_       IN VARCHAR2 )
IS
   CURSOR get_allowed_combs IS
      SELECT posting_type, control_type, code_part
      FROM   POSTING_CTRL_ALLOWED_COMB_TAB
      WHERE  module = UPPER(module_);
BEGIN
   FOR rec_ IN get_allowed_combs LOOP      
      Posting_Ctrl_Allowed_Comb_API.Remove_Allowed_Comb_(rec_.posting_type,
                                                         rec_.control_type,
                                                         UPPER(module_),
                                                         rec_.code_part);
   END LOOP;
END Remove_Allowed_Comb_Per_Module;




PROCEDURE Remove_Ctrl_Types_Per_Module (
   module_        IN VARCHAR2 )
IS

   CURSOR get_control_types IS
      SELECT control_type
      FROM   POSTING_CTRL_CONTROL_TYPE_TAB
      WHERE  module = UPPER(module_);

BEGIN
   FOR rec_ IN get_control_types LOOP      
      Posting_Ctrl_Control_Type_API.Remove_Control_Type_(rec_.control_type, UPPER(module_));
   END LOOP;
END Remove_Ctrl_Types_Per_Module;


PROCEDURE Remove_Posting_Typs_Per_Module (
   module_        IN VARCHAR2 )
IS
   CURSOR get_posting_types IS
      SELECT posting_type
      FROM   POSTING_CTRL_POSTING_TYPE_TAB
      WHERE  module = UPPER(module_);
BEGIN
   FOR rec_ IN get_posting_types LOOP      
      Posting_Ctrl_Posting_Type_API.Remove_Posting_Type_(rec_.posting_type);
   END LOOP;
END Remove_Posting_Typs_Per_Module;


PROCEDURE Rmv_Combctrl_Typs_Per_Module (
   module_        IN VARCHAR2 )
IS
   CURSOR get_combctrl_typs IS
      SELECT company, posting_type, comb_control_type
      FROM   comb_control_type_tab
      WHERE  comb_module = UPPER(module_);
BEGIN
   FOR rec_ IN get_combctrl_typs LOOP      
      Comb_Control_Type_API.Remove_Comb_Control_Type(rec_.company,
                                                     rec_.posting_type,
                                                     rec_.comb_control_type);
   END LOOP;
END Rmv_Combctrl_Typs_Per_Module;


PROCEDURE Rmv_Post_Ctrl_Per_Post_Type (
   posting_type_       IN VARCHAR2 )
IS
   CURSOR get_posting_ctrls IS
      SELECT company, module, code_part, control_type
      FROM   posting_ctrl_tab
      WHERE  posting_type = posting_type_;

BEGIN
   FOR rec_ IN get_posting_ctrls LOOP
      Posting_Ctrl_API.Remove_Posting_Control(rec_.company,
                                              posting_type_,
                                              rec_.code_part,
                                              rec_.control_type,
                                              rec_.module);      
   END LOOP;        
END Rmv_Post_Ctrl_Per_Post_Type;


PROCEDURE Rmv_Allow_Comb_Per_Post_Type (
    posting_type_       IN VARCHAR2 )
IS
   CURSOR get_allowed_combs IS
      SELECT module, control_type, code_part
      FROM   POSTING_CTRL_ALLOWED_COMB_TAB
      WHERE  posting_type = posting_type_;
BEGIN
   FOR rec_ IN get_allowed_combs LOOP      
      Posting_Ctrl_API.Remove_Allowed_Comb(posting_type_,
                                           rec_.control_type,
                                           rec_.module,
                                           rec_.code_part);
   END LOOP;
END Rmv_Allow_Comb_Per_Post_Type;


PROCEDURE Rmv_Combctrl_Typ_Per_Post_Type (
   posting_type_       IN VARCHAR2 )
IS
   CURSOR get_combctrl_typs IS
      SELECT company, comb_control_type
      FROM   comb_control_type_tab
      WHERE  posting_type = posting_type_;
BEGIN
   FOR rec_ IN get_combctrl_typs LOOP      
      Comb_Control_Type_API.Remove_Comb_Control_Type(rec_.company,
                                                     posting_type_,
                                                     rec_.comb_control_type);
   END LOOP;
END Rmv_Combctrl_Typ_Per_Post_Type;

FUNCTION Control_Type_Value_Exists(
   company_            IN VARCHAR2,
   control_type_       IN VARCHAR2,
   control_type_value_ IN VARCHAR2 ) RETURN VARCHAR2
IS
   results_ NUMBER := 0;

   CURSOR check_ctrl_detail IS
      SELECT 1 
      FROM   posting_ctrl_detail_tab t
      WHERE  t.company            = company_ 
      AND    t.control_type       = control_type_
      AND    t.control_type_value = control_type_value_;
  
   CURSOR check_comb_detail IS
      SELECT 1
      FROM   posting_ctrl_comb_detail_tab t
      WHERE  t.company     = company_
      AND    ((t.control_type1 = control_type_ AND t.control_type1_value = control_type_value_) OR
              (t.control_type2 = control_type_ AND t.control_type2_value = control_type_value_));
         
   CURSOR check_comb_spec IS
      SELECT 1 
      FROM   posting_ctrl_comb_det_spec_tab t
      WHERE  t.company = company_
      AND    ((t.spec_control_type1 = control_type_ AND t.spec_control_type1_value = control_type_value_) OR
              (t.spec_control_type2 = control_type_ AND t.spec_control_type2_value = control_type_value_));
         
   CURSOR check_detail_spec IS    
      SELECT 1
      FROM   posting_ctrl_detail_spec_tab t
      WHERE  t.company                 = company_
      AND    t.spec_control_type       = control_type_
      AND    t.spec_control_type_value = control_type_value_;
BEGIN
   OPEN  check_ctrl_detail;
   FETCH check_ctrl_detail INTO results_;
   IF (check_ctrl_detail%FOUND) THEN
      CLOSE check_ctrl_detail;
      RETURN 'TRUE';
   ELSE
      CLOSE check_ctrl_detail;
   END IF;
  
   OPEN  check_comb_detail;
   FETCH check_comb_detail INTO results_;
   IF (check_comb_detail%FOUND) THEN
      CLOSE check_comb_detail;
      RETURN 'TRUE';
   ELSE
      CLOSE check_comb_detail;
   END IF;
    
   OPEN  check_comb_spec;
   FETCH check_comb_spec INTO results_;
   IF (check_comb_spec%FOUND) THEN
     CLOSE check_comb_spec;
     RETURN 'TRUE';
   ELSE
     CLOSE check_comb_spec;
   END IF;
   
   OPEN  check_detail_spec;
   FETCH check_detail_spec INTO results_;
   IF (check_detail_spec%FOUND) THEN
     CLOSE check_detail_spec;
     RETURN 'TRUE';
   ELSE
     CLOSE check_detail_spec;
   END IF;

   RETURN 'FALSE';
END Control_Type_Value_Exists;

PROCEDURE Remove_Posting_Control(
   company_      IN VARCHAR2,
   posting_type_ IN VARCHAR2,
   code_part_    IN VARCHAR2,
   control_type_ IN VARCHAR2,
   module_       IN VARCHAR2)
IS
BEGIN
   Posting_Ctrl_API.Remove_Posting_Control(company_,
                                           posting_type_,
                                           code_part_,
                                           control_type_,
                                           UPPER(module_));
END Remove_Posting_Control;

PROCEDURE Remove_Control_Type (
   control_type_  IN VARCHAR2,
   module_        IN VARCHAR2 )
IS
BEGIN
   Posting_Ctrl_Control_Type_API.Remove_Control_Type_(control_type_, UPPER(module_));
END Remove_Control_Type;

PROCEDURE Remove_Posting_Type (
   posting_type_  IN VARCHAR2 )
IS
BEGIN
   Posting_Ctrl_Posting_Type_API.Remove_Posting_Type_(posting_type_);
END Remove_Posting_Type;

PROCEDURE Remove_Allowed_Comb (
   posting_type_ IN VARCHAR2,
   control_type_ IN VARCHAR2,
   module_       IN VARCHAR2,
   code_part_    IN VARCHAR2 )
IS
BEGIN
   Posting_Ctrl_API.Remove_Allowed_Comb(posting_type_,
                                        control_type_,
                                        UPPER(module_),
                                        code_part_);
END Remove_Allowed_Comb;
