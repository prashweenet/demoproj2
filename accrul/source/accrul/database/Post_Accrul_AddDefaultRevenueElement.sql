-------------------------------------------------------------------------------
--
--  Filename      : Post_Accrul_AddDefaultRevenueElement.sql
--
--  Module        : ACCRUL
--
--  Purpose       : This script will upgrade all companies to have a default revenue element.
--
--  Date    Sign    History
--  ------  ------  -------------------------------------------------------------
--  171023  HWIDLK  Created.
--  190417  HuBaUK  Bug 147850, Added section to insert default revenue element for use with project cost element code part demand
---------------------------------------------------------------------------------

SET SERVEROUTPUT ON

exec Database_SYS.Log_Detail_Time_Stamp('ACCRUL','Post_Accrul_AddDefaultRevenueElement.sql','Timestamp_1');
PROMPT Start Post_Accrul_AddDefaultRevenueElement.sql

exec Database_SYS.Log_Detail_Time_Stamp('ACCRUL','Post_Accrul_AddDefaultRevenueElement.sql','Timestamp_2');
PROMPT Adding a default revenue element

DECLARE
   temp_          NUMBER := 0;
   revenue_exist_ BOOLEAN;
   element_name_  project_cost_element_tab.project_cost_element%TYPE;
   description_   project_cost_element_tab.description%TYPE;

   CURSOR get_companies IS
      SELECT company
      FROM company_tab;

   CURSOR check_record_exists(company_ project_cost_element_tab.company%TYPE) IS
      SELECT 1
      FROM project_cost_element_tab
      WHERE company = company_
         AND project_cost_element = 'REVENUE';

   CURSOR check_element_type(company_ project_cost_element_tab.company%TYPE) IS
      SELECT 1
      FROM project_cost_element_tab
      WHERE company = company_
         AND project_cost_element IN ('REVENUE', 'REVENUE-' || company_)
         AND element_type = 'REVENUE';

   TYPE Companies_Tab IS TABLE OF company_tab.company%TYPE;
   companies_ Companies_Tab;
BEGIN
   OPEN  get_companies;
   FETCH get_companies BULK COLLECT INTO companies_;
   CLOSE get_companies;

   IF (companies_.COUNT <> 0) THEN
      FOR comp IN companies_.FIRST..companies_.LAST LOOP
         revenue_exist_ := FALSE;
         element_name_  := NULL;

         OPEN check_record_exists(companies_(comp));
         FETCH check_record_exists INTO temp_;
         IF (check_record_exists%FOUND) THEN
            revenue_exist_ := TRUE;
         END IF;
         CLOSE check_record_exists;

         IF (revenue_exist_) THEN
            OPEN check_element_type(companies_(comp));
            FETCH check_element_type INTO temp_;
            IF (check_element_type%NOTFOUND) THEN
               element_name_ := 'REVENUE-' || companies_(comp);
            END IF;
            CLOSE check_element_type;
         ELSE
            element_name_ := 'REVENUE';
         END IF;

         IF (element_name_ IS NOT NULL) THEN
            INSERT INTO project_cost_element_tab
                   (company,
                    project_cost_element,
                    description,
                    element_type,
                    default_cost_element,
                    default_no_base,
                    rowversion,
                    rowstate)
            VALUES (companies_(comp),
                    element_name_,
                    'Revenue',
                    'REVENUE',
                    'TRUE',
                    'FALSE',
                    SYSDATE,
                    'Active');

            Basic_Data_Translation_API.Insert_Prog_Translation('ACCRUL', 'ProjectCostElement', companies_(comp) || '^REVENUE','Revenue');
            $IF (Component_Projbf_SYS.INSTALLED) $THEN
            INSERT INTO proj_c_cost_el_code_p_dem_tab
                   (company,
                    project_cost_element,
                    rowversion)
            VALUES (companies_(comp),
                    element_name_,
                    SYSDATE);
            $END
         END IF;
      END LOOP;
      COMMIT;
   END IF;
END;
/

exec Database_SYS.Log_Detail_Time_Stamp('ACCRUL','Post_Accrul_AddDefaultRevenueElement.sql','Done');
PROMPT Finish Post_Accrul_AddDefaultRevenueElement.sql
