-----------------------------------------------------------------------------
--
--  Logical unit: AllLedger
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  110930  Ersruk   Created.
--  130716  Shedlk   Bug 111322, Corrected in Import___ Export___ and Copy___. Prevented IL records from being imported/exported/copied
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------

PROCEDURE Import___ (
   crecomp_rec_ IN Enterp_Comp_Connect_V170_API.Crecomp_Lu_Public_Rec)
IS
   newrec_        ALL_LEDGER_TAB%ROWTYPE;
   empty_rec_     ALL_LEDGER_TAB%ROWTYPE;
   msg_           VARCHAR2(2000);
   i_             NUMBER := 0;
   run_crecomp_   BOOLEAN := FALSE;
                       
   CURSOR get_data IS
      SELECT C1
      FROM   Create_Company_Template_Pub src
      WHERE  component   = 'ACCRUL'
      AND    lu          = lu_name_
      AND    template_id = crecomp_rec_.template_id
      AND    version     = crecomp_rec_.version
      AND    C1 IN ('*', '00')
      AND    NOT EXISTS (SELECT 1 
                         FROM ALL_LEDGER_TAB dest
                         WHERE dest.company = crecomp_rec_.company
                         AND dest.ledger_id = src.C1);
BEGIN
   run_crecomp_ := Check_If_Do_Create_Company___(crecomp_rec_);
   
   IF (run_crecomp_) THEN
      FOR rec_ IN get_data LOOP
         i_ := i_ + 1;
         @ApproveTransactionStatement(2014-01-01,generated)
         SAVEPOINT make_company_insert;
         BEGIN
            newrec_ := empty_rec_;

            newrec_.company                 := crecomp_rec_.company;
            newrec_.ledger_id               := rec_.c1;

            Company_Finance_API.Exist(newrec_.company);

            Error_SYS.Check_Not_Null(lu_name_, 'COMPANY', newrec_.company);
            Error_SYS.Check_Not_Null(lu_name_, 'LEDGER_ID', newrec_.ledger_id);

            New___(newrec_);
            EXCEPTION
               WHEN OTHERS THEN
                  msg_ := SQLERRM;
                  @ApproveTransactionStatement(2014-01-01,generated)
                  ROLLBACK TO make_company_insert;
                  Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'ALL_LEDGER_API', 'Error', msg_);
         END;
      END LOOP;
      IF ( i_ = 0 ) THEN
         msg_ := language_sys.translate_constant(lu_name_, 'NODATAFOUND: No Data Found');
         Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'ALL_LEDGER_API', 'CreatedSuccessfully', msg_);
      ELSE
         IF msg_ IS NULL THEN
            Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'ALL_LEDGER_API', 'CreatedSuccessfully');
         ELSE
            Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'ALL_LEDGER_API', 'CreatedWithErrors');
         END IF;
      END IF;
   END IF;
   -- this statement is to add to the log that the Create company process for LUs is finished if
   -- run_crecomp_ are FALSE
   IF ( NOT run_crecomp_ ) THEN
      Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'ALL_LEDGER_API', 'CreatedSuccessfully');
   END IF;
END Import___;

PROCEDURE Export___ (
   crecomp_rec_ IN Enterp_Comp_Connect_V170_API.Crecomp_Lu_Public_Rec)
IS
   pub_rec_       Enterp_Comp_Connect_V170_API.Tem_Public_Rec;
   i_             NUMBER := 1;
   
   CURSOR get_data IS
      SELECT *
      FROM   ALL_LEDGER_TAB
      WHERE  company = crecomp_rec_.company
      AND    ledger_id IN ('*', '00');

BEGIN
   FOR pctrec_ IN get_data LOOP
      pub_rec_.template_id := crecomp_rec_.template_id;
      pub_rec_.component := 'ACCRUL';
      pub_rec_.version  := crecomp_rec_.version;
      pub_rec_.lu := lu_name_;
      pub_rec_.item_id := i_;
      pub_rec_.c1 := pctrec_.ledger_id;

      Enterp_Comp_Connect_V170_API.Tem_Insert_Detail_Data(pub_rec_);
      i_ := i_ + 1;
   END LOOP;
END Export___;

PROCEDURE Copy___ (
   crecomp_rec_ IN Enterp_Comp_Connect_V170_API.Crecomp_Lu_Public_Rec )
IS
   newrec_        ALL_LEDGER_TAB%ROWTYPE;
   empty_rec_     ALL_LEDGER_TAB%ROWTYPE;
   msg_           VARCHAR2(2000);
   i_             NUMBER := 0;
   run_crecomp_   BOOLEAN := FALSE;
   
   CURSOR get_data IS
      SELECT *
      FROM   ALL_LEDGER_TAB src
      WHERE  company = crecomp_rec_.old_company
      AND    src.ledger_id IN ('*', '00')
      AND    NOT EXISTS (SELECT 1
                         FROM ALL_LEDGER_TAB dest
                         WHERE dest.company = crecomp_rec_.company
                         AND   dest.ledger_id = src.ledger_id);
BEGIN
   run_crecomp_ := Check_If_Do_Create_Company___(crecomp_rec_);
   IF (run_crecomp_) THEN
      FOR rec_ IN get_data LOOP
         i_ := i_ + 1;
         @ApproveTransactionStatement(2014-01-01,generated)
         SAVEPOINT make_company_insert;
         BEGIN
            newrec_ := empty_rec_;
            newrec_.company                       := crecomp_rec_.company;
            newrec_.ledger_id                     := rec_.ledger_id;           
            New___(newrec_);
         EXCEPTION
            WHEN OTHERS THEN
               msg_ := SQLERRM;
               @ApproveTransactionStatement(2014-01-01,generated)
               ROLLBACK TO make_company_insert;
               Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'ALL_LEDGER_API', 'Error', msg_);
         END;
      END LOOP;
      IF ( i_ = 0 ) THEN
         msg_ := language_sys.translate_constant(lu_name_, 'NODATAFOUND: No Data Found');
         Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'ALL_LEDGER_API', 'CreatedSuccessfully', msg_);
      ELSE
         IF msg_ IS NULL THEN
            Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'ALL_LEDGER_API', 'CreatedSuccessfully');
         ELSE
            Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'ALL_LEDGER_API', 'CreatedWithErrors');
         END IF;
      END IF;
   END IF;
   -- this statement is to add to the log that the Create company process for LUs is finished if
   -- run_crecomp_ are FALSE
   IF ( NOT run_crecomp_ ) THEN
      Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'ALL_LEDGER_API', 'CreatedSuccessfully');
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      msg_ := SQLERRM;
      Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'ALL_LEDGER_API', 'Error', msg_);
      Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'ALL_LEDGER_API', 'CreatedWithErrors');
   END Copy___;
   
-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------

-------------------- LU SPECIFIC PROTECTED METHODS --------------------------

-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

PROCEDURE Insert_Ledger (
   company_     IN VARCHAR2,
   ledger_id_   IN VARCHAR2,
   description_ IN VARCHAR2 )
IS
   newrec_        all_ledger_tab%ROWTYPE; 
BEGIN
   newrec_.company     := company_;
   newrec_.ledger_id   := ledger_id_;
   newrec_.description := description_;
   
   New___(newrec_);
END Insert_Ledger;


PROCEDURE Update_Ledger_Description (
   company_     IN VARCHAR2,
   ledger_id_   IN VARCHAR2,
   description_ IN VARCHAR2 )
IS
   objid_         ALL_LEDGER.objid%TYPE;
   objversion_    ALL_LEDGER.objversion%TYPE;
   info_          VARCHAR2(32000);
   attr_          VARCHAR2(2000);
BEGIN
   Client_SYS.Clear_Attr(attr_);
   Client_SYS.Add_To_Attr('DESCRIPTION',  description_,  attr_);

   Get_Id_Version_By_Keys___ (objid_,
                              objversion_,
                              company_,
                              ledger_id_);
   Modify__ (  info_,
               objid_,
               objversion_,
               attr_,
               'DO' );
END Update_Ledger_Description;


PROCEDURE Delete_Ledger (
   company_    IN VARCHAR2,
   ledger_id_  IN VARCHAR2 )
IS
   objid_         ALL_LEDGER.objid%TYPE;
   objversion_    ALL_LEDGER.objversion%TYPE;
   info_          VARCHAR2(32000);
BEGIN
   Get_Id_Version_By_Keys___ (objid_,
                              objversion_,
                              company_,
                              ledger_id_);
   Remove__ (  info_,
               objid_,
               objversion_,
               'DO' );
END Delete_Ledger;


PROCEDURE Get_Control_Type_Value_Desc (
   description_   OUT VARCHAR2,
   company_       IN VARCHAR2,
   ledger_id_     IN VARCHAR2 )
IS
   CURSOR get_desc IS
      SELECT description
      FROM   ALL_LEDGER
      WHERE company     = company_
      AND   ledger_id   = ledger_id_;
BEGIN
   OPEN get_desc;
   FETCH get_desc INTO description_;
   CLOSE get_desc;
END Get_Control_Type_Value_Desc;


PROCEDURE Get_Internal_Ledger_List (
   ledger_list_   OUT VARCHAR2,
   company_       IN VARCHAR2)
IS
   CURSOR get_int_ledger IS
      SELECT ledger_id
      FROM   ALL_LEDGER_TAB
      WHERE company     = company_
      AND   ledger_id   NOT IN ('*','00');
BEGIN
   FOR rec IN get_int_ledger LOOP
      ledger_list_ := ledger_list_ || rec.ledger_id ||  chr(30);
   END LOOP;
END Get_Internal_Ledger_List;

@UncheckedAccess
FUNCTION Is_Allowed (
   company_    VARCHAR2,
   ledger_id_  VARCHAR2 ) RETURN VARCHAR2
IS   
   $IF Component_Intled_SYS.INSTALLED $THEN 
      CURSOR get_rec IS
         SELECT 1
          FROM INTERNAL_LEDGER_USER_TAB b
          WHERE company   = company_
          AND   ledger_id = ledger_id_
          AND   user_id   = Fnd_session_API.Get_Fnd_User;
   result_ NUMBER  := 0;
   $END   
BEGIN   
   $IF Component_Intled_SYS.INSTALLED $THEN 
      OPEN get_rec;
      FETCH get_rec INTO result_;
      IF (get_rec%FOUND) THEN
         CLOSE get_rec;
         RETURN 'TRUE';
      END IF;
   $END
   RETURN 'FALSE';
END Is_Allowed;   

FUNCTION Internal_Ledger_Used (
   company_ IN VARCHAR2) RETURN VARCHAR2
IS 
   dummy_   NUMBER; 
   
   CURSOR get_il IS
      SELECT 1 
      FROM   all_ledger_tab
      WHERE  company = company_
      AND    ledger_id NOT IN ('00','*');
BEGIN
   OPEN get_il;
   FETCH get_il INTO dummy_;
   IF (get_il%FOUND) THEN 
      CLOSE get_il;
      RETURN 'TRUE';
   ELSE
      CLOSE get_il;
      RETURN 'FALSE';
   END IF;
END Internal_Ledger_Used;


