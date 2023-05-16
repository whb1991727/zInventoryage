@EndUserText.label: 'Configuration for Inventory Aging'
@AccessControl.authorizationCheck: #CHECK
define view entity ZI_ConfigurationForInv
  as select from ZMOVEMENTTYPE
  association to parent ZI_ConfigurationForInv_S as _ConfigurationForAll on $projection.SingletonID = _ConfigurationForAll.SingletonID
{
  key BUKRS as Bukrs,
  key MOVEMENTTYPE as Movementtype,
  INUSE as Inuse,
  @Semantics.systemDateTime.lastChangedAt: true
  LASTCHANGEDDATETIME as Lastchangeddatetime,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  LOCINSTLASTCHANGE as Locinstlastchange,
  1 as SingletonID,
  _ConfigurationForAll
  
}
