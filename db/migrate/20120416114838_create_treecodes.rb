class CreateTreecodes < ActiveRecord::Migration
  def change
    create_table :treecodes do |t|
      t.string      :node_class, :null => false, :limit => 20
      t.string      :node, :null => false, :limit => 15
      t.string      :parent_node, :limit => 15
      t.string      :node_cn, :limit => 100
      t.string      :node_en, :limit => 100
      t.boolean     :use_flag, :default => true
      t.string      :value1, :limit => 25
      t.string      :value2, :limit => 25
      t.string      :sort_order, :limit => 10
      t.string      :color, :limit => 20
      
      t.timestamps
    end

    add_index :treecodes, [ :node_class, :node ], :unique => true
  end
end
