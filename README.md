# Challenge

To start your Phoenix server:

* Install dependencies with `mix deps.get`
* Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Phoenix server runs in [`localhost:4000`](http://localhost:4000) in development environment.

## Numbers API Documentation

* In [`/docs/api.md`](/docs/api.md) you can find a Numbers API documentation.

## Some improvements that can be made

* Add a database to persist cached data
* Endpoint pagination
* Add more fields to data returned in index endpoint like extraction_date, transformation_date
* Add more resilience to Challenge.Worker (turn into GenServer or use something more robust like Oban?)
* Create a version of parallel merge sort algorithm
* Add more tests
* Improve code and api documentation
