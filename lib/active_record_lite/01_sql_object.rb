require_relative 'db_connection'
require 'active_support/inflector'
#NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
#    of this project. It was only a warm up.

class SQLObject
	def self.columns
		cols = DBConnection.execute2("SELECT * FROM #{table_name}")[0]
		@columns = []
		cols.each do |key|
			@columns << key.to_sym
			define_method "#{key}" do
				attributes[key.to_sym]
			end
			
			define_method "#{key}=" do |value|
				attributes[key.to_sym] = value
			end
		end
		@columns
	end
	
	def attributes
		@attributes ||= {}
	end

	def self.table_name=(table_name) 
		@table_name = table_name
	end

	def self.table_name
		@table_name ||= self.to_s.tableize
	end

	def self.all
		results = DBConnection.execute("SELECT #{table_name}.* FROM #{table_name}")
		parse_all(results)
	end
  
	def self.parse_all(results)
		results.map {|result| self.new(result)}
	end

	def self.find(id)
		sql = <<-SQL
		SELECT #{table_name}.* 
		FROM #{table_name} 
		WHERE #{table_name}.id = (?)
		SQL
		result = DBConnection.execute(sql, id)
		parse_all(result)[0]
	end

	def insert
		col_names = attributes.keys.join(", ")
		question_marks = (["?"] * attributes.count).join(", ")
		DBConnection.execute(<<-SQL, *attributes.values
	  INSERT INTO #{self.class.table_name}(#{col_names})
		VALUES (#{question_marks})
		SQL
		)
		self.id = DBConnection.last_insert_row_id
	end
	
	def initialize(attr_name = {})
		attr_name.each do |key, value|
			unless self.class.columns.include?(key.to_sym)
				raise "unknown attribute '#{key}'"
			else
				attributes[key.to_sym] = value
			end
		end
	end

	def save
		id.nil? ? self.insert : self.update
	end

	def update
		col_names = attributes.keys.map {|key| "#{key} = ? "}.join(', ')
		DBConnection.execute(<<-SQL, *attributes.values, self.id
	  UPDATE #{self.class.table_name}
		SET #{col_names}
		WHERE id = ?
		SQL
		)
	end

	def attribute_values
		attributes.values
	end
end