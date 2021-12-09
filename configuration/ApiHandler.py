import json
import boto3
import logging
import botocore
from datetime import datetime

def lambda_handler(event, context):
    data = processData(event)
    if pushToDynamo(data) == 200:
        return {
            'statusCode': 200,
            'body': json.dumps('Data inserted successfully!')
        }
        
    return {
            'statusCode': 400,
            'body': json.dumps('Data Insertion failed!')
        }
'''
    Module to process raw data
    Version- 1.0
    @author- Suryadeep
'''
def processData(event):
    
    # Get Body from POST request and Split the string
    try:
        tempStore = event['body'].strip().split(':')
        # Fetch the value field and replace unwanted entries.
        processedData = tempStore[1].replace('}', '')
        
        return processedData
    
    except:
        print('error while parsing entry from POST request')
        raise Exception('POST Body Parsing Error')

'''
    Module to insert processed data in the Database
    Version- 1.0
    @author- Suryadeep
'''
def pushToDynamo(data):
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
        raise err
    