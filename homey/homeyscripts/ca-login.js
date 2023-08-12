// Login to Chargeamps eapi - either at script console or from a flow
// store ca-token and ca-refreshToken
// fetch chargePointId (first one that belongs to user), store i ca-chargePointId
// https://eapi.charge.space/swagger
// (c) 2023 Niklas Ögren - no@nod.se
const baseUrl = 'https://eapi.charge.space';

const vars = await Homey.logic.getVariables(); 
const email = _.find(vars, (o) => o.name === "ca-email");
const password = _.find(vars, (o) => o.name === "ca-password");
const apiKey = _.find(vars, (o) => o.name === "ca-apikey");
const data = { email: email.value, password: password.value };

const res = await fetch(baseUrl + '/api/v4/auth/login', {
        method: 'post',
        body:    JSON.stringify(data),
        headers: { 'Content-Type': 'application/json', 'apiKey': apiKey },
    });

if (!res.ok) {
  throw new Error(res.statusText);
}

const body = await res.json();
log(body);
global.set('ca-token', body.token);
global.set('ca-refreshToken', body.refreshToken);

// Get first chargePointId
const res2 = await fetch(baseUrl + '/api/v4/chargepoints/owned', {
        method: 'get',
        headers: { 'Content-Type': 'application/json', 'Authorization': 'Bearer ' + global.get('ca-token') },
    });

if (!res2.ok) {
  throw new Error(res2.statusText);
}
const body2 = await res2.json();
log(body2)
global.set('ca-chargePointId', body2[0].id);
log('chargePointId: ' + body2[0].id)
return true
