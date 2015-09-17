require 'consistency_fail/index'

module ConsistencyFail
  module Introspectors
    class TableData
      def unique_indexes(model)
        return [] if !model.table_exists?

        unique_indexes_by_table(model, model.connection, model.table_name)
      end

      def unique_indexes_by_table(model, connection, table_name)
        schema = "public"
        if ActiveRecord::Base.connection.instance_values["config"][:adapter] == "postgresql"
          schema = ActiveRecord::Base.connection.execute("select current_schema();").to_a.first["current_schema"]
        end
        table_name = "#{schema}." + table_name if table_name.present?
        ar_indexes = connection.indexes(table_name).select(&:unique)
        result = ar_indexes.map do |index|
          ConsistencyFail::Index.new(model,
                                     table_name,
                                     index.columns)
        end
        result
      end
    end
  end
end
