require 'bundler/setup'
Bundler.require
require 'sinatra/reloader' if development?
require './models.rb'
require 'securerandom'

enable :sessions

before do
    if User.count == 0
        User.create(
          user_name: "管理者",
          mail: "admin",
          password: "8931",) 
    end
    
    if Play.count == 0
        Play.create(
         title: "巨大まちかねワニからの脱出",
         kv: "wani.jpg",
         description: "新歓イベントのための特別公演！
         迫りくる巨大まちかねワニから町を守り切れ！",
         capacity: 60)
    end
    
    if Schedule.count == 0
        Schedule.create(
          play_id: 1,
          day: '2026-06-08',
          time: '12:30',
          duration: 90,
          book_number: 0)
        Schedule.create(
          play_id: 1,
          day: '2026-06-08',
          time: '14:30',
          duration: 90,
          book_number: 60)
        Schedule.create(
          play_id: 1,
          day: '2026-06-09',
          time: '12:30',
          duration: 90,
          book_number: 45)
    end
    
    if Riddle.count == 0
        Riddle.create(
          play_id: 1,
          order: 1,
          img: "moon.png",
          answer: "まんげつ",
          explain: "解説",
          point: 10)
        Riddle.create(
          play_id: 1,
          order: 2,
          img: "sirokuro.png",
          answer: "しろくま",
          explain: "解説",
          point: 10)
    end
end

get '/' do
    if session[:user]
        if session[:user] == 1
            redirect '/admin/plays/1'
        else
            redirect '/plays/1'
        end
    else
        redirect '/sign_in'
    end
end

get '/plays/:id' do
    @play = Play.find(params[:id])
    @schedule_days = @play.schedules.order(:day,:time).group_by(&:day)
    erb :detail
end

get '/plays/:id/book/:schedule_id' do
    @play = Play.find(params[:id])
    @schedule = Schedule.find(params[:schedule_id])
    erb :booking
end

post '/plays/:id/book/:schedule_id' do
    random_token = SecureRandom.hex(8)
    
    book = Book.create(
      user_id: session[:user],
      play_id: params[:id],
      schedule_id: params[:schedule_id],
      headcount: params[:headcount],
      token: random_token)
      
    Guest.create(
      book_id: book.id,
      guest_name: params[:guest_name],
      score: 0,
      is_leader: true)
     
    schedule = Schedule.find(params[:schedule_id]) 
    schedule.update(book_number: schedule.book_number + params[:headcount].to_i)
      
    redirect "/guest/#{book.token}/riddle"
end

get '/guest/:token/riddle' do
    book = Book.find_by(token: params[:token])
    @riddles = book.play.riddles
    
    erb :riddle
end

post '/guest/:token/riddle' do
    score = 0
    book = Book.find_by(token: params[:token])
    riddles = Riddle.where(play_id: book.play_id)
    
    riddles.each do |nazo|
        user_answer = params["nazo-#{nazo.order}"]
        
        if user_answer == nazo.answer
            score += nazo.point
        end
    end

    if book.guests.first
        book.guests.first.update(score: score)
    end
    
    redirect "/guest/#{book.token}/thanks"
end

get '/guest/:token/thanks' do
    @book = Book.find_by(token: params[:token])
    @play = @book.play
    @schedule = @book.schedule
    @guest = @book.guests.first
    
    erb :thanks
end

get '/sign_in' do
    erb :sign_in
end

post '/sign_in' do
    user = User.find_by(mail: params[:mail])
    
    if user && user.authenticate(params[:password])
        session[:user] = user.id
        redirect '/'
    else
        redirect 'sign_in'
    end
end

get '/sign_up' do
    erb :sign_up
end

post '/sign_up' do
    if params[:password] == params[:password_confirm]
        user = User.new(user_name: params[:user_name], mail: params[:mail], password: params[:password])
        
=begin
        if params[:icon_img]
            filename = params[:icon_img][:filename]
            tempfile = params[:icon_img][:tempfile]
            
            save_path = "./public/assets/icon/#{filename}"
            File.open(save_path, 'wb') do |f|
            f.write(tempfile.read)
            end
            
            user.img = filename
        else
            user.img = "none.png"
        end
=end
            
        if user.save
            session[:user] = user.id
            redirect '/'
        end
    end
    redirect '/sign_up'
end

get '/sign_out' do
    session.clear
    redirect '/'
end

get '/admin/plays/:id' do
    @play = Play.find(params[:id])
    @schedule_days = @play.schedules.order(:day,:time).group_by(&:day)
    @books = @play.books.order(:updated_at).all
    
    erb :admin_detail
end