## Disclaimer

Coding session lasted for 03:55 hours, approximately from 7:00pm to 10:55pm.

Documentation lasted for another 20 or so minutes, approximately from 10:55pm to 11:15pm.

Apologize for any misspelling, I didn't have enough time to think about and review what I was writing.

Thanks ;)

## Description

This is a proof-of-concept of a thread-safe in-memory database, using:

- `Concurrent::Hash` data structure from the `concurrent-ruby` gem
- `Rails` API mode
- A custom developed ActiveRecord-like library.

See more about key decisions in the [Project structure](#project-structure) section.

## Tech Requirements

- Ruby 3.3.0
- Rails 7.2.1

## How to start

##### A. The supposedly easy way

Make sure you have `Docker` up and running on your machine ((out of this guide's scope), then...

TBD: docker

#### B. The standard way

Make sure you have `Ruby 3.3.0` installed (out of this guide's scope), then...

Clone the project:

```bash
git clone git@github.com:marcosvafilho/device_readings.git
```

Divo into the project directory:

```bash
cd device_readings
```

Install dependencies:

```bash
bundle exec install
```

Start the web server:

```bash
bundle exec rails server
```

## How to use

Your server will be serving requests on either `http://127.0.0.1:3000` or `http://localhost:3000`, unless you have changed something in your environment.

These are the available endpoints and their respective body, params, and responses:

#### POST `/api/v1/readings`

Description: Adds one or more readings to a given device.

Body:

- **id:** a UUID string representing the device
- **readings:** an array of reading objects
    - **timestamp:** an ISO-8601 string representing the reading timestamp
    - **count:** an integer representing the reading count

```curl
curl -X POST http://127.0.0.1:3000/api/v1/readings \
  -H "Content-Type: application/json" \
  -d '{
  "id": "36d5658a-6908-479e-887e-a949ec199272",
  "readings": [
    {
      "timestamp": "2021-09-29T16:08:15+01:00",
      "count": 2
    },
    {
      "timestamp": "2021-09-29T16:09:15+01:00",
      "count": 15
    }
  ]
}'
```

Response:

```json lines
// HTTP 201 CREATED (no body)
```

---

#### GET `/api/v1/devices/<DEVICE_ID>/latest_timestamp`

Description: Gets the latest reading timestamp for a given device.

Query Params:

- **device_id:** an UUID string representing the device

```curl
curl http://127.0.0.1:3000/api/v1/devices/<DEVICE_ID>/latest_timestamp
```

Response:

```json lines
// HTTP 200 OK

{
  "latest_timestamp": "2021-09-29T16:08:15+01:00"
}
```

---

#### GET `/api/v1/devices/<DEVICE_ID>/cumulative_count`

Description: Gets the cumulative count for a given device.

Query Params:

- **device_id:** an UUID string representing the device

```curl
curl http://127.0.0.1:3000/api/v1/devices/<DEVICE_ID>/cumulative_count
```

Response:

```json lines
// HTTP 200 OK

{
  "cumulative_count": 17
}
```

## Project structure

This proof-of-concept aims to adhere as much as possible to the "Rails way" of building web applications, allowing new developers to quickly get familiar with the architecture and promptly contribute to the project.

The main goal was to build a working application with easy maintainability and onboarding, where everything is located exactly where expected, not to build the most complex/clever architecture.

##### Request Layer

- The API is versioned, currently in the `v1` state.


- Both `latest_timestamp` and `cumulative_count` endpoints are nested under the `device` namespace and id, resulting in urls like `/devices/:uuid/latest_timestamps`, according to established best practice among Rails developers.


- The `readings` creation endpoint is nested under the `reading` namespace, following the the request format which added the `device_id` to the body/payload instead of including in the url: `/readings`


- Controllers are simple, avoiding unnecessary delegation to service objects or other similar approaches.

##### Data Layer (decisions)

- `Concurrent::Hash`, `in-memory SQLite database` and `in-memory Rails.cache datastore` were initially the main candidates to the data layer architecture.


- `in-memory SQLite` offers a great benefit of working out of the box with the standard `ActiveRecord` implementation, on top of being a database that works embedded to the web server process. But I was afraid of bigger challenges regarding thread-safety, as well as that it wouldn't comply with the `no-disk` requirement, due to same advanced features like `temporary databases` and `write ahead logging`.


- `in-memory Rails.cache` never passed the smell test because it felt hacky using a cache tool as a proper database, plus it would apparently require a bigger effort coming up with an ActiveRecord-like interface on top of it.


- `Concurrent::Hash` immediately stood out due to its simple use (exactly the same as standard hashes), its built-in thread-safety, its broader focus instead of narrowed down to caching, the guaranteed `in-memory` and `single-server` approach, and its potential to work with a custom interface.


- An ActiveRecord-like interface was a **MUST** when considering the main goal (easy maintainability and onboarding), while thread safety was also vital, on top of the other requirements. **They all led `Concurrent::Hash` to be the chosen one.**


##### Data Layer (implementation)

- `ActiveMemory` is a custom ActiveRecord-like interface offering easy methods to interact with an `in-memory` data store (as opposed to its inspiration, which works with persistent databases).


- It lives under the `/lib/active_memory` directory, currently implementing `Base`, `Errors` and `Associations` features, while also including `Model`, `Attributes` and `Validations` features from `ActiveModel`.


- The `ActiveMemory::Base` class instantiate a `Concurrent::Hash` in-memory storage, keeping it "alive" through the entire web server process.


- Inspired by `ActiveRecord`, it also implements neat methods like `.find!`, `.where`, `.create!`, `save!`, and others that interact with the storage, querying and inserting data as needed.


- Thanks to `ActiveMemory`, we can still use model files to control domain/data behavior, similar to how we are used to with standard `Rails` applications.


- Models inherit from `ApplicationMemory`, which is only a wrapper to `ActiveMemory::Base`, emulating the `ApplicationRecord` implementation.


- Due to this inheritance, models are enriched with much needed capabilities like querying, in-memory "persistence", validation, and attribute definition/schema/type-casting.


- The association feature offers a basic ability to retrieve associated records, currently missing the ability to set the association from the "owner record" side.


- The validation feature comes from `ActiveModel`, but it gets override by custom errors and custom validators, respectively located at `/lib/active_memory/errors.rb` and `/app/validators`.

## Improvements

Improvements are segmented according to these two different scenarios:

##### 1. Given more time and same strict requirements

- Figure out if other `Concurrent` types would be more appropriate (like `Concurrent:Map`).


- Make `ActiveMemory` more robust by adding other ActiveRecord-like features and integrations.


- Add format validation to the uuid string from payload's `id` key (needs understanding with client/device side about request consistency).  


- Maybe move `latest_timestamp` and `cumulative_count` from calculated methods to eagerly stored attributes, effectively working as a `counter_cache` feature (needs understanding about which one of the endpoints is consumed the most).


- Move custom validators specifically built for `ActiveMemory` from `/app/validators` to `/lib/active_memory`.


- Dry up tests a bit, removing duplicate `let` directives.


- Write validators unit tests (currently missing due to time restrictions).


- Write integration tests (currently missing due to time restrictions).


- Add `JBuilder` in order to build more complex `JSON` responses and move their definition away from controllers.


- Return the newly created records in the `JSON` response, allowing devices to eventually keep track of processed readings.


- Add `json-schema` gem in order to add payload validation at the request layer (currently the data layer bubbles up validation errors up to controllers).


- Eagerly return `HTTP 400 Bad Request` for malformed `JSON` payloads.


- Eagerly validate and return `HTTP 422 Unprocessable Entity` for payloads with invalid records, refusing the entire request, instead of processing some and finishing with the first invalid record (needs better understanding of business rules in order to take a decision).


- Move `readings` creation from `/readings` to `/devices/<DEVICE_ID>/readings`, following the _"Rails way_" of building routes (needs agreement from the client/device side, changing the request payload).


- Allow the `latest_timestamp` endpoint to query with different time zone.


- Experiment with `Rails.cache` either integrated or in replacement of `Concurrent::Hash`.


- Add `Docker` instructions to run the project locally.


- Add `Swagger`, `Slate`, or any other alternative to properly document the API.


- Add `Postman` or `Insomnia` collection.


- Add code coverage


##### 2. Given more time and more flexible requirements

- Try to implement the **in-memory** feature from `SQLite`, in order to have `ActiveRecord` working out of the box, including migrations.


- Use `counter_cache` feature, either from `ActiveRecord` or `counter_culture` gem, instead of calculating `latest_timestamp` and `cumulative_count` on the fly.


- Alternatively to `SQLite`, install and run Redis (different process than the web server, unfortunately).


## Self-evaluation

Does the API function according to the requirements?

```text
Yes. 
  
The API works according to both the business rules and the tech constraints.
  
Business rules:
  
- It stores readings for devices
- It returns the timestamp of the latest reading for a device
- It returns the cumulative count across all readings for a device
  
Tech constraints:
  
- It doesn't persist any data to disk
- It stores all data in memory
- It only requires the web server process running
```
