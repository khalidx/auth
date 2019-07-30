import 'source-map-support/register'

import { CustomAuthorizerHandler, CustomAuthorizerEvent, CustomAuthorizerResult } from 'aws-lambda'
import { SSM } from 'aws-sdk'

const ssm = new SSM()

export const handler: CustomAuthorizerHandler = (event, context, callback) => {
  Promise
  .resolve(event)
  .then((event) => getCredentials(event))
  .then((credentials) => getParameters(credentials))
  .then((parameters) => buildPolicy(event, parameters))
  .then((policy) => {
    console.log(JSON.stringify(policy, null, 2))
    callback(null, policy)
  })
  .catch((error) => {
    console.error(error.message)
    callback('Unauthorized')
  })
}

async function getCredentials (event: CustomAuthorizerEvent): Promise<Credentials> {
  // Ensure the `Authorization` header exists
  if (!event.headers || !event.headers.Authorization) throw new Error('No Authorization header provided')
  // Decode the credentials from the header
  let credentials = Buffer.from(event.headers.Authorization.replace('Basic ', ''), 'base64').toString().split(':')
  return {
    username: credentials[0],
    password: credentials[1]
  }
}

async function getParameters (credentials: { username: string, password: string }): Promise<Parameters> {

  // Ensure the namespace environment variable is provided

  let namespace = process.env.PARAMETER_STORE_NAMESPACE
  if (!namespace) throw new Error('No namespace defined for use by the authorizer')

  // Read the parameters for the `username` from the AWS SSM Parameter Store

  let path = `/${namespace}/${credentials.username}`

  let response = await ssm.getParametersByPath({
    Path: path,
    WithDecryption: true
  }).promise()

  if (!response.Parameters) throw new Error(`No secrets exist for ${credentials.username}`)

  let password = response.Parameters.find(p => p.Name === `${path}/password`)

  if (!password || !password.Value) throw new Error(`No credentials found for ${credentials.username}`)

  if (credentials.password !== password.Value) throw new Error('Invalid credentials')

  let whitelist = response.Parameters.find(p => p.Name === `${path}/whitelist`)

  if (!whitelist || !whitelist.Value) throw new Error(`No actions whitelisted for ${credentials.username}`)

  let apiKey = response.Parameters.find(p => p.Name === `${path}/apiKey`)

  if (!apiKey || !apiKey.Value) throw new Error(`No API Key found for ${credentials.username}`)

  // Return the whitelist and API key

  return {
    username: credentials.username,
    whitelist: JSON.parse(whitelist.Value),
    apiKey: apiKey.Value
  }
}

async function buildPolicy (event: CustomAuthorizerEvent, parameters: Parameters): Promise<CustomAuthorizerResult> {
  let splits = event.methodArn.split(':')
  let apiGatewayArnTmp = splits[5].split('/')
  let awsAccountId = splits[4]
  let awsRegion = splits[3]
  let restApiId = apiGatewayArnTmp[0]
  let stage = apiGatewayArnTmp[1]
  return {
    principalId: parameters.username,
    usageIdentifierKey: parameters.apiKey,
    policyDocument: {
      Version: '2012-10-17',
      Statement: [
        {
          Action: 'execute-api:Invoke',
          Effect: 'Allow',
          Resource: parameters.whitelist.map(operation => `arn:aws:execute-api:${awsRegion}:${awsAccountId}:${restApiId}/${stage}/${operation}`)
        }
      ]
    }
  }
}

interface Credentials {
  username: string
  password: string
}

interface Parameters {
  username: string
  /* Whitelisted operations in the format METHOD/path, as in GET/hello/world */
  whitelist: Array<string>
  apiKey: string
}
