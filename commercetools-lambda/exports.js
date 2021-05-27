const ctools = require('./commercetools.js')
const alg = require('./algolia')

// Main event trigger
// Should ideally just be a logic chain and error handling
exports.update = async (event) => {
  console.log(JSON.stringify(event))
  const algoliasearch = require('algoliasearch')
  const algoliaApp = process.env.ALGOLIA_APP_ID
  const client = algoliasearch(algoliaApp, process.env.ALGOLIA_API_KEY)
  const index = client.initIndex(process.env.ALGOLIA_INDEX_NAME)

  if (event.Records !== undefined) {
    // Will there ever be multiple records? This only takes the first
    let message = JSON.parse(event.Records[0].Sns.Message)

    let ID = message.resource.id
    let type = message.notificationType
    let version = message.version

    console.log(ID, type, version)

    try {
      const product = await ctools.getProduct(ID)

      console.log(product.masterVariant.sku)
      product.objectID = product.masterVariant.sku
      await index.saveObjects([product], true)

      console.log('done')

      return {
        statusCode: 200,
        body: JSON.stringify('all is well'),
      }
    } catch (e) {
      console.log(e)

      return {
        statusCode: 500,
        body: JSON.stringify(e),
      }
    }
  }
}
