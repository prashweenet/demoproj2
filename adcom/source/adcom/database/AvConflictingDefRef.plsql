-----------------------------------------------------------------------------
--
--  Logical unit: AvConflictingDefRef
--  Component:    ADCOM
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  201202  supklk  LMM2020R1-1174, Added Get_Def_Ref_Id_By_Unique_Key to fetch Deferral Reference in data migration
--  200923  SatGlk  LMM2020R1-821, Added Get_Id_Version_By_Mx_Uniq_Key, Pre_Sync_Action
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------


-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------


-------------------- LU SPECIFIC PROTECTED METHODS --------------------------


-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------
PROCEDURE Get_Id_Version_By_Mx_Uniq_Key (
   objid_      OUT VARCHAR2,
   objversion_ OUT VARCHAR2,
   mx_unique_key_ IN VARCHAR2 ) 
IS  
   CURSOR get_key IS
   SELECT   rowid, TO_CHAR(rowversion,'YYYYMMDDHH24MISS')      
      FROM  av_conflicting_def_ref_tab
      WHERE mx_unique_key = mx_unique_key_;
BEGIN
   OPEN  get_key;
   FETCH get_key INTO objid_, objversion_;
   CLOSE get_key;

END Get_Id_Version_By_Mx_Uniq_Key;

PROCEDURE Pre_Sync_Action(
   attr_  IN OUT VARCHAR2)
IS
   local_attr_                 VARCHAR2(4000);
   deferral_ref_id_            av_conflicting_def_ref_tab.deferral_ref_id%TYPE;
   conflicting_defer_ref_id_   av_conflicting_def_ref_tab.conflicting_defer_ref_id%TYPE;
   deferral_ref_unique_key_    av_deferral_reference_tab.mx_unique_key%TYPE;
   conf_defer_ref_unique_key_  av_deferral_reference_tab.mx_unique_key%TYPE;

   CURSOR get_deferral_ref_id IS
      SELECT deferral_reference_id
      FROM   av_deferral_reference_tab
      WHERE  mx_unique_key = deferral_ref_unique_key_;
      
   CURSOR get_conflicting_defer_ref_id IS
      SELECT deferral_reference_id
      FROM   av_deferral_reference_tab
      WHERE  mx_unique_key = conf_defer_ref_unique_key_;      
BEGIN
   local_attr_ := attr_;

   IF Client_SYS.Item_Exist('DEFERRAL_REF_UNIQUE_KEY', local_attr_) THEN
      deferral_ref_unique_key_ := Client_SYS.Get_Item_Value('DEFERRAL_REF_UNIQUE_KEY', local_attr_);    

      OPEN  get_deferral_ref_id;
      FETCH get_deferral_ref_id INTO deferral_ref_id_;
      CLOSE get_deferral_ref_id;
      
      IF deferral_ref_unique_key_ IS NOT NULL AND deferral_ref_id_ IS NULL THEN
         Error_SYS.Appl_General(lu_name_, 'CONFDEFREFSYNCERR: Could not find the indicated Deferral Reference :P1', deferral_ref_unique_key_);
      END IF;
      
      Client_SYS.Add_To_Attr('DEFERRAL_REF_ID', deferral_ref_id_, local_attr_);
      local_attr_:= Client_SYS.Remove_Attr('DEFERRAL_REF_UNIQUE_KEY',  local_attr_);
   END IF;
   
   IF Client_SYS.Item_Exist('CONFLICTING_DEFER_REF_UNIQUE_KEY', local_attr_) THEN
      conf_defer_ref_unique_key_ := Client_SYS.Get_Item_Value('CONFLICTING_DEFER_REF_UNIQUE_KEY', local_attr_);    
      
      OPEN  get_conflicting_defer_ref_id;
      FETCH get_conflicting_defer_ref_id INTO conflicting_defer_ref_id_;
      CLOSE get_conflicting_defer_ref_id;
      
      IF conf_defer_ref_unique_key_ IS NOT NULL AND conflicting_defer_ref_id_ IS NULL THEN
         Error_SYS.Appl_General(lu_name_, 'CONFDEFREFSYNCERR: Could not find the indicated Deferral Reference :P1', conf_defer_ref_unique_key_);
      END IF;
      
      Client_SYS.Add_To_Attr('CONFLICTING_DEFER_REF_ID', conflicting_defer_ref_id_, local_attr_);
      local_attr_:= Client_SYS.Remove_Attr('CONFLICTING_DEFER_REF_UNIQUE_KEY',  local_attr_);
   END IF;
   
   attr_ := local_attr_;
END Pre_Sync_Action;

FUNCTION Get_Def_Ref_Id_By_Unique_Key (
   def_ref_unique_key_ IN VARCHAR2 ) RETURN NUMBER
IS
   temp_ av_deferral_reference_tab.deferral_reference_id%TYPE;
   
   CURSOR get_def_ref_id IS 
      SELECT deferral_reference_id         
        FROM av_deferral_reference_tab
       WHERE mx_unique_key = def_ref_unique_key_;
BEGIN
   OPEN get_def_ref_id;
   FETCH get_def_ref_id INTO temp_; 
   CLOSE get_def_ref_id;
   
   RETURN temp_;
END Get_Def_Ref_Id_By_Unique_Key;