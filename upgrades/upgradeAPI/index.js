// server.js

var express    = require('express'); // call express
var app        = express(); // define our app using express
var bodyParser = require('body-parser');
var JSONminify = require('../json.minify.js');
var fs         = require('fs');

var loadVersionsFile = function(path) {
    var versionsObject;
    var fContents;
        if (fs.existsSync(path)) {
            fContents = fs.readFileSync(path, 'utf8');
            versionsObject = JSON.parse(JSONminify(fContents));
        }
        return versionsObject;
};


app.use(bodyParser.urlencoded({ extended: true }));
app.use(bodyParser.json());

var port = process.env.PORT || 8080; // set our port

var router = express.Router();


router.get('/versions', function(req, res) {

// Loading the file for every request now but for production
// This should be modified to be loaded every X number of hours
var versionObject = loadVersionsFile('./versions.json');
    console.log(versionObject);
    res.json(versionObject);
});

app.use('/api', router);

app.listen(port);
console.log('Listening on port ' + port);
