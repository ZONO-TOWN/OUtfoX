class NewTables < ActiveRecord::Migration[7.2]
  def change
    create_table :plays do |play|
      play.string :title
      play.string :kv
      play.text :description
      play.integer :capacity
      play.timestamps
    end
    
    create_table :schedules do |s|
      s.integer :play_id
      s.date :day
      s.time :time
      s.integer :duration
    end
    
    create_table :riddles do |r|
      r.integer :play_id
      r.integer :order
      r.string :img
      r.string :answer
      r.text :explain
      r.integer :level
    end
    
    create_table :users do |u|
      u.string :user_name
      u.string :mail
      u.string :password_digest
      u.timestamps
    end
    
    create_table :books do |b|
      b.integer :user_id
      b.integer :play_id
      b.integer :headcount
      b.string :token
      b.timestamps
    end
    
    create_table :guests do |g|
      g.integer :book_id
      g.string :guest_name
      g.integer :score
      g.boolean :is_leader
    end
  end
end
