//var EEwriter = require('./wwfactory_eeprom_writer.js');
var Promise = require('es6-promise').Promise;
var fs = require('fs');
// const x509 = require('x509');
// var mimelib = require("mimelib");

readJsonFile = function(filePath, options) {
	var mtself = this;
	return new Promise(function(resolve, reject) {
		fs.readFile(filePath, options, function(error, data) {
			if (error) {
				reject(error);
			}
			else {
				resolve(data);
			}
		});
	});
}

fixCert = function(str) {
	var ray = str.split("\n");
	return ray;

}

getBufferRay = function(ray) {
	var m = new Array();

	ray.pop();
	ray.shift();
	ray.forEach(function(e, i, a) {
		var buf = new Buffer(e, 'base64');
		//console.log(e);
		//console.log(buf);
		//console.log("----");
		m.push(buf);
	});
	console.log(m.length + " x " + m[0].length + " (" + m.length * m[0].length + ")");
	return m;
}

main = function() {
	readJsonFile("./example.json").then(function(result) {
		var j = JSON.parse(result);
		j.ssl.client.certificate = fixCert(j.ssl.client.certificate);
		j.ssl.server.certificate = fixCert(j.ssl.server.certificate);
		j.ssl.client.key = fixCert(j.ssl.client.key);
		j.ssl.server.key = fixCert(j.ssl.server.key);
		//	console.dir(j.ssl);

		j.ssl.client.certificate.bufferRay = getBufferRay(j.ssl.client.certificate);
		j.ssl.client.key.bufferRay = getBufferRay(j.ssl.client.key);
		j.ssl.server.certificate.bufferRay = getBufferRay(j.ssl.server.certificate);
		j.ssl.server.key.bufferRay = getBufferRay(j.ssl.server.key);
		//console.log(JSON.stringify(j));

	}).catch(function(error) {
		console.log("debug", "Read Json file errored: " + error);
	});
}

simpletest = function() {
	console.log("biggie test -------------");
	var biggie = "MIIFTDCCAzSgAwIBAgICAMcwDQYJKoZIhvcNAQELBQAwUzELMAkGA1UEBhMCVVMxDjAMBgNVBAgMBVRleGFzMRMwEQYDVQQKDApXaWdXYWcgSW5jMR8wHQYDVQQDDBZXaWdXYWcgSW50ZXJtZWRpYXRlIENBMB4XDTE2MDYwMzEyNDAyN1oXDTM2MDUyOTEyNDAyN1owWDELMAkGA1UEBhMCVVMxDjAMBgNVBAgMBVRleGFzMQ8wDQYDVQQHDAZBdXN0aW4xEzARBgNVBAoMCldpZ1dhZyBJbmMxEzARBgNVBAMMCldXUkwwMDAwMDAwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDQu0V1I84zA4USUhuepURXAaILaRDA3H29kF2zaD9ZLueZpXSxAQ0NpqS3VVz/pzxqdy2AkbD3Nh6Z0rQrYBkqUo9mdRYxrMipBH+dhIhAChTHiB7CccjDz4c7Ol0rc+RrzdT31kDIC3LM+kRJlCQ3v6wPATK4/1JA2L4O5hSkzARMtIqobcJqumPnC2yzQsSQsMCINmBzNVnx0mquHIvDaUqL64dCBfvNgKwbfhIa+fxfVad1u16ox0K/t+bd+GmC7xIEHHf3HJdR8JDrnhTadySSjx6IoSv+RwdJP9prsdX01fijL4W3OCKX5fyNMq2wMNioWRHXk0PdLc9ycYd1AgMBAAGjggEjMIIBHzAJBgNVHRMEAjAAMBEGCWCGSAGG+EIBAQQEAwIGQDAzBglghkgBhvhCAQ0EJhYkT3BlblNTTCBHZW5lcmF0ZWQgU2VydmVyIENlcnRpZmljYXRlMB0GA1UdDgQWBBSF7CVKHrPLF2aySO6XQuPRBL6FBDCBhQYDVR0jBH4wfIAUD9eDvQ5/CzQId3Szj35Qe1MvrXehYKReMFwxCzAJBgNVBAYTAlVTMQ4wDAYDVQQIDAVUZXhhczEPMA0GA1UEBwwGQXVzdGluMRMwEQYDVQQKDApXaWdXYWcgSW5jMRcwFQYDVQQDDA5XaWdXYWcgUm9vdCBDQYICEAAwDgYDVR0PAQH/BAQDAgWgMBMGA1UdJQQMMAoGCCsGAQUFBwMBMA0GCSqGSIb3DQEBCwUAA4ICAQBNEtFMNhelLb6tClHagAeTONtxQDYlmYp4+4OXDeOFWsB7P/w945jundbevKqc7QbFioUsIT8kCrP/sOo8F2kZ63xuKOJvDA7AiPXyR/pLkRcpm6t2srXV/cqTsVPm+z8bpvTQsqIGQneqmQALOcolX2J1UXG7ILveE1g+O8TPAT103mouRZ8ETBUktI5+QA0AZiPbWQvN1kxG6an8TEzGVYGWiyLE32J2VmyhSJnPS0a+6wzCJn9McSHZ486onMFFiz+od6fqzh+Vo6jQnjdGNRWMRbd/At/sWhiXJeXMEdAbh3XKTn40JrKol3EyRBhhEmZFc4Q0yDnRNqEf7rJBUL+QbE6kZllxEVcCSfCZf9xq9d2BiIQzt8My2KrqnN4wAYSeGCFSnrmbFH1/aPYpSR/glj0FB67r2otIhCrJK+R4ucKXRK8mVJZh0a1Z6nL68khWTWyA2+pVrjBlOJgdW8SMvdyBoC+ond/CuNyMmqP/T6PBT8/7M2IzbSn+rid7y6UE1dTzVw/oTWiL9Uob/G553p8rL4xvaPTjfwc7SO2qLDI4eZbLTjszDlFpH2w2l4rnffKhDykQtrljbgQ4aAbSVK1nxsWNfbNwEBd+CFwLpGs6L3torad3SND2C2xlvTc0FEDTZVg89Iqi6E3IzRjm+OHSWWfWpjblTq6XQA=="
	var buffer2 = new Buffer(biggie, 'base64');
	console.log(buffer2);
	console.log(buffer2.length);
}

main();
//simpletest();

// // //console.log(buffer2.toString('MIME'));
// // //c //onsole.log(mimelib.decodeBase64(biggie));
// // //console.log(__dirname + "/out.crt");
// // //fs.writeFileSync(__dirname + "/out.crt", biggie);
// // var cert = x509.parseCert(__dirname + '/out.crt');
// //console.log(cert);
// null;