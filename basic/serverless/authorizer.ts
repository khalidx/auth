import 'source-map-support/register'

import { CustomAuthorizerHandler, CustomAuthorizerEvent, CustomAuthorizerResult } from 'aws-lambda'

export const handler: CustomAuthorizerHandler = (event, context, callback): void => {
  try {
    // Ensure the `Authorization` header exists

    if (!event.headers || !event.headers.Authorization) return callback('Unauthorized')

    // Decode the credentials from the header

    let credentials = Buffer.from(event.headers.Authorization.replace('Basic ', ''), 'base64').toString().split(':')
    let username = credentials[0]
    let password = credentials[1]

    // Ensure the credentials are valid

    if (!(username === 'admin' && password === 'secret')) return callback('Unauthorized')

    // Build the applicable policy

    let result = buildPolicy(event, username)

    return callback(null, result)
    
  } catch (error) {
    console.error(error)
    return callback('Unauthorized')
  }
}

function buildPolicy (event: CustomAuthorizerEvent, principalId: string): CustomAuthorizerResult {
  let splits = event.methodArn.split(':')
  let apiGatewayArnTmp = splits[5].split('/')
  let awsAccountId = splits[4]
  let awsRegion = splits[3]
  let restApiId = apiGatewayArnTmp[0]
  let stage = apiGatewayArnTmp[1]
  let apiArn = `arn:aws:execute-api:${awsRegion}:${awsAccountId}:${restApiId}/${stage}/*/*`
  return {
    principalId,
    policyDocument: {
      Version: '2012-10-17',
      Statement: [
        {
          Action: 'execute-api:Invoke',
          Effect: 'Allow',
          Resource: [ apiArn ]
        }
      ]
    }
  }
}
