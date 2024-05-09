require 'sinatra'
require 'sinatra/reloader'
require 'slim'
require 'sqlite3'
require 'bcrypt'
require_relative './model/model.rb'

include Modules

enable :sessions 

get('/') do 
    slim(:start)
end 

get('/gallery') do 
    show_all_images(session[:id])
end 

get('/gallery/new') do 
    slim(:"images/new")
end 

post('/gallery/new') do 
    create_new_image(params[:title], params[:desc], params[:url], session[:id])
end 

get('/gallery/:id') do 
    get_image_details(params[:id].to_i, session[:id])
end 

post('/gallery/:id/delete') do 
    delete_image(params[:id].to_i)
end 

get('/gallery/:id/edit') do 
    slim(:"/images/edit", locals: {result: get_image_details(params[:id].to_i, session[:id])})
end 

post('/gallery/:id/update') do 
    update_image(params[:id].to_i, params[:title], params[:desc], params[:url])
end 

get('/user/new') do 
    slim(:"register")
end 

post('/user/new') do
    manage_user_registration(params[:user], params[:email], params[:pswd], params[:pswd_confirm])
end 

get('/login') do
    slim(:"login")
end 

post('/login') do 
    user_id = user_login(params[:user], params[:pswd], session)
end 

get('/logout') do
    session.clear
    redirect('/')
end

get('/user') do
    user_gallery(session[:id])
end 

post('/gallery/:id/like') do
    manage_like(session[:id].to_i, params[:id].to_i, 'like')
end 

post('/gallery/:id/unlike') do
    manage_like(session[:id].to_i, params[:id].to_i, 'unlike')
end 


# KOLLA OM UNSERNAME REDAN FINNS ELLER INTE -- UTVECKLA DET SOM FINNS 
# LÄGG TIL LATT MAN KAN UPPLOADA BILDER ISTÄLLET FÖR LÄNKAR på bilder 