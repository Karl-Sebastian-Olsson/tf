require 'sinatra'
require 'sinatra/reloader'
require 'slim'
require 'sqlite3'

get('/') do 
    slim(:start)
end 
 
# I DATABASEN LÄGG TILL BILDBESKRIVNING


get('/gallery') do 
    db = SQLite3::Database.new("model/db/store.db")
    db.results_as_hash = true
    result = db.execute("SELECT * FROM Images")
    slim(:"images/index", locals:{result:result})
end 

get('/gallery/new') do 
    slim(:"images/new")
end 

post('/gallery/new') do 
    title = params[:title]
    url = params[:url]
    db = SQLite3::Database.new("model/db/store.db")
    db.execute("INSERT INTO Images (Title, Url) VALUES (?, ?)", title, url)
    redirect('/gallery')
end 

get('/gallery/:id') do 
    id = params[:id].to_i
    db = SQLite3::Database.new("model/db/store.db")
    db.results_as_hash = true
    result = db.execute("SELECT * FROM Images WHERE Iid = ?", id).first
    slim(:"images/show", locals:{result:result})
end 

post('/gallery/:id/delete') do 
    id = params[:id].to_i
    db = SQLite3::Database.new("model/db/store.db")
    db.execute("DELETE FROM Images WHERE Iid = ?", id)
    redirect('/gallery')
end 

get('/gallery/:id/edit') do 
    id = params[:id].to_i
    db = SQLite3::Database.new("model/db/store.db")
    db.results_as_hash = true
    result = db.execute("SELECT * FROM Images WHERE Iid = ?", id).first
    slim(:"/images/edit",locals:{result:result})
end 

post('/gallery/:id/update') do 
    id = params[:id].to_i
    title = params[:title]
    url = params[:url]
    db = SQLite3::Database.new("model/db/store.db")
    db.execute("UPDATE Images SET Title=?,Url=? WHERE Iid = ?",title,url,id)
    redirect('/gallery')
end 