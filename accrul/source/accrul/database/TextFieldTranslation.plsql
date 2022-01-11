-----------------------------------------------------------------------------
--
--  Logical unit: TextFieldTranslation
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  960322  xxxx     Base Table to Logical Unit Generator 1.0A
--  970718  SLKO     Converted to Foundation 1.2.2d
--  980916  Ruwan    Removed the Get_Text overloaded function(Bug ID:4973)
--  980921           Created new view ( Bug ID 5304)
--  990415  JPS      Performed Template Changes. (Foundation 2.2.1)
--  000914  HiMu     Added General_SYS.Init_Method
--  001005  prtilk   BUG # 15677  Checked General_SYS.Init_Method
--  001130  ovjose   For new Create Company concept added new view text_field_translation_ect and
--                   text_field_translation_pct. Added procedure Export__, Import__ and Make_Company.
--  010427  LiSv     Removed procedure Insert_Default_Text.
--  010531  Bmekse   Removed methods used by the old way for transfer basic data from
--                   master to slave (nowdays is Replication used instead)
--  010816  OVJOSE   Added Create Company translation method Create_Company_Translations___
--  020102  THSRLK   IID 20001 Enhancement of Update Company. Changes inside make_company method
--                   Changed Import___, Export___ and Copy___ methods to use records
--  020218  Mnisse   IID21003, Changed Get_Text to get the translation from the new
--                   company tranlation database.
--  020306  Shsalk   Remove commented coding from the file.
--  020610  MACHLK   Bug# 30579 Fixed. Added Lov handling for Project.
--  020831  Jakalk   Bug# 31426 corrected.
--  020916  ovjose   Bug 32686 Corrected.
--  021230  dagalk   Salsa sp3 merge bugs.
--  091116  AjPelk   Removed unused - both server and client , variable user_text_type_value_
--  110418  Umdolk   EASTONE-15214, Corrected in Get_Text method.
--  121207  Maaylk   PEPA-183, Removed global variable
--  131104  Hiralk   PBFI-572, Removed obsolete lu NcfNorwegianTax.
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------

PROCEDURE Set_Lu_And_Module___ (
   company_   IN VARCHAR2,
   text_type_ IN VARCHAR2,
   module_    IN OUT VARCHAR2,
   lu_        IN OUT VARCHAR2 ) IS
   
   code_part_          VARCHAR2(2);        
   code_part_func_db_  VARCHAR2(6); 
BEGIN
   module_  := 'ACCRUL';
   lu_ := NULL;
   IF ((LENGTH(text_type_) = 5 ) AND (SUBSTR(text_type_, 1, 4) = 'CODE')) THEN
      code_part_      := SUBSTR(text_type_, 5, 1);
      code_part_func_db_ := Accounting_Code_Parts_API.Get_Code_Part_Function_Db(company_, code_part_ );
      IF (code_part_func_db_ IS NOT NULL) THEN
         IF (code_part_func_db_ = 'PRACC') THEN
            $IF Component_Genled_SYS.INSTALLED $THEN
               lu_ := 'AccountingProject';
               module_  := 'GENLED';
            $ELSE
               lu_ := NULL;
            $END
         ELSIF (code_part_func_db_ = 'FAACC') THEN
            lu_ := 'FaObject';
            module_  := 'FIXASS';
         END IF;
      END IF;
   END IF;
   IF (lu_ IS NULL) THEN
      IF text_type_ = 'ACCOUNTGROUP' THEN
         lu_ := 'AccountGroup';
      ELSIF text_type_ = 'ACCOUNTTYPE' THEN
         lu_ := 'AccountType';
      ELSIF text_type_ = 'CODEA' THEN
         lu_ := 'Account';
      ELSIF text_type_ = 'CODEB' THEN
         lu_ := 'CodeB';
      ELSIF text_type_ = 'CODEC' THEN
         lu_ := 'CodeC';
      ELSIF text_type_ = 'CODED' THEN                    
         lu_ := 'CodeD';
      ELSIF text_type_ = 'CODEE' THEN
         lu_ := 'CodeE';
      ELSIF text_type_ = 'CODEF' THEN
         lu_ := 'CodeF';
      ELSIF text_type_ = 'CODEG' THEN
         lu_ := 'CodeG';
      ELSIF text_type_ = 'CODEH' THEN
         lu_ := 'CodeH';
      ELSIF text_type_ = 'CODEI' THEN
         lu_ := 'CodeI';
      ELSIF text_type_ = 'CODEJ' THEN
         lu_ := 'CodeJ';
      ELSIF text_type_ = 'PROJECT' THEN
         lu_ := 'AccountingProject';
      ELSIF text_type_ = 'DEFINECODE' THEN
         lu_ := 'AccountingCodeParts';
      ELSIF text_type_ = 'PAYMENTTERM' THEN
         lu_ := 'PaymentTerm';
      ELSIF text_type_ = 'VOUCHERTYPE' THEN
         lu_ := 'VoucherType';
      ELSIF text_type_ = 'REMINDERLEVEL' THEN
         module_ := 'PAYLED';
         lu_ := 'ReminderLevel';
      ELSE
         module_ := NULL;
         lu_ := NULL;
      END IF;   
   END IF;
END Set_Lu_And_Module___;


-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------

-------------------- LU SPECIFIC PROTECTED METHODS --------------------------

FUNCTION Translate_Iid_ (
   lu_name_     IN VARCHAR2,
   client_list_ IN VARCHAR2 ) RETURN VARCHAR2
IS
   text_        VARCHAR2(500);
   text_a_       Accounting_Code_Part_Value_Pub.code_part_value%TYPE;
   text_b_       Accounting_Code_Part_Value_Pub.code_part_value%TYPE;
   text_c_       Accounting_Code_Part_Value_Pub.code_part_value%TYPE;
   text_d_       Accounting_Code_Part_Value_Pub.code_part_value%TYPE;
   text_e_       Accounting_Code_Part_Value_Pub.code_part_value%TYPE;
   text_f_       Accounting_Code_Part_Value_Pub.code_part_value%TYPE;
   text_g_       Accounting_Code_Part_Value_Pub.code_part_value%TYPE;
   text_h_       Accounting_Code_Part_Value_Pub.code_part_value%TYPE;
   text_i_       Accounting_Code_Part_Value_Pub.code_part_value%TYPE;
   text_j_       Accounting_Code_Part_Value_Pub.code_part_value%TYPE;
   company_     Accounting_Code_Part_Value_Pub.code_part_value%TYPE;
   userid_      fnd_user.identity%TYPE := Fnd_Session_API.Get_Fnd_User;
BEGIN
   company_ := User_Profile_SYS.Get_Default('COMPANY', userid_);
   text_a_ := Get_Text (company_, 'DEFINECODE', 'A' );
   text_b_ := Get_Text (company_, 'DEFINECODE', 'B' );
   text_c_ := Get_Text (company_, 'DEFINECODE', 'C' );
   text_d_ := Get_Text (company_, 'DEFINECODE', 'D' );
   text_e_ := Get_Text (company_, 'DEFINECODE', 'E' );
   text_f_ := Get_Text (company_, 'DEFINECODE', 'F' );
   text_g_ := Get_Text (company_, 'DEFINECODE', 'G' );
   text_h_ := Get_Text (company_, 'DEFINECODE', 'H' );
   text_i_ := Get_Text (company_, 'DEFINECODE', 'I' );
   text_j_ := Get_Text (company_, 'DEFINECODE', 'J' );
   text_ := text_a_||'^'||text_b_||'^'||text_c_||'^'||text_d_||'^'||text_e_||'^'||text_f_||'^'||text_e_||'^'||text_f_||'^'||text_g_||'^'||text_h_||'^'||text_i_||'^'||text_j_||'^';
   RETURN(nvl(text_, client_list_));
END Translate_Iid_;


-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

@UncheckedAccess
@SecurityCheck Company.UserAuthorized(company_)
FUNCTION Get_Text (
   company_         IN VARCHAR2,
   text_type_       IN VARCHAR2,
   text_type_value_ IN VARCHAR2,
   lang_code_       IN VARCHAR2 DEFAULT NULL ) RETURN VARCHAR2
IS
   module_  VARCHAR2(6);
   lu_      VARCHAR2(30);
BEGIN
   Set_Lu_And_Module___( company_, text_type_, module_, lu_ );

   RETURN Enterp_Comp_Connect_V170_API.Get_Company_Translation( company_,
                                                                  module_,
                                                                  lu_,
                                                                  text_type_value_,
                                                                  lang_code_,
                                                                  'NO' );
END Get_Text;

        

@SecurityCheck Company.UserAuthorized(company_)
PROCEDURE Insert_Text (
   company_         IN VARCHAR2,
   text_type_       IN VARCHAR2,
   text_type_value_ IN VARCHAR2,
   lang_code_       IN VARCHAR2,
   text_            IN VARCHAR2,
   default_text_    IN VARCHAR2 )
IS
   module_  VARCHAR2(6);
   lu_      VARCHAR2(30);
BEGIN
   Set_Lu_And_Module___(company_,  text_type_, module_, lu_ );

   Enterp_Comp_Connect_V170_API.Insert_Company_Translation( company_,
                                                            module_,
                                                            lu_,
                                                            text_type_value_,
                                                            lang_code_,
                                                            text_ );
END Insert_Text;


@SecurityCheck Company.UserAuthorized(company_)
PROCEDURE Update_Text (
   company_         IN VARCHAR2,
   text_type_       IN VARCHAR2,
   text_type_value_ IN VARCHAR2,
   lang_code_       IN VARCHAR2,
   text_            IN VARCHAR2 )
IS
   module_  VARCHAR2(6);
   lu_      VARCHAR2(30);
BEGIN
   Set_Lu_And_Module___(company_,  text_type_, module_, lu_ );
      
   Enterp_Comp_Connect_V170_API.Insert_Company_Translation( company_,
                                                            module_,
                                                            lu_,
                                                            text_type_value_,
                                                            NULL,
                                                            text_);
END Update_Text;


PROCEDURE Remove_Text (
   company_          IN VARCHAR2,
   text_type_        IN VARCHAR2,
   text_type_value_  IN VARCHAR2 )
IS
   module_  VARCHAR2(6);
   lu_      VARCHAR2(30);
BEGIN

   Set_Lu_And_Module___(company_, text_type_, module_, lu_ );

   Enterp_Comp_Connect_V170_API.Remove_Company_Attribute_Key( company_,
                                                              module_,
                                                              lu_,
                                                              text_type_value_ );

END Remove_Text;


PROCEDURE Check_Default (
   company_         IN     VARCHAR2,
   text_type_       IN     VARCHAR2,
   text_type_value_ IN OUT VARCHAR2,
   nrow_            IN OUT NUMBER )
IS
BEGIN
   NULL;
END Check_Default;


