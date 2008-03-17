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
ORDER BY from_delay ASC"]),
			self.find_by_sql(["SELECT o.id, o.buyer_order_number, o.title, o.customer, os.start, DATEDIFF(NOW(), os.start) AS from_delay FROM orders o
INNER JOIN order_stages os ON o.id=os.order_id
WHERE os.stage='warehouse' AND os.end IS NULL
ORDER BY from_delay ASC"]),
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
LEFT JOIN computers c ON c.order_id=o.id
WHERE os2.stage='warehouse' AND os2.end IS NOT NULL AND c.id IS NULL
ORDER BY from_delay ASC"]),
			self.find_by_sql(["SELECT o.id, o.buyer_order_number, o.title, o.customer, NOW(), 0 AS from_delay FROM orders o
INNER JOIN computers c ON c.order_id=o.id
LEFT JOIN computer_stages cs ON cs.computer_id=c.id
WHERE cs.id IS NULL AND o.id NOT IN (
	SELECT o2.id FROM orders o2 LEFT JOIN order_stages os2 ON o2.id=os2.order_id
	WHERE os2.stage = 'manufacturing'
)
ORDER BY from_delay DESC"]),
			self.find_by_sql(["SELECT o.id, o.buyer_order_number, o.title, o.customer, cs.start, DATEDIFF(NOW(), cs.start) AS from_delay, COUNT(c.id) AS comp_qty FROM orders o
INNER JOIN computers c ON c.order_id=o.id
LEFT JOIN computer_stages cs ON cs.computer_id=c.id
WHERE cs.stage='testing' AND cs.end IS NULL
GROUP BY o.id
ORDER BY from_delay DESC"]),
			self.find_by_sql(["SELECT o.id, o.buyer_order_number, o.title, o.customer, cs.start, DATEDIFF(NOW(), cs.start) AS from_delay FROM orders o
INNER JOIN computers c ON c.order_id=o.id
LEFT JOIN computer_stages cs ON cs.computer_id=c.id
WHERE cs.stage='checking' AND cs.end IS NULL
ORDER BY from_delay DESC"]),
			self.find_by_sql(["SELECT o.id, o.buyer_order_number, o.title, o.customer, cs.start, DATEDIFF(NOW(), cs.start) AS from_delay FROM orders o
INNER JOIN computers c ON c.order_id=o.id
LEFT JOIN computer_stages cs ON cs.computer_id=c.id
WHERE cs.stage='packing' AND cs.end IS NULL
ORDER BY from_delay DESC"]),
		]
	end

	def self.with_testings
                Order.find_by_sql("select distinct orders.* from computers inner join testings on testings.computer_id = computers.id inner join orders on computers.order_id = orders.id where testings.id is not null order by orders.buyer_order_number")
	end
end
