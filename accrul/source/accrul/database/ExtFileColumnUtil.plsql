-----------------------------------------------------------------------------
--
--  Logical unit: ExtFileColumnUtil
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  021031  PPerse  Created
--  031020  Brwelk  Init_Method Corrections
--  040805  Jeguse  IID FIHJP335. Modified function Str_To_Date.
--  061212  Kagalk  LCS Merge 61676, Added error message to FUNCTION Str_To_Number
--  070430  JARALK  LCS Merge 64537.
--  080922  Jeguse  Bug 77126, Taken care of new anonymous column
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------

-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------

-------------------- LU SPECIFIC PROTECTED METHODS --------------------------

-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

FUNCTION Str_To_Date (
   str_               IN VARCHAR2,
   date_format_       IN VARCHAR2 DEFAULT NULL,
   date_nls_calendar_ IN VARCHAR2 DEFAULT NULL ) RETURN DATE
IS
   format_               VARCHAR2(30);
   string_               VARCHAR2(100);
   date_nls_calendarx_   VARCHAR2(100);
BEGIN
   format_ := NVL(date_format_,Accrul_Attribute_API.Get_Attribute_Value('DEFAULT_X_DATE_FORMAT'));
   IF (date_nls_calendar_ IS NULL) THEN
      RETURN (TO_DATE(str_, format_));
   ELSE
      date_nls_calendarx_ := 'NLS_CALENDAR='||CHR(39)||date_nls_calendar_||CHR(39);
      SELECT TO_DATE(str_, format_, date_nls_calendarx_)
      INTO   string_
      FROM   dual;
      RETURN string_;
   END IF;
END Str_To_Date;


FUNCTION Str_To_Number (
   str_            IN VARCHAR2,
   decimal_symbol_ IN VARCHAR2 DEFAULT NULL ) RETURN NUMBER
IS
   strx_              VARCHAR2(100);
   decimal_           VARCHAR2(5);
   result_            NUMBER;
BEGIN
   decimal_ := NVL(decimal_symbol_, Accrul_Attribute_API.Get_Attribute_Value('DEFAULT_X_DECIMAL_SYMBOL'));
   strx_    := str_;
   IF (SUBSTR(strx_,-1) = '-') THEN
      strx_ := '-' || SUBSTR(strx_,1,LENGTH(strx_)-1);
   END IF;

   BEGIN
      result_        := TO_NUMBER(strx_);
   EXCEPTION
      WHEN OTHERS THEN
         IF (INSTR(strx_,decimal_) > 0) THEN
            strx_    := REPLACE(strx_,decimal_,'.');
         ELSE
            Error_SYS.record_general(lu_name_, 'INVDECSYMBOL:  Invalid value format or invalid Decimal Symbol in the Loaded File.');
            strx_    := REPLACE(strx_,'.',decimal_);
         END IF;
         result_     := TO_NUMBER(strx_);
   END;
   RETURN result_;
END Str_To_Number;


FUNCTION Str_To_Number2 (
   str_                IN VARCHAR2,
   denominator_        IN NUMBER DEFAULT NULL ) RETURN NUMBER
IS
   decimals_              NUMBER;
   strx_                  VARCHAR2(100);
BEGIN
   strx_    := str_;
   IF (SUBSTR(strx_,-1) = '-') THEN
      strx_ := '-' || SUBSTR(strx_,1,LENGTH(strx_)-1);
   END IF;
   IF (denominator_ IS NOT NULL) THEN
      decimals_ := denominator_;
   ELSE
      decimals_ := 1;
   END IF;
   RETURN (TO_NUMBER(strx_) / decimals_);
END Str_To_Number2;


FUNCTION Number_To_Str (
   number_         IN NUMBER,
   decimal_symbol_ IN VARCHAR2 DEFAULT NULL ) RETURN VARCHAR2
IS
   decimal_           VARCHAR2(5);
   char_value_        VARCHAR2(100);
BEGIN
   char_value_ := TO_CHAR(number_);
   decimal_ := NVL(decimal_symbol_, Accrul_Attribute_API.Get_Attribute_Value('DEFAULT_X_DECIMAL_SYMBOL'));
   IF (INSTR(char_value_,decimal_) > 0) THEN
      RETURN char_value_;
   ELSE
      IF (INSTR(char_value_,'.') > 0) THEN
         RETURN REPLACE(char_value_,'.',decimal_);
      ELSIF (INSTR(char_value_,',') > 0) THEN
         RETURN REPLACE(char_value_,',',decimal_);
      ELSE
         RETURN char_value_;
      END IF;
   END IF;
END Number_To_Str;


FUNCTION Number_To_Str2 (
   number_             IN NUMBER,
   denominator_        IN NUMBER DEFAULT NULL ) RETURN VARCHAR2
IS
   decimals_              NUMBER;
   char_value_            VARCHAR2(100);
BEGIN
   IF (NVL(number_,0) = 0) THEN
      RETURN '0';
   END IF;
   IF (denominator_ IS NOT NULL) THEN
      decimals_ := denominator_;
   ELSE
      decimals_ := 1;
   END IF;
   char_value_ := TO_CHAR(ROUND(number_ * decimals_));
   RETURN char_value_;
END Number_To_Str2;


FUNCTION Date_To_Str (
   date_        IN DATE,
   date_format_ IN VARCHAR2 DEFAULT NULL ) RETURN VARCHAR2
IS
   format_         VARCHAR2(30);
BEGIN
   format_ := NVL(date_format_,Accrul_Attribute_API.Get_Attribute_Value('DEFAULT_X_DATE_FORMAT'));
   RETURN (TO_CHAR(date_, format_));
END Date_To_Str;


FUNCTION Return_N_Value (
   destination_column_    IN VARCHAR2,
   transrec_              IN Ext_File_Trans_Tab%ROWTYPE ) RETURN NUMBER
IS
BEGIN
   IF    (destination_column_ = 'N1')  THEN RETURN transrec_.n1;
   ELSIF (destination_column_ = 'N2')  THEN RETURN transrec_.n2;
   ELSIF (destination_column_ = 'N3')  THEN RETURN transrec_.n3;
   ELSIF (destination_column_ = 'N4')  THEN RETURN transrec_.n4;
   ELSIF (destination_column_ = 'N5')  THEN RETURN transrec_.n5;
   ELSIF (destination_column_ = 'N6')  THEN RETURN transrec_.n6;
   ELSIF (destination_column_ = 'N7')  THEN RETURN transrec_.n7;
   ELSIF (destination_column_ = 'N8')  THEN RETURN transrec_.n8;
   ELSIF (destination_column_ = 'N9')  THEN RETURN transrec_.n9;
   ELSIF (destination_column_ = 'N10') THEN RETURN transrec_.n10;
   ELSIF (destination_column_ = 'N11') THEN RETURN transrec_.n11;
   ELSIF (destination_column_ = 'N12') THEN RETURN transrec_.n12;
   ELSIF (destination_column_ = 'N13') THEN RETURN transrec_.n13;
   ELSIF (destination_column_ = 'N14') THEN RETURN transrec_.n14;
   ELSIF (destination_column_ = 'N15') THEN RETURN transrec_.n15;
   ELSIF (destination_column_ = 'N16') THEN RETURN transrec_.n16;
   ELSIF (destination_column_ = 'N17') THEN RETURN transrec_.n17;
   ELSIF (destination_column_ = 'N18') THEN RETURN transrec_.n18;
   ELSIF (destination_column_ = 'N19') THEN RETURN transrec_.n19;
   ELSIF (destination_column_ = 'N20') THEN RETURN transrec_.n20;
   ELSIF (destination_column_ = 'N21') THEN RETURN transrec_.n21;
   ELSIF (destination_column_ = 'N22') THEN RETURN transrec_.n22;
   ELSIF (destination_column_ = 'N23') THEN RETURN transrec_.n23;
   ELSIF (destination_column_ = 'N24') THEN RETURN transrec_.n24;
   ELSIF (destination_column_ = 'N25') THEN RETURN transrec_.n25;
   ELSIF (destination_column_ = 'N26') THEN RETURN transrec_.n26;
   ELSIF (destination_column_ = 'N27') THEN RETURN transrec_.n27;
   ELSIF (destination_column_ = 'N28') THEN RETURN transrec_.n28;
   ELSIF (destination_column_ = 'N29') THEN RETURN transrec_.n29;
   ELSIF (destination_column_ = 'N30') THEN RETURN transrec_.n30;
   ELSIF (destination_column_ = 'N31') THEN RETURN transrec_.n31;
   ELSIF (destination_column_ = 'N32') THEN RETURN transrec_.n32;
   ELSIF (destination_column_ = 'N33') THEN RETURN transrec_.n33;
   ELSIF (destination_column_ = 'N34') THEN RETURN transrec_.n34;
   ELSIF (destination_column_ = 'N35') THEN RETURN transrec_.n35;
   ELSIF (destination_column_ = 'N36') THEN RETURN transrec_.n36;
   ELSIF (destination_column_ = 'N37') THEN RETURN transrec_.n37;
   ELSIF (destination_column_ = 'N38') THEN RETURN transrec_.n38;
   ELSIF (destination_column_ = 'N39') THEN RETURN transrec_.n39;
   ELSIF (destination_column_ = 'N40') THEN RETURN transrec_.n40;
   ELSIF (destination_column_ = 'N41') THEN RETURN transrec_.n41;
   ELSIF (destination_column_ = 'N42') THEN RETURN transrec_.n42;
   ELSIF (destination_column_ = 'N43') THEN RETURN transrec_.n43;
   ELSIF (destination_column_ = 'N44') THEN RETURN transrec_.n44;
   ELSIF (destination_column_ = 'N45') THEN RETURN transrec_.n45;
   ELSIF (destination_column_ = 'N46') THEN RETURN transrec_.n46;
   ELSIF (destination_column_ = 'N47') THEN RETURN transrec_.n47;
   ELSIF (destination_column_ = 'N48') THEN RETURN transrec_.n48;
   ELSIF (destination_column_ = 'N49') THEN RETURN transrec_.n49;
   ELSIF (destination_column_ = 'N50') THEN RETURN transrec_.n50;
   ELSIF (destination_column_ = 'N51') THEN RETURN transrec_.n51;
   ELSIF (destination_column_ = 'N52') THEN RETURN transrec_.n52;
   ELSIF (destination_column_ = 'N53') THEN RETURN transrec_.n53;
   ELSIF (destination_column_ = 'N54') THEN RETURN transrec_.n54;
   ELSIF (destination_column_ = 'N55') THEN RETURN transrec_.n55;
   ELSIF (destination_column_ = 'N56') THEN RETURN transrec_.n56;
   ELSIF (destination_column_ = 'N57') THEN RETURN transrec_.n57;
   ELSIF (destination_column_ = 'N58') THEN RETURN transrec_.n58;
   ELSIF (destination_column_ = 'N59') THEN RETURN transrec_.n59;
   ELSIF (destination_column_ = 'N60') THEN RETURN transrec_.n60;
   ELSIF (destination_column_ = 'N61') THEN RETURN transrec_.n61;
   ELSIF (destination_column_ = 'N62') THEN RETURN transrec_.n62;
   ELSIF (destination_column_ = 'N63') THEN RETURN transrec_.n63;
   ELSIF (destination_column_ = 'N64') THEN RETURN transrec_.n64;
   ELSIF (destination_column_ = 'N65') THEN RETURN transrec_.n65;
   ELSIF (destination_column_ = 'N66') THEN RETURN transrec_.n66;
   ELSIF (destination_column_ = 'N67') THEN RETURN transrec_.n67;
   ELSIF (destination_column_ = 'N68') THEN RETURN transrec_.n68;
   ELSIF (destination_column_ = 'N69') THEN RETURN transrec_.n69;
   ELSIF (destination_column_ = 'N70') THEN RETURN transrec_.n70;
   ELSIF (destination_column_ = 'N71') THEN RETURN transrec_.n71;
   ELSIF (destination_column_ = 'N72') THEN RETURN transrec_.n72;
   ELSIF (destination_column_ = 'N73') THEN RETURN transrec_.n73;
   ELSIF (destination_column_ = 'N74') THEN RETURN transrec_.n74;
   ELSIF (destination_column_ = 'N75') THEN RETURN transrec_.n75;
   ELSIF (destination_column_ = 'N76') THEN RETURN transrec_.n76;
   ELSIF (destination_column_ = 'N77') THEN RETURN transrec_.n77;
   ELSIF (destination_column_ = 'N78') THEN RETURN transrec_.n78;
   ELSIF (destination_column_ = 'N79') THEN RETURN transrec_.n79;
   ELSIF (destination_column_ = 'N80') THEN RETURN transrec_.n80;
   ELSIF (destination_column_ = 'N81') THEN RETURN transrec_.n81;
   ELSIF (destination_column_ = 'N82') THEN RETURN transrec_.n82;
   ELSIF (destination_column_ = 'N83') THEN RETURN transrec_.n83;
   ELSIF (destination_column_ = 'N84') THEN RETURN transrec_.n84;
   ELSIF (destination_column_ = 'N85') THEN RETURN transrec_.n85;
   ELSIF (destination_column_ = 'N86') THEN RETURN transrec_.n86;
   ELSIF (destination_column_ = 'N87') THEN RETURN transrec_.n87;
   ELSIF (destination_column_ = 'N88') THEN RETURN transrec_.n88;
   ELSIF (destination_column_ = 'N89') THEN RETURN transrec_.n89;
   ELSIF (destination_column_ = 'N90') THEN RETURN transrec_.n90;
   ELSIF (destination_column_ = 'N91') THEN RETURN transrec_.n91;
   ELSIF (destination_column_ = 'N92') THEN RETURN transrec_.n92;
   ELSIF (destination_column_ = 'N93') THEN RETURN transrec_.n93;
   ELSIF (destination_column_ = 'N94') THEN RETURN transrec_.n94;
   ELSIF (destination_column_ = 'N95') THEN RETURN transrec_.n95;
   ELSIF (destination_column_ = 'N96') THEN RETURN transrec_.n96;
   ELSIF (destination_column_ = 'N97') THEN RETURN transrec_.n97;
   ELSIF (destination_column_ = 'N98') THEN RETURN transrec_.n98;
   ELSIF (destination_column_ = 'N99') THEN RETURN transrec_.n99;
   ELSIF (destination_column_ = 'N0')  THEN RETURN transrec_.n0;
   ELSE 
      RETURN NULL;
   END IF;
END Return_N_Value;


PROCEDURE Put_N_Value (
   destination_column_    IN     VARCHAR2,
   value_                 IN     NUMBER,
   transrec_              IN OUT Ext_File_Trans_Tab%ROWTYPE )
IS
BEGIN
   IF    (destination_column_ = 'N1')  THEN transrec_.n1  := value_;
   ELSIF (destination_column_ = 'N2')  THEN transrec_.n2  := value_;
   ELSIF (destination_column_ = 'N3')  THEN transrec_.n3  := value_;
   ELSIF (destination_column_ = 'N4')  THEN transrec_.n4  := value_;
   ELSIF (destination_column_ = 'N5')  THEN transrec_.n5  := value_;
   ELSIF (destination_column_ = 'N6')  THEN transrec_.n6  := value_;
   ELSIF (destination_column_ = 'N7')  THEN transrec_.n7  := value_;
   ELSIF (destination_column_ = 'N8')  THEN transrec_.n8  := value_;
   ELSIF (destination_column_ = 'N9')  THEN transrec_.n9  := value_;
   ELSIF (destination_column_ = 'N10') THEN transrec_.n10 := value_;
   ELSIF (destination_column_ = 'N11') THEN transrec_.n11 := value_;
   ELSIF (destination_column_ = 'N12') THEN transrec_.n12 := value_;
   ELSIF (destination_column_ = 'N13') THEN transrec_.n13 := value_;
   ELSIF (destination_column_ = 'N14') THEN transrec_.n14 := value_;
   ELSIF (destination_column_ = 'N15') THEN transrec_.n15 := value_;
   ELSIF (destination_column_ = 'N16') THEN transrec_.n16 := value_;
   ELSIF (destination_column_ = 'N17') THEN transrec_.n17 := value_;
   ELSIF (destination_column_ = 'N18') THEN transrec_.n18 := value_;
   ELSIF (destination_column_ = 'N19') THEN transrec_.n19 := value_;
   ELSIF (destination_column_ = 'N20') THEN transrec_.n20 := value_;
   ELSIF (destination_column_ = 'N21') THEN transrec_.n21 := value_;
   ELSIF (destination_column_ = 'N22') THEN transrec_.n22 := value_;
   ELSIF (destination_column_ = 'N23') THEN transrec_.n23 := value_;
   ELSIF (destination_column_ = 'N24') THEN transrec_.n24 := value_;
   ELSIF (destination_column_ = 'N25') THEN transrec_.n25 := value_;
   ELSIF (destination_column_ = 'N26') THEN transrec_.n26 := value_;
   ELSIF (destination_column_ = 'N27') THEN transrec_.n27 := value_;
   ELSIF (destination_column_ = 'N28') THEN transrec_.n28 := value_;
   ELSIF (destination_column_ = 'N29') THEN transrec_.n29 := value_;
   ELSIF (destination_column_ = 'N30') THEN transrec_.n30 := value_;
   ELSIF (destination_column_ = 'N31') THEN transrec_.n31 := value_;
   ELSIF (destination_column_ = 'N32') THEN transrec_.n32 := value_;
   ELSIF (destination_column_ = 'N33') THEN transrec_.n33 := value_;
   ELSIF (destination_column_ = 'N34') THEN transrec_.n34 := value_;
   ELSIF (destination_column_ = 'N35') THEN transrec_.n35 := value_;
   ELSIF (destination_column_ = 'N36') THEN transrec_.n36 := value_;
   ELSIF (destination_column_ = 'N37') THEN transrec_.n37 := value_;
   ELSIF (destination_column_ = 'N38') THEN transrec_.n38 := value_;
   ELSIF (destination_column_ = 'N39') THEN transrec_.n39 := value_;
   ELSIF (destination_column_ = 'N40') THEN transrec_.n40 := value_;
   ELSIF (destination_column_ = 'N41') THEN transrec_.n41 := value_;
   ELSIF (destination_column_ = 'N42') THEN transrec_.n42 := value_;
   ELSIF (destination_column_ = 'N43') THEN transrec_.n43 := value_;
   ELSIF (destination_column_ = 'N44') THEN transrec_.n44 := value_;
   ELSIF (destination_column_ = 'N45') THEN transrec_.n45 := value_;
   ELSIF (destination_column_ = 'N46') THEN transrec_.n46 := value_;
   ELSIF (destination_column_ = 'N47') THEN transrec_.n47 := value_;
   ELSIF (destination_column_ = 'N48') THEN transrec_.n48 := value_;
   ELSIF (destination_column_ = 'N49') THEN transrec_.n49 := value_;
   ELSIF (destination_column_ = 'N50') THEN transrec_.n50 := value_;
   ELSIF (destination_column_ = 'N51') THEN transrec_.n51 := value_;
   ELSIF (destination_column_ = 'N52') THEN transrec_.n52 := value_;
   ELSIF (destination_column_ = 'N53') THEN transrec_.n53 := value_;
   ELSIF (destination_column_ = 'N54') THEN transrec_.n54 := value_;
   ELSIF (destination_column_ = 'N55') THEN transrec_.n55 := value_;
   ELSIF (destination_column_ = 'N56') THEN transrec_.n56 := value_;
   ELSIF (destination_column_ = 'N57') THEN transrec_.n57 := value_;
   ELSIF (destination_column_ = 'N58') THEN transrec_.n58 := value_;
   ELSIF (destination_column_ = 'N59') THEN transrec_.n59 := value_;
   ELSIF (destination_column_ = 'N60') THEN transrec_.n60 := value_;
   ELSIF (destination_column_ = 'N61') THEN transrec_.n61 := value_;
   ELSIF (destination_column_ = 'N62') THEN transrec_.n62 := value_;
   ELSIF (destination_column_ = 'N63') THEN transrec_.n63 := value_;
   ELSIF (destination_column_ = 'N64') THEN transrec_.n64 := value_;
   ELSIF (destination_column_ = 'N65') THEN transrec_.n65 := value_;
   ELSIF (destination_column_ = 'N66') THEN transrec_.n66 := value_;
   ELSIF (destination_column_ = 'N67') THEN transrec_.n67 := value_;
   ELSIF (destination_column_ = 'N68') THEN transrec_.n68 := value_;
   ELSIF (destination_column_ = 'N69') THEN transrec_.n69 := value_;
   ELSIF (destination_column_ = 'N70') THEN transrec_.n70 := value_;
   ELSIF (destination_column_ = 'N71') THEN transrec_.n71 := value_;
   ELSIF (destination_column_ = 'N72') THEN transrec_.n72 := value_;
   ELSIF (destination_column_ = 'N73') THEN transrec_.n73 := value_;
   ELSIF (destination_column_ = 'N74') THEN transrec_.n74 := value_;
   ELSIF (destination_column_ = 'N75') THEN transrec_.n75 := value_;
   ELSIF (destination_column_ = 'N76') THEN transrec_.n76 := value_;
   ELSIF (destination_column_ = 'N77') THEN transrec_.n77 := value_;
   ELSIF (destination_column_ = 'N78') THEN transrec_.n78 := value_;
   ELSIF (destination_column_ = 'N79') THEN transrec_.n79 := value_;
   ELSIF (destination_column_ = 'N80') THEN transrec_.n80 := value_;
   ELSIF (destination_column_ = 'N81') THEN transrec_.n81 := value_;
   ELSIF (destination_column_ = 'N82') THEN transrec_.n82 := value_;
   ELSIF (destination_column_ = 'N83') THEN transrec_.n83 := value_;
   ELSIF (destination_column_ = 'N84') THEN transrec_.n84 := value_;
   ELSIF (destination_column_ = 'N85') THEN transrec_.n85 := value_;
   ELSIF (destination_column_ = 'N86') THEN transrec_.n86 := value_;
   ELSIF (destination_column_ = 'N87') THEN transrec_.n87 := value_;
   ELSIF (destination_column_ = 'N88') THEN transrec_.n88 := value_;
   ELSIF (destination_column_ = 'N89') THEN transrec_.n89 := value_;
   ELSIF (destination_column_ = 'N90') THEN transrec_.n90 := value_;
   ELSIF (destination_column_ = 'N91') THEN transrec_.n91 := value_;
   ELSIF (destination_column_ = 'N92') THEN transrec_.n92 := value_;
   ELSIF (destination_column_ = 'N93') THEN transrec_.n93 := value_;
   ELSIF (destination_column_ = 'N94') THEN transrec_.n94 := value_;
   ELSIF (destination_column_ = 'N95') THEN transrec_.n95 := value_;
   ELSIF (destination_column_ = 'N96') THEN transrec_.n96 := value_;
   ELSIF (destination_column_ = 'N97') THEN transrec_.n97 := value_;
   ELSIF (destination_column_ = 'N98') THEN transrec_.n98 := value_;
   ELSIF (destination_column_ = 'N99') THEN transrec_.n99 := value_;
   ELSIF (destination_column_ = 'N0')  THEN transrec_.n0 := value_;
   END IF;
END Put_N_Value;


PROCEDURE Put_D_Value (
   destination_column_    IN     VARCHAR2,
   value_                 IN     DATE,
   transrec_              IN OUT Ext_File_Trans_Tab%ROWTYPE ) 
IS
BEGIN
   IF    (destination_column_ = 'D1')  THEN transrec_.d1  := value_;
   ELSIF (destination_column_ = 'D2')  THEN transrec_.d2  := value_;
   ELSIF (destination_column_ = 'D3')  THEN transrec_.d3  := value_;
   ELSIF (destination_column_ = 'D4')  THEN transrec_.d4  := value_;
   ELSIF (destination_column_ = 'D5')  THEN transrec_.d5  := value_;
   ELSIF (destination_column_ = 'D6')  THEN transrec_.d6  := value_;
   ELSIF (destination_column_ = 'D7')  THEN transrec_.d7  := value_;
   ELSIF (destination_column_ = 'D8')  THEN transrec_.d8  := value_;
   ELSIF (destination_column_ = 'D9')  THEN transrec_.d9  := value_;
   ELSIF (destination_column_ = 'D10') THEN transrec_.d10 := value_;
   ELSIF (destination_column_ = 'D11') THEN transrec_.d11 := value_;
   ELSIF (destination_column_ = 'D12') THEN transrec_.d12 := value_;
   ELSIF (destination_column_ = 'D13') THEN transrec_.d13 := value_;
   ELSIF (destination_column_ = 'D14') THEN transrec_.d14 := value_;
   ELSIF (destination_column_ = 'D15') THEN transrec_.d15 := value_;
   ELSIF (destination_column_ = 'D16') THEN transrec_.d16 := value_;
   ELSIF (destination_column_ = 'D17') THEN transrec_.d17 := value_;
   ELSIF (destination_column_ = 'D18') THEN transrec_.d18 := value_;
   ELSIF (destination_column_ = 'D19') THEN transrec_.d19 := value_;
   ELSIF (destination_column_ = 'D20') THEN transrec_.d20 := value_;
   END IF;
END Put_D_Value;


PROCEDURE Put_C_Value (
   destination_column_    IN     VARCHAR2,
   value_                 IN     VARCHAR2,
   transrec_              IN OUT Ext_File_Trans_Tab%ROWTYPE ) 
IS
BEGIN
   IF    (destination_column_ = 'C1')  THEN transrec_.c1  := value_;
   ELSIF (destination_column_ = 'C2')  THEN transrec_.c2  := value_;
   ELSIF (destination_column_ = 'C3')  THEN transrec_.c3  := value_;
   ELSIF (destination_column_ = 'C4')  THEN transrec_.c4  := value_;
   ELSIF (destination_column_ = 'C5')  THEN transrec_.c5  := value_;
   ELSIF (destination_column_ = 'C6')  THEN transrec_.c6  := value_;
   ELSIF (destination_column_ = 'C7')  THEN transrec_.c7  := value_;
   ELSIF (destination_column_ = 'C8')  THEN transrec_.c8  := value_;
   ELSIF (destination_column_ = 'C9')  THEN transrec_.c9  := value_;
   ELSIF (destination_column_ = 'C10') THEN transrec_.c10 := value_;
   ELSIF (destination_column_ = 'C11') THEN transrec_.c11 := value_;
   ELSIF (destination_column_ = 'C12') THEN transrec_.c12 := value_;
   ELSIF (destination_column_ = 'C13') THEN transrec_.c13 := value_;
   ELSIF (destination_column_ = 'C14') THEN transrec_.c14 := value_;
   ELSIF (destination_column_ = 'C15') THEN transrec_.c15 := value_;
   ELSIF (destination_column_ = 'C16') THEN transrec_.c16 := value_;
   ELSIF (destination_column_ = 'C17') THEN transrec_.c17 := value_;
   ELSIF (destination_column_ = 'C18') THEN transrec_.c18 := value_;
   ELSIF (destination_column_ = 'C19') THEN transrec_.c19 := value_;
   ELSIF (destination_column_ = 'C20') THEN transrec_.c20 := value_;
   ELSIF (destination_column_ = 'C21') THEN transrec_.c21 := value_;
   ELSIF (destination_column_ = 'C22') THEN transrec_.c22 := value_;
   ELSIF (destination_column_ = 'C23') THEN transrec_.c23 := value_;
   ELSIF (destination_column_ = 'C24') THEN transrec_.c24 := value_;
   ELSIF (destination_column_ = 'C25') THEN transrec_.c25 := value_;
   ELSIF (destination_column_ = 'C26') THEN transrec_.c26 := value_;
   ELSIF (destination_column_ = 'C27') THEN transrec_.c27 := value_;
   ELSIF (destination_column_ = 'C28') THEN transrec_.c28 := value_;
   ELSIF (destination_column_ = 'C29') THEN transrec_.c29 := value_;
   ELSIF (destination_column_ = 'C30') THEN transrec_.c30 := value_;
   ELSIF (destination_column_ = 'C31') THEN transrec_.c31 := value_;
   ELSIF (destination_column_ = 'C32') THEN transrec_.c32 := value_;
   ELSIF (destination_column_ = 'C33') THEN transrec_.c33 := value_;
   ELSIF (destination_column_ = 'C34') THEN transrec_.c34 := value_;
   ELSIF (destination_column_ = 'C35') THEN transrec_.c35 := value_;
   ELSIF (destination_column_ = 'C36') THEN transrec_.c36 := value_;
   ELSIF (destination_column_ = 'C37') THEN transrec_.c37 := value_;
   ELSIF (destination_column_ = 'C38') THEN transrec_.c38 := value_;
   ELSIF (destination_column_ = 'C39') THEN transrec_.c39 := value_;
   ELSIF (destination_column_ = 'C40') THEN transrec_.c40 := value_;
   ELSIF (destination_column_ = 'C41') THEN transrec_.c41 := value_;
   ELSIF (destination_column_ = 'C42') THEN transrec_.c42 := value_;
   ELSIF (destination_column_ = 'C43') THEN transrec_.c43 := value_;
   ELSIF (destination_column_ = 'C44') THEN transrec_.c44 := value_;
   ELSIF (destination_column_ = 'C45') THEN transrec_.c45 := value_;
   ELSIF (destination_column_ = 'C46') THEN transrec_.c46 := value_;
   ELSIF (destination_column_ = 'C47') THEN transrec_.c47 := value_;
   ELSIF (destination_column_ = 'C48') THEN transrec_.c48 := value_;
   ELSIF (destination_column_ = 'C49') THEN transrec_.c49 := value_;
   ELSIF (destination_column_ = 'C50') THEN transrec_.c50 := value_;
   ELSIF (destination_column_ = 'C51') THEN transrec_.c51 := value_;
   ELSIF (destination_column_ = 'C52') THEN transrec_.c52 := value_;
   ELSIF (destination_column_ = 'C53') THEN transrec_.c53 := value_;
   ELSIF (destination_column_ = 'C54') THEN transrec_.c54 := value_;
   ELSIF (destination_column_ = 'C55') THEN transrec_.c55 := value_;
   ELSIF (destination_column_ = 'C56') THEN transrec_.c56 := value_;
   ELSIF (destination_column_ = 'C57') THEN transrec_.c57 := value_;
   ELSIF (destination_column_ = 'C58') THEN transrec_.c58 := value_;
   ELSIF (destination_column_ = 'C59') THEN transrec_.c59 := value_;
   ELSIF (destination_column_ = 'C60') THEN transrec_.c60 := value_;
   ELSIF (destination_column_ = 'C61') THEN transrec_.c61 := value_;
   ELSIF (destination_column_ = 'C62') THEN transrec_.c62 := value_;
   ELSIF (destination_column_ = 'C63') THEN transrec_.c63 := value_;
   ELSIF (destination_column_ = 'C64') THEN transrec_.c64 := value_;
   ELSIF (destination_column_ = 'C65') THEN transrec_.c65 := value_;
   ELSIF (destination_column_ = 'C66') THEN transrec_.c66 := value_;
   ELSIF (destination_column_ = 'C67') THEN transrec_.c67 := value_;
   ELSIF (destination_column_ = 'C68') THEN transrec_.c68 := value_;
   ELSIF (destination_column_ = 'C69') THEN transrec_.c69 := value_;
   ELSIF (destination_column_ = 'C70') THEN transrec_.c70 := value_;
   ELSIF (destination_column_ = 'C71') THEN transrec_.c71 := value_;
   ELSIF (destination_column_ = 'C72') THEN transrec_.c72 := value_;
   ELSIF (destination_column_ = 'C73') THEN transrec_.c73 := value_;
   ELSIF (destination_column_ = 'C74') THEN transrec_.c74 := value_;
   ELSIF (destination_column_ = 'C75') THEN transrec_.c75 := value_;
   ELSIF (destination_column_ = 'C76') THEN transrec_.c76 := value_;
   ELSIF (destination_column_ = 'C77') THEN transrec_.c77 := value_;
   ELSIF (destination_column_ = 'C78') THEN transrec_.c78 := value_;
   ELSIF (destination_column_ = 'C79') THEN transrec_.c79 := value_;
   ELSIF (destination_column_ = 'C80') THEN transrec_.c80 := value_;
   ELSIF (destination_column_ = 'C81') THEN transrec_.c81 := value_;
   ELSIF (destination_column_ = 'C82') THEN transrec_.c82 := value_;
   ELSIF (destination_column_ = 'C83') THEN transrec_.c83 := value_;
   ELSIF (destination_column_ = 'C84') THEN transrec_.c84 := value_;
   ELSIF (destination_column_ = 'C85') THEN transrec_.c85 := value_;
   ELSIF (destination_column_ = 'C86') THEN transrec_.c86 := value_;
   ELSIF (destination_column_ = 'C87') THEN transrec_.c87 := value_;
   ELSIF (destination_column_ = 'C88') THEN transrec_.c88 := value_;
   ELSIF (destination_column_ = 'C89') THEN transrec_.c89 := value_;
   ELSIF (destination_column_ = 'C90') THEN transrec_.c90 := value_;
   ELSIF (destination_column_ = 'C91') THEN transrec_.c91 := value_;
   ELSIF (destination_column_ = 'C92') THEN transrec_.c92 := value_;
   ELSIF (destination_column_ = 'C93') THEN transrec_.c93 := value_;
   ELSIF (destination_column_ = 'C94') THEN transrec_.c94 := value_;
   ELSIF (destination_column_ = 'C95') THEN transrec_.c95 := value_;
   ELSIF (destination_column_ = 'C96') THEN transrec_.c96 := value_;
   ELSIF (destination_column_ = 'C97') THEN transrec_.c97 := value_;
   ELSIF (destination_column_ = 'C98') THEN transrec_.c98 := value_;
   ELSIF (destination_column_ = 'C99') THEN transrec_.c99 := value_;
   ELSIF (destination_column_ = 'C0')  THEN transrec_.c0  := value_;
   ELSIF (destination_column_ = 'C100')  THEN transrec_.c100  := value_;
   ELSIF (destination_column_ = 'C101')  THEN transrec_.c101  := value_;
   ELSIF (destination_column_ = 'C102')  THEN transrec_.c102  := value_;
   ELSIF (destination_column_ = 'C103')  THEN transrec_.c103  := value_;
   ELSIF (destination_column_ = 'C104')  THEN transrec_.c104  := value_;
   ELSIF (destination_column_ = 'C105')  THEN transrec_.c105  := value_;
   ELSIF (destination_column_ = 'C106')  THEN transrec_.c106  := value_;
   ELSIF (destination_column_ = 'C107')  THEN transrec_.c107  := value_;
   ELSIF (destination_column_ = 'C108')  THEN transrec_.c108  := value_;
   ELSIF (destination_column_ = 'C109')  THEN transrec_.c109  := value_;
   ELSIF (destination_column_ = 'C110') THEN transrec_.c110 := value_;
   ELSIF (destination_column_ = 'C111') THEN transrec_.c111 := value_;
   ELSIF (destination_column_ = 'C112') THEN transrec_.c112 := value_;
   ELSIF (destination_column_ = 'C113') THEN transrec_.c113 := value_;
   ELSIF (destination_column_ = 'C114') THEN transrec_.c114 := value_;
   ELSIF (destination_column_ = 'C115') THEN transrec_.c115 := value_;
   ELSIF (destination_column_ = 'C116') THEN transrec_.c116 := value_;
   ELSIF (destination_column_ = 'C117') THEN transrec_.c117 := value_;
   ELSIF (destination_column_ = 'C118') THEN transrec_.c118 := value_;
   ELSIF (destination_column_ = 'C119') THEN transrec_.c119 := value_;
   ELSIF (destination_column_ = 'C120') THEN transrec_.c120 := value_;
   ELSIF (destination_column_ = 'C121') THEN transrec_.c121 := value_;
   ELSIF (destination_column_ = 'C122') THEN transrec_.c122 := value_;
   ELSIF (destination_column_ = 'C123') THEN transrec_.c123 := value_;
   ELSIF (destination_column_ = 'C124') THEN transrec_.c124 := value_;
   ELSIF (destination_column_ = 'C125') THEN transrec_.c125 := value_;
   ELSIF (destination_column_ = 'C126') THEN transrec_.c126 := value_;
   ELSIF (destination_column_ = 'C127') THEN transrec_.c127 := value_;
   ELSIF (destination_column_ = 'C128') THEN transrec_.c128 := value_;
   ELSIF (destination_column_ = 'C129') THEN transrec_.c129 := value_;
   ELSIF (destination_column_ = 'C130') THEN transrec_.c130 := value_;
   ELSIF (destination_column_ = 'C131') THEN transrec_.c131 := value_;
   ELSIF (destination_column_ = 'C132') THEN transrec_.c132 := value_;
   ELSIF (destination_column_ = 'C133') THEN transrec_.c133 := value_;
   ELSIF (destination_column_ = 'C134') THEN transrec_.c134 := value_;
   ELSIF (destination_column_ = 'C135') THEN transrec_.c135 := value_;
   ELSIF (destination_column_ = 'C136') THEN transrec_.c136 := value_;
   ELSIF (destination_column_ = 'C137') THEN transrec_.c137 := value_;
   ELSIF (destination_column_ = 'C138') THEN transrec_.c138 := value_;
   ELSIF (destination_column_ = 'C139') THEN transrec_.c139 := value_;
   ELSIF (destination_column_ = 'C140') THEN transrec_.c140 := value_;
   ELSIF (destination_column_ = 'C141') THEN transrec_.c141 := value_;
   ELSIF (destination_column_ = 'C142') THEN transrec_.c142 := value_;
   ELSIF (destination_column_ = 'C143') THEN transrec_.c143 := value_;
   ELSIF (destination_column_ = 'C144') THEN transrec_.c144 := value_;
   ELSIF (destination_column_ = 'C145') THEN transrec_.c145 := value_;
   ELSIF (destination_column_ = 'C146') THEN transrec_.c146 := value_;
   ELSIF (destination_column_ = 'C147') THEN transrec_.c147 := value_;
   ELSIF (destination_column_ = 'C148') THEN transrec_.c148 := value_;
   ELSIF (destination_column_ = 'C149') THEN transrec_.c149 := value_;
   ELSIF (destination_column_ = 'C150') THEN transrec_.c150 := value_;
   ELSIF (destination_column_ = 'C151') THEN transrec_.c151 := value_;
   ELSIF (destination_column_ = 'C152') THEN transrec_.c152 := value_;
   ELSIF (destination_column_ = 'C153') THEN transrec_.c153 := value_;
   ELSIF (destination_column_ = 'C154') THEN transrec_.c154 := value_;
   ELSIF (destination_column_ = 'C155') THEN transrec_.c155 := value_;
   ELSIF (destination_column_ = 'C156') THEN transrec_.c156 := value_;
   ELSIF (destination_column_ = 'C157') THEN transrec_.c157 := value_;
   ELSIF (destination_column_ = 'C158') THEN transrec_.c158 := value_;
   ELSIF (destination_column_ = 'C159') THEN transrec_.c159 := value_;
   ELSIF (destination_column_ = 'C160') THEN transrec_.c160 := value_;
   ELSIF (destination_column_ = 'C161') THEN transrec_.c161 := value_;
   ELSIF (destination_column_ = 'C162') THEN transrec_.c162 := value_;
   ELSIF (destination_column_ = 'C163') THEN transrec_.c163 := value_;
   ELSIF (destination_column_ = 'C164') THEN transrec_.c164 := value_;
   ELSIF (destination_column_ = 'C165') THEN transrec_.c165 := value_;
   ELSIF (destination_column_ = 'C166') THEN transrec_.c166 := value_;
   ELSIF (destination_column_ = 'C167') THEN transrec_.c167 := value_;
   ELSIF (destination_column_ = 'C168') THEN transrec_.c168 := value_;
   ELSIF (destination_column_ = 'C169') THEN transrec_.c169 := value_;
   ELSIF (destination_column_ = 'C170') THEN transrec_.c170 := value_;
   ELSIF (destination_column_ = 'C171') THEN transrec_.c171 := value_;
   ELSIF (destination_column_ = 'C172') THEN transrec_.c172 := value_;
   ELSIF (destination_column_ = 'C173') THEN transrec_.c173 := value_;
   ELSIF (destination_column_ = 'C174') THEN transrec_.c174 := value_;
   ELSIF (destination_column_ = 'C175') THEN transrec_.c175 := value_;
   ELSIF (destination_column_ = 'C176') THEN transrec_.c176 := value_;
   ELSIF (destination_column_ = 'C177') THEN transrec_.c177 := value_;
   ELSIF (destination_column_ = 'C178') THEN transrec_.c178 := value_;
   ELSIF (destination_column_ = 'C179') THEN transrec_.c179 := value_;
   ELSIF (destination_column_ = 'C180') THEN transrec_.c180 := value_;
   ELSIF (destination_column_ = 'C181') THEN transrec_.c181 := value_;
   ELSIF (destination_column_ = 'C182') THEN transrec_.c182 := value_;
   ELSIF (destination_column_ = 'C183') THEN transrec_.c183 := value_;
   ELSIF (destination_column_ = 'C184') THEN transrec_.c184 := value_;
   ELSIF (destination_column_ = 'C185') THEN transrec_.c185 := value_;
   ELSIF (destination_column_ = 'C186') THEN transrec_.c186 := value_;
   ELSIF (destination_column_ = 'C187') THEN transrec_.c187 := value_;
   ELSIF (destination_column_ = 'C188') THEN transrec_.c188 := value_;
   ELSIF (destination_column_ = 'C189') THEN transrec_.c189 := value_;
   ELSIF (destination_column_ = 'C190') THEN transrec_.c190 := value_;
   ELSIF (destination_column_ = 'C191') THEN transrec_.c191 := value_;
   ELSIF (destination_column_ = 'C192') THEN transrec_.c192 := value_;
   ELSIF (destination_column_ = 'C193') THEN transrec_.c193 := value_;
   ELSIF (destination_column_ = 'C194') THEN transrec_.c194 := value_;
   ELSIF (destination_column_ = 'C195') THEN transrec_.c195 := value_;
   ELSIF (destination_column_ = 'C196') THEN transrec_.c196 := value_;
   ELSIF (destination_column_ = 'C197') THEN transrec_.c197 := value_;
   ELSIF (destination_column_ = 'C198') THEN transrec_.c198 := value_;
   ELSIF (destination_column_ = 'C199') THEN transrec_.c199 := value_;
   END IF;
END Put_C_Value;


FUNCTION Return_D_Value (
   destination_column_    IN VARCHAR2,
   transrec_              IN Ext_File_Trans_Tab%ROWTYPE ) RETURN DATE
IS
BEGIN
   IF    (destination_column_ = 'D1')  THEN RETURN transrec_.d1;
   ELSIF (destination_column_ = 'D2')  THEN RETURN transrec_.d2;
   ELSIF (destination_column_ = 'D3')  THEN RETURN transrec_.d3;
   ELSIF (destination_column_ = 'D4')  THEN RETURN transrec_.d4;
   ELSIF (destination_column_ = 'D5')  THEN RETURN transrec_.d5;
   ELSIF (destination_column_ = 'D6')  THEN RETURN transrec_.d6;
   ELSIF (destination_column_ = 'D7')  THEN RETURN transrec_.d7;
   ELSIF (destination_column_ = 'D8')  THEN RETURN transrec_.d8;
   ELSIF (destination_column_ = 'D9')  THEN RETURN transrec_.d9;
   ELSIF (destination_column_ = 'D10') THEN RETURN transrec_.d10;
   ELSIF (destination_column_ = 'D11') THEN RETURN transrec_.d11;
   ELSIF (destination_column_ = 'D12') THEN RETURN transrec_.d12;
   ELSIF (destination_column_ = 'D13') THEN RETURN transrec_.d13;
   ELSIF (destination_column_ = 'D14') THEN RETURN transrec_.d14;
   ELSIF (destination_column_ = 'D15') THEN RETURN transrec_.d15;
   ELSIF (destination_column_ = 'D16') THEN RETURN transrec_.d16;
   ELSIF (destination_column_ = 'D17') THEN RETURN transrec_.d17;
   ELSIF (destination_column_ = 'D18') THEN RETURN transrec_.d18;
   ELSIF (destination_column_ = 'D19') THEN RETURN transrec_.d19;
   ELSIF (destination_column_ = 'D20') THEN RETURN transrec_.d20;
   ELSE 
      RETURN NULL;
   END IF;
END Return_D_Value;


FUNCTION Return_C_Value (
   destination_column_    IN VARCHAR2,
   transrec_              IN Ext_File_Trans_Tab%ROWTYPE ) RETURN VARCHAR2
IS
BEGIN
   IF    (SUBSTR(destination_column_,1,1) = 'N') THEN
      RETURN TO_CHAR(Return_N_Value (destination_column_, transrec_));
   ELSIF (SUBSTR(destination_column_,1,1) = 'D') THEN
      RETURN TO_CHAR(Return_D_Value (destination_column_, transrec_));
   ELSIF (destination_column_ = 'C1')  THEN RETURN transrec_.c1;
   ELSIF (destination_column_ = 'C2')  THEN RETURN transrec_.c2;
   ELSIF (destination_column_ = 'C3')  THEN RETURN transrec_.c3;
   ELSIF (destination_column_ = 'C4')  THEN RETURN transrec_.c4;
   ELSIF (destination_column_ = 'C5')  THEN RETURN transrec_.c5;
   ELSIF (destination_column_ = 'C6')  THEN RETURN transrec_.c6;
   ELSIF (destination_column_ = 'C7')  THEN RETURN transrec_.c7;
   ELSIF (destination_column_ = 'C8')  THEN RETURN transrec_.c8;
   ELSIF (destination_column_ = 'C9')  THEN RETURN transrec_.c9;
   ELSIF (destination_column_ = 'C10') THEN RETURN transrec_.c10;
   ELSIF (destination_column_ = 'C11') THEN RETURN transrec_.c11;
   ELSIF (destination_column_ = 'C12') THEN RETURN transrec_.c12;
   ELSIF (destination_column_ = 'C13') THEN RETURN transrec_.c13;
   ELSIF (destination_column_ = 'C14') THEN RETURN transrec_.c14;
   ELSIF (destination_column_ = 'C15') THEN RETURN transrec_.c15;
   ELSIF (destination_column_ = 'C16') THEN RETURN transrec_.c16;
   ELSIF (destination_column_ = 'C17') THEN RETURN transrec_.c17;
   ELSIF (destination_column_ = 'C18') THEN RETURN transrec_.c18;
   ELSIF (destination_column_ = 'C19') THEN RETURN transrec_.c19;
   ELSIF (destination_column_ = 'C20') THEN RETURN transrec_.c20;
   ELSIF (destination_column_ = 'C21') THEN RETURN transrec_.c21;
   ELSIF (destination_column_ = 'C22') THEN RETURN transrec_.c22;
   ELSIF (destination_column_ = 'C23') THEN RETURN transrec_.c23;
   ELSIF (destination_column_ = 'C24') THEN RETURN transrec_.c24;
   ELSIF (destination_column_ = 'C25') THEN RETURN transrec_.c25;
   ELSIF (destination_column_ = 'C26') THEN RETURN transrec_.c26;
   ELSIF (destination_column_ = 'C27') THEN RETURN transrec_.c27;
   ELSIF (destination_column_ = 'C28') THEN RETURN transrec_.c28;
   ELSIF (destination_column_ = 'C29') THEN RETURN transrec_.c29;
   ELSIF (destination_column_ = 'C30') THEN RETURN transrec_.c30;
   ELSIF (destination_column_ = 'C31') THEN RETURN transrec_.c31;
   ELSIF (destination_column_ = 'C32') THEN RETURN transrec_.c32;
   ELSIF (destination_column_ = 'C33') THEN RETURN transrec_.c33;
   ELSIF (destination_column_ = 'C34') THEN RETURN transrec_.c34;
   ELSIF (destination_column_ = 'C35') THEN RETURN transrec_.c35;
   ELSIF (destination_column_ = 'C36') THEN RETURN transrec_.c36;
   ELSIF (destination_column_ = 'C37') THEN RETURN transrec_.c37;
   ELSIF (destination_column_ = 'C38') THEN RETURN transrec_.c38;
   ELSIF (destination_column_ = 'C39') THEN RETURN transrec_.c39;
   ELSIF (destination_column_ = 'C40') THEN RETURN transrec_.c40;
   ELSIF (destination_column_ = 'C41') THEN RETURN transrec_.c41;
   ELSIF (destination_column_ = 'C42') THEN RETURN transrec_.c42;
   ELSIF (destination_column_ = 'C43') THEN RETURN transrec_.c43;
   ELSIF (destination_column_ = 'C44') THEN RETURN transrec_.c44;
   ELSIF (destination_column_ = 'C45') THEN RETURN transrec_.c45;
   ELSIF (destination_column_ = 'C46') THEN RETURN transrec_.c46;
   ELSIF (destination_column_ = 'C47') THEN RETURN transrec_.c47;
   ELSIF (destination_column_ = 'C48') THEN RETURN transrec_.c48;
   ELSIF (destination_column_ = 'C49') THEN RETURN transrec_.c49;
   ELSIF (destination_column_ = 'C50') THEN RETURN transrec_.c50;
   ELSIF (destination_column_ = 'C51') THEN RETURN transrec_.c51;
   ELSIF (destination_column_ = 'C52') THEN RETURN transrec_.c52;
   ELSIF (destination_column_ = 'C53') THEN RETURN transrec_.c53;
   ELSIF (destination_column_ = 'C54') THEN RETURN transrec_.c54;
   ELSIF (destination_column_ = 'C55') THEN RETURN transrec_.c55;
   ELSIF (destination_column_ = 'C56') THEN RETURN transrec_.c56;
   ELSIF (destination_column_ = 'C57') THEN RETURN transrec_.c57;
   ELSIF (destination_column_ = 'C58') THEN RETURN transrec_.c58;
   ELSIF (destination_column_ = 'C59') THEN RETURN transrec_.c59;
   ELSIF (destination_column_ = 'C60') THEN RETURN transrec_.c60;
   ELSIF (destination_column_ = 'C61') THEN RETURN transrec_.c61;
   ELSIF (destination_column_ = 'C62') THEN RETURN transrec_.c62;
   ELSIF (destination_column_ = 'C63') THEN RETURN transrec_.c63;
   ELSIF (destination_column_ = 'C64') THEN RETURN transrec_.c64;
   ELSIF (destination_column_ = 'C65') THEN RETURN transrec_.c65;
   ELSIF (destination_column_ = 'C66') THEN RETURN transrec_.c66;
   ELSIF (destination_column_ = 'C67') THEN RETURN transrec_.c67;
   ELSIF (destination_column_ = 'C68') THEN RETURN transrec_.c68;
   ELSIF (destination_column_ = 'C69') THEN RETURN transrec_.c69;
   ELSIF (destination_column_ = 'C70') THEN RETURN transrec_.c70;
   ELSIF (destination_column_ = 'C71') THEN RETURN transrec_.c71;
   ELSIF (destination_column_ = 'C72') THEN RETURN transrec_.c72;
   ELSIF (destination_column_ = 'C73') THEN RETURN transrec_.c73;
   ELSIF (destination_column_ = 'C74') THEN RETURN transrec_.c74;
   ELSIF (destination_column_ = 'C75') THEN RETURN transrec_.c75;
   ELSIF (destination_column_ = 'C76') THEN RETURN transrec_.c76;
   ELSIF (destination_column_ = 'C77') THEN RETURN transrec_.c77;
   ELSIF (destination_column_ = 'C78') THEN RETURN transrec_.c78;
   ELSIF (destination_column_ = 'C79') THEN RETURN transrec_.c79;
   ELSIF (destination_column_ = 'C80') THEN RETURN transrec_.c80;
   ELSIF (destination_column_ = 'C81') THEN RETURN transrec_.c81;
   ELSIF (destination_column_ = 'C82') THEN RETURN transrec_.c82;
   ELSIF (destination_column_ = 'C83') THEN RETURN transrec_.c83;
   ELSIF (destination_column_ = 'C84') THEN RETURN transrec_.c84;
   ELSIF (destination_column_ = 'C85') THEN RETURN transrec_.c85;
   ELSIF (destination_column_ = 'C86') THEN RETURN transrec_.c86;
   ELSIF (destination_column_ = 'C87') THEN RETURN transrec_.c87;
   ELSIF (destination_column_ = 'C88') THEN RETURN transrec_.c88;
   ELSIF (destination_column_ = 'C89') THEN RETURN transrec_.c89;
   ELSIF (destination_column_ = 'C90') THEN RETURN transrec_.c90;
   ELSIF (destination_column_ = 'C91') THEN RETURN transrec_.c91;
   ELSIF (destination_column_ = 'C92') THEN RETURN transrec_.c92;
   ELSIF (destination_column_ = 'C93') THEN RETURN transrec_.c93;
   ELSIF (destination_column_ = 'C94') THEN RETURN transrec_.c94;
   ELSIF (destination_column_ = 'C95') THEN RETURN transrec_.c95;
   ELSIF (destination_column_ = 'C96') THEN RETURN transrec_.c96;
   ELSIF (destination_column_ = 'C97') THEN RETURN transrec_.c97;
   ELSIF (destination_column_ = 'C98') THEN RETURN transrec_.c98;
   ELSIF (destination_column_ = 'C99') THEN RETURN transrec_.c99;
   ELSIF (destination_column_ = 'C0')  THEN RETURN transrec_.c0;
   ELSIF (destination_column_ = 'C100')  THEN RETURN transrec_.c100;
   ELSIF (destination_column_ = 'C101')  THEN RETURN transrec_.c101;
   ELSIF (destination_column_ = 'C102')  THEN RETURN transrec_.c102;
   ELSIF (destination_column_ = 'C103')  THEN RETURN transrec_.c103;
   ELSIF (destination_column_ = 'C104')  THEN RETURN transrec_.c104;
   ELSIF (destination_column_ = 'C105')  THEN RETURN transrec_.c105;
   ELSIF (destination_column_ = 'C106')  THEN RETURN transrec_.c106;
   ELSIF (destination_column_ = 'C107')  THEN RETURN transrec_.c107;
   ELSIF (destination_column_ = 'C108')  THEN RETURN transrec_.c108;
   ELSIF (destination_column_ = 'C109')  THEN RETURN transrec_.c109;
   ELSIF (destination_column_ = 'C110') THEN RETURN transrec_.c110;
   ELSIF (destination_column_ = 'C111') THEN RETURN transrec_.c111;
   ELSIF (destination_column_ = 'C112') THEN RETURN transrec_.c112;
   ELSIF (destination_column_ = 'C113') THEN RETURN transrec_.c113;
   ELSIF (destination_column_ = 'C114') THEN RETURN transrec_.c114;
   ELSIF (destination_column_ = 'C115') THEN RETURN transrec_.c115;
   ELSIF (destination_column_ = 'C116') THEN RETURN transrec_.c116;
   ELSIF (destination_column_ = 'C117') THEN RETURN transrec_.c117;
   ELSIF (destination_column_ = 'C118') THEN RETURN transrec_.c118;
   ELSIF (destination_column_ = 'C119') THEN RETURN transrec_.c119;
   ELSIF (destination_column_ = 'C120') THEN RETURN transrec_.c120;
   ELSIF (destination_column_ = 'C121') THEN RETURN transrec_.c121;
   ELSIF (destination_column_ = 'C122') THEN RETURN transrec_.c122;
   ELSIF (destination_column_ = 'C123') THEN RETURN transrec_.c123;
   ELSIF (destination_column_ = 'C124') THEN RETURN transrec_.c124;
   ELSIF (destination_column_ = 'C125') THEN RETURN transrec_.c125;
   ELSIF (destination_column_ = 'C126') THEN RETURN transrec_.c126;
   ELSIF (destination_column_ = 'C127') THEN RETURN transrec_.c127;
   ELSIF (destination_column_ = 'C128') THEN RETURN transrec_.c128;
   ELSIF (destination_column_ = 'C129') THEN RETURN transrec_.c129;
   ELSIF (destination_column_ = 'C130') THEN RETURN transrec_.c130;
   ELSIF (destination_column_ = 'C131') THEN RETURN transrec_.c131;
   ELSIF (destination_column_ = 'C132') THEN RETURN transrec_.c132;
   ELSIF (destination_column_ = 'C133') THEN RETURN transrec_.c133;
   ELSIF (destination_column_ = 'C134') THEN RETURN transrec_.c134;
   ELSIF (destination_column_ = 'C135') THEN RETURN transrec_.c135;
   ELSIF (destination_column_ = 'C136') THEN RETURN transrec_.c136;
   ELSIF (destination_column_ = 'C137') THEN RETURN transrec_.c137;
   ELSIF (destination_column_ = 'C138') THEN RETURN transrec_.c138;
   ELSIF (destination_column_ = 'C139') THEN RETURN transrec_.c139;
   ELSIF (destination_column_ = 'C140') THEN RETURN transrec_.c140;
   ELSIF (destination_column_ = 'C141') THEN RETURN transrec_.c141;
   ELSIF (destination_column_ = 'C142') THEN RETURN transrec_.c142;
   ELSIF (destination_column_ = 'C143') THEN RETURN transrec_.c143;
   ELSIF (destination_column_ = 'C144') THEN RETURN transrec_.c144;
   ELSIF (destination_column_ = 'C145') THEN RETURN transrec_.c145;
   ELSIF (destination_column_ = 'C146') THEN RETURN transrec_.c146;
   ELSIF (destination_column_ = 'C147') THEN RETURN transrec_.c147;
   ELSIF (destination_column_ = 'C148') THEN RETURN transrec_.c148;
   ELSIF (destination_column_ = 'C149') THEN RETURN transrec_.c149;
   ELSIF (destination_column_ = 'C150') THEN RETURN transrec_.c150;
   ELSIF (destination_column_ = 'C151') THEN RETURN transrec_.c151;
   ELSIF (destination_column_ = 'C152') THEN RETURN transrec_.c152;
   ELSIF (destination_column_ = 'C153') THEN RETURN transrec_.c153;
   ELSIF (destination_column_ = 'C154') THEN RETURN transrec_.c154;
   ELSIF (destination_column_ = 'C155') THEN RETURN transrec_.c155;
   ELSIF (destination_column_ = 'C156') THEN RETURN transrec_.c156;
   ELSIF (destination_column_ = 'C157') THEN RETURN transrec_.c157;
   ELSIF (destination_column_ = 'C158') THEN RETURN transrec_.c158;
   ELSIF (destination_column_ = 'C159') THEN RETURN transrec_.c159;
   ELSIF (destination_column_ = 'C160') THEN RETURN transrec_.c160;
   ELSIF (destination_column_ = 'C161') THEN RETURN transrec_.c161;
   ELSIF (destination_column_ = 'C162') THEN RETURN transrec_.c162;
   ELSIF (destination_column_ = 'C163') THEN RETURN transrec_.c163;
   ELSIF (destination_column_ = 'C164') THEN RETURN transrec_.c164;
   ELSIF (destination_column_ = 'C165') THEN RETURN transrec_.c165;
   ELSIF (destination_column_ = 'C166') THEN RETURN transrec_.c166;
   ELSIF (destination_column_ = 'C167') THEN RETURN transrec_.c167;
   ELSIF (destination_column_ = 'C168') THEN RETURN transrec_.c168;
   ELSIF (destination_column_ = 'C169') THEN RETURN transrec_.c169;
   ELSIF (destination_column_ = 'C170') THEN RETURN transrec_.c170;
   ELSIF (destination_column_ = 'C171') THEN RETURN transrec_.c171;
   ELSIF (destination_column_ = 'C172') THEN RETURN transrec_.c172;
   ELSIF (destination_column_ = 'C173') THEN RETURN transrec_.c173;
   ELSIF (destination_column_ = 'C174') THEN RETURN transrec_.c174;
   ELSIF (destination_column_ = 'C175') THEN RETURN transrec_.c175;
   ELSIF (destination_column_ = 'C176') THEN RETURN transrec_.c176;
   ELSIF (destination_column_ = 'C177') THEN RETURN transrec_.c177;
   ELSIF (destination_column_ = 'C178') THEN RETURN transrec_.c178;
   ELSIF (destination_column_ = 'C179') THEN RETURN transrec_.c179;
   ELSIF (destination_column_ = 'C180') THEN RETURN transrec_.c180;
   ELSIF (destination_column_ = 'C181') THEN RETURN transrec_.c181;
   ELSIF (destination_column_ = 'C182') THEN RETURN transrec_.c182;
   ELSIF (destination_column_ = 'C183') THEN RETURN transrec_.c183;
   ELSIF (destination_column_ = 'C184') THEN RETURN transrec_.c184;
   ELSIF (destination_column_ = 'C185') THEN RETURN transrec_.c185;
   ELSIF (destination_column_ = 'C186') THEN RETURN transrec_.c186;
   ELSIF (destination_column_ = 'C187') THEN RETURN transrec_.c187;
   ELSIF (destination_column_ = 'C188') THEN RETURN transrec_.c188;
   ELSIF (destination_column_ = 'C189') THEN RETURN transrec_.c189;
   ELSIF (destination_column_ = 'C190') THEN RETURN transrec_.c190;
   ELSIF (destination_column_ = 'C191') THEN RETURN transrec_.c191;
   ELSIF (destination_column_ = 'C192') THEN RETURN transrec_.c192;
   ELSIF (destination_column_ = 'C193') THEN RETURN transrec_.c193;
   ELSIF (destination_column_ = 'C194') THEN RETURN transrec_.c194;
   ELSIF (destination_column_ = 'C195') THEN RETURN transrec_.c195;
   ELSIF (destination_column_ = 'C196') THEN RETURN transrec_.c196;
   ELSIF (destination_column_ = 'C197') THEN RETURN transrec_.c197;
   ELSIF (destination_column_ = 'C198') THEN RETURN transrec_.c198;
   ELSIF (destination_column_ = 'C199') THEN RETURN transrec_.c199;
   ELSE 
      RETURN NULL;
   END IF;
END Return_C_Value;





