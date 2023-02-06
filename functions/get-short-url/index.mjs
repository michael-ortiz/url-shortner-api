import { customAlphabet } from 'nanoid'
import * as AWS from "@aws-sdk/client-dynamodb";
const ddb = new AWS.DynamoDB({ region: "us-east-1" });

const validUrlRegex = /[-a-zA-Z0-9@:%._+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_+.~#?&//=]*)/
const validAliasRegex = /^[A-Za-z0-9_-]{1,64}$/

const headers = {
    // Required for CORS support to work
    'Access-Control-Allow-Origin': '*',
    // Required for cookies, authorization headers with HTTPS
    'Access-Control-Allow-Credentials': true
}

export const handler = async(event) => {

    if (event.requestContext.http.method !== 'POST') {
        return {
            statusCode: 401,
            body: { message: "HTTP Method not allowed" },
            headers: headers
        }
    }
    
    const body = JSON.parse(event.body);

    let url = body.url;
    let alias = body.alias;

    if (url === undefined || url == "") {
        return { 
            statusCode: 401, 
            body: { message: "{ url } parameter cannot be empty" },
            headers: headers
        }
    }
    
    // Test for valid URL
    if (!validUrlRegex.test(url)) {
        return { 
            statusCode: 401, 
            body: { message: "URL is not valid." },
            headers: headers
        }
    }

    if (alias) {
        if (!validAliasRegex.test(alias)) {
            return { 
                statusCode: 401, 
                body: { message: "Invalid alias. Allowed characters: (A-Z a-z 0-9 _ -)" },
                headers: headers   
            }
        }

        // Validate if alias is available
        let data = await getUrlFromDynamoDB(alias)
        if (data != null || alias === "stats") {
            return { 
                statusCode: 401, 
                body: { message: "Alias taken. Please enter a different value." },
                headers: headers   
            }
        }
    }

    // Generate short id
    const nanoid = customAlphabet('1234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ', 8)
    var shortValue = alias ? alias : nanoid()
    
    const currentDate = new Date().toISOString()

    const insertObject = {
        originalUrl: url,
        shortUrl: `${process.env.DOMAIN_PROTOCOL}://${process.env.DOMAIN_NAME}/${shortValue}`,
        shortValue: shortValue,
        createdDate: currentDate,
        viewsCount: 0,
        lastViewedDate: currentDate
    }

    const didInsert = await insertIntoDynamoDB(insertObject);
    
    if (didInsert) {
        return {
            statusCode: 200,
            body: insertObject,
            headers: headers
        }
    } else {
        return {
            statusCode: 401,
            body: { message: "Could not insert object to database." },
            headers: headers
        }
    }
    
};

async function insertIntoDynamoDB(object) {

    var params = {
        TableName: process.env.TABLE_NAME,
        Item: {
          'ShortValue' : {S: object.shortValue},
          'ShortUrl' : {S: object.shortUrl},
          'OriginalUrl' : {S: object.originalUrl},
          'CreatedDate' : {S: object.createdDate},
          'ViewsCounter' : {N: '0'},
          'LastViewedDate' : {S: object.lastViewedDate}
        }
    };
    
    try {
        await ddb.putItem(params);
        return true;
    } catch (e) {
        console.log("Error", e)
        return false;
    }
}

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
            CreatedDate: data.Item.CreatedDate.S,
            ViewsCounter: data.Item.ViewsCounter.N,
            LastViewedDate: data.Item.LastViewedDate.S
        }
    } catch (e) {
        console.log("Item does not exists", e)
        return null;
    }
}