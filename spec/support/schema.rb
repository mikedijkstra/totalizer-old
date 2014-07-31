ActiveRecord::Schema.define do
  self.verbose = false

  create_table :users, force: true do |t|
    t.string :created_at
    t.integer :actions

    t.timestamps
  end

end
