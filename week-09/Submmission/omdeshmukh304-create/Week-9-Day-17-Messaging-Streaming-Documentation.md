# Week 9 - Messaging, Streaming, and Event-Driven Architecture

# Day 17 - Amazon SQS

## Standard Queue and DLQ

### Dead-letter queue creation and configuration

Created the Standard SQS dead-letter queue:

- Queue: `cloudadhar-orders-dlq-day17`
- Type: Standard
- Visibility timeout: 30 seconds
- Message retention: 14 days
- Delivery delay: 0 seconds
- Maximum message size: 1024 KiB
- Receive message wait time: 20 seconds
- Encryption: SSE-SQS

### Standard queue and DLQ attachment

Created:

- Standard queue: `cloudadhar-orders-standard-day17`
- Visibility timeout: 30 seconds
- Message retention: 4 days
- Long polling: 20 seconds
- DLQ: `cloudadhar-orders-dlq-day17`
- Maximum receives: 3

### Visibility timeout test

Sent a test order with:

```json
{
  "eventId": "EVT-SQS-1001",
  "orderId": "O-1001",
  "status": "PROCESSING_FAILED"
}
```

The message was received without deleting it. It became invisible during the visibility timeout and became available again after the timeout. Repeated receives increased the receive count.

### DLQ population

After the configured maximum receive count was exceeded, the failed message moved to the DLQ.

### DLQ redrive result

The message was successfully redriven from the DLQ back to the source queue.

**Result:**
- Percent processed: `100%`
- Status: `Successfully completed`
- Redrive destination: `Source queue(s)`

![alt text](<WhatsApp Image 2026-10-05 at 9.09.30 PM.jpeg>)

### Long polling configuration and benefits

The Standard queue used a receive message wait time of `20 seconds`.

Long polling:
- waits for a message instead of immediately returning an empty response;
- reduces unnecessary empty receives;
- reduces unnecessary SQS API calls.

---

## FIFO Queue

Created:

- Queue: `cloudadhar-orders-fifo-day17.fifo`
- Type: FIFO
- Visibility timeout: 120 seconds
- Message retention: 4 days
- Content-based deduplication: Disabled
- Encryption: SSE-SQS

![alt text](<WhatsApp Image 2026-10-05 at 9.09.30 PM (1).jpeg>)

### Message group ordering validation

Used the same message group:

```text
order-O-2001
```

Messages:

1. `Payment received`
2. `Order shipped`

The first message was kept in flight. The second message from the same group was not released until the first message was processed/deleted. This validated FIFO ordering within a message group.

### Receipt handle and delete operation

FIFO messages were deleted using the current receipt handle. When an old receipt handle was used after the visibility timeout, the handle could expire; polling again provides a current receipt handle.

### FIFO versus Standard trade-offs

- Standard SQS provides high scalability and at-least-once delivery.
- FIFO provides ordering within a message group and stronger deduplication semantics.
- FIFO ordering can reduce parallelism when too many messages are placed into one message group.
- Multiple message groups allow parallel processing while preserving ordering inside each group.

---

# Day 17 - Amazon SNS

## Topic and Subscriptions

Created Standard SNS topic:

```text
cloudadhar-orders-topic-day17
```

Configured two SQS subscriptions:

1. `cloudadhar-orders-standard-day17`
2. `cloudadhar-priority-orders-day17`

Both subscriptions were confirmed.

![alt text](<WhatsApp Image 2026-10-05 at 9.09.30 PM (2).jpeg>)

## Message Filtering

The priority queue subscription used a message-attribute filter:

```json
{
  "priority": ["HIGH"]
}
```

The Standard queue subscription remained unfiltered.

### HIGH priority test

Published a HIGH-priority order with:

- Order ID: `O-3002`
- Amount: `7500`
- Priority: `HIGH`

The HIGH-priority message was received by the priority SQS queue.

![alt text](<WhatsApp Image 2026-10-05 at 9.09.30 PM (3).jpeg>)

### SNS envelope structure

Raw message delivery was disabled. Therefore, the SQS message contained the SNS notification envelope, including the original message and message attributes.

---

# Day 17 - Amazon EventBridge

## Custom Event Bus

Created:

```text
cloudadhar-orders-bus-day17
```

Configuration:
- Type: Custom event bus
- Description: `Custom order events for Day 17`
- Status: Active
- Encryption: AWS owned key
- Logging: Disabled
- Archive: Disabled
- Schema discovery: Disabled

![alt text](<WhatsApp Image 2026-10-05 at 9.09.31 PM.jpeg>)

## High-Value Orders Rule

Created:

```text
cloudadhar-high-value-orders-rule-day17
```

The rule used content-based matching:

```json
{
  "source": ["cloudadhar.orders"],
  "detail-type": ["OrderCreated"],
  "detail": {
    "amount": [
      {
        "numeric": [">", 5000]
      }
    ]
  }
}
```

Target:

```text
cloudadhar-priority-orders-day17
```

![alt text](<WhatsApp Image 2026-10-05 at 9.09.31 PM (1).jpeg>)

### Event Testing

#### Negative test

An event with:

```text
amount = 2500
```

was expected not to match the rule.

#### Positive test

An event with:

```text
amount = 7500
```

matched the rule and was delivered to the priority SQS queue.

![alt text](<WhatsApp Image 2026-10-05 at 9.09.32 PM.jpeg>)

> The positive test screenshot is the main evidence for successful content-based routing. The separate 2500 negative-test screenshot was not retained in the final evidence set.

---

# Day 17 - EventBridge Scheduler

## One-Time Payment Reminder

Created:

```text
cloudadhar-payment-reminder-day17
```

Configuration:
- Occurrence: One-time
- Time zone: Asia/Calcutta / Asia/Kolkata
- State: Enabled
- Flexible time window: Off
- Action after completion: DELETE
- Target: SQS `cloudadhar-priority-orders-day17`

![alt text](<WhatsApp Image 2026-10-05 at 9.09.31 PM (2).jpeg>)

### Payload

```json
{
  "source": "EventBridge Scheduler",
  "type": "PaymentReminder",
  "orderId": "O-5001",
  "message": "Payment is pending"
}
```

### Execution result

The PaymentReminder message arrived successfully in the priority SQS queue.

![alt text](<WhatsApp Image 2026-10-05 at 9.09.31 PM (2)-1.jpeg>)

### Schedule cleanup behavior

The schedule was configured with:

```text
Action after completion: DELETE
```

Therefore, after successful execution, the one-time schedule is intended to be automatically removed.

### Scheduler DLQ versus SQS DLQ

- Scheduler DLQ is for failures while invoking the configured target.
- SQS DLQ is for messages that repeatedly fail consumer processing.

They solve different failure scenarios.

---

# Day 17 - Kinesis and Firehose

## Kinesis Data Stream

Created:

```text
cloudadhar-clickstream-day17
```

Configuration:
- Capacity mode: On-demand
- Retention: 1 day
- Maximum record size: 1024 KiB
- Enhanced monitoring: Disabled
- Status: Active

### Record production

Two C101 records were produced using the same partition key:

```text
customer-C101
```

Records:

```json
{"event":"PRODUCT_VIEWED","customerId":"C101","productId":"P100"}
```

```json
{"event":"ADD_TO_CART","customerId":"C101","productId":"P100"}
```

### Data Viewer result

Both C101 records appeared on the same shard with increasing sequence numbers.

![alt text](<WhatsApp Image 2026-10-05 at 9.09.33 PM.jpeg>)

### Partition key distribution

Kinesis uses the partition key to calculate a hash that determines the target shard. Using the same partition key keeps related records on the same shard, which is useful when maintaining ordering for a customer or other logical entity.

---

## Firehose Delivery Stream

Created:

```text
cloudadhar-clickstream-firehose-day17
```

Configuration:
- Source: Kinesis Data Streams
- Source stream: `cloudadhar-clickstream-day17`
- Destination: S3
- Buffer size: 5 MiB
- Buffer interval: 300 seconds
- Compression: Uncompressed
- Data transformation: Disabled
- Record format conversion: Disabled
- Decompression: Disabled
- Dynamic partitioning: Disabled
- Error logging: Enabled

> Firehose was allowed to use a console-created IAM service role.

---

## S3 Delivery Validation

The destination S3 bucket was created with:
- Private access
- Block Public Access enabled
- ACLs disabled
- SSE-S3 encryption

The live bucket name used during the practice had an `-om` suffix because the originally proposed bucket name was unavailable.

### C102 test records

After Firehose became Active, new records were sent using:

```text
customer-C102
```

The actual live test used:

```json
{"event":"PRODUCT_VIEWED","customerId":"C102","productId":"P200"}
```

and:

```json
{"event":"ADD_TO_CART","customerId":"C102","productId":"P200"}
```

Both `put-record` operations returned a ShardId and SequenceNumber successfully.

                     

### S3 object delivery

After the Firehose buffering period, an object appeared in S3.

The object listing showed:
- Objects: 1
- Size: 127 B
- Storage class: Standard


### S3 object path structure

Firehose used a time-based path similar to:

```text
YYYY/MM/dd/HH
```

The path uses UTC time, so the S3 folder hour can differ from the local IST clock by 5 hours 30 minutes.

### Buffering and delivery latency

The `5 MiB / 300 seconds` buffering configuration means Firehose may wait for either the buffer size or the buffer interval before delivering data. This reduces the overhead of many tiny S3 objects but increases delivery latency compared with real-time processing.

---

# Day 17 - Service Selection

## Amazon MQ Walkthrough

Amazon MQ was inspected without creating a broker.

Engines reviewed:
- RabbitMQ
- ActiveMQ

Configuration areas reviewed:
- Broker size
- Deployment options
- VPC and subnets
- Security groups
- Private access
- Users/authentication
- Encryption
- Maintenance

### Use case

Amazon MQ is suitable when an existing application already depends on RabbitMQ or ActiveMQ protocols and broker semantics, especially when minimizing application migration changes is important.

## Amazon MSK Walkthrough

Amazon MSK was inspected without creating a cluster.

Options reviewed:
- MSK Provisioned
- MSK Serverless
- Kafka versions
- Topics
- Partitions
- Consumer groups
- VPC networking
- IAM/SASL/SCRAM/TLS authentication
- Encryption
- Monitoring
- Multi-AZ architecture

### Use case

Amazon MSK is suitable when applications require Apache Kafka APIs, Kafka clients, consumer groups, offsets, retained topics, or Kafka ecosystem compatibility.

---

# Architecture Decision

## SQS versus SNS

SQS is a queue used to decouple producers and consumers. A message is normally processed by a consumer from a queue. SNS is a publish/subscribe service where one published message can be delivered to multiple subscribers. In this practical, SNS fanout sent order events to both the Standard and Priority SQS queues.

## Visibility timeout

The visibility timeout should be longer than the expected processing time. After a consumer receives a message, SQS temporarily hides it. If processing succeeds, the consumer deletes it. If processing fails and the message is not deleted, it becomes visible again and can eventually move to the DLQ.

## FIFO ordering

FIFO queues provide ordering within a message group. The trade-off is that strict ordering can limit parallelism when too many messages use one group. Multiple groups allow more parallel processing while preserving per-group ordering.

## Dead-letter queues

The source queue used 4-day message retention while the DLQ used 14 days. The longer DLQ retention provides more time to investigate failed messages before they expire.

## SNS filter policies

SNS filter policies reduce unnecessary deliveries. The Standard queue received every order, while the Priority queue received only messages whose `priority` message attribute was `HIGH`.

## EventBridge patterns

EventBridge can route events based on event content, such as `source`, `detail-type`, and numeric values inside `detail`. This made it possible to route only orders with `amount > 5000` to the Priority queue.

## Scheduler versus Cron

EventBridge Scheduler provides managed scheduling without requiring a server running cron. The one-time schedule was configured to delete itself after successful completion.

## Kinesis partitioning

The customer ID was used as the partition key. Records with the same key were placed on the same shard, which is useful for maintaining ordering for a customer.

## Firehose buffering

Firehose buffering trades delivery latency for efficient S3 delivery. The practice used `5 MiB / 300 seconds`, so delivery was not immediate. Larger batches can reduce the number of small S3 objects and associated overhead.

## Idempotent consumers

Consumers should safely handle duplicate deliveries. A common approach is to store a unique event ID or order ID and ignore an event if it has already been processed. This is important because distributed messaging systems can deliver a message more than once.

## Cost estimation

The main cost drivers to consider are:
- SQS API requests
- SNS message deliveries
- EventBridge invocations
- Kinesis Data Streams capacity/usage
- Firehose data ingestion and delivery
- S3 storage and requests

For a disposable learning lab, deleting unused resources after testing helps avoid unnecessary charges.

---

# Cleanup Verification

The practical cleanup plan was:

- [ ] Firehose stream deleted
- [ ] Kinesis stream deleted
- [ ] S3 bucket emptied and deleted
- [ ] EventBridge rule deleted
- [ ] Custom event bus deleted
- [ ] One-time Scheduler schedule confirmed automatically removed
- [ ] SNS subscriptions and topic deleted
- [ ] All four SQS queues purged and deleted
- [ ] Execution roles cleaned up after confirming they were unused
- [ ] No Amazon MQ broker created
- [ ] No Amazon MSK cluster created
- [ ] Final console verification completed

> Mark the checkboxes only after personally verifying the cleanup. The screenshots in this document prove the creation/testing stages; they should not be treated as cleanup proof.

---

# Reflection

### 1. Why must SQS visibility timeout be longer than the expected processing time?

Because the message should remain hidden while the consumer is processing it. If the timeout expires too early, the same message can become visible and be processed by another consumer before the first consumer finishes.

### 2. What is the difference between SQS Standard and FIFO?

Standard queues prioritize high scalability and throughput. FIFO queues provide ordered processing within message groups and support FIFO-specific deduplication behavior.

### 3. When would you use SNS filter policy versus EventBridge pattern matching?

SNS filter policies are useful when filtering messages delivered from a topic to subscribers. EventBridge patterns are useful when routing application events based on event fields such as source, detail type, and nested content.

### 4. How does EventBridge Scheduler automatically delete one-time schedules?

The schedule was configured with `Action after completion: DELETE`. After the one-time invocation completes, the schedule is automatically removed.

### 5. Why is the partition key important for Kinesis?

The partition key determines the shard assignment. Using the same key keeps related records on the same shard and supports ordered processing for that logical entity.

### 6. How does Firehose buffering affect S3 delivery latency and cost?

Larger buffering can reduce the number of small S3 objects and improve delivery efficiency, but it increases the time before a record becomes available in S3.

### 7. What makes a consumer idempotent?

An idempotent consumer can receive the same event multiple times without causing the business operation to happen multiple times. It can use a unique event ID, transaction ID, or order ID to detect already-processed events.

### 8. How would you monitor queue depth, message age, and DLQ messages in CloudWatch?

Use SQS CloudWatch metrics to monitor available messages, visible/in-flight messages, age of the oldest message, and DLQ activity. Alarms can be created when thresholds are exceeded.

### 9. What is the difference between SQS DLQ and EventBridge Scheduler DLQ?

An SQS DLQ handles messages that repeatedly fail consumer processing. A Scheduler DLQ is associated with failures when Scheduler cannot successfully invoke its target.

### 10. How would you scale this architecture to handle millions of orders per day?

Use multiple SQS consumers, multiple FIFO message groups when ordering is required, SNS fanout for independent consumers, EventBridge rules for event routing, Kinesis partitioning for high-volume streams, Firehose for managed delivery, and CloudWatch monitoring/alarms for bottlenecks and failures.

---

# Troubleshooting Lessons

## Problem 1 - Kinesis PutRecord AccessDenied

**Problem:** The EC2 environment initially received an `AccessDenied` error when trying to call `kinesis:PutRecord`.

**Root cause:** The assumed IAM role did not initially have permission to put records into the Kinesis stream.

**Resolution:** The required Kinesis permission was added to the role.

**Prevention:** Check IAM permissions for the exact AWS API action before testing.

---

## Problem 2 - SNS HIGH filter test did not route initially

**Problem:** The HIGH-priority message was initially not routed to the priority queue.

**Root cause:** The `priority` value was placed only inside the JSON message body, while the SNS filter policy was configured for **Message attributes**.

**Resolution:** Published the message again with a String message attribute:

```text
Name: priority
Value: HIGH
```

**Prevention:** Always match the filter policy scope with the location of the filtering field.

---

## Problem 3 - FIFO receipt handle expired

**Problem:** A FIFO message deletion can fail if an old receipt handle is used.

**Root cause:** The receipt handle belongs to a specific receive operation and can expire after the visibility timeout.

**Resolution:** Poll again, use the current receipt handle, and delete the newly received message before the visibility timeout expires.

**Prevention:** Delete messages using the latest receipt handle.

---

## Problem 4 - Firehose/S3 delivery delay

**Problem:** Kinesis records did not appear in S3 immediately.

**Root cause:** Firehose was configured with a `5 MiB / 300 seconds` buffer.

**Resolution:** Waited for the buffering period and then verified the S3 object.

**Prevention:** Choose buffer settings based on the required balance between delivery latency and efficient object creation.

---

# Final Architecture

```text
                         ┌──────────────────────┐
                         │      SNS Topic       │
                         │ cloudadhar-orders... │
                         └──────────┬───────────┘
                                    │
                       ┌────────────┴────────────┐
                       │                         │
                       ▼                         ▼
              Standard SQS              Priority SQS
              All messages              HIGH messages
                       │                         ▲
                       │                         │
                       ▼                         │
                    DLQ                         │
                       │                         │
                       └── Redrive ─────────────┘


Application Event
       │
       ▼
EventBridge Custom Bus
       │
       │ amount > 5000
       ▼
Priority SQS


EventBridge Scheduler
       │
       │ PaymentReminder
       ▼
Priority SQS


Clickstream
    │
    ▼
Kinesis Data Streams
    │
    ▼
Amazon Data Firehose
    │
    ▼
Private S3 Bucket
```

![alt text](<ChatGPT Image Oct 5, 2026, 09_27_40 PM.png>)



---

# Key Day 17 Result

The practical demonstrated a complete event-driven AWS flow:

- SQS Standard + DLQ + redrive
- SQS FIFO message-group ordering
- SNS topic fanout and filtering
- EventBridge content-based routing
- EventBridge one-time scheduling
- Kinesis partitioning and record ingestion
- Firehose buffering and S3 delivery
- Amazon MQ and MSK service-selection decisions

The main design lesson is that each service solves a different part of an event-driven architecture: **SQS handles durable queueing, SNS handles fanout, EventBridge handles event routing, Scheduler handles time-based events, Kinesis handles streaming ingestion, Firehose handles managed delivery, and S3 provides durable object storage.**
