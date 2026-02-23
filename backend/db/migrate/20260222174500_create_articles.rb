class CreateArticles < ActiveRecord::Migration[8.1]
  def change
    create_table :articles do |t|
      t.string :title, null: false, limit: 200
      t.text :body, null: false
      t.string :author_name, null: false, limit: 100
      t.integer :comments_count, null: false, default: 0

      t.timestamps
    end

    add_index :articles, %i[created_at id],
              order: { created_at: :desc, id: :desc },
              name: "index_articles_on_created_at_desc_id_desc"
    add_index :articles, :comments_count
  end
end
