require('dotenv').config()

const fetch = require('node-fetch')

const createClient = require('@commercetools/sdk-client').createClient

const createAuthMiddlewareForClientCredentialsFlow =
  require('@commercetools/sdk-middleware-auth').createAuthMiddlewareForClientCredentialsFlow

const createLoggerMiddleware =
  require('@commercetools/sdk-middleware-logger').createLoggerMiddleware

<<<<<<< Updated upstream
const createHttpMiddleware = require('@commercetools/sdk-middleware-http')
  .createHttpMiddleware
const createRequestBuilder = require('@commercetools/api-request-builder')
  .createRequestBuilder
=======
const createHttpMiddleware =
  require('@commercetools/sdk-middleware-http').createHttpMiddleware

const createRequestBuilder =
  require('@commercetools/api-request-builder').createRequestBuilder
>>>>>>> Stashed changes

const client = createClient({
  middlewares: [
    createAuthMiddlewareForClientCredentialsFlow({
<<<<<<< Updated upstream
      host: 'https://auth.europe-west1.gcp.commercetools.com',
      projectKey: 'algolia-starter',
=======
      host: process.env.COMMERCETOOLS_AUTH_HOST_URL,
      projectKey: process.env.COMMERCETOOLS_PROJECT_KEY,
>>>>>>> Stashed changes
      credentials: {
        clientId: process.env.COMMERCETOOLS_CLIENT_ID,
        clientSecret: process.env.COMMERCETOOLS_CLIENT_SECRET,
      },
<<<<<<< Updated upstream
      scopes: [`manage_project:algolia-starter`],
=======
      scopes: [`manage_project:${process.env.COMMERCETOOLS_PROJECT_KEY}`],
>>>>>>> Stashed changes
      fetch,
    }),
    createHttpMiddleware({
      host: process.env.COMMERCETOOLS_API_HOST_URL,
      fetch,
    }),
    // createLoggerMiddleware(),
  ],
})

const requestBuilder = createRequestBuilder({
  projectKey: process.env.COMMERCETOOLS_PROJECT_KEY,
})

const getProduct = async (ID) => {
  try {
    let productQuery = requestBuilder.products.byId(ID)

    let productRequest = {
      uri: productQuery.build(),
      method: 'GET',
    }

    const result = await client.execute(productRequest)

    return result.body.masterData.current
  } catch (e) {
    console.log('process error', e)
    return false
  }
}

exports.getProduct = getProduct
