-----------------------------------------------------------------------------
--
--  Logical unit: CurrencyCode
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  960319  PEJON    Created
--  960828  Narni    Modify
--                   .. Currency Code and Description should come from Iso_Currency table
--                   .. No need to save currency code description.
--                   .. Delete restriction/not allowed to delete for currency code if
--                      still have child value (currency rate)
--  961016  JOBJ     Modified according to the report Generator
--  970114  YoHe     Added function Get_Currency_Rounding, Get_No_Of_Decimals_In_Rate
--  970718  SLKO     Converted to Foundation1 1.2.2d
--  971230  SLKO     Converted to Foundation1 2.0.0
--  980430  PRASI    Create Common Library
--  980914  ToKu     Bug # 4973 fixed. Overloaded procedures.
--  990317  Bren     Bug #: 5779. Added a protected & implementation procedure/function
--                   no_of_decimals_in_rate to handle overloaded calls.
--  990417  JPS      Performed Template Changes.(Foundation 2.2.1)
--  991130  Dhar     Daaed Function Get_Parallel_Acc_Currency
--  000912  HiMu     Added General_SYS.Init_Method
--  001005  prtilk   BUG # 15677  Checked General_SYS.Init_Method
--  001013  SAABLK   Call # 50248 Added function Can_Make_Emu_Currency
--  001130  OVJOSE   For new Create Company concept added new view currency_code_ect and currency_code_pct.
--                   Added procedures Copy___, Import___, Export___ and Make_Company.
--  010531  Bmekse   Removed methods used by the old way for transfer basic data from
--                   master to slave (nowdays is Replication used instead)
--  010709  LaLi     Added Create Company translation method Create_Company_Translations___
--  010822  JeGu     Bug #23726 Added procedure Get_Currency_Code_Attributes
--  020102  THSRLK   IID 20001 Enhancement of Update Company. Changes inside make_company method
--                   Changed Import___, Export___ and Copy___ methods to use records
--  020320  Mnisse   Copy__ changed FOUND -> NOTFOUND
--  021002  Nimalk   Removed usage of the view Company_Finance_Auth in CURRENCY_CODE view
--                   and replaced by view Company_Finance_Auth1 using EXISTS caluse instead of joins
--  021224  ISJALK   SP3 merge, Bug #33392.
--
--  040617  sachlk   FIPR338A2: Unicode Changes.
--  040714  AsHelk   Performance Improvement, Reduction of Calls to Basic_Data_Translation_API.
--  070816  Kagalk   LCS Merge 66542, Applied LU Micro Cache
--  090717  ErFelk   Bug 83174, Replaced constant NOCURR with NO_ISO_CURR in Check_Currency_Code.
--  100225  Clstlk   Bug 88845, Modified the code in Copy___() method to copy other currency codes after an error.  
--  100611  Anwese   Bug 89968, Modified the modify__ method, added a info message.
--  100623  Swralk   DF-39, Added value 3 to DB_VALUES to enable 3 decimals for currency amount. 
--  101205  Krpelk   EAPM-8875, Removed the value 3 from DB_VALUES.
--  110128  Thpelk   Bug 95032, Added new method Get_Currency_Codes().
--  120806  Maaylk   Bug 101320, Used the micro cache where it wasn't used
--  130611  Maaylk   Bug 110501, modified Get_Valid_Emu() to not to update micro_cache when currency_code is null.
--  131030  Umdolk   PBFI-1883, Refactoring
--  140708  DIFELK   PRFI-1030, Possibility to add inverted currencies to Parallel currency
--  141121  TAORSE   Added Enumerate_Db
--  160602  CHWTLK   Bug 129417, Modified Check_Common___.
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------

db_value_                  CONSTANT VARCHAR2(6) := '0^2^';

-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------

PROCEDURE Get_Currency_Code_Attribute___ (
   description_       OUT VARCHAR2,
   conv_factor_       OUT NUMBER,
   currency_rounding_ OUT NUMBER,
   company_           IN  VARCHAR2,
   currency_code_     IN  VARCHAR2 )
IS
BEGIN
   description_ := Iso_Currency_API.Get_Description(currency_code_);
   
   Update_Cache___(company_, currency_code_);
   conv_factor_ := micro_cache_value_.conv_factor;
   currency_rounding_ := micro_cache_value_.currency_rounding;
   
   IF (micro_cache_value_.conv_factor IS NULL) THEN
      Error_SYS.Appl_General(lu_name_,'NOCURR: The currency :P1 does not exist',currency_code_);
   END IF;
END Get_Currency_Code_Attribute___;


PROCEDURE Get_Currency_Code_Attribute___ (
   conv_factor_       OUT NUMBER,
   currency_rounding_ OUT NUMBER,
   company_           IN  VARCHAR2,
   currency_code_     IN  VARCHAR2 )
IS
BEGIN
   Update_Cache___(company_, currency_code_);
   conv_factor_ := micro_cache_value_.conv_factor;
   currency_rounding_ := micro_cache_value_.currency_rounding;  
   
   IF (micro_cache_value_.conv_factor IS NULL) THEN
      Error_SYS.Appl_General(lu_name_,'NOCURR: The currency :P1 does not exist',currency_code_);
   END IF;
END Get_Currency_Code_Attribute___;


FUNCTION Get_No_Of_Decimals_In_Rate___ (
   company_       IN VARCHAR2,
   currency_code_ IN VARCHAR2 ) RETURN NUMBER
IS
BEGIN
   Update_Cache___(company_, currency_code_);  
   RETURN micro_cache_value_.decimals_in_rate;
END Get_No_Of_Decimals_In_Rate___;

@Override
PROCEDURE Prepare_Insert___ (
   attr_ IN OUT VARCHAR2 )
IS
BEGIN
   super(attr_);
   Client_SYS.Add_To_Attr('EMU_CURRENCY','FALSE',attr_);
   Client_SYS.Add_To_Attr('INVERTED','FALSE',attr_);
END Prepare_Insert___;


@Override
PROCEDURE Update___ (
   objid_      IN     VARCHAR2,
   oldrec_     IN     CURRENCY_CODE_TAB%ROWTYPE,
   newrec_     IN OUT CURRENCY_CODE_TAB%ROWTYPE,
   attr_       IN OUT VARCHAR2,
   objversion_ IN OUT VARCHAR2,
   by_keys_    IN     BOOLEAN DEFAULT FALSE )
IS
BEGIN
   super(objid_, oldrec_, newrec_, attr_, objversion_, by_keys_);
   IF (newrec_.decimals_in_rate < oldrec_.decimals_in_rate) THEN
      Client_sys.Add_Info(lu_name_, 'CURRATEDECRSD: No of Decimals in Rate'|| 
         ' is decreased. Please update the Currency Rate info accordingly.');
   END IF;
EXCEPTION
   WHEN dup_val_on_index THEN
      Error_SYS.Record_Exist(lu_name_);
END Update___;

@Override
PROCEDURE Check_Common___ (
   oldrec_ IN     currency_code_tab%ROWTYPE,
   newrec_ IN OUT currency_code_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
   company_rec_        Company_Finance_API.Public_Rec;
BEGIN   
   super(oldrec_, newrec_, indrec_, attr_);
   IF (newrec_.conv_factor <= 0) THEN
      Error_SYS.Record_General(lu_name_, 'WRONGFACTOR: Conversion Factor should be greater than Zero.');
   END IF;
   company_rec_ := Company_Finance_API.Get(newrec_.company);
   IF (newrec_.inverted = 'TRUE') THEN
      --Accounting currency, Parallel currency and EUR can be set to Inverted currency - APP9 RTM change
      IF (newrec_.currency_code <> 'EUR') AND 
         (newrec_.currency_code <> company_rec_.currency_code AND newrec_.currency_code <> NVL(company_rec_.parallel_acc_currency, '-999')) THEN
         Error_SYS.Record_General(lu_name_, 'CHECKINVERT: Currency Code :P1 cannot be inverted', newrec_.currency_code);
      END IF;
   END IF;
   IF (newrec_.inverted = 'FALSE') THEN
      IF (newrec_.currency_code = 'EUR')  THEN
         Error_SYS.Record_General(lu_name_, 'CHECKINVERTFALSE: Currency Code :P1 must be inverted', newrec_.currency_code);
      END IF;
   END IF;
   IF (newrec_.currency_rounding NOT IN (0,2,3)) THEN
      Error_SYS.Record_General(lu_name_,'ROUNDAMT: No of decimals in amount should be 0, 2 or 3');
   END IF;
END Check_Common___;


@Override
PROCEDURE Check_Delete___ (
   remrec_ IN CURRENCY_CODE_TAB%ROWTYPE )
IS
BEGIN
   super(remrec_);
   -- Added to check that the rate does not exist in any currency code per company before it does deletion.
   IF (Currency_Rate_API.Check_If_Curr_Rate_Exists(remrec_.company,remrec_.currency_code) = 'TRUE') THEN
      Error_SYS.Record_General(lu_name_,'NODELETE: Remove is not allowed because the currency rate for currency code :P1 still exists.',remrec_.currency_code);
   END IF;
END Check_Delete___;


@Override
PROCEDURE Check_Insert___ (
   newrec_ IN OUT currency_code_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
   exist_              VARCHAR2(10);   
BEGIN
   attr_ := Client_SYS.Remove_Attr('DESCRIPTION', attr_); 
   super(newrec_, indrec_, attr_);
   Check_Currency_Code(newrec_.currency_code, exist_);
END Check_Insert___;


@Override
PROCEDURE Check_Update___ (
   oldrec_ IN     currency_code_tab%ROWTYPE,
   newrec_ IN OUT currency_code_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS  
   parallel_acc_curr_code_  currency_code_tab.currency_code%TYPE;
   found_                   VARCHAR2(5);
   para_curr_round_changed_ VARCHAR2(5);
BEGIN
   IF (Client_SYS.Item_Exist('DESCRIPTION', attr_)) THEN
      Error_SYS.Item_Update(lu_name_, 'DESCRIPTION');
   END IF;    
   
   super(oldrec_, newrec_, indrec_, attr_);
   
   IF (oldrec_.currency_rounding != newrec_.currency_rounding) THEN
      parallel_acc_curr_code_ := Get_Parallel_Acc_Currency(newrec_.company);
      IF (parallel_acc_curr_code_ = newrec_.currency_code) THEN
         para_curr_round_changed_ := 'TRUE';
      ELSE
         para_curr_round_changed_ := 'FALSE';   
      END IF;   
      Voucher_Util_Pub_API.Check_Curr_Info_For_Company(found_, newrec_.company, newrec_.currency_code, para_curr_round_changed_);
      IF (found_ = 'TRUE') THEN
         Error_SYS.Record_General(lu_name_,'EXISTINHOLDTABLE: There are voucher rows in the hold table that have used this currency code (:P1). ' ||
            'Please update them to the GL and then change the currency rounding.', newrec_.currency_code);
      END IF;
   END IF;
END Check_Update___;

-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------

PROCEDURE Get_Currency_Code_Attribute__ (
   description_       OUT VARCHAR2,
   conv_factor_       OUT NUMBER,
   currency_rounding_ OUT NUMBER,
   company_           IN  VARCHAR2,
   currency_code_     IN  VARCHAR2 )
IS
BEGIN
   Get_Currency_Code_Attribute___ (description_,
                                   conv_factor_,
                                   currency_rounding_,
                                   company_,
                                   currency_code_  );
END Get_Currency_Code_Attribute__;


-------------------- LU SPECIFIC PROTECTED METHODS --------------------------

PROCEDURE Get_No_Of_Decimals_In_Rate_ (
   decimals_in_rate_ OUT NUMBER,
   company_          IN  VARCHAR2,
   currency_code_    IN  VARCHAR2 )
IS
   decimals_rate_  NUMBER;
BEGIN
   decimals_rate_ := Get_No_Of_Decimals_In_Rate___(company_, currency_code_);
   IF (decimals_rate_ IS NULL) THEN
      Error_SYS.Appl_General(lu_name_,'NOCURR: The currency :P1 does not exist', currency_code_);
   END IF;
   decimals_in_rate_ := decimals_rate_;
END Get_No_Of_Decimals_In_Rate_;


@UncheckedAccess
FUNCTION No_Of_Decimals_In_Rate_ (
   company_       IN VARCHAR2,
   currency_code_ IN VARCHAR2 ) RETURN NUMBER
IS
   decimals_in_rate_ NUMBER;
BEGIN
   decimals_in_rate_ := Get_No_Of_Decimals_In_Rate___(company_, currency_code_);
   RETURN decimals_in_rate_;
END No_Of_Decimals_In_Rate_;


-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

@UncheckedAccess
FUNCTION Get_Currency_Code (
   company_ IN VARCHAR2 ) RETURN VARCHAR2
IS
   curr_code_ VARCHAR2(3);
BEGIN
   curr_code_ := Company_Finance_API.Get_Currency_Code(company_);
   RETURN curr_code_;
END Get_Currency_Code;

@UncheckedAccess
FUNCTION Get_Description (
   company_ IN VARCHAR2,
   currency_code_ IN VARCHAR2 ) RETURN VARCHAR2
IS
   temp_ VARCHAR2(50);
   CURSOR get_description IS
      SELECT Iso_Currency_API.Get_Description(currency_code)
      FROM  currency_code_tab
      WHERE company = company_
      AND   currency_code = currency_code_;
BEGIN   
   OPEN  get_description;
   FETCH get_description INTO temp_;
   CLOSE get_description;
   RETURN temp_;   
END Get_Description;

   
PROCEDURE Check_Currency_Code (
   currency_code_ IN VARCHAR2,
   exist_         OUT VARCHAR2 )
IS
   currency_code_missing   EXCEPTION;
   CURSOR Check_code IS
      SELECT currency_code
      FROM   iso_currency
      WHERE  currency_code  = currency_code_;
BEGIN
   OPEN  Check_code;
   FETCH Check_code INTO exist_;
   IF (Check_code%NOTFOUND) THEN
      CLOSE Check_code;
      RAISE Currency_code_missing;
   END IF;
   CLOSE Check_code;
EXCEPTION
   WHEN Currency_code_missing THEN
      Error_SYS.Appl_General(lu_name_,'NO_ISO_CURR: The currency code :P1 is no ISO-currency',currency_code_);
END Check_Currency_Code;


PROCEDURE Get_Currency_Code_Attribute (
   description_         OUT VARCHAR2,
   conv_factor_         OUT NUMBER,
   currency_rounding_   OUT NUMBER,
   company_             IN  VARCHAR2,
   currency_code_       IN  VARCHAR2 )
IS
BEGIN
   Get_Currency_Code_Attribute___(description_,
                                  conv_factor_,
                                  currency_rounding_,
                                  company_,
                                  currency_code_);
END Get_Currency_Code_Attribute;


@UncheckedAccess
PROCEDURE Get_Currency_Code_Attribute (
   conv_factor_         OUT NUMBER,
   currency_rounding_   OUT NUMBER,
   company_             IN  VARCHAR2,
   currency_code_       IN  VARCHAR2 )
IS
BEGIN
   Get_Currency_Code_Attribute___(conv_factor_,
                                  currency_rounding_,
                                  company_,
                                  currency_code_);
END Get_Currency_Code_Attribute;


@UncheckedAccess
PROCEDURE Get_No_Of_Decimals_In_Rate (
   decimals_in_rate_    OUT NUMBER,
   company_             IN  VARCHAR2,
   currency_code_       IN  VARCHAR2 )
IS
BEGIN
   Get_No_Of_Decimals_In_Rate_(decimals_in_rate_, company_, currency_code_);
END Get_No_Of_Decimals_In_Rate;


@UncheckedAccess
FUNCTION Get_No_Of_Decimals_In_Rate (
   company_       IN VARCHAR2,
   currency_code_ IN VARCHAR2 ) RETURN NUMBER
IS
   decimals_in_rate_        NUMBER;
BEGIN
   decimals_in_rate_ := Get_No_Of_Decimals_In_Rate___(company_, currency_code_);
   RETURN decimals_in_rate_;
END Get_No_Of_Decimals_In_Rate;


PROCEDURE Get_Control_Type_Value_Desc (
   description_   OUT VARCHAR2,
   company_       IN VARCHAR2,
   currency_code_ IN VARCHAR2 )
IS
BEGIN
   description_ := Iso_Currency_API.Get_Description(currency_code_);
END Get_Control_Type_Value_Desc;         


@UncheckedAccess
FUNCTION Get_Conversion_Factor (
   company_       IN VARCHAR2,
   currency_code_ IN VARCHAR2 ) RETURN NUMBER
IS
BEGIN
   Update_Cache___(company_, currency_code_);
   RETURN micro_cache_value_.conv_factor;
END Get_Conversion_Factor;               


@UncheckedAccess
FUNCTION Get_Emu (
   company_       IN VARCHAR2,
   currency_code_ IN VARCHAR2 ) RETURN VARCHAR2
IS
   is_emu_           VARCHAR2(6);
BEGIN
   is_emu_ := Get_Valid_Emu(company_, currency_code_, SYSDATE);
   RETURN is_emu_;
END Get_Emu;


@UncheckedAccess
FUNCTION Get_Valid_Emu (
   company_       IN VARCHAR2,
   currency_code_ IN VARCHAR2,
   valid_date_    IN DATE ) RETURN VARCHAR2
IS
   is_emu_           VARCHAR2(6);
   temp_             Public_Rec;
BEGIN
   IF (currency_code_ IS NULL) THEN
      RETURN 'FALSE';
   END IF;
   temp_ := Get(company_, currency_code_);
   IF (temp_.emu_currency_from_date <= valid_date_) THEN
      is_emu_ := 'TRUE';
   ELSIF (temp_.emu_currency_from_date IS NULL) OR (temp_.emu_currency_from_date > valid_date_) THEN
      is_emu_ := 'FALSE';
   END IF;
   RETURN is_emu_;
END Get_Valid_Emu;




@UncheckedAccess
FUNCTION Get_Parallel_Acc_Currency (
   company_ IN VARCHAR2 ) RETURN VARCHAR2
IS
   acc_currency_   VARCHAR2(3);
BEGIN
   acc_currency_ := Company_Finance_API.Get_Parallel_Acc_Currency(company_);
   RETURN acc_currency_;
END Get_Parallel_Acc_Currency;


FUNCTION Can_Make_Emu_Currency (
   company_       IN VARCHAR2,
   currency_code_ IN VARCHAR2,
   valid_from_    IN DATE ) RETURN VARCHAR2
IS
  CURSOR get_other_date(curr_type_ IN VARCHAR2) IS
     SELECT valid_from
     FROM   currency_rate_tab
     WHERE  company       = company_
     AND    currency_code = currency_code_
     AND    currency_type = curr_type_;
  other_date_     DATE;
BEGIN
   OPEN  get_other_date(Currency_Type_API.Get_Default_Euro_Type__(company_));
   FETCH get_other_date INTO other_date_;
   IF (get_other_date%NOTFOUND) THEN
      CLOSE get_other_date;
      RETURN 'TRUE';
   ELSIF valid_from_ >= other_date_ THEN
      CLOSE get_other_date;
      RETURN 'TRUE';
   ELSE
      CLOSE get_other_date;
      RETURN 'FALSE';
   END IF;
END Can_Make_Emu_Currency;

   
@UncheckedAccess
PROCEDURE Enumerate (
   client_values_ OUT VARCHAR2 )
IS
BEGIN
   client_values_ := Domain_SYS.Enumerate_(db_value_);
END Enumerate;

@UncheckedAccess
PROCEDURE Enumerate_Db (
   db_values_ OUT VARCHAR2 )
IS
BEGIN
   db_values_ := Domain_SYS.Enumerate_(db_value_);
END Enumerate_Db;


PROCEDURE Get_Currency_Code_Attributes (
   conv_factor_         OUT NUMBER,
   currency_rounding_   OUT NUMBER,
   decimals_in_rate_    OUT NUMBER,
   company_             IN  VARCHAR2,
   currency_code_       IN  VARCHAR2 )
IS
BEGIN
   Update_Cache___(company_, currency_code_);
   conv_factor_ := micro_cache_value_.conv_factor;
   currency_rounding_ := micro_cache_value_.currency_rounding;
   decimals_in_rate_ := micro_cache_value_.decimals_in_rate;
END Get_Currency_Code_Attributes;


@UncheckedAccess
FUNCTION Get_Currency_Codes (
   company_          IN VARCHAR2 ) RETURN VARCHAR2
IS
   currency_codes_      VARCHAR2(32000) := '';

   CURSOR get_curr_codes IS
      SELECT currency_code, conv_factor
      FROM Currency_Code_Tab
      WHERE company =  company_
      AND conv_factor != 1;
BEGIN
   FOR rec_ IN get_curr_codes LOOP
      currency_codes_ := currency_codes_ || rec_.currency_code || CHR(30) || rec_.conv_factor || CHR(30);
   END LOOP;
   RETURN currency_codes_;
END Get_Currency_Codes;

PROCEDURE Copy_Curr_Bal_Currency(
   crecomp_rec_ IN Enterp_Comp_Connect_V170_API.Crecomp_Lu_Public_Rec)
IS
   curr_code_attr_      VARCHAR2(2000);
   
   CURSOR get_curr_code IS
      SELECT currency_code 
      FROM currency_code_tab 
      WHERE company = crecomp_rec_.old_company;
BEGIN
   Client_SYS.Add_To_Attr('COMPANY', crecomp_rec_.company, curr_code_attr_);
   Client_SYS.Add_To_Attr('CODE_PART', crecomp_rec_.curr_bal_code_part, curr_code_attr_);
   Client_SYS.Add_To_Attr('VALID_FROM', crecomp_rec_.valid_from, curr_code_attr_);
   Client_SYS.Add_To_Attr('VALID_UNTIL', TO_DATE('31/12/2049','DD/MM/YYYY'), curr_code_attr_);
   
   FOR rec_ IN get_curr_code LOOP      
      IF (Client_SYS.Item_Exist('CODE_PART_VALUE', curr_code_attr_)) THEN
         Client_SYS.Set_Item_Value('CODE_PART_VALUE', rec_.currency_code, curr_code_attr_);
         Client_SYS.Set_Item_Value('DESCRIPTION', Iso_Currency_API.Get_Description(rec_.currency_code), curr_code_attr_);
      ELSE
         Client_SYS.Add_To_Attr('CODE_PART_VALUE', rec_.currency_code, curr_code_attr_);
         Client_SYS.Add_To_Attr('DESCRIPTION', Iso_Currency_API.Get_Description(rec_.currency_code), curr_code_attr_);
      END IF;  
      
      Accounting_Code_Part_Value_API.New_Code_Part_Value(curr_code_attr_);
   END LOOP;
END Copy_Curr_Bal_Currency;

