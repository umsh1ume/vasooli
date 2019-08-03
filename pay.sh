id=$(curl -s -u "$SUPERPOTATO_RZP_KEY_ID:$SUPERPOTATO_RZP_KEY_SECRET" \
      -d 'amount=200&currency=INR' \
      https://api.razorpay.com/v1/orders | jq -r '.id' | cut -d '_' -f 2)

time=$(date +%s)

curl -X POST https://vasooli.herokuapp.com/webhook \
    -d "payload[payment][entity][id]=pay_$id" \
    -d "payload[payment][entity][amount]=1000" \
    -d "payload[payment][entity][acquirer_data][rrn]=91$time" \
    -d "payload[payment][entity][notes][agent_id]=9823967243"

# '{
#   "event": "payment.authorized",
#   "entity": "event",
#   "contains": [
#     "payment"
#   ],
#   "payload": {
#     "payment": {
#       "entity": {
#         "id": "pay_$id",
#         "entity": "payment",
#         "amount": 50000,
#         "currency": "INR",
#         "status": "authorized",
#         "method": "card",
#         "bank": null,
#         "captured": false,
#         "email": "gaurav.kumar@example.com",
#         "contact": "9123456780",
#         "description": "Payment Description",
#         "error_code": null,
#         "error_description": null,
#         "acquirer_data": {
#           "rrn": "943567387654"
#         },
#         "notes": {
#           "agent_id": "9823967243"
#         },
#         "vpa": null
#       }
#     },
#     "created_at": 1400826760
#   }
# }'