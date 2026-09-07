# AWS Zero to Hero --- Day 14 Practical Documentation

## DynamoDB Orders Application, Queries, TTL, Streams, Lambda & Temporary UI

**Brand:** CloudAdhar × TrainWithShubham\
**Date:** 16-Aug-2026\
**Region:** `ap-south-1`\
**Main Table:** `cloudadhar-orders-day14`

------------------------------------------------------------------------

## 1. Practical Objective

This practical builds a small order-tracking application and
demonstrates:

-   Access-pattern-first DynamoDB design
-   Composite partition and sort keys
-   Global Secondary Index (`GSI1`)
-   Local Secondary Index (`LSI1`)
-   On-demand and provisioned capacity
-   Query vs Scan
-   Time to Live (`ExpiresAt`)
-   DynamoDB Streams with `NEW_AND_OLD_IMAGES`
-   Lambda Stream consumer
-   Temporary browser UI through Lambda Function URL
-   End-to-end flow from UI → DynamoDB → Stream → Lambda → CloudWatch
    Logs
-   Decision points for Global Tables, DAX and ElastiCache

Only synthetic data is used.

------------------------------------------------------------------------
![Architecture](<WhatsApp Image 2026-09-07 at 4.10.11 PM.jpeg>)
## 2. Final Architecture

``` text
Browser
   │ temporary HTTPS
   ▼
UI/API Lambda
cloudadhar-day14-ui
   │ GetItem / Query / UpdateItem
   ▼
DynamoDB Orders Table
cloudadhar-orders-day14
   │ PK + SK + GSI1 + LSI1
   │ DynamoDB Stream
   ▼
Stream Consumer Lambda
cloudadhar-day14-stream-consumer
   │
   ▼
CloudWatch Logs
INSERT / MODIFY / REMOVE
```

### Important flow

The browser does **not** write directly to DynamoDB.

The flow is:

``` text
Browser
  ↓
UI Lambda
  ↓
DynamoDB UpdateItem
  ↓
DynamoDB updates current item + indexes
  ↓
DynamoDB Stream captures the change
  ↓
Stream Consumer Lambda
  ↓
CloudWatch Logs
```

------------------------------------------------------------------------

## 3. Resource Design

  ------------------------------------------------------------------------------------
  Resource                Name                                 Purpose
  ----------------------- ------------------------------------ -----------------------
  Main DynamoDB table     `cloudadhar-orders-day14`            Customer profiles and
                                                               orders

  Global Secondary Index  `GSI1`                               Find an order by order
                                                               ID

  Local Secondary Index   `LSI1`                               Access customer orders
                                                               by status

  Stream Lambda           `cloudadhar-day14-stream-consumer`   Processes DynamoDB
                                                               Stream records

  UI/API Lambda           `cloudadhar-day14-ui`                Temporary browser UI
                                                               and status updates

  TTL attribute           `ExpiresAt`                          Temporary item
                                                               expiration

  Optional provisioned    `cloudadhar-capacity-demo-day14`     Capacity-mode
  table                                                        comparison
  ------------------------------------------------------------------------------------

------------------------------------------------------------------------

# 4. Access-Pattern-First Key Design

The table design starts from application questions rather than choosing
generic keys first.

  -----------------------------------------------------------------------------
  Access Pattern          Key Design                    Purpose
  ----------------------- ----------------------------- -----------------------
  Get customer C101       `PK=CUSTOMER#C101`,           Exact `GetItem`
  profile                 `SK=PROFILE`                  

  List C101 orders        `PK=CUSTOMER#C101`,           Query customer orders
                          `SK=ORDER#time#id`            

  Find O9001 without      `GSI1PK=ORDER#O9001`          GSI lookup
  customer                                              

  Find customer orders by Same PK +                     LSI access path
  status                  `LSI1SK=STATUS#status#time`   

  Expire temporary        `ExpiresAt`                   TTL
  session                                               

  React to order change   DynamoDB Stream               Event-driven processing
  -----------------------------------------------------------------------------

------------------------------------------------------------------------

# 5. DynamoDB Table Configuration

The main table is:

``` text
cloudadhar-orders-day14
```

Primary key:

``` text
Partition key: PK
Sort key: SK
```

Capacity mode:

``` text
PAY_PER_REQUEST / On-demand
```

### Table configuration evidence

![alt text](<WhatsApp Image 2026-09-06 at 11.00.12 PM.jpeg>)

The screenshot shows the DynamoDB table configuration and active table
state.

![alt text](<WhatsApp Image 2026-09-06 at 10.55.10 PM.jpeg>)

The table settings provide evidence of the configured capacity and
related settings.

![alt text](<WhatsApp Image 2026-09-06 at 11.00.12 PM-1.jpeg>)

Additional table configuration is visible here.

![alt text](<WhatsApp Image 2026-09-06 at 11.00.12 PM-2.jpeg>)

Final settings and TTL-related configuration are shown.

------------------------------------------------------------------------

# 6. Customer Profile --- GetItem

`GetItem` is used when both primary-key values are known.

For customer C101:

``` text
PK = CUSTOMER#C101
SK = PROFILE
```

Example command:

``` bash
export DAY14_REGION=ap-south-1
export DAY14_TABLE=cloudadhar-orders-day14

aws dynamodb get-item \
  --region "$DAY14_REGION" \
  --table-name "$DAY14_TABLE" \
  --key '{
    "PK":{"S":"CUSTOMER#C101"},
    "SK":{"S":"PROFILE"}
  }' \
  --no-cli-pager
```

### Result

The profile contains:

``` text
PK    = CUSTOMER#C101
SK    = PROFILE
Name  = Asha Student
Email = asha@example.test
```

### Evidence

![alt text](<WhatsApp Image 2026-09-06 at 11.10.18 PM.jpeg>)
The CloudShell output confirms that the C101 profile was successfully
retrieved.


The returned attributes include the synthetic customer name and email.

------------------------------------------------------------------------

# 7. Customer Orders --- Query

`Query` is used when the partition key is known.

The order items use:

``` text
PK = CUSTOMER#C101
SK = ORDER#timestamp#order-id
```

Example:

``` bash
aws dynamodb query \
  --region "$DAY14_REGION" \
  --table-name "$DAY14_TABLE" \
  --key-condition-expression \
    "PK = :pk AND begins_with(SK, :prefix)" \
  --expression-attribute-values '{
    ":pk":{"S":"CUSTOMER#C101"},
    ":prefix":{"S":"ORDER#"}
  }' \
  --no-scan-index-forward \
  --no-cli-pager
```

`--no-scan-index-forward` returns the newest order first.

### Evidence

![alt text](<WhatsApp Image 2026-09-06 at 11.11.34 PM.jpeg>)

The output shows two orders for `CUSTOMER#C101`.

------------------------------------------------------------------------

# 8. GSI1 --- Search Order by Order ID

The application must support:

``` text
Find O9001 without knowing the customer.
```

For this access pattern:

``` text
GSI1PK = ORDER#O9001
GSI1SK = CUSTOMER#C101
```

Example:

``` bash
aws dynamodb query \
  --region "$DAY14_REGION" \
  --table-name "$DAY14_TABLE" \
  --index-name GSI1 \
  --key-condition-expression 'GSI1PK = :gsipk' \
  --expression-attribute-values '{
    ":gsipk":{"S":"ORDER#O9001"}
  }' \
  --no-cli-pager
```

### Result

The query returns the O9001 order.

### Evidence

![alt text](<WhatsApp Image 2026-09-06 at 11.12.05 PM.jpeg>)

The screenshot confirms that `GSI1` returns one matching order.

------------------------------------------------------------------------

# 9. GSI1 and LSI1 Configuration

The table contains:

``` text
GSI1
----
Partition key: GSI1PK
Sort key:      GSI1SK

LSI1
----
Partition key: PK
Sort key:      LSI1SK
```

### Evidence

![alt text](<WhatsApp Image 2026-09-06 at 10.56.38 PM.jpeg>)

The AWS Console shows:

-   `GSI1` --- Active
-   `LSI1` --- present
-   Both indexes have their expected key definitions.

------------------------------------------------------------------------

# 10. Explore Table Items

The DynamoDB Item Explorer is used to verify the actual records.

The initial lab data contains:

1.  Customer profile
2.  Order O9001
3.  Order O9002

### Evidence

![alt text](<WhatsApp Image 2026-09-06 at 10.57.46 PM.jpeg>)
The Item Explorer shows three items in the table.

------------------------------------------------------------------------

# 11. Query vs Scan

## Query

`Query` targets a known partition key.

Example:

``` text
PK = CUSTOMER#C101
```

It can additionally use a condition on the sort key.

## Scan

`Scan` examines the table or selected index.

Important practical difference:

``` text
Query → access-pattern driven
Scan  → reads through table/index data
```

A filter expression on a Scan does not remove the underlying read work.

For production applications, the preferred approach is to design the
table around known access patterns and use Query whenever possible.

------------------------------------------------------------------------

# 12. TTL --- ExpiresAt

The practical uses:

``` text
ExpiresAt
```

as the DynamoDB TTL attribute.

The value is stored as epoch seconds.

Example:

``` bash
aws dynamodb update-time-to-live \
  --region "$DAY14_REGION" \
  --table-name "$DAY14_TABLE" \
  --time-to-live-specification \
    'Enabled=true,AttributeName=ExpiresAt' \
  --no-cli-pager
```

### Important concept

TTL deletion is asynchronous.

Therefore:

``` text
Expired ≠ immediately deleted
```

An expired item may remain visible for some time before DynamoDB removes
it.

------------------------------------------------------------------------

# 13. DynamoDB Streams

DynamoDB Streams captures item-level changes.

The practical uses:

``` text
View type = NEW_AND_OLD_IMAGES
Stream status = ON
```

This allows the application to see:

``` text
oldImage
newImage
```

for a modification.

### Evidence

![alt text](<WhatsApp Image 2026-09-06 at 11.02.26 PM.jpeg>)

The AWS Console shows DynamoDB Streams enabled and the configured Lambda
trigger.

------------------------------------------------------------------------

# 14. Stream Consumer Lambda

Lambda function:

``` text
cloudadhar-day14-stream-consumer
```

Its responsibility is to process DynamoDB Stream records.

Expected status-change event:

``` text
eventName = MODIFY

oldImage.Status = PAID
newImage.Status = SHIPPED
```

The event-source mapping connects the DynamoDB Stream to the Lambda.

Expected state:

``` text
State = Enabled
Last processing result = OK
```

The visible proof of the old/new values is provided through CloudWatch
Logs.

------------------------------------------------------------------------

# 15. Status Change --- PAID → SHIPPED

The important event-driven demonstration is changing order O9001.

Before:

``` text
Status = PAID
LSI1SK = STATUS#PAID#2026-08-16T18:30:00Z
```

After:

``` text
Status = SHIPPED
LSI1SK = STATUS#SHIPPED#2026-08-16T18:30:00Z
```

Example:

``` bash
aws dynamodb update-item \
  --region "$DAY14_REGION" \
  --table-name "$DAY14_TABLE" \
  --key '{
    "PK":{"S":"CUSTOMER#C101"},
    "SK":{"S":"ORDER#2026-08-16T18:30:00Z#O9001"}
  }' \
  --update-expression \
    'SET #status = :status, LSI1SK = :lsi' \
  --expression-attribute-names '{
    "#status":"Status"
  }' \
  --expression-attribute-values '{
    ":status":{"S":"SHIPPED"},
    ":lsi":{"S":"STATUS#SHIPPED#2026-08-16T18:30:00Z"}
  }' \
  --return-values ALL_NEW \
  --no-cli-pager
```

### Complete change flow

``` text
UpdateItem
    ↓
DynamoDB current item changes
    ↓
GSI / LSI maintained
    ↓
DynamoDB Stream creates MODIFY event
    ↓
Stream Consumer Lambda
    ↓
CloudWatch Logs
```

------------------------------------------------------------------------

# 16. Temporary Order Dashboard UI

![alt text](<Screenshot 2026-09-06 221527.png>)
The second Lambda provides a temporary browser UI.

Its responsibilities are:

-   Serve the HTML dashboard
-   Query customer orders from the base table
-   Filter orders through `LSI1`
-   Search orders through `GSI1`
-   Update order status
-   Update `LSI1SK` together with the status

### Dashboard Evidence


The captured dashboard demonstrates:

``` text
Customer ID: C101

Status filter:
SHIPPED

Access path:
GSI1

Order ID:
O9001

GSI1 returned:
1 order

Status:
SHIPPED

Total:
₹2499
```

This screenshot is the visual proof of the temporary UI portion of the
practical.

------------------------------------------------------------------------

# 17. UI Security Consideration

The temporary Lambda Function URL uses:

``` text
Auth type = NONE
```

Therefore the Function URL is publicly accessible while enabled.

The instructor token protects the write route in the sample application,
but:

``` text
NONE authentication ≠ private URL
```

Reserved concurrency:

``` text
2
```

is a cost-control guardrail, not authentication.

### Cleanup requirement

Delete the Function URL immediately after the demonstration.

Do not put the instructor token into screenshots or HTML source.

------------------------------------------------------------------------

# 18. Global Tables

Global Tables are used when DynamoDB data needs multi-Region
replication.

Conceptually:

``` text
Mumbai
ap-south-1
    ⇅
Singapore
ap-southeast-1
```

Potential benefits:

-   Multi-Region availability
-   Local access for global users
-   Multi-Region writes

The practical does **not** create an additional replica merely for
demonstration.

------------------------------------------------------------------------

# 19. DAX

DAX is a DynamoDB-native caching layer.

Conceptual request path:

``` text
Application
     ↓
DAX cache hit
     ↓
Result
```

On a cache miss:

``` text
Application
     ↓
DAX
     ↓
DynamoDB
     ↓
Cache
     ↓
Result
```

DAX is appropriate when:

-   DynamoDB is the database
-   Reads repeat frequently
-   Eventual consistency is acceptable
-   Very low cached-read latency is required

DAX should not be used as a solution for:

-   Hot partition-key design problems
-   Missing access patterns
-   Write-heavy workloads
-   General Redis data structures

No DAX cluster is created in this standard practical.

------------------------------------------------------------------------

# 20. ElastiCache

ElastiCache is useful for workloads requiring richer caching features.

  Requirement                         Choice
  ----------------------------------- --------------------
  Leaderboards / sorted sets          Redis OSS / Valkey
  Sessions                            Redis OSS / Valkey
  Counters / rate limiting            Redis OSS / Valkey
  Pub/Sub                             Redis OSS / Valkey
  Simple disposable object cache      Memcached
  DynamoDB-native read acceleration   DAX

No ElastiCache cache is created merely for the demonstration.

------------------------------------------------------------------------

# 21. Final Verification Checklist

-   [ ] `cloudadhar-orders-day14` is Active
-   [ ] Primary key is `PK + SK`
-   [ ] `GSI1` is present and Active
-   [ ] `LSI1` is present
-   [ ] Main table uses on-demand capacity
-   [ ] C101 profile retrieved successfully with `GetItem`
-   [ ] C101 orders retrieved using `Query`
-   [ ] O9001 retrieved using `GSI1`
-   [ ] Status filtering demonstrated using `LSI1`
-   [ ] TTL configured using `ExpiresAt`
-   [ ] DynamoDB Streams is On
-   [ ] Stream view type is `NEW_AND_OLD_IMAGES`
-   [ ] Stream Lambda trigger is Enabled
-   [ ] O9001 changed from `PAID` → `SHIPPED`
-   [ ] Stream event shows old/new status
-   [ ] Temporary dashboard successfully searches O9001 through GSI1
-   [ ] Temporary dashboard displays SHIPPED order
-   [ ] Function URL removed after demonstration

------------------------------------------------------------------------

# 22. Cleanup

After completing the practical:

1.  Delete the temporary Lambda Function URL.
2.  Remove the DynamoDB trigger before deleting the Stream Consumer
    Lambda.
3.  Delete the Day 14 Lambda functions if teardown is required.
4.  Delete `cloudadhar-capacity-demo-day14` if it was created.
5.  Delete `cloudadhar-orders-day14` if full teardown is required.
6.  Remove generated Day 14 IAM roles after confirming no other Lambda
    uses them.
7.  Mask account IDs, role ARNs and Function URLs in public screenshots
    or recordings.

------------------------------------------------------------------------

# 23. Practical Outcome

The Day 14 practical demonstrates a complete DynamoDB-driven order
workflow:

``` text
Access Pattern
      ↓
DynamoDB Key Design
      ↓
PK + SK
      ↓
GSI1 + LSI1
      ↓
Query / GetItem
      ↓
Order Status Update
      ↓
DynamoDB Streams
      ↓
Lambda
      ↓
CloudWatch Logs
      ↓
Temporary Browser Dashboard
```

The main learning is that DynamoDB table design should be driven by
**how the application needs to access data**, rather than by designing a
generic table first.

------------------------------------------------------------------------

## End of Day 14 Practical Documentation
