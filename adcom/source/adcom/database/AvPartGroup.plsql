-----------------------------------------------------------------------------
--
--  Logical unit: AvPartGroup
--  Component:    ADCOM
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  201120  aruflk  AD2020R1-1053, Removed Get_Common_Hardware().
--  201105  supklk  LMM2020R1-1146, Implemented Get_Key_By_Mx_Unique_Key and Modified Check_Insert___ to handle duplications in data migration
-- 201026   SWiclk  AD2020R1-958, Added Pre_Sync_Action().
--  200915  SWiclk  LMM2020R1-776, Added Check_Insert___() and Get_Id_Version_By_Mx_Uniq_Key().
--  200908  aruflk  Added Get_Common_Hardware().
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------
@Override
PROCEDURE Check_Insert___ (
   newrec_ IN OUT av_part_group_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
   part_group_id_ NUMBER;
   CURSOR get_part_group_id IS 
      SELECT PART_GROUP_ID_SEQ.nextval 
      FROM dual;
BEGIN
   IF (newrec_.part_group_id IS NULL) THEN
      OPEN get_part_group_id;
      FETCH get_part_group_id INTO part_group_id_;
      CLOSE get_part_group_id;
      newrec_.part_group_id := part_group_id_;
      Client_SYS.Add_To_Attr('PART_GROUP_ID', part_group_id_, attr_);
   END IF;
   super(newrec_, indrec_, attr_);
END Check_Insert___;

-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------


-------------------- LU SPECIFIC PROTECTED METHODS --------------------------


-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------
PROCEDURE Get_Id_Version_By_Mx_Uniq_Key (
   objid_         OUT  VARCHAR2,
   objversion_    OUT  VARCHAR2,
   mx_unique_key_ IN   VARCHAR2) 
IS      
   CURSOR get_id_version IS 
      SELECT rowid, to_char(rowversion,'YYYYMMDDHH24MISS')         
        FROM av_part_group_tab
       WHERE mx_unique_key = mx_unique_key_;
BEGIN
   OPEN get_id_version;
   FETCH get_id_version INTO objid_, objversion_; 
   CLOSE get_id_version;
  
END Get_Id_Version_By_Mx_Uniq_Key;

PROCEDURE Pre_Sync_Action(
   attr_  IN OUT VARCHAR2) 
IS
   local_attr_                VARCHAR2(4000);
   dummy_   NUMBER;
   mx_unique_key_    av_part_group_tab.mx_unique_key%TYPE;   
      
   CURSOR check_exist_part_group IS
      SELECT 1
      FROM   av_part_group_tab
      WHERE  mx_unique_key = mx_unique_key_;

BEGIN
   local_attr_ := attr_;
   
   IF Client_SYS.Item_Exist('MX_UNIQUE_KEY', local_attr_) THEN
      mx_unique_key_ := Client_SYS.Get_Item_Value('MX_UNIQUE_KEY', local_attr_);    

      OPEN  check_exist_part_group;
      FETCH check_exist_part_group INTO dummy_;
      CLOSE check_exist_part_group;      
      IF (dummy_ = 1) THEN
         local_attr_:= Client_SYS.Remove_Attr('AIRCRAFT_TYPE_CODE',  local_attr_);
         local_attr_:= Client_SYS.Remove_Attr('CONFIG_SLOT_CODE',  local_attr_);
         local_attr_:= Client_SYS.Remove_Attr('PART_GROUP_CODE',  local_attr_);         
      END IF;           
   END IF;     
   attr_ := local_attr_;
END Pre_Sync_Action;


FUNCTION Get_Key_By_Mx_Unique_Key (
   mx_unique_key_ IN VARCHAR2 ) RETURN NUMBER
IS
   temp_ av_part_group_tab.part_group_id%TYPE;
   
   CURSOR get_part_group_id IS 
      SELECT part_group_id         
        FROM av_part_group_tab
       WHERE mx_unique_key = mx_unique_key_;
BEGIN
   OPEN get_part_group_id;
   FETCH get_part_group_id INTO temp_; 
   CLOSE get_part_group_id;
   
   RETURN temp_;
END Get_Key_By_Mx_Unique_Key;