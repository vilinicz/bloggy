class CreateComments < ActiveRecord::Migration[8.1]
  def change
    create_table :comments do |t|
      t.references :article, null: false, foreign_key: true
      t.text :body, null: false
      t.string :author_name, null: false, limit: 100

      t.timestamps
    end

    add_index :comments, %i[article_id created_at id],
              order: { created_at: :desc, id: :desc },
              name: "index_comments_on_article_id_created_at_desc_id_desc"
  end
end
