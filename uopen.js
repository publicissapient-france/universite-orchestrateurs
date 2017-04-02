#!/usr/bin/env node
let fs = require('fs');

let input ="scripts/services.json";

let services = JSON.parse(fs.readFileSync(input, 'utf8'));


function printServices() {
    console.log("Available services :");
    for (let key in services) {
        console.log(`  ${key}`);
    }
}
if (process.argv.length < 3) {
    printServices();
    process.exit(0)
}

let service = process.argv[2];

let service_url = services[service];
if(service_url !== undefined) {
    let exec = require('child_process').exec;
    // On Linux systems we should try to call xdg-open instead of open
    let cmd = `/usr/bin/open ${service_url}`;

    exec(cmd, function (error, stdout, stderr) {
        console.log(error);
        // command output is in stdout
    });
}else{
    console.error(`Unkown service ${service}`);
    printServices();
    process.exit(1)
}
