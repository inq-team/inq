class Order < ActiveRecord::Base
	has_many :order_lines
	has_many :order_stages
	has_many :computers

	def update_order(attr)
		order_lines = attr[:order_lines]
		attr.delete(:order_lines)
		p order_lines
		update_attributes(attr)
	end

	def self.staging
		[
			self.find_by_sql(["SELECT o.id, o.buyer_order_number, o.title, o.customer, os.start, DATEDIFF(NOW(), os.start) AS from_delay FROM orders o
INNER JOIN order_stages os ON o.id=os.order_id
WHERE os.stage='ordering' AND os.end IS NULL
ORDER BY from_delay DESC"]),
			self.find_by_sql(["SELECT o.id, o.buyer_order_number, o.title, o.customer, os.start, DATEDIFF(NOW(), os.start) AS from_delay FROM orders o
INNER JOIN order_stages os ON o.id=os.order_id
WHERE os.stage='warehouse' AND os.end IS NULL
ORDER BY from_delay DESC"]),
			self.find_by_sql(["SELECT o.id, o.buyer_order_number, o.title, o.customer, os2.end AS start, DATEDIFF(NOW(), os2.end) AS from_delay
FROM (
	SELECT CAST(SUBSTR(MAX(hint), LOCATE('$', MAX(hint)) + 1) AS UNSIGNED) AS last_os_id
	FROM (
		SELECT *, CONCAT(os.start,'$',os.id) AS hint
		FROM order_stages os
	) t1 GROUP BY t1.order_id
) AS t2
INNER JOIN order_stages os2 ON t2.last_os_id=os2.id
INNER JOIN orders o ON order_id=o.id
WHERE os2.stage='warehouse' AND os2.end IS NOT NULL
ORDER BY from_delay DESC"]),
		]
	end

	def self.with_testings
                Order.find_by_sql("select distinct orders.* from computers inner join testings on testings.computer_id = computers.id inner join orders on computers.order_id = orders.id where testings.id is not null order by orders.buyer_order_number")
	end
end
