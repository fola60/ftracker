from statement_parse import process_finance_request

query1 = "I got some m and ms for like 2.80 by aldi and i have an amazon subscription and my dad gave me like 50 euro yesterday."
query2 = "dad gives me like 50 every night"
query3 = "i get eggs every week for 5 euro"

request1 = process_finance_request(query1)
request2 = process_finance_request(query2)
request3 = process_finance_request(query3)

print("Request 1", request1)
print("Request 2", request2)
print("Request 3", request3)