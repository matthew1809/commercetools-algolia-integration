const algoliasearch = require('algoliasearch')
const algoliaApp = process.env.ALGOLIA_APP_ID
const client = algoliasearch(algoliaApp, process.env.ALGOLIA_API_KEY)
const index = client.initIndex(process.env.ALGOLIA_INDEX_NAME)

exports.index = index
