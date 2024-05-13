require 'sinatra'
require 'sinatra/reloader'
require 'slim'
require 'sqlite3'
require 'bcrypt'
require_relative './model/model.rb'

include Modules

enable :sessions 

# Visar startsidan för webbapplikationen 
#
# @return [string] Renderar landningssidan för webbapplikationen  

get('/') do 
    slim(:start)
end 

# Visar alla bilder som tillgängliga 
#
# @param session_id [string] Lokalt sparad sträng för session id 
# @return [string] Renderar alla bilder i ett album-format
# @see Modules#show_all_images

get('/gallery') do 
    show_all_images(session[:id])
end 

# Visar formuläret för att lägga till en ny bild
#
# @return [string] Renderar formulärsidan för att lägga till en ny bild

get('/gallery/new') do 
    slim(:"images/new")
end 

# Skapar en ny bild och sparar den i databasen
#
# @param title [String] Titeln på bilden
# @param desc [String] Beskrivning av bilden
# @param url [String] URL till bildfilen
# @param session_id [String] Användarens session-id
# @see Modules#create_new_image
# @return [Redirect] Omdirigerar användaren till gallerivyn

post('/gallery/new') do 
    create_new_image(params[:title], params[:desc], params[:url], session[:id])
end 

# Visar detaljer för en specifik bild
#
# @param id [Integer] ID för den specifika bilden
# @param session_id [String] Användarens session-id
# @see Modules#get_image_details
# @return [String] Renderar detaljvy för en specifik bild

get('/gallery/:id') do 
    get_image_details(params[:id].to_i, session[:id])
end 

# Tar bort en specifik bild från databasen
#
# @param id [Integer] ID för den specifika bilden som ska tas bort
# @see Modules#delete_image
# @return [Redirect] Omdirigerar användaren till gallerivyn

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
# YARDOC FUCKER