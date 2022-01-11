-----------------------------------------------------------------------------
--
--  Logical unit: PeriodAllocRuleLine
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  071205  Jeguse  Bug 69803 Created
--  090219  Jeguse  Bug 80680, Corrected
--  100716  Umdolk  EANE-2936, Reverse engineering - Corrected reference in base view.
--  121204  Maaylk  PEPA-183, Removed global variables
--  131029  Umdolk  PBFI-1332, Corrected model file errors
--  131114  Umdolk  PBFI-2064, Refactoring.
--  170309  Dakplk  STRFI-3113, Added method Post_Period_Allocation().
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------

FUNCTION Check_Exist_Line___ (
   alloc_line_id_ IN NUMBER) RETURN BOOLEAN
IS
   dummy_ NUMBER;
   CURSOR exist_control IS
      SELECT 1
      FROM   period_alloc_rule_line_tab
      WHERE  alloc_line_id = alloc_line_id_;
BEGIN
   OPEN  exist_control;
   FETCH exist_control INTO dummy_;
   IF (exist_control%FOUND) THEN
      CLOSE exist_control;
      RETURN(TRUE);
   END IF;
   CLOSE exist_control;
   RETURN(FALSE);
END Check_Exist_Line___;

@Override
PROCEDURE Delete___ (
   objid_  IN VARCHAR2,
   remrec_ IN period_alloc_rule_line_tab%ROWTYPE )
IS   
   alloc_exist_ VARCHAR2(5)     := 'FALSE';
BEGIN
   $IF Component_Genled_SYS.INSTALLED $THEN
      alloc_exist_ := Gen_Led_Voucher_Row_API.Check_Exist_Alloc_Id(remrec_.allocation_id);
   $END  
   IF (alloc_exist_ = 'FALSE') THEN
      super(objid_, remrec_);
   END IF;
END Delete___;

@Override
PROCEDURE Check_Common___ (
   oldrec_ IN     period_alloc_rule_line_tab%ROWTYPE,
   newrec_ IN OUT period_alloc_rule_line_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
   year_period_key_       NUMBER;
   year_period_disp_      VARCHAR2(10);
   year_period_key_flag_  BOOLEAN := FALSE ;
   year_period_disp_flag_ BOOLEAN := FALSE ;
BEGIN
   IF (Client_SYS.Item_Exist('YEAR_PERIOD_KEY',attr_)) THEN
      year_period_key_      := Client_SYS.Attr_Value_To_Number( Client_SYS.Cut_Item_Value('YEAR_PERIOD_KEY',attr_));  
      year_period_key_flag_ := TRUE;
   END IF;
   IF (Client_SYS.Item_Exist('YEAR_PERIOD_DISP',attr_)) THEN
      year_period_disp_      := Client_SYS.Cut_Item_Value('YEAR_PERIOD_DISP',attr_);
      year_period_disp_flag_ := TRUE ;
   END IF;
   IF (year_period_key_flag_) THEN
      newrec_.accounting_year := TRUNC(year_period_key_ / 100);
      newrec_.accounting_period := year_period_key_ - (TRUNC(year_period_key_ / 100)*100);
      Period_Allocation_Rule_API.Exist_Accounting_Period (newrec_.accounting_year,
                                                          newrec_.accounting_period,
                                                          newrec_.allocation_id);
   END IF;
   IF (year_period_disp_flag_) THEN
      BEGIN
         year_period_key_ := REPLACE(year_period_disp_,' ');
      EXCEPTION
         WHEN OTHERS THEN
            Error_SYS.Record_General(lu_name_, 'NOVALYP: Not a valid Accounting Year / Period');
      END;
      newrec_.accounting_year   := TRUNC(year_period_key_ / 100);
      newrec_.accounting_period := year_period_key_ - (TRUNC(year_period_key_ / 100)*100);
      Period_Allocation_Rule_API.Exist_Accounting_Period (newrec_.accounting_year,
                                                          newrec_.accounting_period,
                                                          newrec_.allocation_id);
   END IF;
   Period_Allocation_Rule_API.Exist_Accounting_Period (newrec_.accounting_year,
                                                       newrec_.accounting_period,
                                                       newrec_.allocation_id);
   super(oldrec_, newrec_, indrec_, attr_);
END Check_Common___;

@Override
PROCEDURE Check_Insert___ (
   newrec_ IN OUT period_alloc_rule_line_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS   
BEGIN  
   IF (newrec_.alloc_line_id IS NULL) THEN
      newrec_.alloc_line_id := Period_Allocation_Rule_API.Get_Next_Alloc_Line_Seq;
      Client_SYS.Add_To_Attr('ALLOC_LINE_ID', newrec_.alloc_line_id, attr_);
   END IF;
   
   indrec_.allocation_id := NULL;   
   super(newrec_, indrec_, attr_);
END Check_Insert___;

-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------

-------------------- LU SPECIFIC PROTECTED METHODS --------------------------

-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

PROCEDURE Exist_Line(
   alloc_line_id_ IN NUMBER)
IS
BEGIN
   IF (NOT Check_Exist_Line___(alloc_line_id_)) THEN
      Error_SYS.Record_Not_Exist(lu_name_);
   END IF;
END Exist_Line;

PROCEDURE New(
   newrec_     IN OUT period_alloc_rule_line_tab%ROWTYPE)
IS
   attr_       VARCHAR2(2000);
   objid_      period_alloc_rule_line.objid%TYPE;
   objversion_ period_alloc_rule_line.objversion%TYPE;
BEGIN
   Period_Allocation_Rule_API.Exist_Accounting_Period (newrec_.accounting_year,
                                                       newrec_.accounting_period,
                                                       newrec_.allocation_id);
   newrec_.rowkey := NULL;
   Insert___(objid_, objversion_, newrec_, attr_);
END New;

PROCEDURE Modify (
   attr_          IN OUT VARCHAR2, 
   allocation_id_ IN     NUMBER,
   alloc_line_id_ IN     NUMBER )
IS
   info_           VARCHAR2(2000);
   objid_          period_alloc_rule_line.objid%TYPE;
   objversion_     period_alloc_rule_line.objversion%TYPE;
BEGIN
   Get_Id_Version_By_Keys___ (objid_, objversion_, allocation_id_, alloc_line_id_);
   IF (objid_ IS NOT NULL AND objversion_ IS NOT NULL) THEN
      Modify__( info_, objid_, objversion_, attr_, 'DO');
   END IF;
END Modify;

PROCEDURE Remove(
   allocation_id_ IN NUMBER,
   alloc_line_id_ IN NUMBER )
IS
   info_         VARCHAR2(2000);
   objid_        period_alloc_rule_line.objid%TYPE;
   objversion_   period_alloc_rule_line.objversion%TYPE;
BEGIN
   Get_Id_Version_By_Keys___(objid_, objversion_, allocation_id_, alloc_line_id_);
   IF (objid_ IS NOT NULL AND objversion_ IS NOT NULL) THEN
      Remove__( info_, objid_, objversion_, 'DO');
   END IF;
END Remove;
