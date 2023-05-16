@EndUserText.label: 'Material Stock Age'
@ObjectModel.query.implementedBy: 'ABAP:ZCL_MATERIAL_STOCK_AGE'

@UI.headerInfo: {typeName: 'Inventory Aging'}

define custom entity z_material_stock_age
with parameters 
//@Consumption.valueHelpDefinition: [{ entity: {name:'I_COMPANYCODEVH' ,element: 'CompanyCode' } }] 
//  p_bukrs : bukrs,   
//@Consumption.valueHelpDefinition: [{ entity: {name:'I_PlantStdVH' ,element: 'Plant' } }]  
//  p_plant : werks_d,
//  p_lgort : zlgort,
  P_keydate : vdm_v_key_date
  { 
  
    @UI.selectionField: [{ position: 10 }]
    @Consumption.valueHelpDefinition: [{ entity: {name:'I_COMPANYCODEVH' ,element: 'CompanyCode' } }]
    @Consumption.filter:{mandatory: true}
//    @Consumption.defaultValue: '1310'
    key companycode : bukrs;
    
    @UI.lineItem :[{label:'Plant',position:10 ,importance: #HIGH }]
    @UI.selectionField: [{ position: 20 }]
    @Consumption.valueHelpDefinition: [{ entity: {name:'I_PlantStdVH' ,element: 'Plant' } }] 
    @Consumption.filter:{mandatory: true}
//    @Consumption.defaultValue: '1310'
    key plant : werks_d;
    
    @UI.lineItem :[{label:'Storage Location',position:20 ,importance: #HIGH}]
    @UI.selectionField: [{ position: 30 }]
    @Consumption.valueHelpDefinition: [{ entity: {name:'ZI_StorageLocationStdVH' ,element: 'StorageLocation' } }]
    @Consumption.valueHelpDefinition: [{additionalBinding: [{ element: 'Plant', localElement: 'plant' }]}]
    key stroagelocation: zlgort;
    
    @UI.lineItem :[{label:'Material',position:30 ,importance: #HIGH }]
    @UI.selectionField: [{ position: 40 }]
    @Consumption.valueHelpDefinition: [{ entity: {name:'I_ProductPlantStdVH' ,element: 'Product' } }]
    @Consumption.valueHelpDefinition: [{additionalBinding: [{ element: 'Plant', localElement: 'plant' }]}]
    key material: matnr;
    
    @Semantics.quantity.unitOfMeasure:'meins'
    @UI.lineItem :[{label:'Current Stock Quantity',position:40 ,importance: #HIGH }]
    currentStock : abap.quan( 22, 2 );
    
    @Semantics.amount.currencyCode: 'waers'
    @UI.lineItem :[{label:'Current Stock Value',position:50 ,importance: #HIGH }]
    currentValue : abap.curr( 23, 2 );
     
    @Semantics.quantity.unitOfMeasure:'meins'
    @UI.lineItem :[{label:'0-30 days Quantity',position:60 ,importance: #HIGH }]
    period1 : abap.quan( 22, 2 );
    
    @Semantics.amount.currencyCode: 'waers'
    @UI.lineItem :[{label:'0-30 days Value',position:70 ,importance: #HIGH }]
    period1_v : abap.curr( 23, 2 );
    
    @Semantics.quantity.unitOfMeasure:'meins'
    @UI.lineItem :[{label:'30-60 days Quantity',position:80 ,importance: #HIGH }] 
    period2 : abap.quan( 22, 2 );
    
    @Semantics.amount.currencyCode: 'waers'
    @UI.lineItem :[{label:'30-60 days Value',position:90 ,importance: #HIGH }]
    period2_v : abap.curr( 23, 2 );
    
    @Semantics.quantity.unitOfMeasure:'meins'
    @UI.lineItem :[{label:'Greater than 60 days Quantity',position:100 ,importance: #HIGH }] 
    period3 : abap.quan( 22, 2 );
    
    @Semantics.amount.currencyCode: 'waers'
    @UI.lineItem :[{label:'Greater than 60 days Value',position:110 ,importance: #HIGH }]
    period3_v : abap.curr( 23, 2 );
    
    @UI.hidden: true
    meins: meins;
    
    @UI.hidden: true
    waers: waers;
  }
