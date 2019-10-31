extends Reference

# Fragment Definitions
const PAGINATION_CURSOR_FRAGMENT: String = """
fragment PaginationCursorFragment on PaginationCursor {
    total
    perPage
    currentPage
    hasPages
    from
    to
    lastPage
    hasMorePages
}
"""
const PERMISSION_FRAGMENT: String = """
fragment PermissionFragment on EnjinPermission {
    id
    name
}
"""
const ROLE_FRAGMENT: String = """
fragment RoleFragment on EnjinRole {
    id
    name
    appId
    permissions {
        ...PermissionFragment
    }
}
""" + PERMISSION_FRAGMENT
const SIMPLE_BALANCE_FRAGMENT: String = """
fragment SimpleBalanceFragment on EnjinBalance {
    id(format: $tokenIdFormat)
    index(format: $tokenIndexFormat)
    value
}
"""
const SIMPLE_TOKEN_FRAGMENT: String = """
fragment SimpleTokenFragment on EnjinToken {
    id(format: $tokenIndexFormat)
    name
    appId
    createdAt @include(if: $withTimestamps)
    updatedAt @include(if: $withTimestamps)
}
"""
const WALLET_FRAGMENT: String = """
fragment WalletFragment on EnjinWallet {
    ethAddress
    ethBalance
    enjBalance
    enjAllowance
    balances(
        appId: $balAppId,
        tokenId: $balTokenId,
        value: $balVal,
        value_gt: $balGt,
        value_gte: $balGte,
        value_lt: $balLt,
        value_lte: $balLte
    ) @include(if: $withBalances) {
        ...SimpleBalanceFragment
    }
    tokensCreated @include(if: $withTokensCreated) {
        ...SimpleTokenFragment
    }
}
""" + SIMPLE_BALANCE_FRAGMENT + SIMPLE_TOKEN_FRAGMENT
const IDENTITY_FRAGMENT: String = """
fragment IdentityFragment on EnjinIdentity {
    id
    appId
    linkingCode
    linkingCodeQr
    roles @include(if: $withIdentityRoles) {
        ...RoleFragment
    }
    wallet @include(if: $withWallet) {
        ...WalletFragment
    }
    createdAt @include(if: $withTimestamps)
    updatedAt @include(if: $withTimestamps)
}
""" + WALLET_FRAGMENT + ROLE_FRAGMENT
const USER_FRAGMENT: String = """
fragment UserFragment on EnjinUser {
    id
    name
    email
    roles @include(if: $withUserRoles) {
        ...RoleFragment
    }
    identities @include(if: $withIdentities) {
        ...IdentityFragment
    }
    createdAt @include(if: $withTimestamps)
    updatedAt @include(if: $withTimestamps)
}
""" + IDENTITY_FRAGMENT

# Query Arguments
const GET_USER_ARGS = """    $id: Int,
    $name: String,
    $me: Boolean = true,
    $withUserRoles: Boolean = false,
    $withIdentities: Boolean = false,
    $withIdentityRoles: Boolean = false,
    $withWallet: Boolean = false
    $withBalances: Boolean = true,
    $withTokensCreated: Boolean = false,
    $withTimestamps: Boolean = false,
    $balAppId: Int,
    $balTokenId: String,
    $balVal: Int,
    $balGt: Int,
    $balGte: Int,
    $balLt: Int
    $balLte: Int,
    $tokenIdFormat: TokenIdFormat,
    $tokenIndexFormat: TokenIndexFormat"""

# Query Definitions
const AUTH_USER_QUERY: String = """
query Login($email: String!, $password: String!) {
    result: EnjinOauth(email: $email, password: $password) {
        id,
        accessTokens
    }
}
"""
const GET_USER_QUERY: String = """
query GetUser(
%s
) {
    result: EnjinUser(id: $id, name: $name, me: $me) {
        ...UserFragment
    }
}
""" % GET_USER_ARGS + USER_FRAGMENT
const GET_USERS_QUERY: String = """
query GetUsers(
%s
) {
    result: EnjinUsers(id: $id, name: $name, me: $me) {
        ...UserFragment
    }
}
""" % GET_USER_ARGS + USER_FRAGMENT
const GET_USERS_PAGINATED_QUERY: String = """
query GetUsers(
%s
) {
    result: EnjinUsers(id: $id, name: $name, me: $me) {
        items {
            ...UserFragment
        }
        cursor {
            ...PaginationCursorFragment
        }
    }
}
""" % GET_USER_ARGS + USER_FRAGMENT + PAGINATION_CURSOR_FRAGMENT

static func auth_user_query(var email: String, var password: String):
    print(GET_USER_QUERY)
    var body = {}
    var variables = {}
    body.query = AUTH_USER_QUERY
    body.variables = variables
    variables.email = email
    variables.password = password
    return body


static func get_user(input: EnjinUserInput):
    var body = {}
    body.query = GET_USER_QUERY
    body.operationName = "GetUser"
    body.variables = input.create()
    return body