**Clock Test**

Run clock spec from command line:

```
$ ruby clock_spec.rb
```


Expected output:

```
Run options: --seed 26146

# Running:

....

Finished in 0.002544s, 1572.2795 runs/s, 1572.2795 assertions/s.

4 runs, 4 assertions, 0 failures, 0 errors, 0 skips
```


**Repeating Rides**


Database Schema:


 When an organizer creates a repeating ride it is saved to the `scheduled_rides` table. This row is then used as a
 template for subsequent rides to be generated from.



`scheduled_rides`


```
+----------------+-------------+------------------------------------------------------+
| Field          | Type        | Description                                          |
+----------------+-------------+------------------------------------------------------+
| id             | int(11)     | primary key, auto increment                          |
| user_id        | int(11)     | foreign key for `users` table                        |
| pickup_time    | time        | scheduled pickup time                                |
| ride_name      | string      | organizer can name this ride                         |
| start_address  | string      | Street address of pickup location                    |
| end_address    | string      | Street address of drop-off location                  |
| repeat_type    | enum        | (daily, weekly, monthly)                             |
| repeat_value   | string      | depends on repeat type. examples below               |
| ends_at        | datetime    | when to stop repeating. If NULL then it's indefinite |
| created_at     | datetime    | created timestamp                                    |
| updated_at     | datetime    | updated timestamp                                    |
+----------------+-------------+------------------------------------------------------+

```

After submitting the form for a scheduled ride, an async job (e.g. ApplicationJob or Sidekiq) will create "rides" based
on the frequency setting for up to one year or "ends_at", which ever comes first. The ride information such as pickup
time and locations will be copied to each future ride.

Possible values for `repeat_value` if `repeat_type` is..
```
daily   --  No value required. Async job will create a ride for every day, up to one year or "ends_at" (which ever comes first)
weekly  --  Comma separated value of numeric day of week. e.g. Mon-Thur would be: 1,2,3,4
monthly --  Comma separated value of days of the month, e.g Every 1st and 15th would be 1,15
```

A `rides` row can be created manually from a ride request or generated from a scheduled_ride.

```
+-------------------+-------------+-------------------------------------------------------+
| Field             | Type        | Description                                           |
+-------------------+-------------+-------------------------------------------------------+
| id                | int         | primary key, auto increment                           |
| user_id           | int         | belongs to user                                       |
| driver_id         | int         | belongs to driver                                     |
| pickup_time       | datetime    | requested pickup time                                 |
| start_address     | string      | Street address of pickup location                     |
| end_address       | string      | Street address of drop-off location                   |
| start_location    | point(x,y)  | point(lat, long) for mobile app                       |
| end_location      | point(x,y)  | point(lat, long) for mobile app                       |
| distance          | decimal     | calculated and saved when trip is completed           |
| start_at          | datetime    | NULL/datetime when ride started                       |
| ended_at          | datetime    | NULL/datetime when ride ended                         |
| cancelled_at      | datetime    | NULL/datetime when ride was canceled                  |
| scheduled_ride_id | int(1)      | NULL/scheduled ride id. used for mass update/delete   |
+-------------------+-------------+-------------------------------------------------------+

```



**Rails Active Record Models**

```
scheduled_ride.rb
-
belongs_to :user
has_many :rides

```

```
ride.rb
-
belongs_to :scheduled_ride, optional: true
belongs_to :user
belongs_to :driver
```

**Rails Controllers**
```
#routes.rb
resources :scheduled_rides, :rides
```
scheduled_rides_controller.rb

```
#scheduled_rides_controller.rb

def new
    //show scheduled ride form
end


def create
    //create scheduled_ride record
    //pass new record to async job to generate repeated, future rides
end

def update
    //update all rides where schedule_ride_id matches parent
end


```

rides_controller.rb


```
#rides_controller.rb

def new
    //show new ride request form
end


def create
    //create new ride record
end

def update
    // check if scheduled_ride_id is present. if so, prompt to update all future rides
end


```

**Scheduled Rides REST API Documentation**

1. Creating a new scheduled ride
```
POST https://hopskipdrive.io/schedules (I'm assuming an authentication scheme is already present)

```
Request:


```
+----------------+--------+------------------------------------------------------+------------------------------------------------------------+
| Field          | Type   | Description                                          | Example                                                    |
+----------------+--------+------------------------------------------------------+------------------------------------------------------------+
| pickup_time    | string | pickup time                                          | 2019-06-14 12:30 PM                                        |
| ride_name      | string | name of repeating ride                               | Soccer Practice                                            |
| start_address  | string | Street address of pickup location                    | 123 Main st, Los Angeles, CA 90210                         |
| end_address    | string | Street address of drop-off location                  | 456 Home st, Chino Hills, CA 91709                         |
| repeat_type    | string | How often to repeat this ride                        | Possible values: "daily", weekly" or "monthly"             |
| repeat_value   | string | if repeat_type is "daily", this will be ignored      | Empty string or omit parameter                             |
|                |        | if repeat type is "weekly", set numeric day(s) of wk | 1,3,5 (would be monday, wednesday, friday of every week)   |
|                |        | if repeat type is "monthly",  set day(s) to repeat   | 1,15 (would be 1st and 15th of every month)                |
| ends_at        | string | Date when to stop repeat rides (optional)            | YYYY-MM-DD (will not create future rides passed this date  |
+----------------+--------+------------------------------------------------------+------------------------------------------------------------+

```

```

Example: POST https://hopskipdrive.io/schedules,

Form Data: {
             pickuptime: "2019-06-14 3:50 PM",
             ride_name: "school",
             start_address: "124 Scholarly Rd, Los Angeles, CA 94023",
             end_address: "833 Homestead, Brentwood, CA 94332",
             repeat_type: "weekly",
             repeat_value: "1,2,3,4,5"
             ends_at: '2020-09-21'
           }

```


Create Response
```
+-----------+------------------------------------------------------+-----------------------------------------------------------+
| HTTP CODE | Description                                          | Example                                                   |
+-----------+------------------------------------------------------+-----------------------------------------------------------+
| 201       | Scheduled ride was created successfully              | { message: 'schedule ride was successfully created }      |
| 409       | Conflict with existing schedule                      | { message: 'schedule ride could not be created.. }        |
| 400       | Bad Request                                          | { message: 'bad request. check parameters.. }             |
| 403       | Permission denied                                    | { message: 'authorization failed' }                       |
+-----------+------------------------------------------------------+-----------------------------------------------------------+

```

2. Updating a scheduled ride
```
POST https://hopskipdrive.io/schedules/:id/update

```
Update request parameters
```
+----------------+--------+------------------------------------------------------+------------------------------------------------------------+
| Field          | Type   | Description                                          | Example                                                    |
+----------------+--------+------------------------------------------------------+------------------------------------------------------------+
| pickup_time    | string | pickup time                                          | 2019-06-14 12:30 PM                                        |
| ride_name      | string | name of repeating ride                               | Soccer Practice                                            |
| start_address  | string | Street address of pickup location                    | 123 Main st, Los Angeles, CA 90210                         |
| end_address    | string | Street address of drop-off location                  | 456 Home st, Chino Hills, CA 91709                         |
| repeat_type    | string | How often to repeat this ride                        | Possible values: "daily", weekly" or "monthly"             |
| repeat_value   | string | if repeat_type is "daily", this will be ignored      | Empty string or omit parameter                             |
|                |        | if repeat type is "weekly", set numeric day(s) of wk | 1,3,5 (would be monday, wednesday, friday of every week)   |
|                |        | if repeat type is "monthly",  set day(s) to repeat   | 1,15 (would be 1st and 15th of every month)                |
| ends_at        | string | when to stop repeating rides (optional)              | YYYY-MM-DD (will not create future rides passed this date  |
+----------------+--------+------------------------------------------------------+------------------------------------------------------------+

```

```

Example: POST https://hopskipdrive.io/schedules/23451/update

Form Data: {
             pickuptime: "2019-06-14 3:50 PM",
             repeat_type: "weekly",
             repeat_value: "1,2,3"
           }

```


Update Response
```
+-----------+------------------------------------------------------+-----------------------------------------------------------+
| HTTP CODE | Description                                          | Example                                                   |
+-----------+------------------------------------------------------+-----------------------------------------------------------+
| 200       | Scheduled ride was updated successfully              | { message: 'schedule ride was successfully created }      |
| 400       | Bad Request                                          | { message: 'bad request. check parameters.. }             |
| 409       | Conflict with existing schedule                      | { message: 'schedule ride could not be updated.. }        |
| 403       | Permission denied                                    | { message: 'authorization failed' }                       |
+-----------+------------------------------------------------------+-----------------------------------------------------------+

```


3. Cancelling a scheduled ride
```
POST https://hopskipdrive.io/schedules/:id/cancel

```

```
Example: POST https://hopskipdrive.io/schedules/23451/cancel

```

Cancel Response
```
+-----------+------------------------------------------------------+-----------------------------------------------------------+
| HTTP CODE | Description                                          | Example                                                   |
+-----------+------------------------------------------------------+-----------------------------------------------------------+
| 200       | Scheduled ride was canceled successfully             | { message: 'schedule ride was canceled sucessfully }      |
| 400       | Bad Request                                          | { message: 'bad request. check parameters.. }             |
| 404       | Scheduled Ride not found                             | { message: 'bad request. check parameters.. }             |
| 403       | Permission denied                                    | { message: 'authorization failed' }                       |
+-----------+------------------------------------------------------+-----------------------------------------------------------+

```


**Edge Cases**

```
1. In the event that a new repeating ride conflicts with an existing ride i would allow the ride to be double booked
but provide a visual indication that there is a calender conflict. perhaps use a global flash or notificaton system
to inform the user of the conflict(s). I could test this by writing a test for the async job. in the test setup, insert
rides that will later be conflicted. then make sure proper methods are being invoked to notifiy the user of the conflict

-

2. Since we only create rides up to one year in advance, we would need a scheduled job to create rides for the following year if no changes
were made to the schedule settings.
```


**Performance Issues**

```
One use-case that could be a problem is when creating daily repeated rides. For example, if an organizer creates a
repeating ride that is set to "daily" with no end_date, then the backend would need to create 365 ride entries.

Creating that many entries could result in a bottleneck due to potential validations or
other business rules. To mitigate that I would use ActiveJob to create the rides asynchronously.


I would use the same tactic to handle edits as well.


