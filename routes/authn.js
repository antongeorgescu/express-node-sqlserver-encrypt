const authn_permissions = {permissions : [
    {permission: 'RestrictedAccess', description: 'read restricted to non-sensitive information', password: 'reporter@1'},
    {permission: 'FullAccess', description: 'read sensitive information', password: 'contributor@1'}
]};


const user_directory = {users : [
    {user : 'Anton', group : '', role : '', org: '', tenant : '', permission : ''},
    {user : 'Daniela', group : '', role : '', org: '', tenant : '', permission : ''},
    {user : 'Alex', group : '', role : '', org: '', tenant : '', permission : ''},
    {user : 'Kora', group : '', role : '', org: '', tenant : '', permission : ''},
    {user : 'Jake', group : '', role : '', org: '', tenant : '', permission : ''},
    {user : 'Tangie', group : '', role : '', org: '', tenant : '', permission : ''},
]}


module.exports = {authn_permissions, user_directory}

