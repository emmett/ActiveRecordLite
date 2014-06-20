require_relative 'db_connection'
require_relative '01_sql_object'

module Searchable
  def where(params)
		criteria = params.keys.map { |key| "#{key} = ?" }.join(" AND ")
		sql = <<-SQL
		SELECT * 
		FROM #{table_name} 
		WHERE #{criteria}
		SQL
		result = DBConnection.execute(sql, *params.values)
		self.parse_all(result)
  end
end

class SQLObject
  extend Searchable
end
