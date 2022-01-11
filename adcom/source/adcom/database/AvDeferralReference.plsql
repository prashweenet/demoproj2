-----------------------------------------------------------------------------
--
--  Logical unit: AvDeferralReference
--  Component:    ADCOM
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  200108  SEVHLK  LMM2020R1- Added pre sync action method.
--  210108  SUPKLK  LMM2020R1-1502, Added Get_Sub_Sys_Id_By_Unique_Key to fetch sub system id in data migration
--  201019  SUPKLK  LMM2020R1-1172, Added Get_Key_By_Mx_Unique_Key function and Modified Check_Insert___ method to handle duplicates while data migration.
--  200909  TAJALK  LMM2020R1-771 - Sync logic added
--  200626  LAHNLK  LMM2020R1-74: created.
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------
@Override
PROCEDURE Check_Insert___ (
   newrec_ IN OUT av_deferral_reference_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
   CURSOR get_key_set IS
      SELECT av_deferral_ref_seq.NEXTVAL
      FROM dual;
BEGIN
   IF(newrec_.deferral_reference_id IS NULL) THEN
      OPEN get_key_set;
      FETCH get_key_set INTO newrec_.deferral_reference_id;
      CLOSE get_key_set;
   END IF;
   super(newrec_, indrec_, attr_);
   --Client_SYS.Add_To_Attr('DEFERRAL_REFERENCE_ID', newrec_.deferral_reference_id, attr_);
END Check_Insert___;




-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------


-------------------- LU SPECIFIC PROTECTED METHODS --------------------------


-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------
PROCEDURE Get_Id_Version_By_Mx_Uniq_Key (
   objid_         OUT VARCHAR2,
   objversion_    OUT VARCHAR2,
   mx_unique_key_ IN  VARCHAR2 ) 
IS  
   
   CURSOR get_key IS
   SELECT   rowid, TO_CHAR(rowversion,'YYYYMMDDHH24MISS')      
      FROM  av_deferral_reference_tab
      WHERE mx_unique_key = mx_unique_key_;
BEGIN
   OPEN  get_key;
   FETCH get_key INTO objid_, objversion_;
   CLOSE get_key;
   
END Get_Id_Version_By_Mx_Uniq_Key;


FUNCTION Get_Key_By_Mx_Unique_Key (
   mx_unique_key_ IN VARCHAR2 ) RETURN NUMBER
IS
   deferral_reference_id_ av_deferral_reference.deferral_reference_id%TYPE;
   
   CURSOR get_deferral_reference_id IS 
      SELECT deferral_reference_id         
        FROM av_deferral_reference_tab
       WHERE mx_unique_key = mx_unique_key_;
BEGIN
   OPEN get_deferral_reference_id;
   FETCH get_deferral_reference_id INTO deferral_reference_id_; 
   CLOSE get_deferral_reference_id;
   
   RETURN deferral_reference_id_;
END Get_Key_By_Mx_Unique_Key;

PROCEDURE Pre_Sync_Action(
   attr_ IN OUT VARCHAR2)
IS
   local_attr_                 VARCHAR2(4000);
   sub_system_id_              Av_Aircraft_Sub_System_Tab.sub_system_id%TYPE;
   sub_system_unique_key_      Av_Aircraft_Sub_System_Tab.mx_unique_key%TYPE;
   
   CURSOR Get_Sub_System IS
      SELECT sub_system_id
      FROM   av_aircraft_sub_system_tab
      WHERE  mx_unique_key = sub_system_unique_key_;
   
BEGIN
   local_attr_ := attr_;

   IF Client_SYS.Item_Exist('SUB_SYSTEM_UNIQUE_KEY', local_attr_) THEN
      sub_system_unique_key_ := Client_SYS.Get_Item_Value('SUB_SYSTEM_UNIQUE_KEY', local_attr_);    
      
      OPEN  Get_Sub_System;
      FETCH Get_Sub_System INTO sub_system_id_;
      CLOSE Get_Sub_System;
      
      IF sub_system_unique_key_ IS NOT NULL AND sub_system_id_ IS NULL THEN
         Error_SYS.Appl_General(lu_name_, 'SUBSYSTEMSYNCER: Could not find the indicated Sub System :P1', sub_system_unique_key_);
      END IF;
      
      Client_SYS.Add_To_Attr('SUB_SYSTEM_ID', sub_system_id_, local_attr_);
      local_attr_:= Client_SYS.Remove_Attr('SUB_SYSTEM_UNIQUE_KEY',  local_attr_);
   END IF;
   attr_ := local_attr_;
END Pre_Sync_Action;

FUNCTION Get_Sub_Sys_Id_By_Unique_Key (
   sub_system_unique_key_ IN   VARCHAR2 ) RETURN NUMBER
IS
   temp_ av_aircraft_sub_system_tab.sub_system_id%TYPE;
   
   CURSOR get_sub_system_id IS 
      SELECT sub_system_id         
        FROM av_aircraft_sub_system_tab
       WHERE mx_unique_key = sub_system_unique_key_;
BEGIN
   OPEN get_sub_system_id;
   FETCH get_sub_system_id INTO temp_; 
   CLOSE get_sub_system_id;

   RETURN temp_;
END Get_Sub_Sys_Id_By_Unique_Key;
