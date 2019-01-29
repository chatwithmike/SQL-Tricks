WITH XMLNAMESPACES ('TK461-CustomerOrders' AS co)
SELECT 
	[co:Orders].Client_ID AS [co:cusid]
	,[co:Orders].CC_Type AS [co:CC_Type]
	,[co:Orders].Order_Id AS [co:Order_Id]
	,[co:Orders].Order_Date AS [co:Order_Date]
FROM Football2003_ODS.dbo.Orders AS [co:Orders]
WHERE [co:Orders].Client_ID IN (5219032)--,561476,4487249,17880002,7441938,1293259,10479501,7722676,14727449,15459232)
ORDER BY [co:Orders].Client_ID, [co:Orders].Order_Id
FOR XML AUTO, ELEMENTS, ROOT('CustomerOrders');
/*
<?xml version="1.0"?>
<CustomerOrders xmlns:co="TK461-CustomerOrders">
  <co:Orders>
    <co:cusid>5219032</co:cusid>
    <co:CC_Type>VISA</co:CC_Type>
    <co:Order_Id>6424020</co:Order_Id>
    <co:Order_Date>2009-11-18T11:55:08.717</co:Order_Date>
  </co:Orders>
  <co:Orders>
    <co:cusid>5219032</co:cusid>
    <co:CC_Type>VISA</co:CC_Type>
    <co:Order_Id>6476634</co:Order_Id>
    <co:Order_Date>2009-11-22T18:50:07.107</co:Order_Date>
  </co:Orders>
</CustomerOrders>
*/

SELECT 
	Client_ID	
	,CC_Type		
	,Order_Id	
	,Order_Date	
FROM Football2003_ODS.dbo.Orders 
WHERE 1=2
--WHERE [co:Orders].Client_ID IN (5219032)--,561476,4487249,17880002,7441938,1293259,10479501,7722676,14727449,15459232)
FOR XML AUTO, ELEMENTS, XMLSCHEMA('TK461-CustomerOrders');

/*

<?xml version="1.0" encoding="UTF-8"?>
<xsd:schema xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:schema="TK461-CustomerOrders" xmlns:sqltypes="http://schemas.microsoft.com/sqlserver/2004/sqltypes" targetNamespace="TK461-CustomerOrders" elementFormDefault="qualified">
   <xsd:import namespace="http://schemas.microsoft.com/sqlserver/2004/sqltypes" schemaLocation="http://schemas.microsoft.com/sqlserver/2004/sqltypes/sqltypes.xsd" />
   <xsd:element name="Football2003_ODS.dbo.Orders">
      <xsd:complexType>
         <xsd:sequence>
            <xsd:element name="Client_ID" type="sqltypes:int" minOccurs="0" />
            <xsd:element name="CC_Type" minOccurs="0">
               <xsd:simpleType>
                  <xsd:restriction base="sqltypes:varchar" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                     <xsd:maxLength value="50" />
                  </xsd:restriction>
               </xsd:simpleType>
            </xsd:element>
            <xsd:element name="Order_Id" type="sqltypes:int" />
            <xsd:element name="Order_Date" type="sqltypes:datetime" minOccurs="0" />
         </xsd:sequence>
      </xsd:complexType>
   </xsd:element>
</xsd:schema>

*/