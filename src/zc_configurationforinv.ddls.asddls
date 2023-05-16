@EndUserText.label: 'Configuration for Inventory Aging - Main'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define view entity ZC_ConfigurationForInv
  as projection on ZI_ConfigurationForInv
{
  key Bukrs,
  key Movementtype,
  Inuse,
  Lastchangeddatetime,
  @Consumption.hidden: true
  Locinstlastchange,
  @Consumption.hidden: true
  SingletonID,
  _ConfigurationForAll : redirected to parent ZC_ConfigurationForInv_S
  
}
