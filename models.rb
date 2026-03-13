require 'bundler/setup'
Bundler.require

ActiveRecord::Base.establish_connection

class User < ActiveRecord::Base
    has_secure_password
    
    has_many :books
    has_many :booking_plays, through: :books, source: :play
end

class Play < ActiveRecord::Base
    has_many :books
    has_many :users, through: :books
    has_many :schedules
    has_many :riddles
end

class Schedule < ActiveRecord::Base
    belongs_to :play
end

class Riddle < ActiveRecord::Base
    belongs_to :play
end

class Book < ActiveRecord::Base
    belongs_to :user
    belongs_to :play
    
    has_many :guests
end

class Guest < ActiveRecord::Base
    belongs_to :book
end
