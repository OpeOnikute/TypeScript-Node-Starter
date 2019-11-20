db.createUser({
    user: "otheruser",
    pwd: "example",
    roles: [
        {
            role: "readWrite",
            db: "ts-starter"
        }
    ]
});