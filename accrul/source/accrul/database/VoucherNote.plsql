-----------------------------------------------------------------------------
--
--  Logical unit: VoucherNote
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  090109  Nirplk  Created to correct bug 77430
--  100423  SaFalk  Modified REF for voucher_no in VOUCHER_NOTE.
--  121207  Maaylk  PEPA-183, Removed global variables
--  131101  Umdolk  PBFI-2122, Refactoring
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------

PROCEDURE Update_Il_Notes___(
   company_         IN VARCHAR2,
   voucher_type_    IN VARCHAR2,
   accounting_year_ IN NUMBER,
   voucher_no_      IN NUMBER, 
   note_id_           IN NUMBER)
IS
BEGIN
   $IF Component_Intled_SYS.INSTALLED $THEN
      INTLED_VOU_NOTE_API.Update_Il_Notes(company_,
                                          voucher_type_,
                                          accounting_year_,
                                          voucher_no_,
                                          note_id_);
   $ELSE
      NULL;
   $END
END Update_Il_Notes___;


@Override
PROCEDURE Insert___ (
   objid_      OUT    VARCHAR2,
   objversion_ OUT    VARCHAR2,
   newrec_     IN OUT VOUCHER_NOTE_TAB%ROWTYPE,
   attr_       IN OUT VARCHAR2 )
IS
BEGIN
   super(objid_, objversion_, newrec_, attr_);
   Update_Il_Notes___ (newrec_.company,
					        newrec_.voucher_type,
				           newrec_.accounting_year,
				      	  newrec_.voucher_no,
					        newrec_.note_id);
EXCEPTION
   WHEN dup_val_on_index THEN
      Error_SYS.Record_Exist(lu_name_);
END Insert___;


-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------

-------------------- LU SPECIFIC PROTECTED METHODS --------------------------

-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

@UncheckedAccess
FUNCTION Check_Note_Exist (
   company_         IN VARCHAR2,
	accounting_year_ IN NUMBER,
   voucher_type_    IN VARCHAR2,
   voucher_no_      IN NUMBER ) RETURN VARCHAR2
IS
   CURSOR check_note IS
   SELECT 1
      FROM   VOUCHER_NOTE_TAB
      WHERE  company         = company_
      AND    accounting_year = accounting_year_
      AND     voucher_type     = voucher_type_    
      AND    voucher_no        = voucher_no_;
   temp_     NUMBER;

BEGIN
   OPEN  check_note;
   FETCH check_note INTO temp_;
   CLOSE check_note;
   IF (temp_ > 0) THEN
      RETURN 'TRUE';
   ELSE
      RETURN 'FALSE';
   END IF;
END Check_Note_Exist;

 


@UncheckedAccess
FUNCTION Get_Note_Id (
   key_attr_ IN VARCHAR2 ) RETURN NUMBER						
IS
   company_           VOUCHER_NOTE.company%TYPE;
   accounting_year_   VOUCHER_NOTE.accounting_year%TYPE;
   voucher_type_      VOUCHER_NOTE.voucher_type%TYPE;
   voucher_no_        VOUCHER_NOTE.voucher_no%TYPE;
   note_id_            NUMBER;
   CURSOR get_note IS
      SELECT note_id
      FROM   Voucher_Note_Tab
      WHERE  company            = company_
      AND    accounting_year  = accounting_year_
      AND    voucher_type      = voucher_type_
      AND    voucher_no         = voucher_no_;
BEGIN
   company_         := Client_SYS.Get_Item_Value('COMPANY', key_attr_);
   accounting_year_ := Client_SYS.Get_Item_Value_To_Number('ACCOUNTING_YEAR', key_attr_, lu_name_);
   voucher_type_    := Client_SYS.Get_Item_Value('VOUCHER_TYPE', key_attr_);
   voucher_no_      := Client_SYS.Get_Item_Value_To_Number('VOUCHER_NO', key_attr_, lu_name_);
   OPEN   get_note;
   FETCH  get_note INTO note_id_;
   CLOSE  get_note;
   RETURN note_id_;
END Get_Note_Id;




PROCEDURE Create_Note (
   note_id_   IN NUMBER,                     
   key_attr_  IN VARCHAR2 )
IS
	obj_id_       ROWID;
   obj_version_  VARCHAR2(2000);
   info_         VARCHAR2(2000);
   attr_         VARCHAR2(32000);
BEGIN
	attr_	:= key_attr_;
   Client_SYS.Add_To_Attr( 'NOTE_ID', note_id_, attr_ );
	
   New__ (info_,
          obj_id_,
          obj_version_,
          attr_,
          'DO' );
	
END Create_Note;


PROCEDURE Remove_Note (
   note_id_       IN NUMBER, 
   key_attr_      IN VARCHAR2 )
	
IS
   obj_id_           ROWID;
   obj_version_      VARCHAR2(2000);
   info_             VARCHAR2(2000);
   company_          VOUCHER_NOTE.company%TYPE;
   accounting_year_  VOUCHER_NOTE.accounting_year%TYPE;
   voucher_type_      VOUCHER_NOTE.voucher_type%TYPE;
   voucher_no_         VOUCHER_NOTE.voucher_no%TYPE;
BEGIN
   company_         := Client_SYS.Get_Item_Value('COMPANY', key_attr_);
   accounting_year_ := Client_SYS.Get_Item_Value_To_Number('ACCOUNTING_YEAR', key_attr_, lu_name_);
   voucher_type_    := Client_SYS.Get_Item_Value('VOUCHER_TYPE', key_attr_);
   voucher_no_      := Client_SYS.Get_Item_Value_To_Number('VOUCHER_NO', key_attr_, lu_name_);
   Get_Id_Version_By_Keys___(obj_id_,
                             obj_version_,
                             company_,
                             accounting_year_,
                             voucher_type_,
			     voucher_no_,
                             note_id_);
   Remove__ (info_,
             obj_id_,
             obj_version_,
             'DO');
END Remove_Note;


