-----------------------------------------------------------------------------
--
--  Logical unit: ExtLoadIdStorage
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  000202  Upul     Created.
--  000912  HiMu     Added General_SYS.Init_Method
--  010322  LiSv     For new Create Company concept added new view ext_load_id_storage_ect and ext_load_id_storage_pct.
--                   Added procedures Make_Company, Copy___, Import___ and Export___.
--  010816  OVJOSE   Added Create Company translation method Create_Company_Translations___
--  020102  THSRLK   IID 20001 Enhancement of Update Company. Changes inside make_company method
--                   Changed Import___, Export___ and Copy___ methods to use records
--  020320  Mnisse   Copy__ changed FOUND -> NOTFOUND
--  040623  anpelk   FIPR338A2: Unicode Changes.
--  051024  Gadalk   Bug 52834, Merged.
--  060310  Samwlk   Bug 55911, Merged.
--  090525  AsHelk   Bug 80221, Adding Transaction Statement Approved Annotation.
--  131031  PRatlk   PBFI-1926, Refactored according to the new template
--  140304  MAWELK PBFI-4118(Lcs Bug Id 113927) fixed.
--  190225  AjPelk   Bug 147024, Modify the method, Get_Next_Load_Id, Now this method locks the record at the very begining and commit at the end.  
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------

@Override
PROCEDURE Export_Assign___ (
   pub_rec_     IN OUT Enterp_Comp_Connect_V170_API.Tem_Public_Rec,
   crecomp_rec_ IN     Enterp_Comp_Connect_V170_API.Crecomp_Lu_Public_Rec,
   exprec_      IN     ext_load_id_storage_tab%ROWTYPE )
IS
BEGIN
   super(pub_rec_, crecomp_rec_, exprec_);
   pub_rec_.n1 := 0;
   pub_rec_.n2 := 0;
END Export_Assign___;

------------------- LU SPECIFIC PRIVATE METHODS ----------------------------

-------------------- LU SPECIFIC PROTECTED METHODS --------------------------

-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

PROCEDURE Get_Next_Load_Id (next_load_id_ OUT VARCHAR2,
                            company_       IN VARCHAR2 ) 
IS 
   PRAGMA AUTONOMOUS_TRANSACTION; 
   
   newrec_           ext_load_id_storage_tab%ROWTYPE; 
   max_load_id_      NUMBER; 
   
   CURSOR get_max_load_id IS 
      SELECT NVL(MAX(TO_NUMBER(load_id)),0) 
      FROM   ext_load_info_tab 
      WHERE  company = company_; 
BEGIN 
   newrec_ := Lock_By_Keys___(company_); 
   
   OPEN get_max_load_id; 
   FETCH get_max_load_id INTO max_load_id_; 
   CLOSE get_max_load_id; 
   
   newrec_.current_load_id := GREATEST(newrec_.current_load_id, max_load_id_) + 1; 
   
   Modify___(newrec_);     
   next_load_id_ := newrec_.current_load_id;   
   @ApproveTransactionStatement(2019-02-25,ajpelk) 
   COMMIT; 
END Get_Next_Load_Id;

PROCEDURE Update_Load_Id_Storage (
   company_ IN VARCHAR2,
   load_id_ IN VARCHAR2 )
IS
   PRAGMA AUTONOMOUS_TRANSACTION;
   next_load_id_  NUMBER;
BEGIN

   next_load_id_ := to_number(load_id_);
   UPDATE Ext_Load_Id_Storage_Tab
      SET Current_Load_Id = next_load_id_
    WHERE Company = company_;
   @ApproveTransactionStatement(2009-05-25,ashelk)
   COMMIT;
END Update_Load_Id_Storage;
