'use strict';

const Koa = require('koa');
const app = new Koa();
const headerExcludeList = [
    'host', 
    'connection', 
    'accept',
    'cache-control',
    'sec-ch-ua',
    'sec-ch-ua-mobile',
    'sec-ch-ua-platform',
    'dnt',
    'upgrade-insecure-requests',
    'sec-fetch-site',
    'sec-fetch-mode',
    'sec-fetch-user',
    'sec-fetch-dest'
]

app.use(ctx => {
    let headerList = '';
    for ( let head in ctx.request.header ) {
        if ( headerExcludeList.includes(head)) continue;
        headerList += ` * ${head}: ${ctx.request.header[head]}\n`
    }
    ctx.body = `Hello there!
You're coming from ${ctx.request.ip} looking for ${ctx.request.header.host}. 
(some of) your headers are: \n${headerList}`
    console.log(ctx.request);
});

app.listen(80);