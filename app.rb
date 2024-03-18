require 'sinatra'
require 'sinatra/reloader'
require 'slim'
require 'sqlite3'

get('/') do 
    slim(:index)
end 

#          BYT NAMN PÅ IMAGES(folder) TILL ALBUM, INDEX TILL START OCH IMAGES.slim TILL INDEX

get('/images') do 
    db = SQLite3::Database.new("model/db/store.db")
    db.results_as_hash = true
    result = db.execute("SELECT * FROM Images")
    slim(:"images/images", locals:{images:result})
end 

get('/images/:id') do 
    id = params[:id].to_i
    db = SQLite3::Database.new("model/db/store.db")
    db.results_as_hash = true
    result = db.execute("SELECT * FROM Images WHERE Iid = ?", id).first
    slim(:"images/show", locals:{result:result})
end 

post('/images/:id/delete') do 
    id = params[:id].to_i
    db = SQLite3::Database.new("model/db/store.db")
    db.execute("DELETE FROM Images WHERE Iid = ?", id)
    redirect('/images')
end 

get('/images/new') do 
    slim(:"images/new")
end 

post('/images/new') do 
    title = params[:title]
    url = params[:url]
    db = SQLite3::Database.new("model/db/store.db")
    db.execute("INSERT INTO Images (Title, Url) VALUES (?, ?)", title, url)
    redirect('/images')
end 