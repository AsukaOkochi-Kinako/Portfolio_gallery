class CreatePosts < ActiveRecord::Migration[5.2]
  def change
    create_table :posts do |t|
      t.integer :user_id
      t.string :post_user
      t.string :site_name
      t.string :site_url
      t.string :site_about
      t.text :comment
      t.integer :favorite
    end
  end
end
