************************************************************************
* Program Title: Assignment two                                        *
* Program : ztest_joao                                                 *
* Created By : Joao Filipe Romao                                       *
* Create Date : 10/04/17                                               *
* Description : Abap training - fetch data fron the a database         * 
*               and present the data in an ALV                          *
* CPR No. :                                                            *
************************************************************************
* Modification history:                                                *
************************************************************************
* Date:    Programmer:     CPR # Defect# Reviewer        Review Date   *
* -------- --------------- ----- ------- --------------- -----------   *
* DD/MM/YY                                               DD/MM/YY      *
*                                                                      *
* ->Description:                                                       *
*----------------------------------------------------------------------*
REPORT  ZTEST_JOAO.

TYPE-POOLS: SLIS.

*----------------------------------------------------------------------*
*   declare the types that will hold the values received               *
*   when joining the two table, EKKO and EKPO                          *                                   *
*----------------------------------------------------------------------*

TYPES: BEGIN OF ty_ekko_ekpo,
    lv_com_code TYPE ekko-BUKRS,
    lv_pur_document TYPE ekko-BSART,
    lv_vendor_acc TYPE ekko-LIFNR,
    lv_plant TYPE ekpo-WERKS,
    lv_pur_order_qty type ekpo-MENGE,
    lv_net_price_doc type ekpo-NETPR,
    lv_deleted_rec TYPE EKPO-LOEKZ,
   lv_total_sales TYPE p DECIMALS 2,
  END OF ty_ekko_ekpo.

*----------------------------------------------------------------------*
*           declare the internal table and variables                   *                                                      *
*----------------------------------------------------------------------*
  
DATA: it_joinned_table TYPE TABLE OF ty_ekko_ekpo,
      wa_join LIKE LINE OF it_joinned_table,
      p_comp_code TYPE ekko-BUKRS,
      p_creation_date TYPE ekpo-AEDAT,
      p_plant TYPE ekpo-WERKS.
  
*----------------------------------------------------------------------*
*     *select option to grabe the user input                           *
*----------------------------------------------------------------------*

CONSTANTS : rbSelected TYPE c LENGTH 1 VALUE 'X'.

DATA: it_field TYPE SLIS_T_FIELDCAT_ALV,
      wa_field TYPE SLIS_FIELDCAT_ALV.

*---------------------------------------------------------------------*
*        FIELD-SYMBOLS <fs_ekko_ekpo> TYPE ty_ekko_ekpo               *
*---------------------------------------------------------------------*
FIELD-SYMBOLS: <fs_ekko_ekpo> TYPE ty_ekko_ekpo.

SELECTION-SCREEN BEGIN OF BLOCK frame1 WITH FRAME TITLE text-001.


SELECT-OPTIONS: ls_cCode FOR p_comp_code.
SELECT-OPTIONS: ls_cDate FOR p_creation_date.
SELECT-OPTIONS: ls_plant FOR p_plant.

*----------------------------------------------------------------------*
* Checkbox - if this checkbox is selected, the system will             *
*            fetch the deleted records from the database, else do not  *
*            do not get show the deleted records                       *
*----------------------------------------------------------------------*
PARAMETERS:lc_drec AS CHECKBOX.

SELECTION-SCREEN END OF BLOCK frame1.
*----------------------------------------------------------------------*
*       select query to join two tables                                *
*       if checkbox is checked, perform the first select               * 
*       quesry that will fetch the deleted records                     *
*----------------------------------------------------------------------*
START-OF-SELECTION.
  IF lc_drec = 'X'.
    SELECT
      EKKO~BUKRS " company code
      EKKO~BSART " purchase doc
      EKKO~LIFNR " vendor
      EKPO~WERKS " plant
      EKPO~MENGE " order qty
      EKPO~NETPR " price doc
      EKKO~LOEKZ " delete doc
      FROM EKKO
      JOIN EKPO
      ON EKKO~EBELN EQ EKPO~EBELN
      INTO TABLE it_joinned_table WHERE EKKO~BUKRS in ls_cCode AND EKPO~AEDAT in ls_cDate AND EKPO~WERKS in ls_plant AND EKPO~LOEKZ > 1.

    LOOP AT it_joinned_table ASSIGNING <fs_ekko_ekpo>.
      <fs_ekko_ekpo>-lv_total_sales = <fs_ekko_ekpo>-lv_net_price_doc * <fs_ekko_ekpo>-lv_pur_order_qty.   " calculate Total sales
    ENDLOOP.

    wa_field-fieldname = 'LV_COM_CODE'.
    wa_field-col_pos = 1.
    wa_field-seltext_m = 'Company Code'.
    APPEND wa_field to it_field.

    wa_field-fieldname = 'LV_PUR_DOCUMENT'.
    wa_field-col_pos = 2.
    wa_field-seltext_m = 'Purchasing Document Type'.
    APPEND wa_field to it_field.

    wa_field-fieldname = 'LV_VENDOR_ACC'.
    wa_field-col_pos = 3.
    wa_field-seltext_m = 'Prior Vendor'.
    APPEND wa_field to it_field.

    wa_field-fieldname = 'LV_PLANT'.
    wa_field-col_pos = 4.
    wa_field-seltext_m = 'Plant'.
    APPEND wa_field to it_field.

    wa_field-fieldname = 'LV_NET_PRICE_DOC'.
    wa_field-col_pos = 5.
    wa_field-seltext_m = 'Net Price in Purchasing Document'.
    APPEND wa_field to it_field.

    wa_field-fieldname = 'LV_PUR_ORDER_QTY'.
    wa_field-col_pos = 6.
    wa_field-seltext_m = 'Order Qty'.
    APPEND wa_field to it_field.

    wa_field-fieldname = 'LV_TOTAL_SALES'.
    wa_field-col_pos = 7.
    wa_field-seltext_m = 'Total Sale'.
    APPEND wa_field to it_field.


    CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
      EXPORTING
        IT_FIELDCAT = it_field
      TABLES
        T_OUTTAB    = it_joinned_table.
    IF SY-SUBRC <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

*----------------------------------------------------------------------*
*     else, the ckeclbox is not checked, perform the second select     *
*     statment that will not fetch the deleted recids                  *
*----------------------------------------------------------------------*
  ELSE.
    SELECT
      EKKO~BUKRS " company code
      EKKO~BSART " purchase doc
      EKKO~LIFNR " vendor
      EKPO~WERKS " plant
      EKPO~MENGE " order qty
      EKPO~NETPR " price doc
      FROM EKKO
      JOIN EKPO
      ON EKKO~EBELN EQ EKPO~EBELN
      INTO TABLE it_joinned_table WHERE EKKO~BUKRS in ls_cCode AND EKPO~AEDAT in ls_cDate AND EKPO~WERKS in ls_plant.

    LOOP AT it_joinned_table ASSIGNING <fs_ekko_ekpo>.
      <fs_ekko_ekpo>-lv_total_sales = <fs_ekko_ekpo>-lv_net_price_doc * <fs_ekko_ekpo>-lv_pur_order_qty.   " calculate Total sales
    ENDLOOP.
    
    wa_field-fieldname = 'LV_COM_CODE'.
    wa_field-col_pos = 1.
    wa_field-seltext_m = 'Company Code'.
    APPEND wa_field to it_field.

    wa_field-fieldname = 'LV_PUR_DOCUMENT'.
    wa_field-col_pos = 2.
    wa_field-seltext_m = 'Purchasing Document Type'.
    APPEND wa_field to it_field.

    wa_field-fieldname = 'LV_VENDOR_ACC'.
    wa_field-col_pos = 3.
    wa_field-seltext_m = 'Prior Vendor'.
    APPEND wa_field to it_field.

    wa_field-fieldname = 'LV_PLANT'.
    wa_field-col_pos = 4.
    wa_field-seltext_m = 'Plant'.
    APPEND wa_field to it_field.

    wa_field-fieldname = 'LV_NET_PRICE_DOC'.
    wa_field-col_pos = 5.
    wa_field-seltext_m = 'Net Price in Purchasing Document'.
    APPEND wa_field to it_field.

    wa_field-fieldname = 'LV_PUR_ORDER_QTY'.
    wa_field-col_pos = 6.
    wa_field-seltext_m = 'Order Qty'.
    APPEND wa_field to it_field.

    wa_field-fieldname = 'LV_TOTAL_SALES'.
    wa_field-col_pos = 7.
    wa_field-seltext_m = 'Total Sale'.
    APPEND wa_field to it_field.

    CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
      EXPORTING
        IT_FIELDCAT = IT_FIELD
      TABLES
        T_OUTTAB    = it_joinned_table.
    IF SY-SUBRC <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

  ENDIF.

end-OF-SELECTION.
