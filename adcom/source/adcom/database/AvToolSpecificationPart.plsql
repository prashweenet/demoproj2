-----------------------------------------------------------------------------
--
--  Logical unit: AvToolSpecificationPart
--  Component:    ADCOM
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  201022  SUPKLK  AD2020R1-836 Added Get_Key_By_Mx_Unique_Key function and Modified Check_Insert___ to handle duplicates from data migration
--  201007  TAJALK  LMM2020R1-1308 - Created
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------
@Override
PROCEDURE Check_Insert___ (
   newrec_ IN OUT av_tool_specification_part_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
   tool_specification_part_id_ NUMBER;
   
   CURSOR get_tool_specification_part_id IS 
      SELECT TOOL_SPEC_PART_ID_SEQ.nextval 
      FROM dual;
BEGIN
   IF (newrec_.part_group_part_id IS NULL) THEN
      OPEN  get_tool_specification_part_id;
      FETCH get_tool_specification_part_id INTO tool_specification_part_id_;
      CLOSE get_tool_specification_part_id;      
      newrec_.part_group_part_id := tool_specification_part_id_;
      Client_SYS.Add_To_Attr('PART_GROUP_PART_ID', tool_specification_part_id_, attr_);  
   END IF;   
   super(newrec_, indrec_, attr_);
END Check_Insert___;

-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------


-------------------- LU SPECIFIC PROTECTED METHODS --------------------------


-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

FUNCTION Get_Key_By_Mx_Unique_Key (
   mx_unique_key_ IN VARCHAR2 ) RETURN NUMBER
IS
   temp_ av_tool_specification_part_tab.part_group_part_id%TYPE;
   
   CURSOR get_tool_specification_part_id IS 
      SELECT part_group_part_id         
        FROM av_tool_specification_part_tab
       WHERE mx_unique_key = mx_unique_key_;
BEGIN
   OPEN get_tool_specification_part_id;
   FETCH get_tool_specification_part_id INTO temp_; 
   CLOSE get_tool_specification_part_id;
   
   RETURN temp_;
END Get_Key_By_Mx_Unique_Key;