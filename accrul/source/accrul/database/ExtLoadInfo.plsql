-----------------------------------------------------------------------------
--
--  Logical unit: ExtLoadInfo
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  970128  MaGu   Created
--  970411  MaGu   Changed proc. New_Load_Info.
--  970807  SLKO   Converted to Foundation 1.2.2d
--  990713  UMAB   Modified with respect to new template
--  001005  prtilk BUG # 15677  Checked General_SYS.Init_Method
--  010601  JeGu   Some code cleanup
--  020711  ASHELK Bug 30856, Added View EXT_LOAD_INFO2.
--  021002  Nimalk Removed usage of the view Company_Finance_Auth in EXT_LOAD_INFO,EXT_LOAD_INFO2 view
--                   and replaced by view Company_Finance_Auth1 using EXISTS caluse instead of joins
--  021011  PPerse Merged External Files
--  030107  Nimalk Removed usage of the view Company_Finance_Auth and replaced by view Company_Finance_Auth1 using EXISTS caluse instead of joins
--  040329  Gepelk 2004 SP1 Merge.
--  040830  Jeguse The parts regarding this file for bug 44702 are merged.
--  090304  reanpl Bug 82373, SKwP Ceritificate - Final Closing of Period (SKwP-2)
--  101011  AjPelk Bug 92374 Corrected
--  110528  SJayLK EASTONE-19635, Merged Bug 96366 Corrected - load_id_ replaced with pack_load_id_
--  131108  PRatlk PBFI-2023, Refactored according to the new template
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------

-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------

-------------------- LU SPECIFIC PROTECTED METHODS --------------------------

-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

@UncheckedAccess
FUNCTION Get_Loadable_Load_Id (
   company_      IN VARCHAR2,
   load_file_id_ IN NUMBER ) RETURN VARCHAR2
IS
   temp_ EXT_LOAD_INFO_TAB.load_id%TYPE;
   CURSOR get_attr IS
      SELECT load_id
      FROM EXT_LOAD_INFO_TAB
      WHERE company        = company_
      AND   load_file_id   = load_file_id_
      AND   ext_load_state != '5';
BEGIN
   OPEN get_attr;
   FETCH get_attr INTO temp_;
   CLOSE get_attr;
   RETURN temp_;
END Get_Loadable_Load_Id;


PROCEDURE Update_Load_Info (
   company_ IN VARCHAR2,
   load_id_ IN VARCHAR2,
   load_info_attr_ IN VARCHAR2 )
IS
BEGIN
   NULL;
END Update_Load_Info;


PROCEDURE New_Load_Info (
   company_      IN VARCHAR2,
   load_id_      IN VARCHAR2,
   voucher_type_ IN VARCHAR2,
   load_date_    IN DATE,
   user_id_      IN VARCHAR2,
   load_type_    IN VARCHAR2 DEFAULT NULL,
   load_file_id_ IN NUMBER   DEFAULT NULL )
IS
BEGIN
   INSERT
      INTO ext_load_info_tab (
         company,
         load_id,
         voucher_type,
         load_date,
         userid,
         load_type,
         load_file_id,
         ext_load_state,
         rowversion )
      VALUES (
         company_,
         load_id_,
         voucher_type_,
         load_date_,
         user_id_,
         load_type_,
         load_file_id_,
         '1',
         sysdate );
END New_Load_Info;


PROCEDURE Get_Load_Load_Date (
   load_date_    OUT DATE,
   company_      IN  VARCHAR2,
   load_id_      IN  VARCHAR2 )
IS
   CURSOR getrec IS
      SELECT load_date
      FROM   ext_load_info_tab
      WHERE  company = company_
      AND    load_id = load_id_;
BEGIN

   OPEN getrec;
   FETCH getrec INTO load_date_;
   IF (getrec%NOTFOUND) THEN
      Error_SYS.Record_General( 'ExtLoadInfo', 'LOAD_INFO_NOT_EXIST: Record does not exist in load information for company :P1, load id :P2', company_, load_id_ );
   END IF;
   CLOSE getrec;
END Get_Load_Load_Date;


PROCEDURE Get_Load_Voucher_Type (
   voucher_type_ OUT VARCHAR2,
   company_      IN  VARCHAR2,
   load_id_      IN  VARCHAR2 )
IS
   CURSOR getrec IS
      SELECT voucher_type
      FROM   ext_load_info_tab
      WHERE  company = company_
      AND    load_id = load_id_;
BEGIN
   OPEN getrec;
   FETCH getrec INTO voucher_type_;
   IF (getrec%NOTFOUND) THEN
      Error_SYS.Record_General( 'ExtLoadInfo', 'LOAD_INFO_NOT_EXIST: Record does not exist in load information for company :P1, load id :P2', company_, load_id_ );
   END IF;
   CLOSE getrec;
END Get_Load_Voucher_Type;


@UncheckedAccess
FUNCTION Get_Load_Voucher_Type (
   company_      IN  VARCHAR2,
   load_id_      IN  VARCHAR2 ) RETURN VARCHAR2
IS
   voucher_type_ VARCHAR2(3);
   CURSOR gettype IS
      SELECT voucher_type
      FROM   ext_load_info_tab
      WHERE  company = company_
      AND    load_id = load_id_;
BEGIN
   OPEN gettype;
   FETCH gettype INTO voucher_type_;
   CLOSE gettype;
   RETURN voucher_type_;
END Get_Load_Voucher_Type;


PROCEDURE Get_Load_User (
   user_id_   OUT VARCHAR2,
   company_   IN  VARCHAR2,
   load_id_   IN  VARCHAR2 )
IS
   CURSOR getrec IS
      SELECT userid
      FROM   ext_load_info_tab
      WHERE  company = company_
      AND    load_id = load_id_;
BEGIN
   OPEN getrec;
   FETCH getrec INTO user_id_;
   IF (getrec%NOTFOUND) THEN
      Error_SYS.Record_General( 'ExtLoadInfo', 'LOAD_INFO_NOT_EXIST: Record does not exist in load information for company :P1, load id :P2', company_, load_id_ );
   END IF;
   CLOSE getrec;
END Get_Load_User;


PROCEDURE Complete_Remove (
   company_      IN VARCHAR2,
   pack_all_ids_ IN VARCHAR2 )
IS
   ptr_          NUMBER;
   name_         VARCHAR2(30);
   value_        VARCHAR2(100);
   load_id_      EXT_LOAD_INFO_TAB.load_id%TYPE;
   load_file_id_ EXT_LOAD_INFO_TAB.load_file_id%TYPE;
BEGIN
   WHILE (Client_SYS.Get_Next_From_Attr(pack_all_ids_, ptr_, name_, value_)) LOOP
      IF (name_ = 'LOAD_FILE_ID') THEN
         load_file_id_ := Client_SYS.Attr_Value_To_Number(value_);
         IF load_file_id_ IS NOT NULL THEN
            DELETE
              FROM Ext_File_Trans_Tab
             WHERE load_file_id = load_file_id_;
            
            DELETE
              FROM Ext_File_Load_Tab
             WHERE load_file_id = load_file_id_;
         END IF;
      ELSIF (name_ = 'LOAD_ID') THEN
         load_id_ := value_;
         IF load_id_ IS NOT NULL THEN
            DELETE
              FROM Ext_Transactions_Tab
             WHERE company = company_
               AND load_id = load_id_;
      
            DELETE 
              FROM Ext_Voucher_Tab
             WHERE company = company_
               AND load_id = load_id_;
      
            DELETE
              FROM Ext_Voucher_Row_Tab
             WHERE company = company_
               AND load_id = load_id_;
      
            DELETE
              FROM EXT_LOAD_INFO_TAB
             WHERE company = company_
               AND load_id = load_id_;
         END IF;
      END IF;
   END LOOP;
END Complete_Remove;


PROCEDURE Update_Ext_Load_State (
   company_        IN VARCHAR2,
   load_id_        IN VARCHAR2,
   ext_load_state_ IN VARCHAR2 ) 
IS
BEGIN
   UPDATE EXT_LOAD_INFO_TAB
      SET ext_load_state = ext_load_state_
   WHERE company = company_
   AND   load_id = load_id_;
END Update_Ext_Load_State;


@UncheckedAccess
FUNCTION Check_Non_Created_ExtVou_Exist (
   company_           IN VARCHAR2,
   start_date_        IN DATE,
   end_date_          IN DATE ) RETURN VARCHAR2
IS
   -- 1 - Load Date, 2 - Transaction Date 
   CURSOR check_ext_voucher IS
      SELECT 1 
      FROM   ext_load_info_tab el, ext_transactions_tab et, ext_parameters_tab ep
      WHERE  el.company          = ep.company
      AND    el.load_type        = ep.load_type
      AND    el.company          = et.company
      AND    el.load_id          = et.load_id
      AND    el.company          = company_
      AND    el.ext_load_state  != '5'  -- Created
      AND  ((ep.ext_voucher_date = '1' AND el.load_date BETWEEN start_date_ AND end_date_)
            OR
            (ep.ext_voucher_date = '2' AND et.transaction_date BETWEEN start_date_ AND end_date_));

   dummy_                 NUMBER;
BEGIN
   
   OPEN  check_ext_voucher;
   FETCH check_ext_voucher INTO dummy_;
   IF check_ext_voucher%FOUND THEN
      CLOSE check_ext_voucher;
      RETURN 'TRUE';
   END IF;
   CLOSE check_ext_voucher;

   RETURN 'FALSE';
END Check_Non_Created_ExtVou_Exist;


-- Exist
--   Checks if given pointer (e.g. primary key) to an instance of this
--   logical unit exists. If not an exception will be raised.
@UncheckedAccess
PROCEDURE Exist (
   exist_   OUT VARCHAR2,
   company_ IN  VARCHAR2,
   load_id_ IN  VARCHAR2 )
IS
BEGIN
   exist_ := 'TRUE';
   IF (NOT Check_Exist___(company_, load_id_)) THEN
      exist_ := 'FALSE';
   END IF;
END Exist;



@UncheckedAccess
FUNCTION Non_Created_Vou_Exist_Ledger (
   company_           IN VARCHAR2,
   start_date_        IN DATE,
   end_date_          IN DATE,
   ledger_id_         IN VARCHAR2 ) RETURN VARCHAR2
IS
   -- 1 - Load Date, 2 - Transaction Date 
   CURSOR check_ext_voucher IS
      SELECT 1 
      FROM   ext_load_info_tab el, ext_transactions_tab et, ext_parameters_tab ep
      WHERE  el.company          = ep.company
      AND    el.load_type        = ep.load_type
      AND    el.company          = et.company
      AND    el.load_id          = et.load_id
      AND    el.company          = company_
      AND    el.ext_load_state  != '5'  -- Created
      AND  ((ep.ext_voucher_date = '1' AND el.load_date BETWEEN start_date_ AND end_date_)
            OR
            (ep.ext_voucher_date = '2' AND et.transaction_date BETWEEN start_date_ AND end_date_))
      AND  el.voucher_type IN (SELECT v.voucher_type
                               FROM   voucher_type_tab v
                               WHERE  el.company     = v.company
                               AND    v.ledger_id    IN (ledger_id_, '*'));

   dummy_                 NUMBER;
BEGIN
   
   OPEN  check_ext_voucher;
   FETCH check_ext_voucher INTO dummy_;
   IF check_ext_voucher%FOUND THEN
      CLOSE check_ext_voucher;
      RETURN 'TRUE';
   END IF;
   CLOSE check_ext_voucher;

   RETURN 'FALSE';
END Non_Created_Vou_Exist_Ledger;