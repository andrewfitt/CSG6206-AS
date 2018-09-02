#!/usr/bin/python
import mysql.connector
import uuid
from mysql.connector import Error


conn = mysql.connector.connect(host='192.168.44.52', database='test_volume',user='test',password='test')
conn.is_connected()
cursor = conn.cursor()

query = "INSERT INTO test(ObjectID, AttributeID, AttributeGroupName, ObjectTypeId, RelationTypeId) " \
        "VALUES(%s,%s,%s,%s,%s)"
args = (str(uuid.uuid4()),str(uuid.uuid4()),'Application details','400',str(uuid.uuid4()))

print (args)

try:
	for x in xrange(2000000): 
		cursor.execute(query, args)
 		print("Going: "+str(x))
	conn.commit()
except Error as error:
	print(error)
finally:
	cursor.close()
	conn.close()