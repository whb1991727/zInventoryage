CLASS LHC_RAP_TDAT_CTS DEFINITION FINAL.
  PUBLIC SECTION.
    CLASS-METHODS:
      GET
        RETURNING
          VALUE(RESULT) TYPE REF TO IF_MBC_CP_RAP_TABLE_CTS.

ENDCLASS.

CLASS LHC_RAP_TDAT_CTS IMPLEMENTATION.
  METHOD GET.
    result = mbc_cp_api=>rap_table_cts( table_entity_relations = VALUE #(
                                         ( entity = 'ConfigurationForInv' table = 'ZMOVEMENTTYPE' )
                                       ) ) ##NO_TEXT.
  ENDMETHOD.
ENDCLASS.
CLASS LHC_ZI_CONFIGURATIONFORINV_S DEFINITION FINAL INHERITING FROM CL_ABAP_BEHAVIOR_HANDLER.
  PRIVATE SECTION.
    METHODS:
      GET_INSTANCE_FEATURES FOR INSTANCE FEATURES
        IMPORTING
          KEYS REQUEST requested_features FOR ConfigurationForAll
        RESULT result,
      SELECTCUSTOMIZINGTRANSPTREQ FOR MODIFY
        IMPORTING
          KEYS FOR ACTION ConfigurationForAll~SelectCustomizingTransptReq
        RESULT result,
      GET_GLOBAL_AUTHORIZATIONS FOR GLOBAL AUTHORIZATION
        IMPORTING
           REQUEST requested_authorizations FOR ConfigurationForAll
        RESULT result.
ENDCLASS.

CLASS LHC_ZI_CONFIGURATIONFORINV_S IMPLEMENTATION.
  METHOD GET_INSTANCE_FEATURES.
    DATA: selecttransport_flag TYPE abp_behv_flag VALUE if_abap_behv=>fc-o-enabled,
          edit_flag            TYPE abp_behv_flag VALUE if_abap_behv=>fc-o-enabled.

    IF cl_bcfg_cd_reuse_api_factory=>get_cust_obj_service_instance(
        iv_objectname = 'ZMOVEMENTTYPE'
        iv_objecttype = cl_bcfg_cd_reuse_api_factory=>simple_table )->is_editable( ) = abap_false.
      edit_flag = if_abap_behv=>fc-o-disabled.
    ENDIF.
    DATA(transport_service) = cl_bcfg_cd_reuse_api_factory=>get_transport_service_instance(
                                iv_objectname = 'ZMOVEMENTTYPE'
                                iv_objecttype = cl_bcfg_cd_reuse_api_factory=>simple_table ).
    IF transport_service->is_transport_allowed( ) = abap_false.
      selecttransport_flag = if_abap_behv=>fc-o-disabled.
    ENDIF.
    READ ENTITIES OF ZI_ConfigurationForInv_S IN LOCAL MODE
    ENTITY ConfigurationForAll
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(all).
    IF all[ 1 ]-%IS_DRAFT = if_abap_behv=>mk-off.
      selecttransport_flag = if_abap_behv=>fc-o-disabled.
    ENDIF.
    result = VALUE #( (
               %TKY = all[ 1 ]-%TKY
               %ACTION-edit = edit_flag
               %ASSOC-_ConfigurationForInv = edit_flag
               %ACTION-SelectCustomizingTransptReq = selecttransport_flag ) ).
  ENDMETHOD.
  METHOD SELECTCUSTOMIZINGTRANSPTREQ.
    MODIFY ENTITIES OF ZI_ConfigurationForInv_S IN LOCAL MODE
      ENTITY ConfigurationForAll
        UPDATE FIELDS ( TransportRequestID HideTransport )
        WITH VALUE #( FOR key IN keys
                        ( %TKY               = key-%TKY
                          TransportRequestID = key-%PARAM-transportrequestid
                          HideTransport      = abap_false ) ).

    READ ENTITIES OF ZI_ConfigurationForInv_S IN LOCAL MODE
      ENTITY ConfigurationForAll
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(entities).
    result = VALUE #( FOR entity IN entities
                        ( %TKY   = entity-%TKY
                          %PARAM = entity ) ).
  ENDMETHOD.
  METHOD GET_GLOBAL_AUTHORIZATIONS.
    AUTHORITY-CHECK OBJECT 'S_TABU_NAM' ID 'TABLE' FIELD 'ZI_CONFIGURATIONFORINV' ID 'ACTVT' FIELD '02'.
    DATA(is_authorized) = COND #( WHEN sy-subrc = 0 THEN if_abap_behv=>auth-allowed
                                  ELSE if_abap_behv=>auth-unauthorized ).
    result-%UPDATE      = is_authorized.
    result-%ACTION-Edit = is_authorized.
    result-%ACTION-SelectCustomizingTransptReq = is_authorized.
  ENDMETHOD.
ENDCLASS.
CLASS LSC_ZI_CONFIGURATIONFORINV_S DEFINITION FINAL INHERITING FROM CL_ABAP_BEHAVIOR_SAVER.
  PROTECTED SECTION.
    METHODS:
      SAVE_MODIFIED REDEFINITION,
      CLEANUP_FINALIZE REDEFINITION.
ENDCLASS.

CLASS LSC_ZI_CONFIGURATIONFORINV_S IMPLEMENTATION.
  METHOD SAVE_MODIFIED.
    READ TABLE update-ConfigurationForAll INDEX 1 INTO DATA(all).
    IF all-TransportRequestID IS NOT INITIAL.
      lhc_rap_tdat_cts=>get( )->record_changes(
                                  transport_request = all-TransportRequestID
                                  create            = REF #( create )
                                  update            = REF #( update )
                                  delete            = REF #( delete ) ).
    ENDIF.
  ENDMETHOD.
  METHOD CLEANUP_FINALIZE ##NEEDED.
  ENDMETHOD.
ENDCLASS.
CLASS LHC_ZI_CONFIGURATIONFORINV DEFINITION FINAL INHERITING FROM CL_ABAP_BEHAVIOR_HANDLER.
  PRIVATE SECTION.
    METHODS:
      VALIDATETRANSPORTREQUEST FOR VALIDATE ON SAVE
        IMPORTING
          KEYS FOR ConfigurationForInv~ValidateTransportRequest,
      GET_GLOBAL_FEATURES FOR GLOBAL FEATURES
        IMPORTING
          REQUEST REQUESTED_FEATURES FOR ConfigurationForInv
        RESULT result,
      COPYCONFIGURATIONFORINV FOR MODIFY
        IMPORTING
          KEYS FOR ACTION ConfigurationForInv~CopyConfigurationForInv,
      GET_GLOBAL_AUTHORIZATIONS FOR GLOBAL AUTHORIZATION
        IMPORTING
           REQUEST requested_authorizations FOR ConfigurationForInv
        RESULT result,
      GET_INSTANCE_FEATURES FOR INSTANCE FEATURES
        IMPORTING
          KEYS REQUEST requested_features FOR ConfigurationForInv
        RESULT result.
ENDCLASS.

CLASS LHC_ZI_CONFIGURATIONFORINV IMPLEMENTATION.
  METHOD VALIDATETRANSPORTREQUEST.
    DATA change TYPE REQUEST FOR CHANGE ZI_ConfigurationForInv_S.
    SELECT SINGLE TransportRequestID
      FROM ZMOVEMENTTYP_D_S
      WHERE SingletonID = 1
      INTO @DATA(TransportRequestID).
    lhc_rap_tdat_cts=>get( )->validate_changes(
                                transport_request = TransportRequestID
                                table             = 'ZMOVEMENTTYPE'
                                keys              = REF #( keys )
                                reported          = REF #( reported )
                                failed            = REF #( failed )
                                change            = REF #( change-ConfigurationForInv ) ).
  ENDMETHOD.
  METHOD GET_GLOBAL_FEATURES.
    DATA edit_flag TYPE abp_behv_flag VALUE if_abap_behv=>fc-o-enabled.
    IF cl_bcfg_cd_reuse_api_factory=>get_cust_obj_service_instance(
         iv_objectname = 'ZMOVEMENTTYPE'
         iv_objecttype = cl_bcfg_cd_reuse_api_factory=>simple_table )->is_editable( ) = abap_false.
      edit_flag = if_abap_behv=>fc-o-disabled.
    ENDIF.
    result-%UPDATE = edit_flag.
    result-%DELETE = edit_flag.
  ENDMETHOD.
  METHOD COPYCONFIGURATIONFORINV.
    DATA new_ConfigurationForInv TYPE TABLE FOR CREATE ZI_ConfigurationForInv_S\_ConfigurationForInv.

    READ ENTITIES OF ZI_ConfigurationForInv_S IN LOCAL MODE
      ENTITY ConfigurationForInv
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(ref_ConfigurationForInv)
      FAILED DATA(read_failed).

    LOOP AT ref_ConfigurationForInv ASSIGNING FIELD-SYMBOL(<ref_ConfigurationForInv>).
      DATA(key) = keys[ KEY draft %TKY = <ref_ConfigurationForInv>-%TKY ].
      DATA(key_cid) = key-%CID.
      APPEND VALUE #(
        %TKY-SingletonID = 1
        %IS_DRAFT = <ref_ConfigurationForInv>-%IS_DRAFT
        %TARGET = VALUE #( (
          %CID = key_cid
          %IS_DRAFT = <ref_ConfigurationForInv>-%IS_DRAFT
          %DATA = CORRESPONDING #( <ref_ConfigurationForInv> EXCEPT
            Bukrs
            Lastchangeddatetime
            Locinstlastchange
            Movementtype
            SingletonID
        ) ) )
      ) TO new_ConfigurationForInv ASSIGNING FIELD-SYMBOL(<new_ConfigurationForInv>).
      <new_ConfigurationForInv>-%TARGET[ 1 ]-Bukrs = key-%PARAM-Bukrs.
      <new_ConfigurationForInv>-%TARGET[ 1 ]-Movementtype = key-%PARAM-Movementtype.
    ENDLOOP.

    MODIFY ENTITIES OF ZI_ConfigurationForInv_S IN LOCAL MODE
      ENTITY ConfigurationForAll CREATE BY \_ConfigurationForInv
      FIELDS (
               Bukrs
               Movementtype
               Inuse
             ) WITH new_ConfigurationForInv
      MAPPED DATA(mapped_create)
      FAILED failed
      REPORTED reported.

    mapped-ConfigurationForInv = mapped_create-ConfigurationForInv.
    INSERT LINES OF read_failed-ConfigurationForInv INTO TABLE failed-ConfigurationForInv.

    reported-ConfigurationForInv = VALUE #( FOR created IN mapped-ConfigurationForInv (
                                               %CID = created-%CID
                                               %ACTION-CopyConfigurationForInv = if_abap_behv=>mk-on
                                               %MSG = mbc_cp_api=>message( )->get_item_copied( )
                                               %PATH-ConfigurationForAll-%IS_DRAFT = created-%IS_DRAFT
                                               %PATH-ConfigurationForAll-SingletonID = 1 ) ).
  ENDMETHOD.
  METHOD GET_GLOBAL_AUTHORIZATIONS.
    AUTHORITY-CHECK OBJECT 'S_TABU_NAM' ID 'TABLE' FIELD 'ZI_CONFIGURATIONFORINV' ID 'ACTVT' FIELD '02'.
    DATA(is_authorized) = COND #( WHEN sy-subrc = 0 THEN if_abap_behv=>auth-allowed
                                  ELSE if_abap_behv=>auth-unauthorized ).
    result-%ACTION-CopyConfigurationForInv = is_authorized.
  ENDMETHOD.
  METHOD GET_INSTANCE_FEATURES.
    result = VALUE #( FOR row IN keys ( %TKY = row-%TKY
                                        %ACTION-CopyConfigurationForInv = COND #( WHEN row-%IS_DRAFT = if_abap_behv=>mk-off THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled )
   ) ).
  ENDMETHOD.
ENDCLASS.
