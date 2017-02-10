require_relative 'db_connection'
require 'active_support/inflector'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
  def self.columns
    @cols ||= DBConnection.execute2(<<-SQL).first.map(&:to_sym)
      SELECT
        *
      FROM
        #{self.table_name}
    SQL
  end

  def self.finalize!
    self.columns.each do |column|
      define_method(column.to_s) do
        self.attributes[column.to_sym]
      end
      define_method("#{column}=") do |value|
        self.attributes[column.to_sym] = value
      end
    end
  end

  def self.table_name=(table_name = nil)
    @table_name ||= table_name
  end

  def self.table_name
    @table_name || self.to_s.tableize
  end

  def self.all
    as_objects = DBConnection.execute(<<-SQL)
      SELECT #{self.table_name}.*
      FROM #{self.table_name}
    SQL
    self.parse_all(as_objects)
  end

  def self.parse_all(results)
    results.map do |obj|
      params = {}
      obj.each do |key, value|
        params[key] = value
      end
      self.new(params)
    end
  end

  def self.find(id)
    found = DBConnection.execute(<<-SQL, id)
      SELECT #{self.table_name}.*
      FROM #{self.table_name}
      WHERE #{self.table_name}.id = ?
    SQL
    found.nil? ? nil : self.parse_all(found).first
  end

  def initialize(params = {})
    params.each do |attr_name, value|
      unless self.class.columns.include? attr_name.to_sym
        raise("unknown attribute '#{attr_name}'")
      end
      send("#{attr_name}=", value)
    end

  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    # ...
  end

  def insert
    # ...
  end

  def update
    # ...
  end

  def save
    # ...
  end
end
