ActiveRecord::Schema.define do
  self.verbose = false

  create_table :users, force: true do |t|
    t.integer :actions
    t.timestamps
  end

  create_table :posts, force: true do |t|
    t.integer :user_id
    t.timestamps
  end
end
