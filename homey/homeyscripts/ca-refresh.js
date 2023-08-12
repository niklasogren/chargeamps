// Refresh tokens  to Chargeamps eapi
// Run from a flow every N minutes (N=55?)
// https://eapi.charge.space/swagger
// (c) 2023 Niklas Ögren - no@nod.se

const baseUrl = 'https://eapi.charge.space';

const token = global.get('ca-token');
const refreshToken = global.get('ca-refreshToken');

const data = { token: token, refreshToken: refreshToken };

const res = await fetch(baseUrl + '/api/v4/auth/refreshtoken', {
        method: 'post',
        body:    JSON.stringify(data),
        headers: { 'Content-Type': 'application/json' },
    });

if (!res.ok) {
  throw new Error(res.statusText);
}

const body = await res.json();
log(body);
global.set('ca-token', body.token);
global.set('ca-refreshToken', body.refreshToken);
return true
