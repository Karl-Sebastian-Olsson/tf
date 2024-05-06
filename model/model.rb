def db_define()
    db = SQLite3::Database.new("model/db/store.db")
    db.results_as_hash = true
    return db
end

def authorize(db, uid)
    if uid != 0
        return db.execute("SELECT Role FROM Users WHERE Uid = ?", uid).first["Role"]
    else 
        return "Guest"
    end
end 