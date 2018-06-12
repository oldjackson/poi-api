
# poi-api

This very simple API is a wrapper for [Mapbox](https://www.mapbox.com) handling specifically the search of museums around a given location.

## Specifications
The goal was to have an endpoint like

`/museums?lat=52.494857&lng=13.437641`

return a JSON response containing information about museums existing around the `(lat, lng)` GPS point provided in the URL via the query string. Specifically, the returned object has to represent the hash of the museums' names ordered using their postcodes as keys, as in
```json
{
  "10999": ["Werkbundarchiv – museum of things"],
  "12043": ["Museum im Böhmischen Dorf"],
  "10179": [
   "Märkisches Museum",
   "Museum Kindheit und Jugend",
   "Historischer Hafen Berlin"
  ],
 "12435": ["Archenhold Observatory"]
}
```
The corresponding Mapbox request, as detailed in the [Mapbox documentation](https://www.mapbox.com/api-documentation/#poi-categories), needs a slightly more complicated query (including the registered user's API key) and returns a lot  more information. The idea is then simply to wrap a POI request to Mapbox and extract from the response only the desired information, reordering it as shown.

## Rails app overview
I used Ruby 2.4.4 and Rails 5.2 .

Having to build essentially a one-routed (or at least one-controller) RESTful API, I kept it as simple as possible, generating it with
```sh
rails new poi-api -0 --skip-spring --skip-active-storage -C -M --api
```
that is, without any database (`-0`), no Spring, no Active Storage, no Action Cable, no Action Mailer (`--skip-spring`, `--skip-active-storage`, `-C`, `-M` respectively) and `--api` to configure it to render JSON.

### Controller
The specs require one route, `/museums`, but looking at the Mapbox documentation one realizes that museums are just one of quite many available POI categories, whose search route differ from one another for the category name itself appearing in the URL. It is therefore natural to define a `Poi` controller rather than a `Museum` one, providing a `pois#museums` action for museums: the action just passes the category name down to the methods making the proper request. Such methods can then be factored out as private to the controller, while defining new actions for new categories becomes obvious (`/cinemas` for cinemas via `pois#cinemas` etc).

To make the actual requests to Mapbox, I chose the simple `RestClient` gem. I factored out also a method which builds the complete URL for Mapbox, noting that this also can be easily improved by adding other query parameters supported by Mapbox.

### Routes, versioning and tests
The route automatically created by
```sh
rails g controller pois museums
```
is not the requested one and needs to be redefined as
```ruby
get 'museums', to: 'pois#museums'
```
For the tests I chose to use the `Minitest` suite embedded in Rails: the `PoisControllerTest` class is also automatically created by the controller generator.

Following the best practices for APIs, I versioned the app. The resulting routes are prepended by `/api/v1`, which breaks the correspondence with the helpers `pois_museums_url` in the tests. Then I chose not to version the tests but instead to hardcode another route used by the tests, so to change only that one when switching versions (though probably another solution would have been smarter).

### VCR
To make the tests independent of the actual response from Mapbox, which is not guaranteed to be stable (their db is constantly evolving; Mapbox could be offline, or interrupt the responses after an amount of requests from the same free-account user), I used the `VCR` gem.

`VCR` stores the response to a given request in a "cassette" file the first time such request is made. Subsequent requests by the test to the same URL will not trigger a real new request: instead, `VCR` will trick the test responding with the content of the locally stored cassette. This also speeds up the test execution.



## Installation
After cloning the repo, you should

 - `bundle install`
 - Since Mapbox requires, to use their API, a registered user token to be embedded in the request, anyone willing to use `poi-api` needs to sign up to Mapbox and embed their API token into the `poi-api` configuration. You can do this overwriting the placeholder in `config/mbconfig.yml` with your key.
 - `Minitest` may complain about `schema.rb` even if our app has no models at all. A `rails db:migrate` fixes the problem.

## Usage
After launching the rails server with `rails s` you are good to go.

As is, `poi-api` supports the `/museums` routes with two possible query strings:
 1. The one requested by specifications, as in
 ```url
 http://localhost:3000/api/v1/museums?lat=45.474306&lng=9.204665
 ```
 returning some museums in Milan ordered by post code. If one chooses a location too far from any area covered by Mapbox, the result is not very useful (some museums scattered around the world), but consistent in itself.

 2. Empty query string, as in
 ```url
 http://localhost:3000/api/v1/museums
 ```
 The result coincides with the border case of 1.

In case Mapbox returns some error (missing API key, out of bounds coordinates, ... ) the message is returned as it is.

## Testing
By running `rake`, the test suite will be executed along with a style check performed by `rubocop`.
To run only the tests or only the linter, run respectively `rake test` or `rake rubocop`.

If needed, one can delete the `VCR` cassette files in `/fixtures`, as they will be recreated relaunching the tests. A cassette name is uniquely linked with a requested URL: deleting the cassette becomes necessary if a change in some test url is needed.
