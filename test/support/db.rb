ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: "globalid.db")

ActiveRecord::Schema.define(version: 0) do
  create_table :users, force: true do |t|
    t.string :name
  end

  create_table :posts, force: true do |t|
    t.string :name
    t.references :user
  end
end