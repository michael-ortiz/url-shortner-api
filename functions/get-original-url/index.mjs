import * as AWS from "@aws-sdk/client-dynamodb";
const ddb = new AWS.DynamoDB({ region: "us-east-1" });

const headers = {
    // Required for CORS support to work
    'Access-Control-Allow-Origin': '*',
    // Required for cookies, authorization headers with HTTPS
    'Access-Control-Allow-Credentials': true
}

export const handler = async(event) => {

    if (event.requestContext.http.method !== 'GET') {
        return {
            statusCode: 401,
            body: { message: "HTTP Method not allowed" },
            headers: headers
        }
    }
    
    const query = event.queryStringParameters
    
    let shortValue = query.shortValue;

    const validShortValueRegex = /^[A-Za-z0-9_-]{1,64}$/
    
    if (!validShortValueRegex.test(shortValue)) {
        return {
            statusCode: 404,
            body: { message: "Invalid URL" },
            headers: headers
        }
    }

    let item = await getUrlFromDynamoDB(shortValue);
    
    if (item != null) {

        const updatedItem = await updateViewCounter(shortValue);
        item.lastViewedDate = updatedItem.lastViewedDate
        item.viewsCounter = updatedItem.viewsCounter

        return {
            statusCode: 200,
            body: item,
            headers: headers
        }
    } else {
        return {
            statusCode: 404,
            body: { message: "Could not find URL" },
            headers: headers
        }
    }
    
};

async function getUrlFromDynamoDB(shortValue) {

    var params = {
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
        console.log("Error", e)
        return null;
    }
}

async function updateViewCounter(shortValue) {

    const params = {
        TableName: process.env.TABLE_NAME,
        Key: {
            'ShortValue' : {S: shortValue}
        },
        UpdateExpression: "set ViewsCounter = ViewsCounter + :num, LastViewedDate = :date",
        ExpressionAttributeValues: {
            ":num": {"N": "1"},
            ":date": {"S": new Date().toISOString()}
        },
        ReturnValues : "UPDATED_NEW"
    }

    try {
        const data = await ddb.updateItem(params);
        console.log(data)
        return {
            viewsCounter: data.Attributes.ViewsCounter.N,
            lastViewedDate: data.Attributes.LastViewedDate.S 
        }
    } catch (e) {
        console.log("Error", e)
        return null;
    }

}