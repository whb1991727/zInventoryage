@EndUserText.label: 'Configuration for Inventory Aging Single'
@AccessControl.authorizationCheck: #NOT_REQUIRED
define root view entity ZI_ConfigurationForInv_S
  as select from I_Language
    left outer join ZMOVEMENTTYPE on 0 = 0
  composition [0..*] of ZI_ConfigurationForInv as _ConfigurationForInv
{
  key 1 as SingletonID,
  _ConfigurationForInv,
  max( ZMOVEMENTTYPE.LASTCHANGEDDATETIME ) as LastChangedAtMax,
  cast( '' as SXCO_TRANSPORT) as TransportRequestID,
  cast( 'X' as ABAP_BOOLEAN preserving type) as HideTransport
  
}
where I_Language.Language = $session.system_language
