-----------------------------------------------------------------------------
--
--  Logical unit: AvPartNumber
--  Component:    ADCOM
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  201016  SUPKLK  AD2020R1-833: Modified Check_Insert___ to handle duplicate data from data migration 
--  200923  SatGlk  LMM2020R1-786: Added Get_Id_Version_By_Mx_Uniq_Key
--  200923  SatGlk  LMM2020R1-751: Overriden Check_Insert___ to handle sequence for  part_number_id.
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------
@Override
PROCEDURE Check_Insert___ (
   newrec_ IN OUT av_part_number_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
   part_number_id_   NUMBER;
   CURSOR get_key_seq IS
      SELECT PART_NUMBER_ID_SEQ.NEXTVAL
      FROM dual;
BEGIN   
   IF(newrec_.part_number_id IS NULL) THEN
      OPEN  get_key_seq;
      FETCH get_key_seq INTO part_number_id_;
      CLOSE get_key_seq;
      newrec_.part_number_id := part_number_id_;
      Client_SYS.Add_To_Attr('PART_NUMBER_ID', part_number_id_, attr_);
   END IF;
   super(newrec_, indrec_, attr_);
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
      FROM  av_part_number_tab
      WHERE mx_unique_key = mx_unique_key_;
BEGIN
   OPEN  get_key;
   FETCH get_key INTO objid_, objversion_;
   CLOSE get_key;
   
END Get_Id_Version_By_Mx_Uniq_Key;



FUNCTION Get_Key_By_Mx_Unique_Key (
   mx_unique_key_ IN VARCHAR2 ) RETURN NUMBER
IS
   temp_ av_part_number.part_number_id%TYPE;
   
   CURSOR get_part_number_id IS 
      SELECT part_number_id         
        FROM av_part_number_tab
       WHERE mx_unique_key = mx_unique_key_;
BEGIN
   OPEN get_part_number_id;
   FETCH get_part_number_id INTO temp_; 
   CLOSE get_part_number_id;
   
   RETURN temp_;
END Get_Key_By_Mx_Unique_Key;
