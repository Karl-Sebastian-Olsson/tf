def authorize(db, uid)
    if uid != 0
        return db.execute("SELECT Role FROM Users WHERE Uid = ?", uid).first["Role"]
    else 
        return "Guest"
    end
end 