require 'sinatra'
require 'sinatra/reloader'
require 'slim'
require 'sqlite3'
require 'bcrypt'
require 'sinatra/flash'
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

# Visar redigeringsformuläret för en specifik bild
#
# @param id [Integer] ID för den specifika bilden
# @param session_id [String] Användarens session-id
# @see Modules#get_image_details
# @return [String] Renderar redigeringsformuläret för en specifik bild
get('/gallery/:id/edit') do 
    slim(:"/images/edit", locals: {result: get_image_details(params[:id].to_i, session[:id])})
end 

# Uppdaterar information om en specifik bild
#
# @param id [Integer] ID för den specifika bilden
# @param title [String] Uppdaterad titel på bilden
# @param desc [String] Uppdaterad beskrivning av bilden
# @param url [String] Uppdaterad URL till bildfilen
# @see Modules#update_image
# @return [Redirect] Omdirigerar användaren till gallerivyn
post('/gallery/:id/update') do 
    update_image(params[:id].to_i, params[:title], params[:desc], params[:url])
end 

# Visar registreringsformuläret för nya användare
#
# @return [string] Renderar registreringsformuläret
get('/user/new') do 
    slim(:"register")
end 

# Hanterar registrering av en ny användare
#
# @param user [String] Användarnamnet
# @param email [String] E-postadressen
# @param pswd [String] Lösenordet
# @param pswd_confirm [String] Bekräftelse av lösenordet
# @see Modules#manage_user_registration
# @return [Redirect/String] Omdirigerar till startsidan eller visar felmeddelande
post('/user/new') do
    manage_user_registration(params[:user], params[:email], params[:pswd], params[:pswd_confirm])
end 

# Visar inloggningssidan
#
# @return [String] Renderar inloggningssidan
get('/login') do
    slim(:"login")
end 

# Hanterar inloggning för en användare
#
# @param user [String] Användarnamnet
# @param pswd [String] Lösenordet
# @param session [Hash] Session-hashen som används för att spara användar-id
# @see Modules#user_login
# @return [Redirect/String] Omdirigerar till startsidan eller visar felmeddelande
post('/login') do 
    user_id = user_login(params[:user], params[:pswd], session)
end 

# Hanterar utloggning för en användare
#
# @return [Redirect] Rensar sessionen och omdirigerar till startsidan
get('/logout') do
    session.clear
    redirect('/')
end

# Visar galleriet för den inloggade användaren
#
# @param session_id [String] Användarens session-id
# @see Modules#user_gallery
# @return [String] Renderar användarens personliga galleri
get('/user') do
    user_gallery(session[:id])
end 


#HHHHHHHHHHdfljgskfjghpdfijghsdpfighsdfjghHHHH

post('/user/delete') do
    delete_user(session[:id])
end 

# Gör att man kan gilla en specifik bild
#
# @param id [Integer] ID för den specifika bilden
# @param session_id [String] Användarens session-id
# @param action [String] Aktionen att utföra ('like')
# @see Modules#manage_like
# @return [Redirect] Omdirigerar användaren tillbaka till bilden --------------> Ändra till redirec till tidigare sida 

post('/gallery/:id/like') do
    manage_like(session[:id].to_i, params[:id].to_i, 'like')
end 

# Gör att man kan ogilla en specifik bild
#
# @param id [Integer] ID för den specifika bilden
# @param session_id [String] Användarens session-id
# @param action [String] Aktionen att utföra ('unlike')
# @see Modules#manage_like
# @return [Redirect] Omdirigerar användaren tillbaka till bilden
post('/gallery/:id/unlike') do
    manage_like(session[:id].to_i, params[:id].to_i, 'unlike')
end 



# MELLANRUM MELLAN DOC OCH GET
# KOLLA OM UNSERNAME REDAN FINNS ELLER INTE -- UTVECKLA DET SOM FINNS 