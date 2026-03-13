require 'bundler/setup'
Bundler.require
require 'sinatra/reloader' if development?
require './models.rb'

enable :sessions

before do
    if Play.count == 0
        Play.create(
         title: "巨大まちかねワニからの脱出",
         kv: "wani.jpg",
         description: "新歓イベントのための特別公演！迫りくる巨大まちかねワニから町を守り切れ！",
         capacity: 60)
    end
    
    if Schedule.count == 0
        Schedule.create(
          play_id: 1,
          day: '2026-06-08',
          time: '12:30',
          duration: 90)
        Schedule.create(
          play_id: 1,
          day: '2026-06-08',
          time: '14:30',
          duration: 90) 
        Schedule.create(
          play_id: 1,
          day: '2026-06-09',
          time: '12:30',
          duration: 90)   
    end
    
    @play = Play.find(params[:id])
end

get '/' do
    if session[:user]
        redirect '/plays/1'
    else
        redirect '/sign_in'
    end
end

get '/plays/:id' do
    @schedule_days = @play.schedules.order(:day,:time).group_by(&:day)
    erb :detail
end

get '/plays/:id/book/:day' do
    
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