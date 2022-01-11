-----------------------------------------------------------------------------
--
--  Logical unit: AuditUtil
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  121129  Hawalk  Bug 107064, Changed Filter_Text___() by using UNISTR in place of non-single byte characters 
--  121129          that would cause problems in Oracle db on Japanese OS. 
--  120830  Umdolk  EDEL-1531. added assert safe tag.
--  120829  JuKoDE  EDEL-1535, Added CLOSE src_cur, EXCEPTION CLOSE CURSOR cursor_ in Generate_Output___(), Generate_Report_Output___()
--  121204   Maaylk  PEPA-183, Removed global variable
--  161121  Chwtlk  STRFI-4066, Merged LCS Bugs 132660 and 132570, Modified Generate_Output___.
--  171110  Nudilk  STRFI-10822, Merged Bug 138743.
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------

buffer_flush_point_  CONSTANT NUMBER := 10000;

-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------

FUNCTION Get_Column_Translation___(
   audit_source_    IN VARCHAR2,
   audit_type_db_   IN VARCHAR2,
   column_id_           IN VARCHAR2) RETURN VARCHAR2
IS 
   temp_       VARCHAR2(200);
   type_       VARCHAR2(50);
   path_       VARCHAR2(500);
   attribute_  VARCHAR2(500);
   report_id_  Audit_Source_Tab.report_id%TYPE;  
BEGIN
   type_ := 'Column';
   path_ := audit_source_ || '.' || column_id_;
   attribute_ := 'Prompt';
   
   temp_ := Language_SYS.Lookup(type_,
                                path_,
                                attribute_,
                                Fnd_Session_API.Get_Language );
                                
   IF (audit_type_db_ = 'REPORT' AND temp_ IS NULL) THEN
      type_ := 'Report Column';
      report_id_ := Audit_Source_API.Get_Report_Id(audit_source_);
      path_ := Report_SYS.Get_Lu_Name(report_id_) || '.' || report_id_ || '.' || column_id_;
      attribute_ := 'Title';
      temp_ := Language_SYS.Lookup(type_,
                                path_,
                                attribute_,
                                Fnd_Session_API.Get_Language );
      
      type_ := 'Column';
      path_ := audit_source_ || '.' || column_id_;
      attribute_ := 'Prompt';
   END IF;

   -- if still null then try to get text from the dictionary
   IF (temp_ IS NULL) THEN
      temp_ := Dictionary_SYS.Get_Item_Prompt_(Dictionary_SYS.Get_Logical_Unit(audit_source_, 'VIEW'),
                                               audit_source_,
                                               column_id_);
   END IF;

   -- if still null for report then try to get text from the report storage
   IF (temp_ IS NULL AND audit_type_db_ = 'REPORT') THEN
      temp_ := Report_SYS.Get_Column_Title(report_id_,
                                           column_id_);
   END IF;

   RETURN temp_;
END Get_Column_Translation___;


PROCEDURE Write_Lob___ (
   lob_     IN OUT NOCOPY CLOB,
   buffer_  IN OUT NOCOPY VARCHAR2,
   text_    IN VARCHAR2 )
IS
BEGIN
   buffer_ := buffer_ || text_;
   IF (length(buffer_) > buffer_flush_point_) THEN
      Dbms_Lob.WriteAppend (lob_, length(buffer_), buffer_);
      buffer_ := '';
   END IF;
END Write_Lob___;

PROCEDURE Write_Lob___ (
   lob_              IN OUT NOCOPY CLOB,
   buffer_           IN OUT NOCOPY VARCHAR2,
   text_             IN VARCHAR2,
   remove_new_line_  IN BOOLEAN )
IS
   str_     VARCHAR2(32000);
BEGIN
   str_ := text_;
   IF remove_new_line_ THEN
      str_ := Remove_New_Line_Char___(str_);
   END IF;
   Write_Lob___(lob_, buffer_, str_);   
END Write_Lob___;

FUNCTION Filter_Text___(
   text_ IN VARCHAR2) RETURN VARCHAR2
IS
   new_text_ VARCHAR2(2000);
BEGIN
   new_text_ := text_;
   new_text_ := REPLACE(new_text_, '&', 'u.');
   --                    equivalents.
   -- Note: See Design History on the use of UNISTR.
   new_text_ := REPLACE(new_text_, UNISTR('\00E4'), 'ae');
   new_text_ := REPLACE(new_text_, UNISTR('\00F6'), 'oe');
   new_text_ := REPLACE(new_text_, UNISTR('\00FC'), 'ue');
   new_text_ := REPLACE(new_text_, UNISTR('\00C4'), 'Ae');
   new_text_ := REPLACE(new_text_, UNISTR('\00D6'), 'Oe');
   new_text_ := REPLACE(new_text_, UNISTR('\00DC'), 'Ue');
   new_text_ := REPLACE(new_text_, UNISTR('\00DF'), 'ss');
   
   RETURN new_text_;
END Filter_Text___;


PROCEDURE Generate_Output___ (
   objid_         OUT VARCHAR2,
   country_       IN VARCHAR2,
   view_          IN VARCHAR2,
   company_       IN VARCHAR2,
   date_from_     IN DATE,
   date_to_       IN DATE,
   batch_         IN VARCHAR2 DEFAULT 'FALSE',
   ledger_id_     IN VARCHAR2 DEFAULT NULL )
IS
   lob_xml_data_        CLOB;
   lob_data_            CLOB;
   temp_raw_            CLOB;
   utl_                 utl_file.file_type;
   src_cur_             SYS_REFCURSOR;
   cursor_              NUMBER;
   ret_                 NUMBER;
   data_                VARCHAR2(32000);
   buffer_              VARCHAR2(32000);
   country_db_          VARCHAR2(2);
   company_name_        company.name%TYPE;
   company_city_        company_address.city%TYPE;
   addr_id_             company_address.address_id%TYPE;
   audit_format_        Audit_Format_API.Public_Rec;
   decimal_point_       VARCHAR2(1);
   thousand_separator_  VARCHAR2(1);
   date_format_         VARCHAR2(20);
   stmt_                VARCHAR2(32000);
   delim_               VARCHAR2(20);
   --data_type_           VARCHAR2(1);
   date_selection_      VARCHAR2(30);
   data_len_            NUMBER;
   byte_len_            NUMBER;
   from_                NUMBER;
   x_                   NUMBER;
   number_char_format_  VARCHAR2(30);
   ctr_                 NUMBER;
   out_objid_           VARCHAR2(200);
   index_               NUMBER;
   TYPE t_lob IS TABLE OF CLOB INDEX BY BINARY_INTEGER;
   lob_data_arr_        t_lob;

   CURSOR get_column IS
      SELECT *
        FROM audit_source_column_tab
       WHERE audit_source = view_;
BEGIN
   buffer_              := '';
   country_db_          := Iso_Country_API.Encode(country_);
   addr_id_             := Company_Address_API.Get_Default_Address (company_, Address_Type_Code_API.Decode('INVOICE'));
   company_name_        := Company_API.Get_Name(company_);
   company_city_        := Company_Address_API.Get_City(company_, addr_id_);
   audit_format_        := Audit_Format_API.Get(company_, country_db_, 'GDPdU');
   decimal_point_       := Audit_Decimal_API.Get_Value(audit_format_.decimal_point);
   IF (audit_format_.thousand_separator = 3) THEN
      thousand_separator_ := NULL;
   ELSIF (audit_format_.thousand_separator = 2) THEN
      thousand_separator_ := ' ';
   ELSE
      thousand_separator_  := Audit_Decimal_API.Get_Value(audit_format_.thousand_separator);
   END IF;
   IF (thousand_separator_ IS NULL) THEN
      number_char_format_ := '999999999999999999999D';
   ELSE
      number_char_format_ := '9G999G999G999G999G999G999G999D';
   END IF;
   date_format_         := Audit_Date_Format_API.Get_Value(audit_format_.date_format);

   IF (DBMS_LOB.istemporary(lob_xml_data_) = 1) THEN
       DBMS_LOB.freetemporary(lob_xml_data_);
   END IF;
   DBMS_LOB.createtemporary(lob_xml_data_, TRUE);

   Write_Lob___ (lob_xml_data_, buffer_, '<?xml version="1.0" encoding="UTF-8"?>');
   Write_Lob___ (lob_xml_data_, buffer_, CHR(10));
   Write_Lob___ (lob_xml_data_, buffer_, '<!DOCTYPE DataSet SYSTEM "GDPDU-01-08-2002.dtd">');
   Write_Lob___ (lob_xml_data_, buffer_, CHR(10));
   Write_Lob___ (lob_xml_data_, buffer_, '<DataSet>');
   Write_Lob___ (lob_xml_data_, buffer_, CHR(10));
   Write_Lob___ (lob_xml_data_, buffer_, '   <Version>1.0</Version>');
   Write_Lob___ (lob_xml_data_, buffer_, CHR(10));
   IF (company_name_ IS NOT NULL) THEN
      Write_Lob___ (lob_xml_data_, buffer_, '      <DataSupplier>');
      Write_Lob___ (lob_xml_data_, buffer_, CHR(10));
      Write_Lob___ (lob_xml_data_, buffer_, '         <Name>' || Filter_Text___(company_name_) || '</Name>');
      Write_Lob___ (lob_xml_data_, buffer_, CHR(10));
      Write_Lob___ (lob_xml_data_, buffer_, '         <Location>' || Filter_Text___(company_city_) || '</Location>');
      Write_Lob___ (lob_xml_data_, buffer_, CHR(10));
      Write_Lob___ (lob_xml_data_, buffer_, '         <Comment>Datentraegerueberlassung nach GDPdU aus IFS Applications</Comment>');
      Write_Lob___ (lob_xml_data_, buffer_, CHR(10));
      Write_Lob___ (lob_xml_data_, buffer_, '      </DataSupplier>');
      Write_Lob___ (lob_xml_data_, buffer_, CHR(10));
   END IF;
   Write_Lob___ (lob_xml_data_, buffer_, '   <Media>');
   Write_Lob___ (lob_xml_data_, buffer_, CHR(10));
   Write_Lob___ (lob_xml_data_, buffer_, '      <Name>' || view_ || '</Name>');
   Write_Lob___ (lob_xml_data_, buffer_, CHR(10));
   Write_Lob___ (lob_xml_data_, buffer_, '      <Table>');
   Write_Lob___ (lob_xml_data_, buffer_, CHR(10));
   Write_Lob___ (lob_xml_data_, buffer_, '         <URL>' || view_ || '</URL>');
   Write_Lob___ (lob_xml_data_, buffer_, CHR(10));
   Write_Lob___ (lob_xml_data_, buffer_, '         <Validity>');
   Write_Lob___ (lob_xml_data_, buffer_, CHR(10));
   Write_Lob___ (lob_xml_data_, buffer_, '            <Range>');
   Write_Lob___ (lob_xml_data_, buffer_, CHR(10));
   Write_Lob___ (lob_xml_data_, buffer_, '               <From>' || TO_CHAR(date_from_, date_format_) || '</From>');
   Write_Lob___ (lob_xml_data_, buffer_, CHR(10));
   Write_Lob___ (lob_xml_data_, buffer_, '               <To>' || TO_CHAR(date_to_, date_format_) || '</To>');
   Write_Lob___ (lob_xml_data_, buffer_, CHR(10));
   Write_Lob___ (lob_xml_data_, buffer_, '            </Range>');
   Write_Lob___ (lob_xml_data_, buffer_, CHR(10));
   Write_Lob___ (lob_xml_data_, buffer_, '            <Format>' || date_format_ || '</Format>');
   Write_Lob___ (lob_xml_data_, buffer_, CHR(10));
   Write_Lob___ (lob_xml_data_, buffer_, '         </Validity>');
   Write_Lob___ (lob_xml_data_, buffer_, CHR(10));
   Write_Lob___ (lob_xml_data_, buffer_, '         <DecimalSymbol>' || decimal_point_ || '</DecimalSymbol>');
   Write_Lob___ (lob_xml_data_, buffer_, CHR(10));
   Write_Lob___ (lob_xml_data_, buffer_, '         <DigitGroupingSymbol>' || thousand_separator_ || '</DigitGroupingSymbol>');
   Write_Lob___ (lob_xml_data_, buffer_, CHR(10));
   Write_Lob___ (lob_xml_data_, buffer_, '         <VariableLength>');
   Write_Lob___ (lob_xml_data_, buffer_, CHR(10));

   stmt_    := 'SELECT ';
   delim_   := '';
   date_selection_ := '';

   FOR col_rec_ IN get_column LOOP
      IF col_rec_.selection_date = 'TRUE' THEN
         date_selection_ := col_rec_.source_column;
      END IF;

      col_rec_.precision := nvl(col_rec_.precision,0);

      Write_Lob___ (lob_xml_data_, buffer_, '            <VariableColumn>');
      Write_Lob___ (lob_xml_data_, buffer_, CHR(10));
      Write_Lob___ (lob_xml_data_, buffer_, '               <Name>' || Get_Column_Translation___(view_, 'VIEW', col_rec_.source_column) || '</Name>');
      Write_Lob___ (lob_xml_data_, buffer_, CHR(10));
      IF col_rec_.datatype = '1' THEN
         Write_Lob___ (lob_xml_data_, buffer_, '               <AlphaNumeric/>');
      ELSIF col_rec_.datatype = '3' THEN
         Write_Lob___ (lob_xml_data_, buffer_, '               <Date>');
         Write_Lob___ (lob_xml_data_, buffer_, CHR(10));
         Write_Lob___ (lob_xml_data_, buffer_, '                  <Format>' || date_format_ || '</Format>');
         Write_Lob___ (lob_xml_data_, buffer_, CHR(10));
         Write_Lob___ (lob_xml_data_, buffer_, '               </Date>');
      ELSE
         IF (col_rec_.precision > 0) THEN
            Write_Lob___ (lob_xml_data_, buffer_, '               <Numeric>');
            Write_Lob___ (lob_xml_data_, buffer_, CHR(10));
            Write_Lob___ (lob_xml_data_, buffer_, '                  <Accuracy>' || TO_CHAR(col_rec_.precision) || '</Accuracy>');
            Write_Lob___ (lob_xml_data_, buffer_, CHR(10));
            Write_Lob___ (lob_xml_data_, buffer_, '               </Numeric>');
         ELSE
            Write_Lob___ (lob_xml_data_, buffer_, '               <Numeric/>');
         END IF;
      END IF;
      Write_Lob___ (lob_xml_data_, buffer_, CHR(10));
      Write_Lob___ (lob_xml_data_, buffer_, '            </VariableColumn>');
      Write_Lob___ (lob_xml_data_, buffer_, CHR(10));
   
      stmt_ := stmt_ || delim_;

      IF col_rec_.datatype = '1' THEN
         stmt_ := stmt_ || '''"'' || replace(' || col_rec_.source_column || ', ''"'', '''''''') || ''"''';
      ELSIF col_rec_.datatype = '3' THEN
         stmt_ := stmt_ || 'TO_CHAR(' || col_rec_.source_column || ', ''' || date_format_ || ''')';
      ELSIF (col_rec_.precision > 0) THEN
         stmt_ := stmt_ || 'TRIM(TO_CHAR(' || col_rec_.source_column || ', ''' || number_char_format_;
         FOR i IN 1 .. col_rec_.precision LOOP
            stmt_ := stmt_ || '9';
         END LOOP;
         stmt_ := stmt_ || ''', ''NLS_NUMERIC_CHARACTERS = ''''' || decimal_point_ || nvl(thousand_separator_,' ') || '''''''))';
      ELSE
         stmt_ := stmt_ || col_rec_.source_column;
      END IF;
      delim_ := ' || '';'' || ';

   END LOOP;
   
   stmt_ := stmt_ || ' FROM ' || view_ || ' WHERE COMPANY = :company_ ';
   IF date_selection_ IS NOT NULL THEN
      stmt_ := stmt_ || ' AND TRUNC(SELECTION_DATE) >= TRUNC(:date_from_) ';
      stmt_ := stmt_ || ' AND TRUNC(SELECTION_DATE) <= TRUNC(:date_to_) ';
      IF (ledger_id_ IS NOT NULL) THEN
         stmt_ := stmt_ || ' AND LEDGER_ID = :ledger_id_ ';
      END IF;
      stmt_ := REPLACE(stmt_, 'SELECTION_DATE', date_selection_);
   END IF;

   Write_Lob___ (lob_xml_data_, buffer_, '         </VariableLength>');
   Write_Lob___ (lob_xml_data_, buffer_, CHR(10));
   Write_Lob___ (lob_xml_data_, buffer_, '      </Table>');
   Write_Lob___ (lob_xml_data_, buffer_, CHR(10));
   Write_Lob___ (lob_xml_data_, buffer_, '   </Media>');
   Write_Lob___ (lob_xml_data_, buffer_, CHR(10));
   Write_Lob___ (lob_xml_data_, buffer_, '</DataSet>');

   IF (length(buffer_) > 0) THEN
      Dbms_Lob.WriteAppend (lob_xml_data_, length(buffer_), buffer_);
   END IF;

   buffer_ := '';

   IF (DBMS_LOB.istemporary(lob_data_) = 1) THEN
       DBMS_LOB.freetemporary(lob_data_);
   END IF;
   DBMS_LOB.createtemporary(lob_data_, TRUE);
   ctr_     := 0;
   objid_   := '';
   cursor_ := DBMS_SQL.OPEN_CURSOR;
   Assert_SYS.Assert_Is_View(view_);
   @ApproveDynamicStatement(2012-08-30,umdolk)
   DBMS_SQL.PARSE(cursor_, stmt_, DBMS_SQL.NATIVE);
   DBMS_SQL.BIND_VARIABLE(cursor_, 'company_',     company_);
   IF date_selection_ IS NOT NULL THEN
      DBMS_SQL.BIND_VARIABLE(cursor_, 'date_from_',   date_from_);
      DBMS_SQL.BIND_VARIABLE(cursor_, 'date_to_',     date_to_);
   END IF;  
   IF (ledger_id_ IS NOT NULL) THEN
      DBMS_SQL.BIND_VARIABLE(cursor_, 'ledger_id_',     ledger_id_);
   END IF;
  
   ret_ := DBMS_SQL.EXECUTE(cursor_);
   index_ := 0;
   src_cur_ := DBMS_SQL.TO_REFCURSOR(cursor_);
   LOOP
      FETCH src_cur_ INTO data_;
      EXIT WHEN src_cur_%NOTFOUND;
      ctr_ := ctr_ + 1;
      IF (ctr_ > 100000) THEN
         IF (length(buffer_) > 0) THEN
            Dbms_Lob.WriteAppend (lob_data_, length(buffer_), buffer_);
         END IF;
         Audit_Storage_API.Insert_Data (out_objid_, view_, lob_xml_data_, lob_data_);
         lob_data_arr_(index_) := lob_data_;
         index_ := index_ + 1;
         buffer_ := '';
         IF (DBMS_LOB.istemporary(lob_data_) = 1) THEN
             DBMS_LOB.freetemporary(lob_data_);
         END IF;
         DBMS_LOB.createtemporary(lob_data_, TRUE);
         objid_ := objid_ || out_objid_ || ';';
         ctr_ := 0;
      END IF;
      Write_Lob___ (lob_data_, buffer_, data_, TRUE);
      Write_Lob___ (lob_data_, buffer_, CHR(13) || CHR(10));
   END LOOP;
   CLOSE src_cur_;

   IF (length(buffer_) > 0) THEN
      Dbms_Lob.WriteAppend (lob_data_, length(buffer_), buffer_);
   END IF;
   Audit_Storage_API.Insert_Data (out_objid_, view_, lob_xml_data_, lob_data_);
   objid_ := objid_ || out_objid_ || ';';
   lob_data_arr_(index_) := lob_data_;
   IF batch_ = 'TRUE' THEN
      -- write data file
      utl_ := Open_File_Batch___( audit_format_.output_file_dir_server, view_);
      FOR i_ IN lob_data_arr_.FIRST..lob_data_arr_.LAST LOOP
         lob_data_ := lob_data_arr_(i_);
         data_len_ := DBMS_LOB.GetLength(lob_data_);
         x_ := data_len_;
         byte_len_ := 32000;
         IF data_len_ < 32760 THEN
            utl_file.put_raw( utl_, utl_raw.cast_to_raw(lob_data_));
            utl_file.fflush(utl_);
         ELSE
            from_ := 1;
            WHILE from_ < data_len_ AND byte_len_ > 0 LOOP
               temp_raw_ := substr(lob_data_, from_, byte_len_);
               utl_file.put_raw(utl_, utl_raw.cast_to_raw(temp_raw_));
               utl_file.fflush(utl_); 
               from_ := from_ + byte_len_;
               x_ := x_ - byte_len_;
               IF x_ < 32000 THEN
                  byte_len_ := x_;
               END IF;
            END LOOP;
         END IF;
      END LOOP;
      utl_file.fclose(utl_);
      -- write xml file
      utl_ := Open_File_Batch___( audit_format_.output_file_dir_server, view_ || '_I.XML');
      utl_file.put_raw( utl_, utl_raw.cast_to_raw(lob_xml_data_));
      utl_file.fflush(utl_);
      utl_file.fclose(utl_);
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      IF (DBMS_SQL.IS_OPEN(cursor_)) THEN
         DBMS_SQL.CLOSE_CURSOR(cursor_);
      END IF;
      RAISE;
END Generate_Output___;


PROCEDURE Generate_Report_Output___ (
   objid_         OUT VARCHAR2,
   company_       IN VARCHAR2,
   country_       IN VARCHAR2,
   view_          IN VARCHAR2,
   report_attr_   IN VARCHAR2,
   report_param_  IN VARCHAR2,
   batch_         IN VARCHAR2 DEFAULT 'FALSE' )
IS
   lob_xml_data_        CLOB;
   lob_data_            CLOB;
   temp_raw_            CLOB;
   utl_                 utl_file.file_type;
   src_cur_             SYS_REFCURSOR;
   cursor_              NUMBER;
   ret_                 NUMBER;
   data_                VARCHAR2(32000);
   buffer_              VARCHAR2(32000);
   country_db_          VARCHAR2(2);
   company_name_        company.name%TYPE;
   company_city_        company_address.city%TYPE;
   addr_id_             company_address.address_id%TYPE;
   audit_format_        Audit_Format_API.Public_Rec;
   decimal_point_       VARCHAR2(1);
   thousand_separator_  VARCHAR2(1);
   date_format_         VARCHAR2(20);
   stmt_                VARCHAR2(32000);
   delim_               VARCHAR2(20);
   --data_type_           VARCHAR2(1);
   result_key_          NUMBER;
   data_len_            NUMBER;
   byte_len_            NUMBER;
   from_                NUMBER;
   x_                   NUMBER;
   number_char_format_  VARCHAR2(20);
   ctr_                 NUMBER;
   out_objid_           VARCHAR2(200);
   index_               NUMBER;
   TYPE t_lob IS TABLE OF CLOB INDEX BY BINARY_INTEGER;
   lob_data_arr_        t_lob;
   CURSOR get_column IS
      SELECT *
        FROM audit_source_column_tab
       WHERE audit_source = view_;
BEGIN
   buffer_              := '';
   country_db_          := Iso_Country_API.Encode(country_);
   addr_id_             := Company_Address_API.Get_Default_Address (company_, Address_Type_Code_API.Decode('INVOICE'));
   company_name_        := Company_API.Get_Name(company_);
   company_city_        := Company_Address_API.Get_City(company_, addr_id_);
   audit_format_        := Audit_Format_API.Get(company_, country_db_, 'GDPdU');
   decimal_point_       := Audit_Decimal_API.Get_Value(audit_format_.decimal_point);
   IF (audit_format_.thousand_separator = 3) THEN
      thousand_separator_ := NULL;
   ELSIF (audit_format_.thousand_separator = 2) THEN
      thousand_separator_ := ' ';
   ELSE
      thousand_separator_  := Audit_Decimal_API.Get_Value(audit_format_.thousand_separator);
   END IF;
   IF (thousand_separator_ IS NULL) THEN
      number_char_format_ := '999999999999D';
   ELSE
      number_char_format_ := '9G999G999G999D';
   END IF;
   date_format_         := Audit_Date_Format_API.Get_Value(audit_format_.date_format);

   Archive_API.New_Client_Report( result_key_, report_attr_, report_param_, NULL, NULL);

   IF (DBMS_LOB.istemporary(lob_xml_data_) = 1) THEN
       DBMS_LOB.freetemporary(lob_xml_data_);
   END IF;
   DBMS_LOB.createtemporary(lob_xml_data_, TRUE);

   Write_Lob___ (lob_xml_data_, buffer_, '<?xml version="1.0" encoding="UTF-8"?>');
   Write_Lob___ (lob_xml_data_, buffer_, CHR(10));
   Write_Lob___ (lob_xml_data_, buffer_, '<!DOCTYPE DataSet SYSTEM "GDPDU-01-08-2002.dtd">');
   Write_Lob___ (lob_xml_data_, buffer_, CHR(10));
   Write_Lob___ (lob_xml_data_, buffer_, '<DataSet>');
   Write_Lob___ (lob_xml_data_, buffer_, CHR(10));
   Write_Lob___ (lob_xml_data_, buffer_, '   <Version>1.0</Version>');
   Write_Lob___ (lob_xml_data_, buffer_, CHR(10));
   IF (company_name_ IS NOT NULL) THEN
      Write_Lob___ (lob_xml_data_, buffer_, '      <DataSupplier>');
      Write_Lob___ (lob_xml_data_, buffer_, CHR(10));
      Write_Lob___ (lob_xml_data_, buffer_, '         <Name>' || Filter_Text___(company_name_) || '</Name>');
      Write_Lob___ (lob_xml_data_, buffer_, CHR(10));
      Write_Lob___ (lob_xml_data_, buffer_, '         <Location>' || Filter_Text___(company_city_) || '</Location>');
      Write_Lob___ (lob_xml_data_, buffer_, CHR(10));
      Write_Lob___ (lob_xml_data_, buffer_, '         <Comment>Datentraegerueberlassung nach GDPdU aus IFS Applications</Comment>');
      Write_Lob___ (lob_xml_data_, buffer_, CHR(10));
      Write_Lob___ (lob_xml_data_, buffer_, '      </DataSupplier>');
      Write_Lob___ (lob_xml_data_, buffer_, CHR(10));
   END IF;
   Write_Lob___ (lob_xml_data_, buffer_, '   <Media>');
   Write_Lob___ (lob_xml_data_, buffer_, CHR(10));
   Write_Lob___ (lob_xml_data_, buffer_, '      <Name>' || view_ || '</Name>');
   Write_Lob___ (lob_xml_data_, buffer_, CHR(10));
   Write_Lob___ (lob_xml_data_, buffer_, '      <Table>');
   Write_Lob___ (lob_xml_data_, buffer_, CHR(10));
   Write_Lob___ (lob_xml_data_, buffer_, '         <URL>' || view_ || '</URL>');
   Write_Lob___ (lob_xml_data_, buffer_, CHR(10));
   Write_Lob___ (lob_xml_data_, buffer_, '         <DecimalSymbol>' || decimal_point_ || '</DecimalSymbol>');
   Write_Lob___ (lob_xml_data_, buffer_, CHR(10));
   Write_Lob___ (lob_xml_data_, buffer_, '         <DigitGroupingSymbol>' || thousand_separator_ || '</DigitGroupingSymbol>');
   Write_Lob___ (lob_xml_data_, buffer_, CHR(10));
   Write_Lob___ (lob_xml_data_, buffer_, '         <VariableLength>');
   Write_Lob___ (lob_xml_data_, buffer_, CHR(10));

   stmt_    := 'SELECT ';
   delim_   := '';

   FOR col_rec_ IN get_column LOOP
      col_rec_.precision := nvl(col_rec_.precision,0);

      Write_Lob___ (lob_xml_data_, buffer_, '            <VariableColumn>');
      Write_Lob___ (lob_xml_data_, buffer_, CHR(10));
      Write_Lob___ (lob_xml_data_, buffer_, '               <Name>' || Get_Column_Translation___(view_, 'REPORT', col_rec_.source_column) || '</Name>');
      Write_Lob___ (lob_xml_data_, buffer_, CHR(10));
      IF col_rec_.datatype = '1' THEN
         Write_Lob___ (lob_xml_data_, buffer_, '               <AlphaNumeric/>');
      ELSIF col_rec_.datatype = '3' THEN
         Write_Lob___ (lob_xml_data_, buffer_, '               <Date>');
         Write_Lob___ (lob_xml_data_, buffer_, CHR(10));
         Write_Lob___ (lob_xml_data_, buffer_, '                  <Format>' || date_format_ || '</Format>');
         Write_Lob___ (lob_xml_data_, buffer_, CHR(10));
         Write_Lob___ (lob_xml_data_, buffer_, '               </Date>');
      ELSE
         IF (col_rec_.precision > 0) THEN
            Write_Lob___ (lob_xml_data_, buffer_, '               <Numeric>');
            Write_Lob___ (lob_xml_data_, buffer_, CHR(10));
            Write_Lob___ (lob_xml_data_, buffer_, '                  <Accuracy>' || TO_CHAR(col_rec_.precision) || '</Accuracy>');
            Write_Lob___ (lob_xml_data_, buffer_, CHR(10));
            Write_Lob___ (lob_xml_data_, buffer_, '               </Numeric>');
         ELSE
            Write_Lob___ (lob_xml_data_, buffer_, '               <Numeric/>');
         END IF;
      END IF;
      Write_Lob___ (lob_xml_data_, buffer_, CHR(10));
      Write_Lob___ (lob_xml_data_, buffer_, '            </VariableColumn>');
      Write_Lob___ (lob_xml_data_, buffer_, CHR(10));
   
      stmt_ := stmt_ || delim_;

      IF col_rec_.datatype = '1' THEN
         stmt_ := stmt_ || '''"'' || replace(' || col_rec_.source_column || ', ''"'', '''''''') || ''"''';
      ELSIF col_rec_.datatype = '3' THEN
         stmt_ := stmt_ || 'TO_CHAR(' || col_rec_.source_column || ', ''' || date_format_ || ''')';
      ELSIF (col_rec_.precision > 0) THEN
         stmt_ := stmt_ || 'TRIM(TO_CHAR(' || col_rec_.source_column || ', ''' || number_char_format_;
         FOR i IN 1 .. col_rec_.precision LOOP
            stmt_ := stmt_ || '9';
         END LOOP;
         stmt_ := stmt_ || ''', ''NLS_NUMERIC_CHARACTERS = ''''' || decimal_point_ || nvl(thousand_separator_,' ') || '''''''))';
      ELSE
         stmt_ := stmt_ || col_rec_.source_column;
      END IF;
      delim_ := ' || '';'' || ';

   END LOOP;
   
   stmt_ := stmt_ || ' FROM ' || view_ || ' WHERE RESULT_KEY = ' || TO_CHAR(result_key_);

   Write_Lob___ (lob_xml_data_, buffer_,  '         </VariableLength>');
   Write_Lob___ (lob_xml_data_, buffer_,  CHR(10));
   Write_Lob___ (lob_xml_data_, buffer_,  '      </Table>');
   Write_Lob___ (lob_xml_data_, buffer_,  CHR(10));
   Write_Lob___ (lob_xml_data_, buffer_,  '   </Media>');
   Write_Lob___ (lob_xml_data_, buffer_,  CHR(10));
   Write_Lob___ (lob_xml_data_, buffer_,  '</DataSet>');

   IF (length(buffer_) > 0) THEN
      Dbms_Lob.WriteAppend (lob_xml_data_, length(buffer_), buffer_);
   END IF;

   buffer_ := '';
   ctr_    := 0;
   objid_  := '';

   IF (DBMS_LOB.istemporary(lob_data_) = 1) THEN
       DBMS_LOB.freetemporary(lob_data_);
   END IF;
   DBMS_LOB.createtemporary(lob_data_, TRUE);

   cursor_ := DBMS_SQL.OPEN_CURSOR;
   Assert_SYS.Assert_Is_View(view_);
   @ApproveDynamicStatement(2012-08-30,umdolk)
   DBMS_SQL.PARSE(cursor_, stmt_, DBMS_SQL.NATIVE);
  
   ret_ := DBMS_SQL.EXECUTE(cursor_);
   index_ := 0;
   src_cur_ := DBMS_SQL.TO_REFCURSOR(cursor_);
   LOOP
      FETCH src_cur_ INTO data_;
      EXIT WHEN src_cur_%NOTFOUND;
      ctr_ := ctr_ + 1;
      IF (ctr_ > 100000) THEN
         IF (length(buffer_) > 0) THEN
            Dbms_Lob.WriteAppend (lob_data_, length(buffer_), buffer_);
         END IF;
         Audit_Storage_API.Insert_Data (out_objid_, view_, lob_xml_data_, lob_data_);
         lob_data_arr_(index_) := lob_data_;
         index_ := index_ + 1;
         buffer_ := '';
         IF (DBMS_LOB.istemporary(lob_data_) = 1) THEN
             DBMS_LOB.freetemporary(lob_data_);
         END IF;
         DBMS_LOB.createtemporary(lob_data_, TRUE);
         objid_ := objid_ || out_objid_ || ';';
         ctr_ := 0;
      END IF;
      Write_Lob___ (lob_data_, buffer_, data_, TRUE);
      Write_Lob___ (lob_data_, buffer_, CHR(13) || CHR(10));
   END LOOP;
   CLOSE src_cur_;

   IF (length(buffer_) > 0) THEN
      Dbms_Lob.WriteAppend (lob_data_, length(buffer_), buffer_);
   END IF;

   Audit_Storage_API.Insert_Data (out_objid_, view_, lob_xml_data_, lob_data_);
   objid_ := objid_ || out_objid_ || ';';
   lob_data_arr_(index_) := lob_data_;

   IF batch_ = 'TRUE' THEN
      -- write data file
      utl_ := Open_File_Batch___( audit_format_.output_file_dir_server, view_ );
      FOR i_ IN lob_data_arr_.FIRST..lob_data_arr_.LAST LOOP
         lob_data_ := lob_data_arr_(i_);
         data_len_ := DBMS_LOB.GetLength(lob_data_);
         x_ := data_len_;
         byte_len_ := 32000;
         IF data_len_ < 32760 THEN
            utl_file.put_raw( utl_, utl_raw.cast_to_raw(lob_data_));
            utl_file.fflush(utl_);
         ELSE
            from_ := 1;
            WHILE from_ < data_len_ AND byte_len_ > 0 LOOP
               temp_raw_ := substr(lob_data_, from_, byte_len_);
               utl_file.put_raw(utl_, utl_raw.cast_to_raw(temp_raw_));
               utl_file.fflush(utl_); 
               from_ := from_ + byte_len_;
               x_ := x_ - byte_len_;
               IF x_ < 32000 THEN
                  byte_len_ := x_;
               END IF;
            END LOOP;
         END IF;
      END LOOP;
      utl_file.fclose(utl_);
      -- write xml file
      utl_ := Open_File_Batch___( audit_format_.output_file_dir_server, view_ || '_I.XML');
      utl_file.put_raw( utl_, utl_raw.cast_to_raw(lob_xml_data_));
      utl_file.fflush(utl_);
      utl_file.fclose(utl_);
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      IF (DBMS_SQL.IS_OPEN(cursor_)) THEN
         DBMS_SQL.CLOSE_CURSOR(cursor_);
      END IF;
      RAISE;
END Generate_Report_Output___;

FUNCTION Remove_New_Line_Char___(
   data_ IN VARCHAR2) RETURN VARCHAR2
IS
   ret_str_ VARCHAR2(32000);
BEGIN
   ret_str_ := REPLACE(data_ , CHR(13)||CHR(10), ' ');
   ret_str_ := REPLACE(ret_str_ , CHR(13), ' ');
   ret_str_ := REPLACE(ret_str_ , CHR(10), ' ');
   RETURN ret_str_;
END Remove_New_Line_Char___;

FUNCTION Open_File_Batch___(
   dir_path_      Audit_Format_Tab.output_file_dir_server%TYPE,
   file_name_     VARCHAR2) RETURN utl_file.file_type 
IS
   utl_  utl_file.file_type;
BEGIN
   utl_ := utl_file.fopen( dir_path_ , file_name_, 'wb', max_linesize => 32767 );
   RETURN utl_;
EXCEPTION
   WHEN OTHERS THEN
      Error_SYS.Appl_General( lu_name_, 'UTLINVPATH: Invalid File Path (:P1) ', dir_path_);
      Ext_File_Server_Util_API.Close_External_File (utl_);
END Open_File_Batch___;
-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------

PROCEDURE Generate_Output_Batch__ (
   attr_          IN VARCHAR2 )
IS
   objid_         VARCHAR2(20000);
   country_       VARCHAR2(100);
   view_          VARCHAR2(30);
   company_       VARCHAR2(20);
   date_from_     DATE;
   date_to_       DATE;
   ledger_id_     VARCHAR2(20);
BEGIN
   
   country_    := Client_SYS.Get_Item_Value('COUNTRY', attr_);
   view_       := Client_SYS.Get_Item_Value('VIEW', attr_);
   company_    := Client_SYS.Get_Item_Value('COMPANY', attr_);
   date_from_  := Client_SYS.Get_Item_Value_To_Date('DATE_FROM', attr_, lu_name_);
   date_to_    := Client_SYS.Get_Item_Value_To_Date('DATE_TO', attr_, lu_name_);
   ledger_id_  := Client_SYS.Get_Item_Value('LEDGER_ID', attr_);
   Generate_Output___ (objid_, country_, view_, company_, date_from_, date_to_, 'TRUE', ledger_id_);
END Generate_Output_Batch__;


PROCEDURE Generate_Rep_Output_Batch__ (
   attr_          IN VARCHAR2 )
IS
   objid_         VARCHAR2(20000);
   country_       VARCHAR2(100);
   view_          VARCHAR2(30);
   company_       VARCHAR2(20);
   report_attr_   VARCHAR2(2000);
   report_param_  VARCHAR2(2000);
BEGIN
   
   Message_SYS.Get_Attribute(attr_, 'COMPANY', company_);
   Message_SYS.Get_Attribute(attr_, 'COUNTRY', country_);
   Message_SYS.Get_Attribute(attr_, 'VIEW', view_);
   Message_SYS.Get_Attribute(attr_, 'REPORT_ATTR', report_attr_);
   report_param_ := Message_SYS.Find_Attribute(attr_, 'REPORT_PARAM','');
   Generate_Report_Output___ (objid_, company_, country_, view_, report_attr_, report_param_, 'TRUE');
END Generate_Rep_Output_Batch__;


-------------------- LU SPECIFIC PROTECTED METHODS --------------------------

-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

@UncheckedAccess
FUNCTION Get_Column_Translation(
   audit_source_    IN VARCHAR2,
   audit_type_db_   IN VARCHAR2,
   column_id_           IN VARCHAR2) RETURN VARCHAR2
IS
BEGIN
   RETURN Get_Column_Translation___(audit_source_,
                                    audit_type_db_,
                                    column_id_);
END Get_Column_Translation;




PROCEDURE Generate_Output (
   objid_         OUT VARCHAR2,
   job_id_        OUT NUMBER,
   country_       IN VARCHAR2,
   view_          IN VARCHAR2,
   company_       IN VARCHAR2,
   date_from_     IN DATE,
   date_to_       IN DATE,
   batch_         IN VARCHAR2 DEFAULT 'FALSE',
   ledger_id_     IN VARCHAR2 DEFAULT NULL )
IS
   attr_          VARCHAR2(2000);
   desc_          VARCHAR2(200);
BEGIN

   IF batch_ = 'FALSE' THEN
      Generate_Output___ (objid_, country_, view_, company_, date_from_, date_to_, 'FALSE', ledger_id_);
   ELSE
      attr_ := NULL;
      Client_SYS.Add_To_Attr('COUNTRY', country_, attr_);
      Client_SYS.Add_To_Attr('VIEW', view_, attr_);
      Client_SYS.Add_To_Attr('COMPANY', company_, attr_);
      Client_SYS.Add_To_Attr('DATE_FROM', date_from_, attr_);
      Client_SYS.Add_To_Attr('DATE_TO', date_to_, attr_);
      Client_SYS.Add_To_Attr('LEDGER_ID', ledger_id_, attr_);
      desc_ := Language_SYS.Translate_Constant(lu_name_, 'AUDITBATCHDESC: Generate Audit.');
      Transaction_SYS.Deferred_Call(job_id_, 'Audit_Util_API.Generate_Output_Batch__', 'ATTRIBUTE', attr_, desc_);
   END IF;
END Generate_Output;


PROCEDURE Generate_Report_Output (
   objid_         OUT VARCHAR2,
   job_id_        OUT NUMBER,
   company_       IN VARCHAR2,
   country_       IN VARCHAR2,
   view_          IN VARCHAR2,
   report_attr_   IN VARCHAR2,
   report_param_  IN VARCHAR2,
   batch_         IN VARCHAR2 DEFAULT 'FALSE' )
IS
   attr_          VARCHAR2(2000);
   desc_          VARCHAR2(200);
BEGIN

   IF batch_ = 'FALSE' THEN
      Generate_Report_Output___ (objid_, company_, country_, view_, report_attr_, report_param_, 'FALSE');
   ELSE
      attr_ := Message_SYS.Construct('');
      Message_SYS.Add_Attribute( attr_, 'COMPANY', company_);
      Message_SYS.Add_Attribute( attr_, 'COUNTRY', country_);
      Message_SYS.Add_Attribute( attr_, 'VIEW', view_);
      Message_SYS.Add_Attribute( attr_, 'REPORT_ATTR', report_attr_);
      Message_SYS.Add_Attribute( attr_, 'REPORT_PARAM', report_param_);
      desc_ := Language_SYS.Translate_Constant(lu_name_, 'AUDITBATCHDESC: Generate Audit.');
      Transaction_SYS.Deferred_Call(job_id_, 'Audit_Util_API.Generate_Rep_Output_Batch__', 'ATTRIBUTE', attr_, desc_);
      --Audit_Util_API.Generate_Rep_Output_Batch__ (attr_);
   END IF;
END Generate_Report_Output;

PROCEDURE Remove_Audit_Source(
   audit_source_  IN VARCHAR2) 
IS
BEGIN
   
   Assert_SYS.Assert_Is_View(audit_source_);
   
   DELETE 
   FROM   Audit_Source_Column_Tab 
   WHERE  audit_source = audit_source_;

   DELETE 
   FROM   Audit_Source_Tab 
   WHERE  audit_source = audit_source_;

   DELETE
   FROM   language_sys_tab t
   WHERE  module    = 'ACCRUL'
   AND    path      = 'AuditSource_ACCRUL.'||audit_source_
   AND    type      = 'Basic Data'
   AND    lang_code = 'PROG';

   DELETE
   FROM   language_sys_tab t
   WHERE  module    = 'ACCRUL'
   AND    path      LIKE 'AuditSourceColumn_ACCRUL.'||audit_source_||'%'
   AND    type      = 'Basic Data'
   AND    lang_code = 'PROG'; 
END Remove_Audit_Source;
