class AddColumnToEmployee < ActiveRecord::Migration[6.1]
  def change
    add_column :employees, :news_posts_auth, :boolean, null: false,  default: false
  end
end
