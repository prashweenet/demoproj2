-----------------------------------------------------------------------------
--
--  Logical unit: PeriodAllocation
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  960321  xxxx  Base Table to Logical Unit Generator 1.0A
--  970124  YoHe  Added function Any_Voucher
--  970214  YoHe  Added new column call ALLOC_AMOUNT
--  970226  YoHe  Added procedure Get_Period_Interval
--  970227  YoHe  Added one more parameter in function Any_Voucher
--  970717  SLKO  Converted to Foundation 1.2.2d
--  970721  JoTh  Bug #97-0030 corrected -> STD_0100B, STD_0200A, STD_0300
--  970919  ????  Corrected bug #97-0058
--  970922  PICZ  OBJVERSION converted to LONG STRING
--  970926  ANDJ  Bug correction # 97-0058 undone.
--  980127  SLKO  Converted to Foundation1 2.0.0
--  990709  HIMM  Modified withrespect to template changes
--  991005  Ruwan Bug # 11111, Missing reference
--  000914  HiMu  Added General_SYS.Init_Method
--  011011  Thsrlk Added  procedure Insert_IL_Peralloc___
--  011016  JeGu   Bug #25504. Modified Insert_IL_Peralloc___ and New___
--  011022  Thsrlk Bug # 24054  Added  procedure Modify_IL_Peralloc___ & Added  procedure Remove_IL_Peralloc___
--  020123  Thsrlk Bug # 24054. canged Insert_IL_Peralloc___, Modify_IL_Peralloc___ &  Remove_IL_Peralloc___
--  021002  Nimalk   Removed usage of the view Company_Finance_Auth in PERIOD_ALLOCATION view
--                   and replaced by view Company_Finance_Auth1 using EXISTS caluse instead of joins
--  041103  Gawilk FIPR307. Added methods New, Modify, Remove.
--  050915  Chajlk LCS Merge(33986).
--  050926  Nsillk LCS Merge(51863).
--  051108  Gawilk Removed Get_Allocation_Details.
--  071125  Jeguse Bug 69231 Corrected.
--  071201  Jeguse Bug 69803 Corrected.
--  080308  Nsillk Bug 71922, Corrected.Modified method Update_Alloc_Vou_Type
--  080714  Mawelk Bug 74726 corrected. Modifications to Insert___() and Update___()
--  090508  reanpl Bug 82373, SKwP Ceritificate - Final Closing of Period
--  100101  HimRlk Reverse engineering, made accounting_year a parent key and added REF to VoucherRow from 
--  100101         column accounting_year in view comments.
--  100423  SaFalk Modified REF to row_no in PERIOD_ALLOCATION.
--  111020  Swralk SFI-143, Added conditional compilation for the places that had called package INTLED_CONNECTION_V110_API and INTLED_CONNECTION_V130_API.
--  120404  clstlk EASTRTM-8686 (LCS Merge Bug 101800).
--  121123  Thpelk  Bug 106680 - Modified Conditional compilation to use single component package.
--  121204  Maaylk  PEPA-183, Removed global variable
--  131217  Umdolk  PBFI-3638, Moved overrides in Modify__, Remove__ to Update___ and Delete___.
--  170309  AjPelk  STRFI-3114, Added method Distribute_Allocation_Lines() and New() and Get_Until_Date()
--  170601  chiblk  STRFI-5116, changed the signature of the method Distribute_Allocation_Lines().
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------

@DynamicComponentDependency INTLED
PROCEDURE Insert_Il_Peralloc___ (
   alloc_rec_ IN period_allocation_tab%ROWTYPE )
IS
   il_alloc_rec_     Internal_Ledger_Util_Pub_API.Int_Per_Alloc_Rec;   
BEGIN   
   IF (Voucher_Type_API.Is_Vou_Type_All_Ledger (alloc_rec_.company,
                                                alloc_rec_.voucher_type) = 'TRUE') THEN
      il_alloc_rec_.company                :=  alloc_rec_.company;
      il_alloc_rec_.voucher_type           :=  alloc_rec_.voucher_type;
      il_alloc_rec_.voucher_no             :=  alloc_rec_.voucher_no;
      il_alloc_rec_.ref_row_no             :=  alloc_rec_.row_no;
      il_alloc_rec_.accounting_year        :=  alloc_rec_.accounting_year;
      il_alloc_rec_.alloc_period           :=  alloc_rec_.alloc_period;
      il_alloc_rec_.alloc_year             :=  alloc_rec_.alloc_year;
      il_alloc_rec_.alloc_percent          :=  alloc_rec_.alloc_percent;
      il_alloc_rec_.until_year             :=  alloc_rec_.until_year;
      il_alloc_rec_.until_period           :=  alloc_rec_.until_period;
      il_alloc_rec_.alloc_amount           :=  alloc_rec_.alloc_amount;
      il_alloc_rec_.per_alloc_voucher_type :=  alloc_rec_.alloc_vou_type;
      il_alloc_rec_.user_group             :=  alloc_rec_.user_group;
      Internal_Ledger_Util_Pub_API.Insert_IL_Peralloc (il_alloc_rec_);
   END IF;
END Insert_Il_Peralloc___;

@DynamicComponentDependency INTLED
PROCEDURE Modify_Il_Peralloc___ (
   alloc_rec_ IN period_allocation_tab%ROWTYPE )
IS
   il_alloc_rec_     Internal_Ledger_Util_Pub_API.Int_Per_Alloc_Rec;   
BEGIN   
   IF (Voucher_Type_API.Is_Vou_Type_All_Ledger (alloc_rec_.company,
                                                alloc_rec_.voucher_type) = 'TRUE') THEN
      il_alloc_rec_.company                :=  alloc_rec_.company;
      il_alloc_rec_.voucher_type           :=  alloc_rec_.voucher_type;
      il_alloc_rec_.voucher_no             :=  alloc_rec_.voucher_no;
      il_alloc_rec_.ref_row_no             :=  alloc_rec_.row_no;
      il_alloc_rec_.accounting_year        :=  alloc_rec_.accounting_year;
      il_alloc_rec_.alloc_period           :=  alloc_rec_.alloc_period;
      il_alloc_rec_.alloc_year             :=  alloc_rec_.alloc_year;
      il_alloc_rec_.alloc_percent          :=  alloc_rec_.alloc_percent;
      il_alloc_rec_.until_year             :=  alloc_rec_.until_year;
      il_alloc_rec_.until_period           :=  alloc_rec_.until_period;
      il_alloc_rec_.alloc_amount           :=  alloc_rec_.alloc_amount;
      il_alloc_rec_.per_alloc_voucher_type :=  alloc_rec_.alloc_vou_type;
      il_alloc_rec_.user_group             :=  alloc_rec_.user_group;
      Internal_Ledger_Util_Pub_API.Modify_IL_Peralloc (il_alloc_rec_);
   END IF;
  
END Modify_Il_Peralloc___;

@DynamicComponentDependency INTLED
PROCEDURE Remove_Il_Peralloc___ (
   alloc_rec_ IN period_allocation_tab%ROWTYPE )
IS
   il_alloc_rec_     Internal_Ledger_Util_Pub_API.Int_Per_Alloc_Rec;
BEGIN

   IF (Voucher_Type_API.Is_Vou_Type_All_Ledger (alloc_rec_.company,
                                                alloc_rec_.voucher_type) = 'TRUE') THEN
      il_alloc_rec_.company         :=  alloc_rec_.company;
      il_alloc_rec_.voucher_type    :=  alloc_rec_.voucher_type;
      il_alloc_rec_.voucher_no      :=  alloc_rec_.voucher_no;
      il_alloc_rec_.ref_row_no      :=  alloc_rec_.row_no;
      il_alloc_rec_.accounting_year :=  alloc_rec_.accounting_year;
      il_alloc_rec_.alloc_period    :=  alloc_rec_.alloc_period;
      il_alloc_rec_.alloc_year      :=  alloc_rec_.alloc_year;
      il_alloc_rec_.alloc_percent   :=  alloc_rec_.alloc_percent;
      il_alloc_rec_.until_year      :=  alloc_rec_.until_year;
      il_alloc_rec_.until_period    :=  alloc_rec_.until_period;
      il_alloc_rec_.alloc_amount    :=  alloc_rec_.alloc_amount;
      Internal_Ledger_Util_Pub_API.Remove_IL_Peralloc (il_alloc_rec_);
   END IF;
END Remove_Il_Peralloc___;

@Override
PROCEDURE Update___ (
   objid_      IN     VARCHAR2,
   oldrec_     IN     period_allocation_tab%ROWTYPE,
   newrec_     IN OUT period_allocation_tab%ROWTYPE,
   attr_       IN OUT VARCHAR2,
   objversion_ IN OUT VARCHAR2,
   by_keys_    IN     BOOLEAN DEFAULT FALSE )
IS
BEGIN   
   super(objid_, oldrec_, newrec_, attr_, objversion_, by_keys_);
   $IF Component_Intled_SYS.INSTALLED $THEN
       Modify_IL_Peralloc___(newrec_);
   $END
END Update___;

@Override
PROCEDURE Insert___ (
   objid_      OUT    VARCHAR2,
   objversion_ OUT    VARCHAR2,
   newrec_     IN OUT period_allocation_tab%ROWTYPE,
   attr_       IN OUT VARCHAR2 )
IS
BEGIN   
   Voucher_API.Prepare_Allocation__ (newrec_.company,
                                     newrec_.accounting_year,
                                     newrec_.voucher_type,
                                     newrec_.voucher_no);   
   super(objid_, objversion_, newrec_, attr_);
   --Add post-processing code here
   $IF Component_Intled_SYS.INSTALLED $THEN
      Insert_IL_Peralloc___(newrec_);
   $ELSE
      NULL;
   $END    
END Insert___;

@Override
PROCEDURE Delete___ (
   objid_  IN VARCHAR2,
   remrec_ IN period_allocation_tab%ROWTYPE )
IS
BEGIN
   super(objid_, remrec_);
   $IF Component_Intled_SYS.INSTALLED $THEN
      Remove_IL_Peralloc___(remrec_);
   $END
END Delete___;

PROCEDURE Get_Allocation_Info___(
   user_group_      OUT VARCHAR2,
   alloc_vou_type_  OUT VARCHAR2,
   distr_type_      OUT VARCHAR2,
   creator_         OUT VARCHAR2,
   from_date_       OUT DATE,
   until_date_      OUT DATE,   
   company_         IN VARCHAR2,
   voucher_type_    IN VARCHAR2,
   accounting_year_ IN NUMBER,
   voucher_no_      IN NUMBER,
   row_no_          IN NUMBER)
IS 
   CURSOR get_rec IS
      SELECT user_group, alloc_vou_type, distr_type, creator, from_date, until_date
      FROM   period_allocation_tab 
      WHERE  company         = company_
      AND    voucher_type    = voucher_type_
      AND    accounting_year = accounting_year_
      AND    voucher_no      = voucher_no_
      AND    row_no          = row_no_;   
BEGIN
   OPEN  get_rec;
   FETCH get_rec INTO user_group_, alloc_vou_type_, distr_type_, creator_, from_date_, until_date_;
   CLOSE get_rec;
END Get_Allocation_Info___;

-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------


-------------------- LU SPECIFIC PROTECTED METHODS --------------------------

PROCEDURE Remove_Period_Allocation_ (
   company_          IN VARCHAR2,
   voucher_type_     IN VARCHAR2,
   accounting_year_  IN NUMBER,
   voucher_no_       IN NUMBER )
IS
   info_       VARCHAR2(100);
   
   CURSOR getperalloc IS
      SELECT rowid objid, ltrim(lpad(to_char(rowversion,'YYYYMMDDHH24MISS'),2000)) objversion
      FROM   period_allocation_tab
      WHERE  company = company_
      AND    voucher_type = voucher_type_
      AND    accounting_year = accounting_year_
      AND    voucher_no = voucher_no_;
BEGIN
   FOR rec_peralloc IN getperalloc LOOP
      Remove__ ( info_, rec_peralloc.objid, rec_peralloc.objversion, 'DO' );
   END LOOP;   
END Remove_Period_Allocation_;

PROCEDURE Remove_Period_Allocation2_ (
   company_          IN VARCHAR2,
   voucher_type_     IN VARCHAR2,
   accounting_year_  IN NUMBER,
   voucher_no_       IN NUMBER )
IS
BEGIN
   DELETE
   FROM   period_allocation_tab
   WHERE  company         = company_
   AND    voucher_type    = voucher_type_
   AND    accounting_year = accounting_year_
   AND    voucher_no      = voucher_no_;
END Remove_Period_Allocation2_;

-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------



@UncheckedAccess
FUNCTION Any_Allocation (
   company_          IN VARCHAR2,
   voucher_type_     IN VARCHAR2,
   voucher_no_       IN NUMBER,
   row_no_           IN NUMBER,
   accounting_year_  IN NUMBER ) RETURN VARCHAR2
IS
   dummy_ VARCHAR2(1);
   
   CURSOR period_alloc IS
      SELECT 'X'
      FROM   PERIOD_ALLOCATION_TAB
      WHERE  company         = company_
      AND    voucher_type    = voucher_type_
      AND    voucher_no      = voucher_no_
      AND    row_no          = row_no_
      AND    accounting_year = accounting_year_;   
BEGIN
   OPEN period_alloc ;
   FETCH period_alloc INTO dummy_;
   IF (period_alloc%FOUND) THEN
      CLOSE period_alloc;
      RETURN('Y');
   ELSE
      CLOSE period_alloc;
      RETURN('N');
   END IF;
   CLOSE period_alloc;
END Any_Allocation;


@UncheckedAccess
FUNCTION Any_Allocation (
   company_          IN VARCHAR2,
   voucher_type_     IN VARCHAR2,
   voucher_no_       IN NUMBER,
   accounting_year_  IN NUMBER ) RETURN VARCHAR2
IS
   dummy_ VARCHAR2(1);
   
   CURSOR period_alloc IS
      SELECT 'X'
      FROM   period_allocation_tab
      WHERE  company         = company_
      AND    voucher_type    = voucher_type_
      AND    voucher_no      = voucher_no_
      AND    accounting_year = accounting_year_;  
BEGIN
   OPEN period_alloc ;
   FETCH period_alloc INTO dummy_;
   IF (period_alloc%FOUND) THEN
      CLOSE period_alloc;
      RETURN('Y');
   ELSE
      CLOSE period_alloc;
      RETURN('N');
   END IF;
   CLOSE period_alloc;
END Any_Allocation;

@UncheckedAccess
FUNCTION Check_Year_Period_Exist (
   company_      IN VARCHAR2,
   alloc_year_   IN NUMBER,
   alloc_period_ IN VARCHAR2 ) RETURN VARCHAR2
IS
   dummy_ NUMBER;
   CURSOR exist_control IS
      SELECT 1
      FROM   period_allocation_tab
      WHERE  company      = company_
      AND    alloc_year   = alloc_year_
      AND    alloc_period = alloc_period_;
BEGIN
   OPEN exist_control;
   FETCH exist_control INTO dummy_;
   IF (exist_control%FOUND) THEN
      CLOSE exist_control;
      RETURN('TRUE');
   END IF;
   CLOSE exist_control;
   RETURN('FALSE');
END Check_Year_Period_Exist;

@UncheckedAccess
FUNCTION Check_Allocation_Exist_Todate (
   company_      IN VARCHAR2,
   alloc_year_   IN NUMBER,
   alloc_period_ IN NUMBER ) RETURN VARCHAR2
IS
   dummy_ NUMBER;
   CURSOR exist_control IS
      SELECT 1
      FROM   period_allocation_tab
      WHERE  company      = company_
      AND    ((alloc_year = alloc_year_ AND alloc_period <= alloc_period_) OR (alloc_year < alloc_year_));       
BEGIN
   OPEN exist_control;
   FETCH exist_control INTO dummy_;
   IF (exist_control%FOUND) THEN
      CLOSE exist_control;
      RETURN('TRUE');
   END IF;
   CLOSE exist_control;
   RETURN('FALSE');
END Check_Allocation_Exist_Todate;

PROCEDURE Get_Period_Interval (
   from_year_       IN OUT NUMBER,
   from_period_     IN OUT NUMBER,
   until_year_      IN OUT NUMBER,
   until_period_    IN OUT NUMBER,
   company_         IN     VARCHAR2,
   voucher_type_    IN     VARCHAR2,
   voucher_no_      IN     NUMBER,
   accounting_year_ IN     NUMBER,
   row_no_          IN     NUMBER )
IS
   CURSOR get_period_interval IS
      SELECT MIN(alloc_year),
             MIN(alloc_period),
             MAX(alloc_year),
             MAX(alloc_period)
      FROM   period_allocation_tab
      WHERE  company         = company_
      AND    voucher_type    = voucher_type_
      AND    voucher_no      = voucher_no_
      AND    accounting_year = accounting_year_
      AND    row_no          = row_no_;
BEGIN
   OPEN get_period_interval;
   FETCH get_period_interval INTO from_year_, from_period_, until_year_, until_period_;
   IF (get_period_interval%NOTFOUND) THEN
      from_year_    := NULL;
      from_period_  := NULL;
      until_year_   := NULL;
      until_period_ := NULL;
   END IF;
   CLOSE get_period_interval;
END Get_Period_Interval;

PROCEDURE New(
   attr_ IN OUT VARCHAR2)
IS
   info_           VARCHAR2(2000);
   objid_          period_allocation.objid%TYPE;
   objversion_     period_allocation.objversion%TYPE;
   alloc_percent_  NUMBER;
BEGIN
   alloc_percent_ := Client_SYS.Get_Item_Value_To_Number('ALLOC_PERCENT', attr_, lu_name_);
   IF (alloc_percent_ IS NOT NULL AND alloc_percent_ != 0) THEN
      New__( info_, objid_, objversion_, attr_, 'DO');
   END IF;   
END New;

PROCEDURE Modify (
   attr_              IN OUT VARCHAR2, 
   company_           IN     VARCHAR2,
   voucher_type_      IN     VARCHAR2,
   voucher_no_        IN     NUMBER,
   row_no_            IN     NUMBER,
   accounting_year_   IN     NUMBER,
   alloc_period_      IN     NUMBER,
   alloc_year_        IN     NUMBER)
IS
   info_              VARCHAR2(2000);
   objid_             period_allocation.objid%TYPE;
   objversion_        period_allocation.objversion%TYPE;
BEGIN
   Get_Id_Version_By_Keys___ ( objid_,
                               objversion_,
                               company_,
                               voucher_type_,
                               voucher_no_,
                               row_no_,
                               accounting_year_,
                               alloc_period_,
                               alloc_year_);
   IF (objid_ IS NOT NULL AND objversion_ IS NOT NULL) THEN
      Modify__( info_, objid_, objversion_, attr_, 'DO');
   END IF;
END Modify;

PROCEDURE Remove(
   company_           IN VARCHAR2,
   voucher_type_      IN VARCHAR2,
   voucher_no_        IN NUMBER,
   row_no_            IN NUMBER,
   accounting_year_   IN NUMBER,
   alloc_period_      IN NUMBER,
   alloc_year_        IN NUMBER)
IS
   info_              VARCHAR2(2000);
   objid_             period_allocation.objid%TYPE;
   objversion_        period_allocation.objversion%TYPE;
BEGIN
   Get_Id_Version_By_Keys___ ( objid_,
                               objversion_,
                               company_,
                               voucher_type_,
                               voucher_no_,
                               row_no_,
                               accounting_year_,
                               alloc_period_,
                               alloc_year_);

   IF (objid_ IS NOT NULL AND objversion_ IS NOT NULL) THEN
      Remove__( info_, objid_, objversion_, 'DO');
   END IF;
END Remove;

PROCEDURE New_Record(
   newrec_     IN period_allocation_tab%ROWTYPE)
IS
   newrecx_       period_allocation_tab%ROWTYPE;
   objid_         VARCHAR2(2000);
   objversion_    VARCHAR2(2000);
   attr_          VARCHAR2(2000);
BEGIN
   newrecx_ := newrec_;
   newrecx_.rowkey := NULL;
   Insert___ ( objid_,
               objversion_,
               newrecx_,
               attr_ );
END New_Record;

FUNCTION Get_Default_Voucher_Type (
   company_         IN VARCHAR2,   
   from_date_       IN DATE,
   user_group_      IN VARCHAR2) RETURN VARCHAR2   
IS
   voucher_type_        Period_Allocation_TAB.alloc_vou_type%TYPE;
   accounting_year_     NUMBER;
   accounting_period_   NUMBER;
BEGIN
   Accounting_Period_API.Get_Ordinary_Accounting_Year(accounting_year_, accounting_period_, company_, from_date_);   
   Voucher_Type_User_Group_API.Get_Default_Voucher_Type(voucher_type_, company_, user_group_, accounting_year_, 'X');   
   RETURN voucher_type_;   
END Get_Default_Voucher_Type;

-- to be used by the period_allocation dialogs
PROCEDURE Validate_UserGrp_Vou_Type(
   company_         IN VARCHAR2,   
   from_date_       IN DATE,
   user_group_      IN VARCHAR2,
   alloc_vou_type_  IN VARCHAR2)   
IS
   accounting_year_     NUMBER;
   accounting_period_   NUMBER;
BEGIN
   Accounting_Period_API.Get_Ordinary_Accounting_Year(accounting_year_, accounting_period_, company_, from_date_);   
   Voucher_Type_API.Validate_Vou_Type_Vou_Grp(company_, alloc_vou_type_, 'X');
   Voucher_Type_API.Validate_Vou_Type_All_Gen(company_, alloc_vou_type_);
   Voucher_Type_User_Group_API.Validate_Voucher_Type(company_, alloc_vou_type_, 'X', accounting_year_, user_group_);         
END Validate_UserGrp_Vou_Type;   

@SecurityCheck Company.UserAuthorized(company_)
PROCEDURE Update_Alloc_Vou_Type (
   company_         IN VARCHAR2,
   voucher_type_    IN VARCHAR2,
   voucher_no_      IN NUMBER,
   row_no_          IN NUMBER,
   accounting_year_ IN NUMBER,
   user_group_      IN VARCHAR2,
   alloc_vou_type_  IN VARCHAR2 )
IS
   dummy_    NUMBER;
   
   CURSOR check_user_group IS
      SELECT 1 
      FROM   user_group_member_finance4 
      WHERE  company = company_ 
      AND    allowed_acc_period_db = '1'
      AND    user_group = user_group_;
      
   CURSOR check_vou_type IS
      SELECT 1 
      FROM   voucher_type_user_grp_all_gl 
      WHERE  company         = company_ 
      AND    accounting_year = accounting_year_
      AND    user_group      = user_group_
      AND    voucher_type    = alloc_vou_type_;
BEGIN
   OPEN  check_user_group;
   FETCH check_user_group INTO dummy_;
   IF (check_user_group%NOTFOUND) THEN
      CLOSE check_user_group;
      Error_SYS.Record_General(lu_name_, 'ERRALLUGRP: User Group :P1 does not exist', user_group_);
   END IF;
   CLOSE check_user_group;
   --
   OPEN  check_vou_type;
   FETCH check_vou_type INTO dummy_;
   IF (check_vou_type%NOTFOUND) THEN
      CLOSE check_vou_type;
      Error_SYS.Record_General(lu_name_, 'ERRALLVOUG: Voucher Type :P1 is not valid', alloc_vou_type_);
   END IF;
   CLOSE check_vou_type;
   --
   UPDATE period_allocation_tab
   SET    user_group      = user_group_,
          alloc_vou_type  = alloc_vou_type_,
          rowversion      = SYSDATE
   WHERE  company         = company_
   AND    voucher_type    = voucher_type_
   AND    voucher_no      = voucher_no_
   AND    row_no          = row_no_
   AND    accounting_year = accounting_year_;
END Update_Alloc_Vou_Type;


PROCEDURE Update_Row_No(
   new_row_no_     IN NUMBER,
   company_         IN VARCHAR2,
   voucher_type_    IN VARCHAR2,
   accounting_year_ IN NUMBER,
   voucher_no_      IN NUMBER,
   old_row_no_     IN NUMBER)
IS
BEGIN
   UPDATE period_allocation_tab
   SET    row_no          = new_row_no_
   WHERE  company         = company_
   AND    voucher_type    = voucher_type_
   AND    accounting_year = accounting_year_
   AND    voucher_no      = voucher_no_
   AND    row_no          = old_row_no_;
END Update_Row_No;

@UncheckedAccess
FUNCTION Exists_Year_Period_Until (
   company_      IN VARCHAR2,
   alloc_year_   IN NUMBER,
   alloc_period_ IN NUMBER,
   ledger_id_    IN VARCHAR2 ) RETURN NUMBER
IS
   count_           NUMBER;  
                     
   CURSOR exist_control IS
      SELECT COUNT(*)
      FROM   period_allocation_tab p
      WHERE  p.company      = company_
      AND    (p.alloc_year < alloc_year_ 
             OR (p.alloc_year = alloc_year_ AND p.alloc_period = alloc_period_ ))
      AND    1 = (SELECT 1 
                  FROM   voucher_type_tab v 
                  WHERE  p.company        = v.company
                  AND    p.alloc_vou_type = v.voucher_type
                  AND    v.ledger_id     IN (ledger_id_, '*'));
BEGIN
   IF (NOT Company_Finance_API.Is_User_Authorized(company_)) THEN
      RETURN 0;
   END IF;
   
   OPEN exist_control;
   FETCH exist_control INTO count_;
   CLOSE exist_control;
   
   RETURN count_;
END Exists_Year_Period_Until;

@UncheckedAccess
FUNCTION Check_Year_Period_Exist_Ledger(
   company_      IN VARCHAR2,
   alloc_year_   IN NUMBER,
   alloc_period_ IN NUMBER,
   ledger_id_    IN VARCHAR2) RETURN VARCHAR2
IS
   dummy_ NUMBER;
   CURSOR exist_control IS
      SELECT 1
      FROM   period_allocation_tab p
      WHERE  p.company      = company_
      AND    p.alloc_year   = alloc_year_
      AND    p.alloc_period = alloc_period_
      AND    EXISTS (SELECT 1 
                  FROM   voucher_type_tab v 
                  WHERE  p.company        = v.company
                  AND    p.alloc_vou_type = v.voucher_type
                  AND    v.ledger_id   IN (ledger_id_, '*'));
BEGIN
   OPEN exist_control;
   FETCH exist_control INTO dummy_;
   IF (exist_control%FOUND) THEN
      CLOSE exist_control;
      RETURN('TRUE');
   END IF;
   CLOSE exist_control;
   RETURN('FALSE');
END Check_Year_Period_Exist_Ledger;

PROCEDURE New(
   newrec_     IN OUT period_allocation_tab%ROWTYPE)
IS
BEGIN
   New___(newrec_);
END New;

PROCEDURE Distribute_Allocation_Lines(
   company_               IN VARCHAR2,
   accounting_year_       IN NUMBER,
   voucher_type_          IN VARCHAR2,
   voucher_no_            IN NUMBER,
   row_no_                IN NUMBER,
   from_date_             IN DATE,
   until_date_            IN DATE,
   total_amount_          IN NUMBER,
   distr_type_            IN VARCHAR2,
   currency_code_         IN VARCHAR2,
   user_group_            IN VARCHAR2,   
   alloc_vou_type_        IN VARCHAR2)
IS
   alloc_tab_              Period_Allocation_Rule_API.Public_Allocation_Tab;    
   newrec_                 period_allocation_tab%ROWTYPE;
   ledger_id_              acc_year_ledger_info_tab.ledger_id%TYPE;
   from_year_              NUMBER;
   from_period_            NUMBER;
   until_year_             NUMBER;
   until_period_           NUMBER;   
   no_of_actual_periods_   NUMBER;         
   from_year_period_       NUMBER;
   until_year_period_      NUMBER;
   until_per_from_date_    DATE;
   until_per_until_date_   DATE;
   from_per_from_date_     DATE;
   from_per_until_date_    DATE;
   
   CURSOR count_accperiod_actual IS
      SELECT 1
      FROM   accounting_period_tab
      WHERE  company = company_
      AND    ((accounting_year * 100) + accounting_period) BETWEEN from_year_period_ AND until_year_period_
      AND    year_end_period = 'ORDINARY'
      AND    User_Group_Period_API.Is_Period_Open_GL_IL(company, 
                                                        accounting_year, 
                                                        accounting_period, 
                                                        user_group_ , 
                                                        ledger_id_) = 'FALSE';         
BEGIN  
   DELETE 
   FROM  period_allocation_tab
   WHERE company = company_
   AND   accounting_year = accounting_year_
   AND   voucher_type = voucher_type_
   AND   voucher_no = voucher_no_
   AND   row_no   = row_no_;
  
   Accounting_Period_API.Get_Period_Info(from_year_, from_period_, from_per_from_date_, from_per_until_date_, company_, from_date_);
   Accounting_Period_API.Get_Period_Info(until_year_, until_period_, until_per_from_date_, until_per_until_date_, company_, until_date_);
   from_year_period_  := (from_year_ * 100) + from_period_;
   until_year_period_ := (until_year_ * 100) + until_period_;  
   
   ledger_id_ := Voucher_Type_API.Get_Ledger_Id(company_, voucher_type_);
   
   OPEN  count_accperiod_actual;      
   FETCH count_accperiod_actual INTO no_of_actual_periods_;
   IF (count_accperiod_actual%FOUND) THEN
      CLOSE count_accperiod_actual;         
      Error_SYS.Record_General( lu_name_, 'PERIODCLOSED: One or more period(s) in the interval are closed for user group :P1.', user_group_);         
   END IF;
   CLOSE count_accperiod_actual;  
      
   alloc_tab_ := Period_Allocation_Rule_API.Distribute_Allocations(company_,
                                                                  from_date_,
                                                                  until_date_,
                                                                  total_amount_,
                                                                  NVL(distr_type_,'E'),
                                                                  currency_code_);  
   newrec_.company            := company_;
   newrec_.accounting_year    := accounting_year_;
   newrec_.voucher_type       := voucher_type_;
   newrec_.voucher_no         := voucher_no_;
   newrec_.row_no             := row_no_;
   newrec_.alloc_vou_type     := alloc_vou_type_;
   newrec_.user_group         := user_group_;
   newrec_.from_date          := from_date_;
   newrec_.until_date         := until_date_;     
   newrec_.until_period       := from_period_;
   newrec_.until_year         := until_year_;
   newrec_.distr_type         := distr_type_;
   newrec_.creator            := 'ManualVoucher';   
   
   IF (alloc_tab_.COUNT > 0) THEN
      FOR i_ IN alloc_tab_.FIRST.. alloc_tab_.LAST LOOP
         newrec_.alloc_year            := alloc_tab_(i_).accounting_year;
         newrec_.alloc_period          := alloc_tab_(i_).accounting_period;
         newrec_.alloc_amount          := alloc_tab_(i_).amount;
         newrec_.alloc_percent         := alloc_tab_(i_).percentage;      
         Period_Allocation_API.New___(newrec_);         
      END LOOP;
   END IF;
END Distribute_Allocation_Lines;

FUNCTION Get_Alloc_User_Group(
   company_         IN VARCHAR2,
   voucher_type_    IN VARCHAR2,
   voucher_no_      IN NUMBER,
   row_no_          IN NUMBER,
   accounting_year_ IN NUMBER) RETURN VARCHAR2
IS
   user_group_      period_allocation_tab.user_group%TYPE;
   alloc_vou_type_  period_allocation_tab.alloc_vou_type%TYPE;
   distr_type_      period_allocation_tab.distr_type%TYPE;
   from_date_       period_allocation_tab.from_date%TYPE;
   until_date_      period_allocation_tab.until_date%TYPE;
   creator_         period_allocation_tab.creator%TYPE;
BEGIN
   Get_Allocation_Info___(user_group_, alloc_vou_type_, distr_type_, creator_, from_date_, until_date_,company_, voucher_type_, accounting_year_, voucher_no_, row_no_);
   RETURN user_group_;
END Get_Alloc_User_Group; 

FUNCTION Get_Alloc_Vou_Type(
   company_         IN VARCHAR2,
   voucher_type_    IN VARCHAR2,
   voucher_no_      IN NUMBER,
   row_no_          IN NUMBER,
   accounting_year_ IN NUMBER) RETURN VARCHAR2
IS
   user_group_      period_allocation_tab.user_group%TYPE;
   alloc_vou_type_  period_allocation_tab.alloc_vou_type%TYPE;
   distr_type_      period_allocation_tab.distr_type%TYPE;
   from_date_       period_allocation_tab.from_date%TYPE;
   until_date_      period_allocation_tab.until_date%TYPE;
   creator_         period_allocation_tab.creator%TYPE;
BEGIN
   Get_Allocation_Info___(user_group_, alloc_vou_type_, distr_type_, creator_, from_date_, until_date_, company_, voucher_type_, accounting_year_, voucher_no_, row_no_);
   RETURN alloc_vou_type_;      
END Get_Alloc_Vou_Type; 

FUNCTION Get_Alloc_Distr_Type_Db(
   company_         IN VARCHAR2,
   voucher_type_    IN VARCHAR2,
   voucher_no_      IN NUMBER,
   row_no_          IN NUMBER,
   accounting_year_ IN NUMBER) RETURN VARCHAR2
IS
   user_group_      period_allocation_tab.user_group%TYPE;
   alloc_vou_type_  period_allocation_tab.alloc_vou_type%TYPE;
   distr_type_      period_allocation_tab.distr_type%TYPE;
   from_date_       period_allocation_tab.from_date%TYPE;
   until_date_      period_allocation_tab.until_date%TYPE;
   creator_         period_allocation_tab.creator%TYPE;
BEGIN
   Get_Allocation_Info___(user_group_, alloc_vou_type_, distr_type_, creator_, from_date_, until_date_, company_, voucher_type_, accounting_year_, voucher_no_, row_no_);
   RETURN distr_type_;      
END Get_Alloc_Distr_Type_Db;

@UncheckedAccess
FUNCTION Get_Creator (
   company_         IN VARCHAR2,
   accounting_year_ IN NUMBER,
   voucher_type_    IN VARCHAR2,
   voucher_no_      IN NUMBER,
   row_no_          IN NUMBER) RETURN VARCHAR2
IS
   user_group_      period_allocation_tab.user_group%TYPE;
   alloc_vou_type_  period_allocation_tab.alloc_vou_type%TYPE;
   distr_type_      period_allocation_tab.distr_type%TYPE;
   from_date_       period_allocation_tab.from_date%TYPE;
   until_date_      period_allocation_tab.until_date%TYPE;
   creator_         period_allocation_tab.creator%TYPE;
BEGIN
   Get_Allocation_Info___(user_group_, alloc_vou_type_, distr_type_, creator_, from_date_, until_date_, company_, voucher_type_, accounting_year_, voucher_no_, row_no_);
   RETURN creator_;
END Get_Creator;  

@UncheckedAccess
FUNCTION Get_Creator_Desc (
   company_         IN VARCHAR2,
   accounting_year_ IN NUMBER,
   voucher_type_    IN VARCHAR2,
   voucher_no_      IN NUMBER,
   row_no_          IN NUMBER) RETURN VARCHAR2
IS
   user_group_      period_allocation_tab.user_group%TYPE;
   alloc_vou_type_  period_allocation_tab.alloc_vou_type%TYPE;
   distr_type_      period_allocation_tab.distr_type%TYPE;
   from_date_       period_allocation_tab.from_date%TYPE;
   until_date_      period_allocation_tab.until_date%TYPE;
   creator_         period_allocation_tab.creator%TYPE;
BEGIN
   Get_Allocation_Info___(user_group_, alloc_vou_type_, distr_type_, creator_, from_date_, until_date_, company_, voucher_type_, accounting_year_, voucher_no_, row_no_);
   RETURN Period_Allocation_Rule_API.Get_Creator_Desc (NVL(creator_, 'ManualVoucher'));
END Get_Creator_Desc;

FUNCTION Get_Alloc_From_Date(
   company_         IN VARCHAR2,
   voucher_type_    IN VARCHAR2,
   voucher_no_      IN NUMBER,
   row_no_          IN NUMBER,
   accounting_year_ IN NUMBER) RETURN DATE
IS
   user_group_      period_allocation_tab.user_group%TYPE;
   alloc_vou_type_  period_allocation_tab.alloc_vou_type%TYPE;
   distr_type_      period_allocation_tab.distr_type%TYPE;
   from_date_       period_allocation_tab.from_date%TYPE;
   until_date_      period_allocation_tab.until_date%TYPE;
   creator_         period_allocation_tab.creator%TYPE;
BEGIN
   Get_Allocation_Info___(user_group_, alloc_vou_type_, distr_type_, creator_, from_date_, until_date_, company_, voucher_type_, accounting_year_, voucher_no_, row_no_);
   RETURN from_date_;      
END Get_Alloc_From_Date;

FUNCTION Get_Alloc_Until_Date(
   company_         IN VARCHAR2,
   voucher_type_    IN VARCHAR2,
   voucher_no_      IN NUMBER,
   row_no_          IN NUMBER,
   accounting_year_ IN NUMBER) RETURN DATE
IS
   user_group_      period_allocation_tab.user_group%TYPE;
   alloc_vou_type_  period_allocation_tab.alloc_vou_type%TYPE;
   distr_type_      period_allocation_tab.distr_type%TYPE;
   from_date_       period_allocation_tab.from_date%TYPE;
   until_date_      period_allocation_tab.until_date%TYPE;
   creator_         period_allocation_tab.creator%TYPE;
BEGIN
   Get_Allocation_Info___(user_group_, alloc_vou_type_, distr_type_, creator_, from_date_, until_date_, company_, voucher_type_, accounting_year_, voucher_no_, row_no_);
   RETURN until_date_;      
END Get_Alloc_Until_Date;

@UncheckedAccess
FUNCTION Get_Alloc_Voucher_Type(
   company_         IN VARCHAR2,
   voucher_type_    IN VARCHAR2,
   accounting_year_ IN NUMBER,
   voucher_no_      IN NUMBER,
   row_no_          IN NUMBER) RETURN VARCHAR2
IS 
   until_year_     NUMBER;
   until_period_   NUMBER;
   until_date_     DATE;
   
   CURSOR get_from_date IS
      SELECT MAX(alloc_year), MAX(alloc_period)
      FROM   period_allocation_tab
      WHERE  company         = company_
      AND    voucher_type    = voucher_type_
      AND    accounting_year = accounting_year_
      AND    voucher_no      = voucher_no_
      AND    row_no          = row_no_;      
BEGIN
   OPEN get_from_date;
   FETCH get_from_date INTO until_year_, until_period_;
   IF (get_from_date%FOUND) THEN
      CLOSE get_from_date;
      until_date_ := Accounting_Period_API.Get_Date_Until(company_ , until_year_, until_period_);
      RETURN until_date_;
   ELSE
      CLOSE get_from_date;
      RETURN NULL;
   END IF;
END Get_Alloc_Voucher_Type;

PROCEDURE Remove_Period_Allocation (
   company_          IN VARCHAR2,
   voucher_type_     IN VARCHAR2,
   accounting_year_  IN NUMBER,
   voucher_no_       IN NUMBER)
IS
BEGIN
   IF (Any_Allocation(company_,
                      voucher_type_ ,
                      voucher_no_   ,
                      accounting_year_) = 'Y') THEN 
      Remove_Period_Allocation_(company_,
                                voucher_type_ ,
                                accounting_year_,
                                voucher_no_);
   END IF;                             
END Remove_Period_Allocation;

PROCEDURE Get_Allocation_Info(
   user_group_      OUT VARCHAR2,
   alloc_vou_type_  OUT VARCHAR2,   
   from_date_       OUT DATE,
   until_date_      OUT DATE,
   company_         IN  VARCHAR2,
   voucher_type_    IN  VARCHAR2,
   accounting_year_ IN  NUMBER,
   voucher_no_      IN  NUMBER,
   row_no_          IN  NUMBER)
IS
   distr_type_       VARCHAR2(20);
   creator_          VARCHAR2(20);
BEGIN
   Get_Allocation_Info___( user_group_,
                           alloc_vou_type_,
                           distr_type_,
                           creator_,
                           from_date_,
                           until_date_,
                           company_,
                           voucher_type_,
                           accounting_year_,
                           voucher_no_,
                           row_no_);
END Get_Allocation_Info;
