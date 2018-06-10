require 'test_helper'
require 'json'

class PoisControllerTest < ActionDispatch::IntegrationTest
  test "should respond to the basic museum search" do
    get pois_museums_url
    assert_response :success, "Did not get a successful response for museums without query"
    response_hash = JSON.parse(response.body)
    assert_not_empty response_hash, "Got an empty response"
  end

  test "should respond to the museum search around a location" do
    get "#{pois_museums_url}?lat=52.494857&lng=13.437641"

    assert_response :success, "Did not get a successful response for museums around a location"

    response_hash = JSON.parse(response.body)
    assert_not_empty response_hash, "Got an empty response"
  end

  test "should get some of the museums around Görlitzer Park, Berlin" do
    get "#{pois_museums_url}?lat=52.494857&lng=13.437641"

    response_hash = JSON.parse(response.body)

    assert_includes(response_hash.values.flatten, "Werkbundarchiv – museum of things", "Did not get the Museum of Things")
    assert_includes(response_hash.values.flatten, "Museum Kindheit und Jugend", "Did not get the Museum of Chilhood and Youth")
    assert_includes(response_hash.values.flatten, "Archenhold Observatory", "Did not get the Archenhold Observatory")
  end

  test "should get some of the museums around Görlitzer Park, Berlin, with their correct post codes" do
    get "#{pois_museums_url}?lat=52.494857&lng=13.437641"

    response_hash = JSON.parse(response.body)

    assert_includes(response_hash.keys, "10999", "Did not get the Museum of Things under its correct post code")
    assert_includes(response_hash["10999"], "Werkbundarchiv – museum of things", "Did not get the Museum of Things under its correct post code")

    assert_includes(response_hash.keys, "10179", "Did not get the Museum of Chilhood and Youth under its correct post code")
    assert_includes(response_hash["10179"], "Museum Kindheit und Jugend", "Did not get the Museum of Chilhood and Youth under its correct post code")

    assert_includes(response_hash.keys, "12435", "Did not get the Archenhold Observatory under its correct post code")
    assert_includes(response_hash["12435"], "Archenhold Observatory", "Did not get the Archenhold Observatory under its correct post code")
  end

  test "should get some of the museums around Porta Venezia, Milan" do
    get "#{pois_museums_url}?lat=45.474306&lng=9.204665"

    response_hash = JSON.parse(response.body)

    assert_includes(response_hash.values.flatten, "Planetario di Milano", "Did not get the Milan Planetarium")
    assert_includes(response_hash.values.flatten, "Bagatti Valsecchi Museum", "Did not get the Bagatti Valsecchi Museum")
    assert_includes(response_hash.values.flatten, "Spazio Oberdan", "Did not get the Spazio Oberdan")
  end

  test "should get some of the museums around Porta Venezia, Milan, with their correct post codes" do
    get "#{pois_museums_url}?lat=45.474306&lng=9.204665"
    response_hash = JSON.parse(response.body)

    assert_includes(response_hash.keys, "20121", "Did not get the Milan Planetarium under its correct post code")
    assert_includes(response_hash["20121"], "Planetario di Milano", "Did not get the Milan Planetarium under its correct post code")

    assert_includes(response_hash.keys, "20121", "Did not get the Bagatti Valsecchi Museum under its correct post code")
    assert_includes(response_hash["20121"], "Bagatti Valsecchi Museum", "Did not get the Bagatti Valsecchi Museum under its correct post code")

    assert_includes(response_hash.keys, "20124", "Did not get the Spazio Oberdan under its correct post code")
    assert_includes(response_hash["20124"], "Spazio Oberdan", "Did not get the Spazio Oberdan under its correct post code")
  end
end
