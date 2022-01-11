-----------------------------------------------------------------------------
--
--  Logical unit: AvPartGroupPart
--  Component:    ADCOM
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  201105  SUPKLK  LMM2020R1-1147, Implemented Get_Key_By_Mx_Unique_Key and modified Check_Insert___ to handle duplicate data
--  201104  SatGlk  AD2020R1-1065, Added check exist in pre_sync, when an update happens Part_Group_ID and Part_No_ID should not be updated (those attrbites will be natural keys in future
--  201026  SWIclk  AD2020R1-958, Modified Pre_Sync_Action() by replacing PART_NUMBER_ID with PART_NO_ID.
--  200916  SWiclk  LMM2020R1-781, Added Check_Insert___(), Get_Id_Version_By_Mx_Uniq_Key() and Pre_Sync_Action().
--  200716  MADGLK Added function Get_Part_Group_Id().
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------
@Override
PROCEDURE Check_Insert___ (
   newrec_ IN OUT av_part_group_part_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
   part_group_part_id_ NUMBER;
   CURSOR get_part_group_part_id IS 
      SELECT PART_GROUP_PART_ID_SEQ.nextval 
      FROM dual;
BEGIN
   IF(newrec_.part_group_part_id IS NULL) THEN
      OPEN get_part_group_part_id;
      FETCH get_part_group_part_id INTO part_group_part_id_;
      CLOSE get_part_group_part_id;
      newrec_.part_group_part_id := part_group_part_id_;
      Client_SYS.Add_To_Attr('PART_GROUP_PART_ID', part_group_part_id_, attr_);
   END IF;
   super(newrec_, indrec_, attr_);
END Check_Insert___;

-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------


-------------------- LU SPECIFIC PROTECTED METHODS --------------------------


-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------
FUNCTION Get_Part_Group_Id(
  part_no_id_   IN NUMBER ) RETURN NUMBER
IS
   CURSOR get_part_group IS
   SELECT Part_Group_Id
   FROM AV_PART_GROUP_PART_TAB
   WHERE part_no_id =part_no_id_;
   part_group_id_  NUMBER := 0 ;
BEGIN
   OPEN get_part_group;
   FETCH get_part_group INTO part_group_id_;
   CLOSE get_part_group;
   
   RETURN part_group_id_;   
END Get_Part_Group_Id ;

PROCEDURE Get_Id_Version_By_Mx_Uniq_Key (
   objid_         OUT  VARCHAR2,
   objversion_    OUT  VARCHAR2,
   mx_unique_key_ IN   VARCHAR2) 
IS      
   CURSOR get_id_version IS 
      SELECT rowid, to_char(rowversion,'YYYYMMDDHH24MISS')         
        FROM av_part_group_part_tab
       WHERE mx_unique_key = mx_unique_key_;
BEGIN
   OPEN get_id_version;
   FETCH get_id_version INTO objid_, objversion_; 
   CLOSE get_id_version;
  
END Get_Id_Version_By_Mx_Uniq_Key;

PROCEDURE Pre_Sync_Action(
   attr_  IN OUT VARCHAR2) 
IS
   local_attr_               VARCHAR2(4000);
   part_group_id_            av_part_group_tab.part_group_id%TYPE;
   part_no_id_               av_part_number_tab.part_number_id%TYPE;
   part_group_unique_key_    av_part_group_tab.mx_unique_key%TYPE;
   part_no_unique_key_       av_part_number_tab.mx_unique_key%TYPE;
   mx_unique_key_            av_part_group_part_tab.mx_unique_key%TYPE;
   check_exists_             NUMBER;
   
   CURSOR get_part_group_id_cursor IS
      SELECT part_group_id
      FROM   av_part_group_tab
      WHERE  mx_unique_key = part_group_unique_key_;
   
   CURSOR get_part_no_id IS
      SELECT part_number_id
      FROM   av_part_number_tab
      WHERE  mx_unique_key = part_no_unique_key_;
      
   CURSOR check_exist_part_grp_part IS
      SELECT 1
      FROM   av_part_group_part_tab
      WHERE  mx_unique_key = mx_unique_key_;   
BEGIN
   local_attr_ := attr_;
   mx_unique_key_:= Client_SYS.Get_Item_Value('MX_UNIQUE_KEY', attr_);
   OPEN  check_exist_part_grp_part;
   FETCH check_exist_part_grp_part INTO check_exists_;
   CLOSE check_exist_part_grp_part;
   
   -- Note: When an update happens Part_Group_ID and Part_No_ID should not be updated (those attrbites will be
   -- natural keys in future).
   IF (check_exists_ IS NULL OR check_exists_ != 1) THEN      
      IF Client_SYS.Item_Exist('PART_GROUP_UNIQUE_KEY', local_attr_) THEN
         part_group_unique_key_ := Client_SYS.Get_Item_Value('PART_GROUP_UNIQUE_KEY', local_attr_);    

         OPEN  get_part_group_id_cursor;
         FETCH get_part_group_id_cursor INTO part_group_id_;
         CLOSE get_part_group_id_cursor;

         IF part_group_unique_key_ IS NOT NULL AND part_group_id_ IS NULL THEN
            Error_SYS.Appl_General(lu_name_, 'PARTGROUPSYNCERR: Could not find the indicated Part Group ID :P1', part_group_unique_key_);
         END IF;      
         Client_SYS.Add_To_Attr('PART_GROUP_ID', part_group_id_, local_attr_);
         local_attr_:= Client_SYS.Remove_Attr('PART_GROUP_UNIQUE_KEY',  local_attr_);
      END IF; 

      IF Client_SYS.Item_Exist('PART_NUMBER_UNIQUE_KEY', local_attr_) THEN
         part_no_unique_key_ := Client_SYS.Get_Item_Value('PART_NUMBER_UNIQUE_KEY', local_attr_);

         OPEN  get_part_no_id;
         FETCH get_part_no_id INTO part_no_id_;
         CLOSE get_part_no_id;

         IF part_no_unique_key_ IS NOT NULL AND part_no_id_ IS NULL THEN
            Error_SYS.Appl_General(lu_name_, 'PARTNUMBERSYNCERR: Could not find the indicated Part Number ID :P1', part_no_unique_key_);
         END IF;      
         Client_SYS.Add_To_Attr('PART_NO_ID', part_no_id_, local_attr_);
         local_attr_:= Client_SYS.Remove_Attr('PART_NUMBER_UNIQUE_KEY',  local_attr_);
      END IF;  
   END IF;

   IF Client_SYS.Item_Exist('IS_STANDARD', local_attr_) THEN
      IF Client_SYS.Get_Item_Value('IS_STANDARD', local_attr_) = 1 THEN
         Client_SYS.Set_Item_Value('IS_STANDARD', 'True', local_attr_);
      ELSE
         Client_SYS.Set_Item_Value('IS_STANDARD', 'False', local_attr_);
      END IF;
   END IF;   
   
   IF Client_SYS.Item_Exist('IS_APPROVED', local_attr_) THEN
      IF Client_SYS.Get_Item_Value('IS_APPROVED', local_attr_) = 1 THEN
         Client_SYS.Set_Item_Value('IS_APPROVED', 'True', local_attr_);
      ELSE
         Client_SYS.Set_Item_Value('IS_APPROVED', 'False', local_attr_);
      END IF;
   END IF;
   
   IF Client_SYS.Item_Exist('IS_CONDITIONS', local_attr_) THEN
      IF Client_SYS.Get_Item_Value('IS_CONDITIONS', local_attr_) = 1 THEN
         Client_SYS.Set_Item_Value('IS_CONDITIONS', 'True', local_attr_);
      ELSE
         Client_SYS.Set_Item_Value('IS_CONDITIONS', 'False', local_attr_);
      END IF;
   END IF;
   
   attr_ := local_attr_;
END Pre_Sync_Action;


FUNCTION Get_Key_By_Mx_Unique_Key (
   mx_unique_key_ IN VARCHAR2 ) RETURN NUMBER
IS
   temp_ av_part_group_part_tab.part_group_part_id%TYPE;
   
   CURSOR get_part_group_part_id IS 
      SELECT part_group_part_id         
        FROM av_part_group_part_tab
       WHERE mx_unique_key = mx_unique_key_;
BEGIN
   OPEN get_part_group_part_id;
   FETCH get_part_group_part_id INTO temp_; 
   CLOSE get_part_group_part_id;
   
   RETURN temp_;
END Get_Key_By_Mx_Unique_Key;

FUNCTION Get_Part_Group_Id (
   pg_mx_unique_key_ IN VARCHAR2 ) RETURN NUMBER
IS
   temp_ av_part_group_tab.part_group_id%TYPE;
   
   CURSOR get_part_group_id IS 
      SELECT part_group_id         
        FROM av_part_group_tab
       WHERE mx_unique_key = pg_mx_unique_key_;
BEGIN
   OPEN get_part_group_id;
   FETCH get_part_group_id INTO temp_; 
   CLOSE get_part_group_id;
   
   RETURN temp_;
END Get_Part_Group_Id;

FUNCTION Get_Part_Number_Id (
   pn_mx_unique_key_ IN VARCHAR2 ) RETURN NUMBER
IS
   temp_ av_part_number_tab.part_number_id%TYPE;
   
   CURSOR get_part_number_id IS 
      SELECT part_number_id         
        FROM av_part_number_tab
       WHERE mx_unique_key = pn_mx_unique_key_;
BEGIN
   OPEN get_part_number_id;
   FETCH get_part_number_id INTO temp_; 
   CLOSE get_part_number_id;
   
   RETURN temp_;
END Get_Part_Number_Id;