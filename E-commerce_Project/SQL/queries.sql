-- Querie Assessment by Antonio Caradonna

-- ================================================================================
-- 2. Join campaign names and default_bid to KPIs with a SQL statement.

SELECT *
FROM ad_groups
JOIN kpis
	USING(campaign_id);

/*
I use USING instead of ON to leverage the fact that both columns have the same 
name in the two tables and to avoid having the campaign_id column duplicated 
in the resulting table.
*/

-- ================================================================================

-- 3. Aggregate KPIs costs, clicks, impressions, paid revenues, paid orders, 
-- paid conversion per campaign for the whole period.

WITH joined AS (
  SELECT *
FROM ad_groups
JOIN kpis
	USING(campaign_id);)

SELECT campaign_id,
	name,
	'Min' AS metric, 
    MIN(cost) AS cost_values,
    MIN(clicks) AS click_values,
    MIN(impressions) AS impressions_values,
    MIN(paid_revenue) AS paid_revenue_values,
    MIN(paid_orders) AS paid_orders_values,
    MIN(paid_conversions) AS paid_conversions_values
FROM joined
GROUP BY campaign_id, name
UNION
SELECT campaign_id,
	name,
	'Max' AS metric, 
    MAX(cost) AS cost_values,
    MAX(clicks) AS click_values,
    MAX(impressions) AS impressions_values,
    MAX(paid_revenue) AS paid_revenue_values,
    MAX(paid_orders) AS paid_orders_values,
    MAX(paid_conversions) AS paid_conversions_values
FROM joined
GROUP BY campaign_id, name
UNION
SELECT campaign_id,
	name,
	'Mean' AS metric, 
    ROUND(AVG(cost),2) AS cost_values,
    ROUND(AVG(clicks),2) AS click_values,
    ROUND(AVG(impressions),2) AS impressions_values,
    ROUND(AVG(paid_revenue),2) AS paid_revenue_values,
    ROUND(AVG(paid_orders),2) AS paid_orders_values,
    ROUND(AVG(paid_conversions),2) AS paid_conversions_values
FROM joined
GROUP BY campaign_id, name
UNION
SELECT campaign_id,
	name,
	'Sum' AS metric, 
    ROUND(SUM(cost),2) AS cost_values,
    SUM(clicks) AS click_values,
    SUM(impressions) AS impressions_values,
    ROUND(SUM(paid_revenue),2) AS paid_revenue_values,
    SUM(paid_orders) AS paid_orders_values,
    SUM(paid_conversions) AS paid_conversions_values
FROM joined
GROUP BY campaign_id, name;
ORDER BY metric;

/*
For this query, although it could be much shorter by doing the aggregations on a 
single query, the looks of it would have been much worse (in my opinion), because 
all the aggregations would have been shown in different columns. The way I did it, 
you see the aggregations as rows and the columns represent each of the columns of 
study. Also, I show the name of the campaign to make it more user-friendly for 
the reader and, to do that, I had to use a WITH statement to join the tables 
separedly and not for every UNION.
*/

-- ================================================================================

-- 4. As an addition to the KPIs from above, please calculate average costs per 
-- click and ad costs of sales per campaign for the whole period.

SELECT campaign_id,
   ROUND(SUM(cost)/SUM(clicks),3) AS Avg_CPC,
   ROUND((SUM(cost)/SUM(paid_revenue))*100,3) AS ACoS_percentage
FROM kpis
GROUP BY campaign_id;

/*
Something that caught my attention is that the average CPC (0.258) for the Bathrobe 
is higher than its default_bid (0.25), which theoretically is the ighest price that
the company is willing to pay for a click. This is something I would discuss with
my team.
*/

-- ================================================================================

-- 5. Let's suppose there is an ACOS target of 12%. Please code a rule in SQL that 
-- will change the default bid (that is what is offered to amazon as a maximum for 
-- every new click on the advertising campaign) per campaign in order to get 
-- closer to that ACOS target.

WITH acos AS(
  SELECT (SUM(cost)/SUM(paid_revenue)) AS acos_decimal,
  	campaign_id
FROM kpis
GROUP BY campaign_id)

SELECT campaign_id, 
	default_bid AS Current_bid,
    ROUND(default_bid*0.12/acos_decimal,3) AS New_bid
FROM kpis
JOIN acos USING(campaign_id)
JOIN ad_groups USING(campaign_id)
GROUP BY campaign_id;
      
/*
First, I calculated the ACoS by campaign, then I joined the acos table to the kpis 
and ad_groups to be able to show both the default_bid and the new_bid needed to 
reach an ACoS of 12%. The calculation was a simple rule of three.
*/   
    



