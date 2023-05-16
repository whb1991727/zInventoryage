@EndUserText.label: 'Configuration for Inventory Aging Single'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@ObjectModel.semanticKey: [ 'SingletonID' ]
define root view entity ZC_ConfigurationForInv_S
  provider contract transactional_query
  as projection on ZI_ConfigurationForInv_S
{
  key SingletonID,
  LastChangedAtMax,
  TransportRequestID,
  HideTransport,
  _ConfigurationForInv : redirected to composition child ZC_ConfigurationForInv
  
}
