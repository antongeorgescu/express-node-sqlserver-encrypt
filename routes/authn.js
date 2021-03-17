const permissions = [
    {permission: 'RestrictedAccess', description: 'read restricted to non-sensitive information', password: 'reporter@1'},
    {permission: 'FullAccess', description: 'read sensitive information', password: 'contributor@1'}
];

const groups = [
    {group: 'Agents', description: 'agents who can manage users and can read restricted data'},
    {group: 'Supervisors', description: 'agents who can manage users and can read full access data'}
];

const roles = [
    {role: 'Reporter', description: 'report on data, by using read-only endpoints, with no sensitive data shown'},
    {role: 'Contributor', description: 'manage data by using read/write end points'}
]

const organizations = [
    {organization : 'UGuelph', description : 'University of Guelph, Guelph, Ontario'},
    {organization : 'UWaterloo', description : 'Waterloo University, Waterloo, Ontario'},
    {organization : 'CSheridan', description : 'Sheridan College, Oakville, Ontario'},
    {organization : 'NSLSC', description : 'National Student Loans Service Centre'}
]

const tenants = [
    {tenant : 'FedUniFT', description : 'Federal university full-time Loans'},
    {tenant : 'ProvColPT', description : 'Provincial college part-time loans'},
]

const profiles = [
    {user : 'Anton', email:'antongeorgescu@gmail.com'},
    {user : 'Daniela', email:''},
    {user : 'Alex', email:''},
    {user : 'Kora', email:''},
    {user : 'Jake', email:''},
    {user : 'Alvianda', email:'alvianda@gmail.com'}
]

const users = [
    {user : 'Jake', group : 'Supervisors', role : '', org: 'UGuelph', tenant : 'FedUniFT', permission : ''},
    {user : 'Daniela', group : 'Supervisors', role : '', org: 'CSheridan', tenant : 'ProvColPT', permission : ''},
    {user : 'Alex', group : 'Agents', role : 'Contributor', org: 'UGuelph', tenant : 'FedUniFT', permission : 'FullAccess'},
    {user : 'Kora', group : 'Agents', role : 'Reporter', org: 'UWaterloo', tenant : 'FedUniFT', permission : 'RestrictedAccess'},
    {user : 'Anton', group : 'Agents', role : 'Reporter', org: 'UGuelph', tenant : 'FedUniFT', permission : 'RestrictedAccess'},
    {user : 'Alvianda', group : 'Agents', role : 'Contributor', org: 'CSheridan', tenant : 'ProvColPT', permission : 'FullAccess'},
]


module.exports = {profiles, users,permissions}

