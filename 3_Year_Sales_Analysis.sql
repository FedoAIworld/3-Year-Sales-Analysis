USE eCommerce;
/*
3 Year Sales Analysis
*/

/*
The data we shall query & extract is based on the business requirement of 3 year sales analysis.
Hence, we have a set of columns that are dimensions and metrics, these form the basis of our 
visualisations contained in our dashboards.

Product,ProductSubCategory and ProductCategory dimensions are part of the data source that has the
potential to be used in subsequent visualisations.

The OnlineSales table is the primary transaction (fact) table source by which we build our analysis
for the dashboards.

Prefixes in the column names ...
    tc  = candidate fields for Tableau Calculated fields
    ov  = columns output from the Window function OVER 
    lag = columns output from the Window function LAG() OVER
    mv  = columns output from Window function OVER (Preceding)
    xj  = columns output from Cross Join 

	cte = columns output from CTE (Common Table Expression) queries, although not shown in the final  
			  union query as CTE's are not able to be UNIONED in this context.

This is the UNION Template of identified columns for the data set
  
Select
  ProductKey,											
  OrderDate,
  '' as City,
  '' as State,
  '' as Country,
  0 as tcSalesValue,									
  0 as tcProductCost,									
  0	as tcSalesTax,										
  0 as tcTransportCost,									
  0 as tcOrderCount,									
  0 as ovOrderCount,									
  0 as ovRunningOrderCount,								
  0 as ovSalesValue,									
  0 as ovRunningSalesTotal,								
  0 as lagSalesGrowthIn$,								 
  0 as lagSalesGrowthInPercent,							
  0 as lagFreightGrowthIn$,								
  0 as lagFreightGrowthInPercent,						
  0 as mvSalesValue,											 
  0 as mvAvgSales,
  0 as mvOrderCount,
  0 as mvAvgOrders,
  '' as xjSaleTypeName,									 
  '' as xjSaleStatus,
  '' as xjGeoSaleStatus,
  0 as xjGeoSaleStatusCount,
  0 as cteAverageCustSales$,
  0 as cteAvgOrderProductQty
from
  Table(s)	
where	
  Condition(s)
group by
  Column(s)

  UNION ALL
*/

-- Dimensions for visualization
select * from ProductSubcategory;
select * from ProductCategory;
select
	ProductKey,ProductSubcategoryKey,ProductName,StandardCost,ListPrice,SupplierId
from
	product;

/*
GEO analysis (Mapping)
Let's modify the above template to include the following data and values...
				
	1) City,State & Country
  2) The aggregation resulting in the column tcSalesValue being populated
  3) The aggregation resulting in the column tcProductCost being populated
	4) The aggregation resulting in the column tcSalesTax being populated
	5) The aggregation resulting in the column tcTransportCost being populated
	6) The aggregation resulting in the column tcOrderCount being populated

For the visualizations, we will need four lable sheets:

  a) Sales $
  b) Margin % (this will be a calculated field)
  c) Transport cost $
	d) Transport cost as a percentage of gross sales (this will be a calculated field)
*/

Select
  ProductKey,											
  OrderDate,
  City as City,
  StateProvinceName as State,
  CountryRegionName as Country,
  sum(SalesAmount) as tcSalesValue,									
  sum(TotalProductCost) as tcProductCost,									
  sum(TaxAmt) as tcSalesTax,										
  sum(Freight) as tcTransportCost,									
  Count(distinct SalesOrderNumber) as tcOrderCount,									
  0 as ovOrderCount,									
  0 as ovRunningOrderCount,								
  0 as ovSalesValue,									
  0 as ovRunningSalesTotal,								
  0 as lagSalesGrowthIn$,								 
  0 as lagSalesGrowthInPercent,							
  0 as lagFreightGrowthIn$,								
  0 as lagFreightGrowthInPercent,						
  0 as mvSalesValue,											 
  0 as mvAvgSales,
  0 as mvOrderCount,
  0 as mvAvgOrders,
  '' as xjSaleTypeName,									 
  '' as xjSaleStatus,
  '' as xjGeoSaleStatus,
  0 as xjGeoSaleStatusCount,
  0 as cteAverageCustSales$,
  0 as cteAvgOrderProductQty
from
  OnlineSales os inner join
  Customer cus on os.CustomerKey = cus.CustomerKey left join
  GeoLocation geo on cus.GeographyKey = geo.GeographyKey
where	
  year(OrderDate) between 2017 and 2019
group by
  ProductKey,
  OrderDate,
  City,
  StateProvinceName,
  CountryRegionName

/*
The requirement is to produce a single daily order count along side a single 
running total order count so we can plot this on a dual value chart 

Visualization : Daily Orders count with accumulated count trend line
*/ 

UNION ALL

Select
  0 as ProductKey,											
  OrderDate,
  '' as City,
  '' as State,
  '' as Country,
  0 as tcSalesValue,									
  0 as tcProductCost,									
  0	as tcSalesTax,										
  0 as tcTransportCost,									
  0 as tcOrderCount,									
  ovOrderCount,									
  ovRunningOrderCount,								
  0 as ovSalesValue,									
  0 as ovRunningSalesTotal,								
  0 as lagSalesGrowthIn$,								 
  0 as lagSalesGrowthInPercent,							
  0 as lagFreightGrowthIn$,								
  0 as lagFreightGrowthInPercent,						
  0 as mvSalesValue,											 
  0 as mvAvgSales,
  0 as mvOrderCount,
  0 as mvAvgOrders,
  '' as xjSaleTypeName,									 
  '' as xjSaleStatus,
  '' as xjGeoSaleStatus,
  0 as xjGeoSaleStatusCount,
  0 as cteAverageCustSales$,
  0 as cteAvgOrderProductQty
from
 (
 select
	OrderDate,
	count(distinct [SalesOrderNumber]) as ovOrderCount,
	sum(count(distinct SalesOrderNumber)) over (Order By OrderDate) as ovRunningOrderCount
 from
	OnlineSales 
 where
	year(OrderDate) between 2017 and 2019
 group by
	OrderDate
 ) dt

/*
The requirement is to produce:
  1) Sales value over time (i.e. Order Date) 
  2) Running total of sales over time 

The visualization showing:
  a) Bars for the sales total
	b) Trend line for the accumulated sale
*/

UNION ALL
    
Select
  0 as ProductKey,											
  OrderDate,
  '' as City,
  '' as State,
  '' as Country,
  0 as tcSalesValue,									
  0 as tcProductCost,									
  0	as tcSalesTax,										
  0 as tcTransportCost,									
  0 as tcOrderCount,									
  0 as ovOrderCount,									
  0 as ovRunningOrderCount,								
  ovSalesValue,									
  ovRunningSalesTotal,								
  0 as lagSalesGrowthIn$,								 
  0 as lagSalesGrowthInPercent,							
  0 as lagFreightGrowthIn$,								
  0 as lagFreightGrowthInPercent,						
  0 as mvSalesValue,											 
  0 as mvAvgSales,
  0 as mvOrderCount,
  0 as mvAvgOrders,
  '' as xjSaleTypeName,									 
  '' as xjSaleStatus,
  '' as xjGeoSaleStatus,
  0 as xjGeoSaleStatusCount,
  0 as cteAverageCustSales$,
  0 as cteAvgOrderProductQty
from
 (
 select
	OrderDate,
	sum(SalesAmount) as ovSalesValue,
	sum(sum(SalesAmount)) over (Order By OrderDate) as ovRunningSalesTotal
 from
	OnlineSales 
 where
	year(OrderDate) between 2017 and 2019
 group by
	OrderDate
 ) dt
 
/*
The requirement is to produce:
  1) Month on Month Sales Growth/Shrink both as a monthly $value and %value

Visualisation : Month on Month $ growth/shrink and % growth/shrink
                The Month is the finest grain for display on a chart 
*/

UNION ALL

Select
  0 as ProductKey,											
  OrderDate,
  '' as City,
  '' as State,
  '' as Country,
  0 as tcSalesValue,									
  0 as tcProductCost,									
  0	as tcSalesTax,										
  0 as tcTransportCost,									
  0 as tcOrderCount,									
  0 as ovOrderCount,									
  0 as ovRunningOrderCount,								
  0 as ovSalesValue,									
  0 as ovRunningSalesTotal,								
  lagSalesGrowthIn$,								 
  lagSalesGrowthInPercent,							
  0 as lagFreightGrowthIn$,								
  0 as lagFreightGrowthInPercent,						
  0 as mvSalesValue,											 
  0 as mvAvgSales,
  0 as mvOrderCount,
  0 as mvAvgOrders,
  '' as xjSaleTypeName,									 
  '' as xjSaleStatus,
  '' as xjGeoSaleStatus,
  0 as xjGeoSaleStatusCount,
  0 as cteAverageCustSales$,
  0 as cteAvgOrderProductQty
from
(
 select
    MonthStartDate AS OrderDate,
    sum([SalesAmount]) SalesValue,
    LAG(sum([SalesAmount]), 1) OVER (Order By MonthStartDate) PreviousYearMonthSales,
    sum([SalesAmount]) - LAG(sum([SalesAmount]),1) OVER (ORDER BY MonthStartDate) lagSalesGrowthIn$,
    100 * (
      (sum([SalesAmount]) - LAG(sum([SalesAmount]),1) OVER (ORDER BY MonthStartDate))/
        LAG(sum([SalesAmount]),1) OVER (ORDER BY MonthStartDate)
      ) lagSalesGrowthInPercent
 from
	  OnlineSales os INNER JOIN 
    Calendar cal ON os.OrderDate = cal.DisplayDate
 where
	  year(OrderDate) between 2017 and 2019
 group by
	  MonthStartDate
) dt

/*
Let's now produce a Week on Week Transport cost Growth/Shrink analysis as 
Transport is a significant cost point for the business and if this can be 
reduced the overall margin can be improved.
  1) $ Growth/Shrink value of Transport (Freight)
  2) % Growth/Shrink value of Transport (Freight)
  
Visualisation:
  a) Bars for the Transport cost
	b) Trend line for the transport cost %
*/

UNION ALL

Select
  0 as ProductKey,											
  OrderDate,
  '' as City,
  '' as State,
  '' as Country,
  0 as tcSalesValue,									
  0 as tcProductCost,									
  0	as tcSalesTax,										
  0 as tcTransportCost,									
  0 as tcOrderCount,									
  0 as ovOrderCount,									
  0 as ovRunningOrderCount,								
  0 as ovSalesValue,									
  0 as ovRunningSalesTotal,								
  0 as lagSalesGrowthIn$,								 
  0 as lagSalesGrowthInPercent,							
  lagFreightGrowthIn$,								
  lagFreightGrowthInPercent,						
  0 as mvSalesValue,											 
  0 as mvAvgSales,
  0 as mvOrderCount,
  0 as mvAvgOrders,
  '' as xjSaleTypeName,									 
  '' as xjSaleStatus,
  '' as xjGeoSaleStatus,
  0 as xjGeoSaleStatusCount,
  0 as cteAverageCustSales$,
  0 as cteAvgOrderProductQty
from
(
 select
    WeekStartDate AS OrderDate,
    sum([Freight]) FreightValue,
    LAG(sum([Freight]), 1) OVER (Order By WeekStartDate) PreviousYearMonthFreight,
    sum([Freight]) - LAG(sum([Freight]),1) OVER (ORDER BY WeekStartDate) lagFreightGrowthIn$,
    100 * (
      (sum([Freight]) - LAG(sum([Freight]),1) OVER (ORDER BY WeekStartDate))/
        LAG(sum([Freight]),1) OVER (ORDER BY WeekStartDate)
      ) lagFreightGrowthInPercent
 from
	  OnlineSales os INNER JOIN 
    Calendar cal ON os.OrderDate = cal.DisplayDate
 where
	  year(OrderDate) between 2017 and 2019
 group by
	  WeekStartDate
) dt 

/*
The requirement is to provide a moving average sales analysis alongside the daily sales total 
Visualisation : Show the 3 year sales trend with a moving average to smooth the daily sales 
*/
UNION ALL

Select
  0 as ProductKey,											
  OrderDate,
  '' as City,
  '' as State,
  '' as Country,
  0 as tcSalesValue,									
  0 as tcProductCost,									
  0	as tcSalesTax,										
  0 as tcTransportCost,									
  0 as tcOrderCount,									
  0 as ovOrderCount,									
  0 as ovRunningOrderCount,								
  0 as ovSalesValue,									
  0 as ovRunningSalesTotal,								
  0 as lagSalesGrowthIn$,								 
  0 as lagSalesGrowthInPercent,							
  0 as lagFreightGrowthIn$,								
  0 as lagFreightGrowthInPercent,						
  mvSalesValue,											 
  mvAvgSales,
  0 as mvOrderCount,
  0 as mvAvgOrders,
  '' as xjSaleTypeName,									 
  '' as xjSaleStatus,
  '' as xjGeoSaleStatus,
  0 as xjGeoSaleStatusCount,
  0 as cteAverageCustSales$,
  0 as cteAvgOrderProductQty
from
-- Step 2 : Calculate the moving average of the sales totals from the below derived table
(
select
	OrderDate,
	mvSalesValue,
	avg(mvSalesValue) over (Order By OrderDate rows between 30 preceding and current row) as mvAvgSales

-- Step 1 : Establish the Daily Sales Totals    
from
(
select											
	OrderDate,
	sum(SalesAmount) as mvSalesValue
from
	OnlineSales  
where
	year(OrderDate) between 2017 and 2019
group by 
	OrderDate
) dt
) dtMvAvgSales

/*
Next, let's produce an analysis of the number of Sales Orders along with the moving average.
Visualisation : Show the 3 year sales order trend with a moving average
*/

UNION ALL 

Select
  0 as ProductKey,											
  OrderDate,
  '' as City,
  '' as State,
  '' as Country,
  0 as tcSalesValue,									
  0 as tcProductCost,									
  0	as tcSalesTax,										
  0 as tcTransportCost,									
  0 as tcOrderCount,									
  0 as ovOrderCount,									
  0 as ovRunningOrderCount,								
  0 as ovSalesValue,									
  0 as ovRunningSalesTotal,								
  0 as lagSalesGrowthIn$,								 
  0 as lagSalesGrowthInPercent,							
  0 as lagFreightGrowthIn$,								
  0 as lagFreightGrowthInPercent,						
  0 as mvSalesValue,											 
  0 as mvAvgSales,
  mvOrderCount,
  mvAvgOrders,
  '' as xjSaleTypeName,									 
  '' as xjSaleStatus,
  '' as xjGeoSaleStatus,
  0 as xjGeoSaleStatusCount,
  0 as cteAverageCustSales$,
  0 as cteAvgOrderProductQty
from
-- Step 2 : Calculate the moving average of the sales totals from the below derived table
(
select
	OrderDate,
	mvOrderCount,
	avg(mvOrderCount) over (Order By OrderDate rows between 30 preceding and current row) as mvAvgOrders

-- Step 1 : Establish the Daily Sales Orders  
from
(
select											
	OrderDate,
	count(distinct [SalesOrderNumber]) as mvOrderCount
from
	OnlineSales  
where
	year(OrderDate) between 2017 and 2019
group by 
	OrderDate
) dt
) dtMvAvgOrders

/*
The requirement is to provide a visualisation of the distribution of all Products that were either 
Sold/Not Sold via the Sales Types contained in the SaleType table e.g. TV Advertisement
	
Hence a status of (Had Sale(s) / No Sale) should be evaluated across all
Sales transactions between 2017 and 2019 
*/

UNION ALL

Select
  ProductKey,											
  OrderDate,
  '' as City,
  '' as State,
  '' as Country,
  0 as tcSalesValue,									
  0 as tcProductCost,									
  0	as tcSalesTax,										
  0 as tcTransportCost,									
  0 as tcOrderCount,									
  0 as ovOrderCount,									
  0 as ovRunningOrderCount,								
  0 as ovSalesValue,									
  0 as ovRunningSalesTotal,								
  0 as lagSalesGrowthIn$,								 
  0 as lagSalesGrowthInPercent,							
  0 as lagFreightGrowthIn$,								
  0 as lagFreightGrowthInPercent,						
  0 as mvSalesValue,											 
  0 as mvAvgSales,
  0 as mvOrderCount,
  0 as mvAvgOrders,
  xjSaleTypeName,									 
  xjSaleStatus,
  '' as xjGeoSaleStatus,
  0 as xjGeoSaleStatusCount,
  0 as cteAverageCustSales$,
  0 as cteAvgOrderProductQty
from
(
   select
    prod.ProductKey,
	  st.SaleTypeName as xjSaleTypeName,
	case
  	when SalesValue > 0 then 'Had Sale(s)'
	  when SalesValue is null then 'No Sale'
	end as xjSaleStatus,
	'2019-12-31' as OrderDate
   from
	SaleType st cross join
	Product prod left join
    (
	select
		SaleTypeKey,
		ProductKey,
		sum(SalesAmount) as SalesValue
	from
		OnlineSales
	where
		year(OrderDate) between 2017 and 2019 
	group by
		SaleTypeKey,
		ProductKey
    ) as SaleTypeSales on SaleTypeSales.SaleTypeKey = st.SaleTypeKey and
						  SaleTypeSales.ProductKey = prod.ProductKey

   Where
    prod.ProductKey>0
) dt

/*
Analyse the customer geography to establish where in the world products were sold or not 
sold via the various Sale Types.
*/

UNION ALL 

Select
  ProductKey,											
  OrderDate,
  '' as City,
  '' as State,
  Country,
  0 as tcSalesValue,									
  0 as tcProductCost,									
  0	as tcSalesTax,										
  0 as tcTransportCost,									
  0 as tcOrderCount,									
  0 as ovOrderCount,									
  0 as ovRunningOrderCount,								
  0 as ovSalesValue,									
  0 as ovRunningSalesTotal,								
  0 as lagSalesGrowthIn$,								 
  0 as lagSalesGrowthInPercent,							
  0 as lagFreightGrowthIn$,								
  0 as lagFreightGrowthInPercent,						
  0 as mvSalesValue,											 
  0 as mvAvgSales,
  0 as mvOrderCount,
  0 as mvAvgOrders,
  '' as xjSaleTypeName,									 
  '' as xjSaleStatus,
  xjGeoSaleStatus,
  count(xjGeoSaleStatus) as xjGeoSaleStatusCount,
  0 as cteAverageCustSales$,
  0 as cteAvgOrderProductQty
from
   (
  	select
	    distinct(prod.ProductKey),
	    geo.CountryRegionName as Country,
	  case
  	  when SalesValue > 0 then 'Had Sale(s)'
	    when SalesValue is null then 'No Sale'
	  end as xjGeoSaleStatus,
	 '2019-12-31' as OrderDate
	from
	  GeoLocation geo cross join					
	  Product prod 	left join						 	
	(
	  select
			cus.GeographyKey
			,ProductKey
			,sum(SalesAmount) as SalesValue	
		from
			OnlineSales os inner join
			Customer cus on os.CustomerKey = cus.CustomerKey
		where 
			year(OrderDate) between 2017 and 2019 
		group by
			 GeographyKey
			,ProductKey	
	) as geoSaleTypedSales ON geoSaleTypedSales.GeographyKey = geo.GeographyKey and
						      geoSaleTypedSales.ProductKey = prod.ProductKey
	where 
	  prod.ProductKey > 0
    ) dt
group by
	ProductKey,
	Country,
	xjGeoSaleStatus,
	OrderDate;

/*
Note: cannot use UNION ALL in the result set above, it will need to 
be appended to the data source excel file, still use the template though.

The requirement is to provide a yearly (2017,2018,2019) average total sale value.
*/

with Sales_CTE (OrderDate,CustomerKey,SalesValue)
	AS
	(
	select
		cast(year(OrderDate) as char(4)) + '-01-01' as OrderDate,
		CustomerKey,
		sum(SalesAmount) as SalesValue
	from
		OnlineSales
	where
		year(OrderDate) between 2017 and 2019
	group by
		Year(OrderDate),
		CustomerKey
	)
	Select
	  0 as ProductKey,											
	  OrderDate,
	  '' as City,
	  '' as State,
	  '' as Country,
	  0 as tcSalesValue,									
	  0 as tcProductCost,									
	  0	as tcSalesTax,										
	  0 as tcTransportCost,									
	  0 as tcOrderCount,									
	  0 as ovOrderCount,									
	  0 as ovRunningOrderCount,								
	  0 as ovSalesValue,									
	  0 as ovRunningSalesTotal,								
	  0 as lagSalesGrowthIn$,								 
	  0 as lagSalesGrowthInPercent,							
	  0 as lagFreightGrowthIn$,								
	  0 as lagFreightGrowthInPercent,						
	  0 as mvSalesValue,											 
	  0 as mvAvgSales,
	  0 as mvOrderCount,
	  0 as mvAvgOrders,
	  '' as xjSaleTypeName,									 
	  '' as xjSaleStatus,
	  '' as xjGeoSaleStatus,
	  0 as xjGeoSaleStatusCount,
  	avg(SalesValue) as cteAverageCustSales$,
	  0 as cteAvgOrderProductQty
	from
		Sales_CTE
	group by
		OrderDate
	order by
		OrderDate;

/*
The average number of products purchased for 2017,2018,2019
*/

WITH Orders_CTE (OrderDate,CustomerKey,OrderProductQty ) 
	AS  
	(  
		SELECT  
			cast(year(Orderdate) as char(4)) + '-01-01'  as OrderDate, 
			CustomerKey,
			count(ProductKey) as OrderProductQty
		FROM	
			OnlineSales  
		where
			year(OrderDate) between 2017 and 2019
		GROUP BY 
			year(Orderdate),
			CustomerKey,
			SalesOrderNumber	
		)  
	SELECT 
	  0 as ProductKey,											
	  OrderDate,
	  '' as City,
	  '' as State,
	  '' as Country,
	  0 as tcSalesValue,									
	  0 as tcProductCost,									
	  0	as tcSalesTax,										
	  0 as tcTransportCost,									
	  0 as tcOrderCount,									
	  0 as ovOrderCount,									
	  0 as ovRunningOrderCount,								
	  0 as ovSalesValue,									
	  0 as ovRunningSalesTotal,								
	  0 as lagSalesGrowthIn$,								 
	  0 as lagSalesGrowthInPercent,							
	  0 as lagFreightGrowthIn$,								
	  0 as lagFreightGrowthInPercent,						
	  0 as mvSalesValue,											 
	  0 as mvAvgSales,
	  0 as mvOrderCount,
	  0 as mvAvgOrders,
	  '' as xjSaleTypeName,									 
	  '' as xjSaleStatus,
	  '' as xjGeoSaleStatus,
	  0 as xjGeoSaleStatusCount,
  	0 as cteAverageCustSales$,
  	avg(OrderProductQty) AS cteAvgOrderProductQty
	FROM 
		Orders_CTE
	Group By
		OrderDate
	order by 
		OrderDate desc;