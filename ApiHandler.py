import json
import boto3
import logging
import botocore
from datetime import datetime

def lambda_handler(event, context):
    # Check if Post object contains entry
    if not event:
        return createResponse(201, 'Post Object empty!')

    data = processData(event)
    if data == 202:
        return createResponse(202, 'Body not present in POST request!')
    
    
    if pushToDynamo(data) != 200:
        return createResponse(203, 'Table not found!')
        
    return createResponse(200, 'Successful! item inserted in table!')

'''
    Module to process raw data
    Version- 1.0
    @author- Suryadeep
'''
def processData(event):
    ERROR_CODE = 202
    
    # Get Body from POST request and Split the string
    try:
        tempStore = event['body'].strip().split(':')
        # Fetch the value field and replace unwanted entries.
        processedData = tempStore[1].replace('}', '')
        
        return processedData
    
    except:
        print('error while parsing entry from POST request')
        return ERROR_CODE

'''
    Module to insert processed data in the Database
    Version- 1.0
    @author- Suryadeep
'''
def pushToDynamo(data):
    ERROR_CODE = 203

    # Setting up Logger
    logging.basicConfig(level=logging.INFO)
    logger = logging.getLogger()
    
    dynamodb = boto3.resource('dynamodb')
    dbtable = dynamodb.Table('StoreApiValue')
    
    # Put item in the Dynamo DB table
    try:
        logger.info('Setting Up connection with Dynamo DB Table')
        response = dbtable.put_item(
            Item={
                'timestamp': str(datetime.now()),
                'value': data
            }
        )
        
        return response['ResponseMetadata']['HTTPStatusCode']
    
    except dynamodb.meta.client.exceptions.ResourceNotFoundException as err:
        print("Table does not exist!".format(err.response['Error']))
        return ERROR_CODE

'''
    Module to create Response objects
    Version- 1.0
    @author- Suryadeep
'''
def createResponse(status, message):
    return {
        'statusCode' : status,
        'body': json.dumps(message)
    }
