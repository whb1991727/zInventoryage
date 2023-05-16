@AbapCatalog: {
                sqlViewName: 'ZSTORAGELOCSTDVH',
                preserveKey: true,
                compiler.compareFilter: true,
                dataMaintenance: #RESTRICTED
              }
@EndUserText.label: 'Storage Location'
@ObjectModel: {
                usageType:{
                            sizeCategory: #S,
                            serviceQuality: #B,
                            dataClass: #CUSTOMIZING
                          },
                dataCategory: #VALUE_HELP,
                modelingPattern: #ANALYTICAL_DIMENSION,
                representativeKey: 'StorageLocation',
                supportedCapabilities: [#VALUE_HELP_PROVIDER,#ANALYTICAL_DIMENSION] //PAT2
              }

@Search.searchable: true
@Metadata: {
             allowExtensions: true,
             ignorePropagatedAnnotations: true
           }
@ClientHandling.algorithm: #SESSION_VARIABLE
@Consumption.ranked: true

define view ZI_StorageLocationStdVH
  as select from I_StorageLocation
  association [1..1] to I_ConfignDeprecationCode as _ConfigDeprecationCode on  $projection.ConfigDeprecationCode                   =  _ConfigDeprecationCode.ConfigurationDeprecationCode
                                                                           and _ConfigDeprecationCode.ConfigurationDeprecationCode <> 'E'
{
      @ObjectModel.text.element: ['PlantName']
      @ObjectModel.foreignKey.association: '_Plant'
      @Semantics.text: true
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
      @Search.ranking: #LOW
      @Consumption.valueHelpDefinition: [
        {
          entity:
            { name: 'I_PlantStdVH',
              element: 'Plant'
            }
        }
        ]
      @UI.lineItem:[{position:30}]
      @Consumption.valueHelpDefault.binding.usage: #FILTER_AND_RESULT
  key Plant,

      @ObjectModel.text.element: ['StorageLocationName']
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
      @Search.ranking: #HIGH
      @UI.lineItem:[{position:10}]
      @Consumption.valueHelpDefault.binding.usage: #FILTER_AND_RESULT
  key StorageLocation,

      @Semantics.text: true
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
      @Search.ranking: #LOW
      @UI.lineItem:[{position:20}]
      StorageLocationName,

      @Consumption.valueHelpDefinition: [
        {
          entity:
            { name: 'I_ConfignDeprecationCode',
              element: 'ConfigurationDeprecationCode'                 // old GFN
            }
        }
        ]
      @ObjectModel.text.element: [ 'ConfignDeprecationCodeName' ]
      ConfigDeprecationCode,
      _ConfigDeprecationCode._Text[1:Language=$session.system_language].ConfignDeprecationCodeName,
      _Plant.PlantName,
      
      /* Associations */
      @Consumption.hidden: true
      _Plant,
      _ConfigDeprecationCode
}
where
  ConfigDeprecationCode <> 'E'
