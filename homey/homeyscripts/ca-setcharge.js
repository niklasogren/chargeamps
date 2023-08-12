// Set args[0] (an integer) as current maxCurrent level in first chargePointId
// Run from a flow with arg.
// https://eapi.charge.space/swagger
// (c) 2023 Niklas Ögren - no@nod.se

const baseUrl = 'https://eapi.charge.space';

const token = global.get('ca-token');
const chargePointId = global.get('ca-chargePointId');

//if (typeof args[0] !== 'integer') {
//  throw new Error('This script must be run from a Flow with a number argument!');
//}

const maxCurrent = args[0];

const data = { id: chargePointId, maxCurrent: maxCurrent };

const res = await fetch(baseUrl + '/api/v4/chargepoints/' + chargePointId + '/settings', {
        method: 'put',
        body:    JSON.stringify(data),
        headers: { 'Content-Type': 'application/json', 'Authorization': 'Bearer ' + token },
    });

if (!res.ok) {
  throw new Error(res.statusText);
}
log(await res);
return true
