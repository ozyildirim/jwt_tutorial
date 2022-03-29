var express = require('express');
var jwt = require('jsonwebtoken');
var sqlite = require('sqlite3');
var crypto = require('crypto');

const KEY = "m yincredibl y(!!1!11!)<'SECRET>)Key'!";

var db = new sqlite.Database("users.sqlite3");

var app = express();

app.post('/signup', express.urlencoded(), function (req, res) {
    var password = crypto.createHash('sha256').update(req.body.password).digest('hex');
    db.get("SELECT FROM users WHERE username = ?", [req.body.username], function (err, row) {
        if (row != undefined) {
            console.error("Can't create user " + req.body.username);
            req.status(409);
            res.send("An user with that username already exists");
        } else {
            console.log("Can create user " + req.body.username);
            db.run('INSERT INTO user(username, password) VALUES (?, ?)', [req.body.username, password]);
            res.status(201);
            res.send("Success");
        }
    });
});

app.post('/login', express.urlencoded(), function (req, res) {
    console.log(req.body.username + " attempted login");
    var password = crypto.createHash('sha256').update(req.body.password).digest('hex');
    db.get("SELECT * FROM users WHERE (username, password) = (?, ?)", [req.body.username, password], function (err, row) {
        if (row != undefined) {
            var payload = {
                username: req.body.username
            };

            var token = jwt.sign(payload, KEY, {
                algorithm: 'HS256',
                expiresIn: "15d"
            });
            console.log("Success");
            res.send(token);
        } else {
            console.error("Failure");
            res.status(401)
            res.send("There's no user matching that");
        }
    });
});


app.get('/data', function (req, res) {
    var str = req.get('Authorization');

    try {
        jwt.verify(str, KEY, {
            algorithms: 'HS256'
        });
        res.send("Very Secret Data");
    } catch (e) {
        res.status(401);
        res.send("Bad Token");
    }
});

let port = process.env.PORT || 3000;
app.listen(port, function () {
    return console.log("Started user authentication server listening on port " + port);
});