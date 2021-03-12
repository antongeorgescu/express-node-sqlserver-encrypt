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
]

const tenants = [
    {tenant : 'UFTLoan', description : 'University full-time Loans'},
    {tenant : 'CPTLoan', description : 'College part-time loans'},
]

const users = [
    {user : 'Anton', group : 'Supervisors', role : '', org: 'UGuelph, UWaterloo', tenant : 'UFTLoan', permission : ''},
    {user : 'Daniela', group : 'Supervisors', role : '', org: 'CSheridan', tenant : 'CPTLoan', permission : ''},
    {user : 'Alex', group : 'Agents', role : 'Contributor', org: 'UGuelph', tenant : 'UFTLoan', permission : 'FullAccess'},
    {user : 'Kora', group : 'Agents', role : 'Reporter', org: 'UWaterloo', tenant : 'UFTLoan', permission : 'RestrictedAccess'},
    {user : 'Jake', group : 'Agents', role : 'Reporter', org: 'CSheridan', tenant : 'CPTLoan', permission : 'RestrictedAccess'},
    {user : 'Tangie', group : 'Agents', role : 'Contributor', org: 'CSheridan', tenant : 'CPTLoan', permission : 'FullAccess'},
]


module.exports = {permissions, users}

