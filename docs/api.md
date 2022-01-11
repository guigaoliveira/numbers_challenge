# Numbers API

## Get all sorted numbers

### GET - /api/v1/numbers/

Content-Type: application/json

Query Params:

```txt
order_by - "asc" or "desc"
```

If the order by parameter was not passed in request, the ordering of numbers is "asc".

Response:

**HTTP Status Code - 200:**

When numbers have already been pulled from the external API:

```json
{
  "data": {
    "numbers": [1, 2, 3, 4, 5],
    "status": "processed"
  }
}
```

When numbers were not pulled from external API:

```json
{
   "data":{
      "numbers": [],
      "status":"unprocessed"
   }
}
```

**HTTP Status Code - 422:**

When order_by is not "asc" or "desc":

```json
{
   "error":"invalid params",
   "details":[
      {
         "order_by":"must be \"asc\" or \"desc\""
      }
   ]
}
```
