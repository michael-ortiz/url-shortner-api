import * as AWS from "@aws-sdk/client-dynamodb";
const ddb = new AWS.DynamoDB({ region: "us-east-1" });

const headers = {
    // Required for CORS support to work
    'Access-Control-Allow-Origin': '*',
    // Required for cookies, authorization headers with HTTPS
    'Access-Control-Allow-Credentials': true
}

const validShortValueRegex = /^[A-Za-z0-9_-]{1,64}$/

export const handler = async(event) => {
    
    const queryParameters = event.queryStringParameters

    // Only allow GET requests
    if (event.requestContext.http.method !== 'GET') {
        return {
            statusCode: 401,
            body: { message: "HTTP Method not allowed" },
            headers: headers
        }
    }

    // Extract short value
    const shortValue = queryParameters.shortValue;

    // Validate shortValue parameter
    if (!validShortValueRegex.test(shortValue)) {
        return {
            statusCode: 404,
            body: { message: "Invalid short value" },
            headers: headers
        }
    }

    // Get URL statistics
    const item = await getUrlStatisticsFromDynamoDB(shortValue);
    
    if (item != null) {
        return {
            statusCode: 200,
            body: item,
            headers: headers
        }
    } else {
        return {
            statusCode: 404,
            body: { message: "Could not find URL." },
            headers: headers
        }
    }
};

/**
 * 
 * Gets URL statistics from DynamoDB by passing a shortValue.
 * 
 * @param {*} shortValue 
 * @returns 
 */
async function getUrlStatisticsFromDynamoDB(shortValue) {

    const params = {
        TableName: process.env.TABLE_NAME,
        Key: {
          'ShortValue' : {S: shortValue}
        }
    };
    
    try {
        const data = await ddb.getItem(params);
        return {
            originalUrl: data.Item.OriginalUrl.S,
            shortUrl: data.Item.ShortUrl.S,
            shortValue: data.Item.ShortValue.S,
            createdDate: data.Item.CreatedDate.S,
            viewsCounter: data.Item.ViewsCounter.N,
            lastViewedDate: data.Item.LastViewedDate.S,
        }
    } catch (e) {
        console.error("Error", e)
        return null;
    }
}