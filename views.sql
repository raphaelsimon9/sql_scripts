use sales;

create view high_category_prices as
select 
	productName `Product Name`,
	categoryName `Category Name`,
    unitPrice `Unit Price`,
	(select avg(unitPrice)
		from products
		where categoryID = p.categoryID
	) `Avg Unit Price`,
    (case
		when unitPrice > (select avg(unitPrice) from products where categoryID = p.categoryID)
        then 'Above Average'
        else 'Below Average'
	end) as Remark
from products p
inner join categories using(categoryID)
order by `Remark`;


select * from high_category_prices;