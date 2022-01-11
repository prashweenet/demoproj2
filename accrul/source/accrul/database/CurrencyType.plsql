-----------------------------------------------------------------------------
--
--  Logical unit: CurrencyType
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  960319  PEJON    Created
--  961016  JOBJ     Modified according to the report Generator
--  970718  SLKO     Converted to Foundation1 1.2.2d
--  980106  SLKO     Converted to Foundation1 2.0.0
--  980220  PICZ     Changed lenght of type_default column: now 3 characters
--  980317  PICZ     Bug #1328
--  990417  JPS      Performed Template Changes. (Foundation 2.2.1)
--  000110  Uma      Bug Id #28427
--  000524  Uma      Fixed Bug Id #39254. Added VIEW3.
--  000912  HiMu     Added General_SYS.Init_Method
--  000920  Uma      Corrected Bug ID#48718.
--  001005  prtilk   BUG # 15677  Checked General_SYS.Init_Method
--  001130  OVJOSE   For new Create Company concept added new view currency_type_ect and currency_type_pct.
--                   Added procedures Copy___, Import___ and Export___.
--  001219  OVJOSE   For new Create Company concept added public procedure Make Company.
--  010531  Bmekse   Removed methods used by the old way for transfer basic data from
--                   master to slave (nowdays is Replication used instead)
--  010816  OVJOSE   Added Create Company translation method Create_Company_Translations___
--  010922  GAWILK   Bug # 24653 fixed. Checked for the default type.
--  020102  THSRLK   IID 20001 Enhancement of Update Company. Changes inside make_company method
--                   Changed Import___, Export___ and Copy___ methods to use records
--  021002  Nimalk   Removed usage of the view Company_Finance_Auth in CURRENCY_TYPE,CURRENCY_TYPE1 and CURRENCY_TYPE2  view
--                   and replaced by view Company_Finance_Auth1 using EXISTS caluse instead of joins
--  021022  OVJOSE   Glob01. Changed cursor that select from module_lu_translation to basic_data_translation
--  021226  Hecolk   SP3 Merge. Bug 33017 Merged.
--  031029  ShSalk   Modified procedure Check_If_Default_Rate.
--  040918  Nalslk   Modified method Get_Default_Type(),  Add method Get_Default_Euro_Type()
--  070719  Paralk   B146838 Call Enterp_Comp_Connect_V160_API.Get_Attribute_Translation() in VIEW 
--  071108  RUFELK   Bug 68433 - Added the Check_If_Curr_Type_Exist() and Validate_Currency_Type___() methods.
--  100618  Janslk   Added field RATE_TYPE_CATEGORY and made associated modifications. Changed Prepare_Insert___ 
--                   to default rate_type_category. ALso changed logic for giving error messages in Unpack_Check_Insert___. 
--  100624  Chselk   Added Get_Rate_Type_Category_Db. Modified Exist() to add Rate_Type_Category check.
--  100707  Janslk   Changed the Import___ method to include the rate_type_category column.
--  100803  Janslk   Changed the base view to only show "Normal" Currency Types. Added view CURRENCY_TYPE3 to 
--                   display all currency types. Changed Check_Exist___ method to check only for "Normal" currency types.
--  101115  THTHLK   HIGHPK-2801, Modified PROCEDURE Prepare_Insert___
--  101228  Janslk   Merged model changes.
--  110914  Shdilk   EASTTWO-11277, Modified PROCEDURE Check_If_Curr_Type_Exist
--  121123  Janblk   DANU-122, Parallel currency implementation.
--  130531  NILILK   DANU-263, Added New Method Exist_Rate_Type_Category. 
--  130613  NILILK   DANU-1312, Parallel currency implementation, Added some validation to Unpack_Check_Insert.  
--  131030  UMDOLK   PBFI-1879, Refactoring
--  151118  Bhhilk   STRFI-39, Modified CurrTypeDef enumeration to FinanceYesNo.
--  151203  chiblk   STRFI-682,removing sub methods and rewriting them as implementation methods
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------

PROCEDURE Curr_Type_Exist_Parallel (
   company_       IN VARCHAR2,
   currency_type_ IN VARCHAR2 )
IS
   rec_     currency_type_tab%ROWTYPE;
BEGIN   
   rec_ := Get_Object_By_Keys___(company_, currency_type_);   
   -- if company is null then object does not exist
   IF (rec_.company IS NOT NULL) THEN
      Curr_Type_Exist_Parallel___(rec_);
   END IF;
END Curr_Type_Exist_Parallel;

PROCEDURE Curr_Type_Exist_Tax (
   company_       IN VARCHAR2,
   currency_type_ IN VARCHAR2 )
IS
   dummy_ NUMBER;
   CURSOR check_type_tax IS
      SELECT 1
      FROM   CURRENCY_TYPE_TAB
      WHERE  company = company_
      AND    rate_type_category = 'TAX_REPORTING'
      AND    currency_type = currency_type_;
BEGIN
   OPEN check_type_tax;
   FETCH check_type_tax INTO dummy_;
   IF (check_type_tax%FOUND) THEN
      CLOSE check_type_tax;
   ELSE
      CLOSE check_type_tax;   
      Error_SYS.Appl_General(lu_name_,'RATETYPECATGTAX: The selected Currency Rate Type should have the Rate Type Category defined as Tax Reporting.');
   END IF;
END Curr_Type_Exist_Tax;

-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------

PROCEDURE Curr_Type_Exist_Parallel___ (
   rec_     IN currency_type_tab%ROWTYPE )
IS
BEGIN
   IF (rec_.rate_type_category = 'PARALLEL_CURRENCY') THEN
      Error_SYS.Appl_General(lu_name_,'INVALIDRATETYPECAT: The selected Currency Rate Type should have the Rate Type Category defined as Normal.');
   END IF;
END Curr_Type_Exist_Parallel___;

FUNCTION Get_Next_From_Attr___ (
   attr_             IN VARCHAR2,
   ptr_              IN OUT NUMBER,
   value_            IN OUT VARCHAR2,
   record_separator_ IN VARCHAR2 ) RETURN BOOLEAN
IS
   from_  NUMBER;
   to_    NUMBER;
   index_ NUMBER;
BEGIN
   from_ := nvl(ptr_, 1);
   to_   := instr(attr_, record_separator_, from_);
   IF (to_ > 0) THEN
      index_ := instr(attr_, record_separator_, from_);
      value_ := substr(attr_, from_, index_-from_);
      ptr_   := to_+1;
      RETURN(TRUE);
   ELSE
      RETURN(FALSE);
   END IF;
END Get_Next_From_Attr___;
   
PROCEDURE Internal_Insert_Proc___(
   errmsg_ OUT VARCHAR2,
   crecomp_rec_ IN ENTERP_COMP_CONNECT_V170_API.Crecomp_Lu_Public_Rec,
   rec_ IN currency_type_def_tab%ROWTYPE)
IS
   m_             CONSTANT VARCHAR2(10) := CURRENCY_TYPE_API.module_;
   l_             CONSTANT VARCHAR2(30) := CURRENCY_TYPE_API.lu_name_;
   desc_          currency_type_tab.description%TYPE;
   text_          VARCHAR2(2000);
   ptr_           NUMBER;
   value_         VARCHAR2(2000);
   language_code_ VARCHAR2(5);
BEGIN
   -- Check if currency exists and is active
   IF (rec_.ref_currency_code IS NOT NULL) THEN
      Iso_Currency_API.Exist(rec_.ref_currency_code);
   END IF;

   INSERT INTO currency_type_tab (
      company,
      currency_type,
      description,
      type_default,
      ref_currency_code,
      rate_type_category,
      rowversion)
   VALUES(
      crecomp_rec_.company,
      rec_.currency_type,
      NVL(rec_.description, rec_.currency_type), -- using NVL since description is not mandatory in currency_type_def_tab
      rec_.type_default,
      rec_.ref_currency_code,
      rec_.rate_type_category,
      SYSDATE);

   -- Insert company translation for all basic data translations
   Enterp_Comp_Connect_V170_API.Insert_Company_Prog_Trans(crecomp_rec_.company,
                                                          m_,
                                                          l_,
                                                          rec_.currency_type,
                                                          desc_);

   WHILE Get_Next_From_Attr___(crecomp_rec_.languages, ptr_, value_, '^') LOOP
      language_code_ := value_;
      text_ := Basic_Data_Translation_API.Get_Basic_Data_Translation(m_,
                                                                     l_,
                                                                     rec_.currency_type,
                                                                     language_code_);

      --Using private method since this LUs translations needs special handling.
      Company_Key_Lu_API.Insert_Translation__(crecomp_rec_.company,
                                              m_,
                                              l_,
                                              rec_.currency_type,
                                              language_code_,
                                              text_);
   END LOOP;
EXCEPTION
   WHEN OTHERS THEN
      errmsg_ := SQLERRM;
END Internal_Insert_Proc___;
   
PROCEDURE Curr_Type_Exist_Project___ (
   company_       IN VARCHAR2,
   currency_type_ IN VARCHAR2 )
IS
   rec_     currency_type_tab%ROWTYPE;
BEGIN
   rec_ := Get_Object_By_Keys___(company_, currency_type_);   
   -- if company is null then object does not exist
   IF (rec_.company IS NOT NULL) THEN
      Curr_Type_Exist_Project___(rec_);
   END IF;   
END Curr_Type_Exist_Project___;

PROCEDURE Curr_Type_Exist_Tax___ (
   rec_       IN currency_type_tab%ROWTYPE )
IS
BEGIN
   IF (rec_.rate_type_category = 'TAX_REPORTING') THEN
      Error_SYS.Appl_General(lu_name_,'INVALIDRATETYPECAT: The selected Currency Rate Type should have the Rate Type Category defined as Normal.');
   END IF;   
END Curr_Type_Exist_Tax___;

PROCEDURE Curr_Type_Exist_Project___ (
   rec_       IN currency_type_tab%ROWTYPE )
IS
BEGIN   
   IF (rec_.rate_type_category = 'PROJECT') THEN
      Error_SYS.Appl_General(lu_name_,'INVALIDRATETYPECAT: The selected Currency Rate Type should have the Rate Type Category defined as Normal.');
   END IF;
END Curr_Type_Exist_Project___;


FUNCTION Check_Def_Curr_Type_Exist___ (
    company_ IN VARCHAR2,
    ref_currency_code_ IN VARCHAR2 ) RETURN BOOLEAN
IS
    is_default_  VARCHAR2(5);

    CURSOR Get_Attributes IS
      SELECT   'TRUE'
      FROM     CURRENCY_TYPE_TAB
      WHERE    company = company_
      AND      type_default = 'Y'
      AND      ref_currency_code = ref_currency_code_;
BEGIN
   OPEN Get_Attributes;
   FETCH Get_Attributes INTO is_default_;
   IF (Get_Attributes%FOUND) THEN
      CLOSE Get_Attributes;
      RETURN(TRUE);
   END IF;
   CLOSE Get_Attributes;
   RETURN(FALSE);
END Check_Def_Curr_Type_Exist___;


PROCEDURE Import___ (
   crecomp_rec_ IN ENTERP_COMP_CONNECT_V170_API.Crecomp_Lu_Public_Rec )
IS
   --
   dummy_          VARCHAR2(1);
   msg_            VARCHAR2(2000);
   emu_curr_       VARCHAR2(5);
   i_              NUMBER := 0;
   update_by_key_  BOOLEAN;
   rate_type_attr_      VARCHAR2(100);
   company_finance_rec_ Company_Finance_API.Public_Rec;
   --
   CURSOR exist_company IS
     SELECT 'X'
     FROM   CURRENCY_TYPE_TAB
     WHERE  company = crecomp_rec_.company;
   --
   CURSOR get_data IS
      SELECT *
      FROM currency_type_def_tab src
      WHERE NOT EXISTS ( SELECT 1
                         FROM currency_type_tab dest
                         WHERE dest.company = crecomp_rec_.company
                         AND src.currency_type = dest.currency_type );

BEGIN
   company_finance_rec_ := Company_Finance_API.Get(crecomp_rec_.company);
   -- Almost obsolete by now...
   emu_curr_ := Currency_Code_API.Get_Emu(crecomp_rec_.company,company_finance_rec_.currency_code);
   --
   
   update_by_key_ := ENTERP_COMP_CONNECT_V170_API.Use_Keys(module_, lu_name_, crecomp_rec_);
   IF (update_by_key_) THEN
      FOR rec_ IN get_data LOOP
         -- Soon obsolete. Remove the IF-statements when possible.
         IF ((emu_curr_ = 'TRUE') OR (company_finance_rec_.currency_code = 'EUR')) AND (NVL(rec_.rate_type_category,' ') != 'PARALLEL_CURRENCY') THEN
            IF (rec_.ref_currency_code = 'EUR') THEN
               Internal_Insert_Proc___(msg_,crecomp_rec_,rec_);
            END IF;
         ELSIF (rec_.rate_type_category = 'PARALLEL_CURRENCY') THEN
            rec_.ref_currency_code := company_finance_rec_.parallel_acc_currency;
            IF (company_finance_rec_.parallel_acc_currency IS NOT NULL) THEN
               IF (company_finance_rec_.parallel_base = 'ACCOUNTING_CURRENCY') THEN  
                  IF company_finance_rec_.currency_code = 'EUR' THEN
                     Client_SYS.Add_To_Attr('PARALLEL_RATE_TYPE', '2', rate_type_attr_);
                  ELSE 
                     Client_SYS.Add_To_Attr('PARALLEL_RATE_TYPE', '1', rate_type_attr_);
                  END IF;   
                  Company_Finance_API.Update_Company_Finance(rate_type_attr_, crecomp_rec_.company);
               ELSIF (company_finance_rec_.parallel_base = 'TRANSACTION_CURRENCY') THEN  
                  Client_SYS.Add_To_Attr('PARALLEL_RATE_TYPE', rec_.currency_type, rate_type_attr_);
                  Internal_Insert_Proc___(msg_,crecomp_rec_,rec_);
                  -- Do not update company finance if row was not created
                  IF (msg_ IS NULL) THEN
                     Company_Finance_API.Update_Company_Finance(rate_type_attr_, crecomp_rec_.company);
                  END IF;
               END IF;
            END IF;
         ELSE
            rec_.ref_currency_code := NVL(rec_.ref_currency_code,company_finance_rec_.currency_code);
            Internal_Insert_Proc___(msg_,crecomp_rec_,rec_);
         END IF;
         IF (msg_ IS NOT NULL) THEN
            Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company,module_,'CURRENCY_TYPE_API','Error',msg_);
         END IF;
         i_ := get_data%ROWCOUNT;
      END LOOP;
   ELSE
      OPEN exist_company;
      FETCH exist_company INTO dummy_;
      IF exist_company%NOTFOUND THEN
         FOR rec_ IN get_data LOOP
            -- Soon obsolete. Remove the IF-statements when possible.
            IF ((emu_curr_ = 'TRUE') OR (company_finance_rec_.currency_code = 'EUR')) AND (NVL(rec_.rate_type_category,' ') != 'PARALLEL_CURRENCY') THEN
               IF (rec_.ref_currency_code = 'EUR') THEN
                  Internal_Insert_Proc___(msg_,crecomp_rec_,rec_);
               END IF;
            ELSIF (rec_.rate_type_category = 'PARALLEL_CURRENCY') THEN
               rec_.ref_currency_code := company_finance_rec_.parallel_acc_currency;
               IF (company_finance_rec_.parallel_acc_currency IS NOT NULL) THEN
                  IF (company_finance_rec_.parallel_base = 'ACCOUNTING_CURRENCY') THEN  
                     IF company_finance_rec_.currency_code = 'EUR' THEN
                        Client_SYS.Add_To_Attr('PARALLEL_RATE_TYPE', '2', rate_type_attr_);
                     ELSE 
                        Client_SYS.Add_To_Attr('PARALLEL_RATE_TYPE', '1', rate_type_attr_);
                     END IF;   
                     Company_Finance_API.Update_Company_Finance(rate_type_attr_, crecomp_rec_.company);
                  ELSIF (company_finance_rec_.parallel_base = 'TRANSACTION_CURRENCY') THEN  
                     Client_SYS.Add_To_Attr('PARALLEL_RATE_TYPE', rec_.currency_type, rate_type_attr_);
                     Internal_Insert_Proc___(msg_,crecomp_rec_,rec_);
                     -- Do not update company finance if row was not created
                     IF (msg_ IS NULL) THEN
                        Company_Finance_API.Update_Company_Finance(rate_type_attr_, crecomp_rec_.company);
                     END IF;
                  END IF;
               END IF;
            ELSE
               rec_.ref_currency_code := NVL(rec_.ref_currency_code,company_finance_rec_.currency_code);
               Internal_Insert_Proc___(msg_,crecomp_rec_,rec_);
            END IF;
            IF (msg_ IS NOT NULL) THEN
               Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company,module_,'CURRENCY_TYPE_API','Error',msg_);
            END IF;
            i_ := get_data%ROWCOUNT;
         END LOOP;
      END IF;
      CLOSE exist_company;
   END IF;
   IF (i_ = 0) THEN
      msg_ := Language_SYS.Translate_Constant(lu_name_, 'NODATAFOUND: No Data Found');
      Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company,module_,'CURRENCY_TYPE_API','CreatedSuccessfully',msg_);
   ELSE
      IF (msg_ IS NULL) THEN
         Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company,module_,'CURRENCY_TYPE_API','CreatedSuccessfully');
      ELSE
         Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company,module_,'CURRENCY_TYPE_API','CreatedWithErrors');
      END IF;
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      IF (exist_company%ISOPEN) THEN
         CLOSE exist_company;
      END IF;
      msg_ := SQLERRM;
      Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company,module_,'CURRENCY_TYPE_API','Error',msg_);
      Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company,module_,'CURRENCY_TYPE_API','CreatedWithErrors');
END Import___;


PROCEDURE Copy___ (
   crecomp_rec_   IN ENTERP_COMP_CONNECT_V170_API.Crecomp_Lu_Public_Rec )
IS
BEGIN
   Import___(crecomp_rec_);
END Copy___;


PROCEDURE Validate_Currency_Type___ (
   rec_       IN currency_type_tab%ROWTYPE)
IS
   accounting_currency_  VARCHAR2(3);
BEGIN
   accounting_currency_ := Company_Finance_API.Get_Currency_Code(rec_.company);
   IF (accounting_currency_ != rec_.ref_currency_code) THEN
      Error_SYS.Appl_General(lu_name_,'NOTVALIDCURRTYPE: The Currency Rate Type must have accounting currency as reference currency.');
   END IF;   
END Validate_Currency_Type___;

@Override
PROCEDURE Prepare_Insert___ (
   attr_ IN OUT VARCHAR2 )
IS
BEGIN
   super(attr_);
   Client_SYS.Add_To_Attr( 'TYPE_DEFAULT', Finance_Yes_No_API.Decode('N'), attr_ );
   Client_SYS.Add_To_Attr( 'RATE_TYPE_CATEGORY', Curr_Rate_Type_Category_API.Decode('NORMAL'), attr_ );
END Prepare_Insert___;


@Override
PROCEDURE Insert___ (
   objid_      OUT    VARCHAR2,
   objversion_ OUT    VARCHAR2,
   newrec_     IN OUT CURRENCY_TYPE_TAB%ROWTYPE,
   attr_       IN OUT VARCHAR2 )
IS
BEGIN
   IF (newrec_.type_default = 'Y') THEN
      UPDATE currency_type_tab
      SET    type_default = 'N'
      WHERE  company = newrec_.company
      AND    ref_currency_code = newrec_.ref_currency_code;
   END IF;
   super(objid_, objversion_, newrec_, attr_);
EXCEPTION
   WHEN dup_val_on_index THEN
      Error_SYS.Record_Exist(lu_name_);
END Insert___;


@Override
PROCEDURE Update___ (
   objid_      IN     VARCHAR2,
   oldrec_     IN     CURRENCY_TYPE_TAB%ROWTYPE,
   newrec_     IN OUT CURRENCY_TYPE_TAB%ROWTYPE,
   attr_       IN OUT VARCHAR2,
   objversion_ IN OUT VARCHAR2,
   by_keys_    IN     BOOLEAN DEFAULT FALSE )
IS
BEGIN
   IF (newrec_.type_default = 'Y') THEN
      UPDATE currency_type_tab
      SET    type_default = 'N'
      WHERE  company = newrec_.company
      AND    ref_currency_code = newrec_.ref_currency_code;
   END IF;
   super(objid_, oldrec_, newrec_, attr_, objversion_, by_keys_);
EXCEPTION
   WHEN dup_val_on_index THEN
      Error_SYS.Record_Exist(lu_name_);
END Update___;


@Override
PROCEDURE Check_Delete___ (
   remrec_ IN CURRENCY_TYPE_TAB%ROWTYPE )
IS
   exists_ VARCHAR2(10);
BEGIN
   Check_If_Rates_Exist(exists_, remrec_.company, remrec_.currency_type);
   --
   super(remrec_);
END Check_Delete___;


@Override
PROCEDURE Check_Insert___ (
   newrec_ IN OUT currency_type_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
   currency_type_value_ VARCHAR2(10);
   company_finance_rec_ Company_Finance_API.Public_Rec;
BEGIN
   super(newrec_, indrec_, attr_);
   
   IF (newrec_.type_default != 'Y' AND newrec_.rate_type_category = 'NORMAL') THEN
      IF NOT Check_Def_Curr_Type_Exist___(newrec_.company, newrec_.ref_currency_code) THEN
         newrec_.type_default := 'Y';
         Client_SYS.Add_To_Attr('TYPE_DEFAULT',Finance_Yes_No_API.Decode(newrec_.type_default),attr_);
      END IF;
   END IF;

   currency_type_value_ := newrec_.type_default;
   company_finance_rec_ := Company_Finance_API.Get(newrec_.company);
 
   IF (newrec_.rate_type_category = 'NORMAL') THEN
      IF (Currency_Code_API.Get_Emu(newrec_.company,company_finance_rec_.currency_code) = 'TRUE') AND (newrec_.ref_currency_code != 'EUR') THEN
         Error_SYS.Appl_General(lu_name_,'NODEFTYPE1: IF the Rate Type Category is Normal only EUR can be used as Reference Currency Code. IF the category is Project or Tax Reporting, any currency can be used as Reference Currency Code.');
      END IF;
   END IF;

   IF (newrec_.rate_type_category = 'NORMAL') THEN
      IF (newrec_.ref_currency_code != company_finance_rec_.currency_code) AND (newrec_.ref_currency_code != 'EUR') THEN
         IF (currency_type_value_ = 'Y' ) THEN
            IF (company_finance_rec_.currency_code = 'EUR') THEN --JOELSE
               Error_SYS.Appl_General(lu_name_,'NODEFTYPE1: IF the Rate Type Category is Normal only EUR can be used as Reference Currency Code. IF the category is Project or Tax Reporting, any currency can be used as Reference Currency Code.');
            ELSE
               Error_SYS.Appl_General(lu_name_,'NODEFTYPE3: IF the Rate Type Category is Normal only :P1 and EUR can be used as Reference Currency Code. IF the category is Project or Tax Reporting, any currency can be used as Reference Currency Code.', company_finance_rec_.currency_code);
            END IF;
         END IF;
      END IF;
   END IF;

   IF (newrec_.rate_type_category != 'NORMAL' AND newrec_.type_default = 'Y') THEN
      Error_SYS.Appl_General(lu_name_,'NODEFTYPE4: Only :P1 rate types can be default currency types', Curr_Rate_Type_Category_API.Decode('NORMAL'));
   END IF;

   IF (newrec_.rate_type_category = 'PARALLEL_CURRENCY' AND company_finance_rec_.parallel_base = 'TRANSACTION_CURRENCY') THEN
      IF (newrec_.ref_currency_code != company_finance_rec_.parallel_acc_currency) THEN
         Error_SYS.Appl_General(lu_name_,'NODEFTYPE5: Only Parallel Currency can be set as Reference Currency when rate type category is Parallel Currency');
      END IF;
   END IF;
   IF (newrec_.rate_type_category = 'PARALLEL_CURRENCY' AND company_finance_rec_.parallel_base = 'ACCOUNTING_CURRENCY') THEN
      IF (newrec_.ref_currency_code != company_finance_rec_.currency_code) THEN
         Error_SYS.Appl_General(lu_name_,'NODEFTYPE6: Only Accounting Currency can be set as Reference Currency when rate type category is Parallel Currency');
      END IF;
   END IF;
   IF (newrec_.rate_type_category = 'PARALLEL_CURRENCY' AND company_finance_rec_.parallel_base IS NULL) THEN
      Error_SYS.Appl_General(lu_name_,'NODEFTYPE7: The Parallel Currency rate type category can only be used if the company uses Parallel Currency functionality');  
   END IF;
END Check_Insert___;


@Override
PROCEDURE Check_Update___ (
   oldrec_ IN     currency_type_tab%ROWTYPE,
   newrec_ IN OUT currency_type_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
   is_default_          VARCHAR2(10);
   currency_type_value_ VARCHAR2(10);
   base_currency_code_  VARCHAR2(3);
BEGIN
   super(oldrec_, newrec_, indrec_, attr_);
      
   currency_type_value_ := newrec_.type_default;

   IF (currency_type_value_ != 'Y') THEN
      Check_default_Type(is_default_, newrec_.company, newrec_.currency_type);
   END IF;

   base_currency_code_ := Company_Finance_API.Get_Currency_Code(newrec_.company);

   IF (newrec_.ref_currency_code != base_currency_code_) AND (newrec_.ref_currency_code != 'EUR') THEN
      IF (currency_type_value_ = 'Y' ) THEN
         Error_SYS.Appl_General(lu_name_,'NODEFTYPE2: Ref Currency Code :P1 cannot be a default currency type', newrec_.ref_currency_code);
      END IF;
   END IF;

   IF (newrec_.rate_type_category != 'NORMAL' AND newrec_.type_default = 'Y') THEN
      Error_SYS.Appl_General(lu_name_,'NODEFTYPE4: Only :P1 rate types can be default currency types', Curr_Rate_Type_Category_API.Decode('NORMAL'));
   END IF;
END Check_Update___;

@Override
PROCEDURE Raise_Record_Not_Exist___ (
   company_ IN VARCHAR2,
   currency_type_ IN VARCHAR2 )
IS
BEGIN
   Error_SYS.Record_General(lu_name_, 'CURRTYPENOTEXIST: The currency type :P1 does not exist in company :P2.', currency_type_, company_);
   super(company_, currency_type_);
END Raise_Record_Not_Exist___;


-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------

@UncheckedAccess
FUNCTION Get_Default_Euro_Type__ (
   company_ IN VARCHAR2 ) RETURN VARCHAR2
IS
   currency_type_    VARCHAR2(10);
   CURSOR Get_Attributes IS
      SELECT   currency_type
      FROM     CURRENCY_TYPE_TAB
      WHERE    company = company_
      AND      ref_currency_code = 'EUR'
      AND      type_default = 'Y';
BEGIN
   OPEN Get_Attributes;
   FETCH Get_Attributes INTO currency_type_  ;
   IF (Get_Attributes%NOTFOUND) THEN
       CLOSE Get_Attributes;
       RETURN (NULL);
   ELSE
      CLOSE Get_Attributes;
      RETURN (currency_type_  );
   END IF;
END Get_Default_Euro_Type__;

   
PROCEDURE Create_Company_Reg__ (
   execution_order_   IN OUT NOCOPY NUMBER,
   create_and_export_ IN     BOOLEAN  DEFAULT TRUE,
   active_            IN     BOOLEAN  DEFAULT TRUE,
   account_related_   IN     BOOLEAN  DEFAULT FALSE,
   standard_table_    IN     BOOLEAN  DEFAULT TRUE )
IS
   
BEGIN
   Enterp_Comp_Connect_V170_API.Reg_Add_Component_Detail(
      module_, lu_name_, 'CURRENCY_TYPE_API',
      CASE create_and_export_ WHEN TRUE THEN 'TRUE' ELSE 'FALSE' END,
      execution_order_,
      CASE active_ WHEN TRUE THEN 'TRUE' ELSE 'FALSE' END,
      CASE account_related_ WHEN TRUE THEN 'TRUE' ELSE 'FALSE' END,
      NULL, NULL);
   Enterp_Comp_Connect_V170_API.Reg_Add_Table(
      module_,'CURRENCY_TYPE_TAB',
      CASE standard_table_ WHEN TRUE THEN 'TRUE' ELSE 'FALSE' END);  
   Enterp_Comp_Connect_V170_API.Reg_Add_Table_Detail(
      module_,'CURRENCY_TYPE_TAB','COMPANY','<COMPANY>');
   execution_order_ := execution_order_+1;
END Create_Company_Reg__;

-------------------- LU SPECIFIC PROTECTED METHODS --------------------------

-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

@Override
@UncheckedAccess
PROCEDURE Exist (
   company_ IN VARCHAR2,
   currency_type_ IN VARCHAR2 )
IS
   rec_     currency_type_tab%ROWTYPE;
BEGIN  
   super(company_, currency_type_);      
   rec_ := Get_Object_By_Keys___(company_, currency_type_); 
   Curr_Type_Exist_Project___(rec_);
   Curr_Type_Exist_Tax___(rec_);
   
   IF (rec_.rate_type_category NOT IN ('PROJECT','PARALLEL_CURRENCY','TAX_REPORTING')) THEN   
      Validate_Currency_Type___(rec_);      
   END IF;
END Exist;


PROCEDURE Exist_Rate_Type_Category (
   company_            IN VARCHAR2,
   currency_type_      IN VARCHAR2,
   rate_type_category_ IN VARCHAR2)
IS
   rec_     currency_type_tab%ROWTYPE;
BEGIN   
   rec_ := Get_Object_By_Keys___(company_, currency_type_); 
   
   IF (rec_.rate_type_category = rate_type_category_) THEN
      NULL;
   ELSE
      Error_SYS.Record_General(lu_name_, 'CURRTYPEWITHCATGNOTEXIST: The currency type :P1 with rate type category :P2 does not exist in company :P3.', currency_type_, Curr_Rate_Type_Category_API.Decode(rate_type_category_), company_); 
   END IF;
   
   IF (rec_.rate_type_category NOT IN ('PROJECT', 'PARALLEL_CURRENCY', 'TAX_REPORTING'))THEN
      Validate_Currency_Type___(rec_);      
   END IF;   
END Exist_Rate_Type_Category;

PROCEDURE Check_If_Rates_Exist (
   exists_        OUT VARCHAR2,
   company_       IN  VARCHAR2,
   currency_type_ IN  VARCHAR2 )
IS      
   CURSOR check_rates IS
      SELECT 'TRUE'
      FROM   currency_rate_tab
      WHERE  company = company_
      AND    currency_type = currency_type_;   
BEGIN    
   OPEN check_rates;
   FETCH check_rates INTO exists_;
   IF (check_rates%NOTFOUND) THEN
      exists_ := 'FALSE';
      CLOSE check_rates;
   ELSE
      CLOSE check_rates;
      Error_SYS.Appl_General(lu_name_,'RATESEXIST: There are rates entered for this currency type it cannot be deleted ');
   END IF;   
END Check_If_Rates_Exist;


PROCEDURE Check_If_Default_Rate (
   exists_        OUT VARCHAR2,
   company_       IN  VARCHAR2,
   currency_type_ IN  VARCHAR2 )
IS
   rec_     currency_type_tab%ROWTYPE;
BEGIN
   rec_ := Get_Object_By_Keys___(company_, currency_type_);   
   IF (rec_.type_default = 'Y') THEN      
      exists_ := 'TRUE';
   ELSE
      exists_ := 'FALSE';
   END IF;   
END Check_If_Default_Rate;


PROCEDURE Get_Currency_Type_Attribute (
   description_   OUT VARCHAR2,
   type_default_  OUT VARCHAR2,
   company_       IN  VARCHAR2,
   currency_type_ IN  VARCHAR2 )
IS
   rec_     currency_type_tab%ROWTYPE;
BEGIN   
   rec_ := Get_Object_By_Keys___(company_, currency_type_);
   -- if company is null then the object does not exist
   IF (rec_.company IS NULL) THEN
      Raise_Record_Not_Exist___(company_, currency_type_);      
   END IF;
   description_ := rec_.description;
   type_default_ := rec_.type_default;
END Get_Currency_Type_Attribute;


PROCEDURE Check_Default_Type (
   is_default_       OUT VARCHAR2,
   company_          IN  VARCHAR2,
   currency_type_ IN VARCHAR2 )
IS
   ref_curr_code_   CURRENCY_TYPE_TAB.ref_currency_code%TYPE;
   is_emu_          VARCHAR2(5) := 'FALSE';

   CURSOR Get_Attributes IS
      SELECT   'TRUE'
      FROM     CURRENCY_TYPE_TAB
      WHERE    company = company_
      AND      type_default = 'Y'
      AND      ref_currency_code = ref_curr_code_
      AND      currency_type != currency_type_;
BEGIN
   ref_curr_code_ := Company_Finance_API.Get_Currency_Code(company_);
   is_emu_ := Currency_Code_API.Get_Valid_Emu(company_ ,ref_curr_code_, sysdate);

   OPEN Get_Attributes;
   FETCH Get_Attributes INTO is_default_;
   IF (Get_Attributes%NOTFOUND) THEN
      CLOSE Get_Attributes;
      IF (is_emu_ = 'TRUE') THEN
         ref_curr_code_ := 'EUR';
         OPEN Get_Attributes;
         FETCH Get_Attributes INTO is_default_;
         IF (Get_Attributes%NOTFOUND) THEN
            is_default_ := 'FALSE';
            CLOSE Get_Attributes;
            Error_SYS.Appl_General(lu_name_,'NODEFAULT: There must be a default type for this reference currency ');
         END IF;
         CLOSE Get_Attributes;
      ELSE
         Error_SYS.Appl_General(lu_name_,'NODEFAULT: There must be a default type for this reference currency ');
      END IF;
   ELSE
      CLOSE Get_Attributes;
   END IF;

   IF (is_emu_ = 'FALSE') THEN
      ref_curr_code_ := Currency_Type_API.Get_Ref_Currency_Code(company_,currency_type_);
      IF ref_curr_code_ = 'EUR' THEN
         OPEN Get_Attributes;
         FETCH Get_Attributes INTO is_default_;
         IF (Get_Attributes%NOTFOUND) THEN
            is_default_ := 'FALSE';
            CLOSE Get_Attributes;
            Error_SYS.Appl_General(lu_name_,'NODEFAULT: There must be a default type for this reference currency ');
         END IF;
         CLOSE Get_Attributes;
      END IF;
   END IF;
END Check_Default_Type;


PROCEDURE Check_One_Default_Type (
   is_default_    OUT VARCHAR2,
   company_       IN  VARCHAR2,
   currency_type_ IN  VARCHAR2 )
IS
   CURSOR Get_Attributes IS
      SELECT   'TRUE'
      FROM     CURRENCY_TYPE_TAB
      WHERE    company = company_
      AND      type_default = 'Y';
BEGIN
   OPEN Get_Attributes;
   FETCH Get_Attributes INTO is_default_;
   IF (Get_Attributes%NOTFOUND) THEN
      is_default_ := 'FALSE';
      CLOSE Get_Attributes;
   ELSE
      CLOSE Get_Attributes;
   END IF;
END Check_One_Default_Type;


@UncheckedAccess
FUNCTION Get_Default_Type (
   company_ IN VARCHAR2,
   related_to_ IN VARCHAR2 DEFAULT NULL ) RETURN VARCHAR2
IS
   currency_type_   CURRENCY_TYPE_TAB.currency_type%TYPE;
   ref_curr_code_   CURRENCY_TYPE_TAB.ref_currency_code%TYPE;
   is_emu_          VARCHAR2(5);
   CURSOR Get_Attributes IS
      SELECT   currency_type
      FROM     CURRENCY_TYPE_TAB
      WHERE    company = company_
      AND      ref_currency_code = ref_curr_code_
      AND      type_default = 'Y';
BEGIN
   currency_type_ := '';
   IF (related_to_ = 'CUSTOMER') THEN
      currency_type_ := Currency_Type_Basic_Data_Api.Get_Sell(company_);
   ELSIF (related_to_ = 'SUPPLIER') THEN   
      currency_type_ := Currency_Type_Basic_Data_Api.Get_Buy(company_);
   END IF;
   IF (currency_type_ IS NULL) THEN
      ref_curr_code_ := Company_Finance_API.Get_Currency_Code(company_);
      OPEN Get_Attributes;
      FETCH Get_Attributes INTO currency_type_;
      IF (Get_Attributes%NOTFOUND) THEN
         CLOSE Get_Attributes;
         is_emu_ := Currency_Code_API.Get_Emu(company_ ,ref_curr_code_);
         IF (is_emu_ = 'TRUE') THEN
            ref_curr_code_ := 'EUR';
            OPEN Get_Attributes;
            FETCH Get_Attributes INTO currency_type_;
            CLOSE Get_Attributes;
         END IF;
      ELSE
         CLOSE Get_Attributes;
      END IF;
      RETURN (currency_type_);
   ELSE
      RETURN currency_type_;
   END IF;
END Get_Default_Type;


PROCEDURE Make_Company (
   attr_       IN VARCHAR2 )
IS
   rec_        Enterp_Comp_Connect_V170_API.Crecomp_Lu_Public_Rec;
BEGIN
   rec_ := Enterp_Comp_Connect_V170_API.Get_Crecomp_Lu_Rec('ACCRUL', attr_);

   IF (rec_.make_company = 'EXPORT') THEN
      NULL;
   ELSIF (rec_.make_company = 'IMPORT') THEN
      IF (rec_.action = 'NEW') THEN
         Import___(rec_);
      ELSIF (rec_.action = 'DUPLICATE') THEN
         Copy___(rec_);
      END IF;
   END IF;
END Make_Company;


@UncheckedAccess
FUNCTION Get_Default_Euro_Type (
   company_ IN VARCHAR2 ) RETURN VARCHAR2
IS
BEGIN
   RETURN Get_Default_Euro_Type__(company_);
END Get_Default_Euro_Type;


PROCEDURE Check_If_Curr_Type_Exist (
   company_       IN VARCHAR2,
   currency_type_ IN VARCHAR2 )
IS
   rec_     currency_type_tab%ROWTYPE;
BEGIN   
   Exist(company_, currency_type_);
   rec_ := Get_Object_By_Keys___(company_, currency_type_);
   Curr_Type_Exist_Project___(rec_);
   Curr_Type_Exist_Tax___(rec_);
   IF (Company_Finance_API.Get_Parallel_Base_Db(company_) = 'TRANSACTION_CURRENCY') THEN      
      Curr_Type_Exist_Parallel___(rec_);
   END IF;   
END Check_If_Curr_Type_Exist;


PROCEDURE Check_Exist_All_Types (
   company_       IN  VARCHAR2,
   currency_type_ IN  VARCHAR2 )
IS    
   exists_  BOOLEAN := FALSE;
BEGIN
   exists_ := Check_Exist___(company_, currency_type_);
   IF (NOT exists_) THEN
      Raise_Record_Not_Exist___(company_, currency_type_);      
   END IF;
END Check_Exist_All_Types;


@UncheckedAccess
FUNCTION Is_Correct_Curr_Type(
   company_                IN VARCHAR2,
   parallel_curr_base_db_  IN VARCHAR2,
   currency_type_          IN VARCHAR2,
   accounting_currency_    IN VARCHAR2) RETURN NUMBER
IS
   rec_     currency_type_tab%ROWTYPE;
   temp_    NUMBER := 0;
BEGIN
   rec_ := Get_Object_By_Keys___(company_, currency_type_);   
   IF (parallel_curr_base_db_ = 'TRANSACTION_CURRENCY') THEN
      IF (rec_.rate_type_category = 'PARALLEL_CURRENCY') THEN
         temp_ := 1;
      END IF;
   ELSIF (parallel_curr_base_db_ = 'ACCOUNTING_CURRENCY') THEN
      IF (rec_.ref_currency_code = accounting_currency_) THEN
         temp_ := 1;
      END IF;      
   END IF;
   RETURN temp_;
END Is_Correct_Curr_Type;



   

