const ctools = require('./commercetools.js')
<<<<<<< Updated upstream

=======
const alg = require('./algolia')

// Main event trigger
// Should ideally just be a logic chain and error handling
>>>>>>> Stashed changes
exports.update = async (event) => {
  const algoliasearch = require('algoliasearch')
  const algoliaApp = 'ZW1HH57FVV'
  const client = algoliasearch(algoliaApp, process.env.lambda_algolia_api_key)
  const index = client.initIndex('products')

  if (event.Records !== undefined) {
<<<<<<< Updated upstream
=======
    // Will there ever be multiple records? This only takes the first
>>>>>>> Stashed changes
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
