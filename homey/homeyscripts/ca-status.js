// Print a few status objects to be run manually in script console
// https://eapi.charge.space/swagger
// (c) 2023 Niklas Ögren - no@nod.se

const baseUrl = 'https://eapi.charge.space';

const token = global.get('ca-token');
const chargePointId = global.get('ca-chargePointId');

fetch(baseUrl + '/api/v4/chargepoints/owned', {
        method: 'get',
        headers: { 'Content-Type': 'application/json', 'Authorization': 'Bearer ' + token },
    })
    .then(res => res.json())
    .then(json => console.log(json));

fetch(baseUrl + '/api/v4/chargepoints/' + chargePointId, {
        method: 'get',
        headers: { 'Content-Type': 'application/json', 'Authorization': 'Bearer ' + token },
    })
    .then(res => res.json())
    .then(json => console.log(json));

fetch(baseUrl + '/api/v4/chargepoints/' + chargePointId + '/status', {
        method: 'get',
        headers: { 'Content-Type': 'application/json', 'Authorization': 'Bearer ' + token },
    })
    .then(res => res.json())
    .then(json => console.log(json));

fetch(baseUrl + '/api/v4/chargepoints/' + chargePointId + '/settings', {
        method: 'get',
        headers: { 'Content-Type': 'application/json', 'Authorization': 'Bearer ' + token },
    })
    .then(res => res.json())
    .then(json => console.log(json));

return true
