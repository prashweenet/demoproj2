-------------------------------------------------------------------------------
--
--  Filename      : Post_Accrul_InsertPlannedObjectIntoCodePartValue.sql
--
--  Module        : ACCRUL
--
--  Purpose       : Insert fa objects in 'Planned' state as a Code Part Value
--
--  Date    Sign    History
--  ------  ------  -------------------------------------------------------------
--  140522  MAAYLK  Bug 116874, Inserting the fa_objects that are in 'Planned' state into
--                  Accounting_Code_Part_Value_Tab along with there CompanyLUTranslations.
--                  Before this bug correction FA_Objects created in 'Planned' state are not
--                  copied to Code Part Values. But it was allowed to use those obejcts in
--                  Budgeting. Therefore it was decided to insert 'Planned' objects to
--                  Code part values as well.
---------------------------------------------------------------------------------

SET SERVEROUTPUT ON

exec Database_SYS.Log_Detail_Time_Stamp('ACCRUL','Post_Accrul_InsertPlannedObjectIntoCodePartValue.sql','Timestamp_1');
PROMPT Post_Accrul_InsertPlannedObjectIntoCodePartValue.sql

DECLARE
$IF Component_Fixass_SYS.INSTALLED $THEN
   code_part_    VARCHAR2(1);

   CURSOR get_planned_objects IS
      SELECT company,
             object_id,
             description,
             valid_from,
             valid_until
      FROM   fa_object_tab f
      WHERE  rowstate = 'Planning'
      AND  NOT EXISTS ( SELECT 1
                        FROM   accounting_code_part_value_tab c
                        WHERE  c.company         = f.company
                        AND    c.code_part_value = f.object_id
                        AND    c.code_part       = 'FAACC');

   TYPE planned_objects IS TABLE OF get_planned_objects%ROWTYPE INDEX BY PLS_INTEGER;
   planned_objects_ planned_objects;
   lang_code_        VARCHAR2(10) := Language_SYS.Get_Language;
$END
BEGIN
$IF Component_Fixass_SYS.INSTALLED $THEN
   OPEN get_planned_objects;
   FETCH get_planned_objects BULK COLLECT INTO planned_objects_;
   CLOSE get_planned_objects;

   FOR i IN 1..planned_objects_.COUNT LOOP

      code_part_ := Accounting_Code_Parts_API.Get_Codepart_Function(planned_objects_(i).company, Fa_System_Parameter_API.Get_Parameter_Value('FA_CODEPART_FUNCTION_NAME'));

      INSERT
         INTO accounting_code_part_value_tab (
              company,
              code_part,
              code_part_value,
              valid_from,
              valid_until,
              text,
              description,
              sort_value,
              rowversion,
              bud_account,
              rowtype)
         VALUES (
              planned_objects_(i).company,
              code_part_,
              planned_objects_(i).object_id,
              planned_objects_(i).valid_from,
              planned_objects_(i).valid_until,
              Fa_Object_Note_Api.Get_Object_Note_Text(planned_objects_(i).company, planned_objects_(i).object_id),
              planned_objects_(i).description,
              ACCOUNTING_CODE_PART_VALUE_API.Generate_Sort_Value(planned_objects_(i).object_id),
              sysdate,
              'N',
              'Code'||code_part_);

      Enterp_Comp_Connect_V170_API.Insert_Company_Translation( planned_objects_(i).company,
                                                               'ACCRUL',
                                                               'Code'||code_part_,
                                                               planned_objects_(i).object_id,
                                                               lang_code_,
                                                               planned_objects_(i).description );
   END LOOP;
   COMMIT;
$ELSE
   NULL;
$END
END;
/
exec Database_SYS.Log_Detail_Time_Stamp('ACCRUL','Post_Accrul_InsertPlannedObjectIntoCodePartValue.sql','Done');
