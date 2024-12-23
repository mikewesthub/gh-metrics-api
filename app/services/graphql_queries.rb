require_relative 'graphql_api'

module GraphQLQueries
  EnterpriseOrganizationsQuery = GraphQLAPI::Client.parse <<~'GRAPHQL'
    query($slug: String!) {
      enterprise(slug: $slug) {
        name
        organizations(first:100){
          nodes{
            name
            ... on Organization{
              login
            }
          }
        }
      }
    }
  GRAPHQL

  EnterpriseAllOrganizationsQuery = GraphQLAPI::Client.parse <<~'GRAPHQL'
    query($slug: String!, $after: String) {
      enterprise(slug: $slug) {
        name
        organizations(first:100, after: $after){
          nodes{
            name
            ... on Organization{
              login
            }
          }
          pageInfo{
            hasNextPage
            endCursor
          }
        }
      }
    }
  GRAPHQL
end
