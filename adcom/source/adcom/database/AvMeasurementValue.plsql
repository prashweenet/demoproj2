-----------------------------------------------------------------------------
--
--  Logical unit: AvMeasurementValue
--  Component:    ADCOM
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------


-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------


-------------------- LU SPECIFIC PROTECTED METHODS --------------------------


-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

/*
   This procedure will fetch the objid and objversion using the natural 
   keys of the entitiy and remove the keys of the entity from attr to update.
*/
PROCEDURE Get_Id_Version_By_Natural_Keys (
   objid_       OUT     VARCHAR2,
   objversion_  OUT     VARCHAR2,
   attr_        IN OUT  VARCHAR2) 
IS  
   CURSOR get_key IS
      SELECT rowid, TO_CHAR(rowversion,'YYYYMMDDHH24MISS')     
      FROM  av_measurement_value_tab
      WHERE measurement_type_code = CLIENT_SYS.Get_Item_Value('MEASUREMENT_TYPE_CODE', attr_) AND 
            meas_type_value_code = CLIENT_SYS.Get_Item_Value('MEAS_TYPE_VALUE_CODE', attr_);
BEGIN
   OPEN  get_key;
   FETCH get_key INTO objid_, objversion_;
   CLOSE get_key;
   
   IF  objid_ IS NOT NULL AND objversion_ IS NOT NULL THEN
      attr_ := Client_SYS.Remove_Attr('MEASUREMENT_TYPE_CODE', attr_);
      attr_ := Client_SYS.Remove_Attr('MEAS_TYPE_VALUE_CODE', attr_);
   END IF;
END Get_Id_Version_By_Natural_Keys;