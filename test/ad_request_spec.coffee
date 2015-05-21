require './test_case'
{expect} = require 'chai'

AdRequest = require '../src/ad_request'
{Ajax}    = require 'ajax'


describe 'AdRequest', ->

  beforeEach ->
    @config  = @injector.getInstance 'config'
    @request = @injector.getInstance AdRequest
    @http    = @injector.getInstance Ajax

  it 'should inject a config', ->
    expect(@request.config).to.equal @injector.getInstance 'config'

  it 'should get proper url from config', ->
    expect(@config.url)
      .to.equal 'http://test.api.vistarmedia.com/api/v1/get_ad/json'

  it 'should make a POST request to the get_ad endpoint', (done) ->
    url = 'http://test.api.vistarmedia.com/api/v1/get_ad/json'
    @http.match url: url, type: 'POST', (req, promise) ->
      done()

    @request.fetch().then -> done()

  describe '#body', ->

    it 'should have the network_id', ->
      body = @request.body()
      expect(body.network_id).to.equal 'YOUR_NETWORK_ID'

    it 'should have the api_key', ->
      body = @request.body()
      expect(body.api_key).to.equal 'YOUR_API_KEY'

    it 'should have the device_id', ->
      body = @request.body()
      expect(body.device_id).to.equal 'YOUR_DEVICE_ID'

    it 'should have the venue_id', ->
      body = @request.body()
      expect(body.venue_id).to.equal 'YOUR_VENUE_ID'

    it 'should have the number_of_screens', ->
      body = @request.body()
      expect(body.number_of_screens).to.equal 1

    it 'should have latitude', ->
      body = @request.body()
      expect(body.latitude).to.equal 39.9859241

    it 'should have longitude', ->
      body = @request.body()
      expect(body.longitude).to.equal -75.1299363

    it 'should have direct_connection', ->
      body = @request.body()
      expect(body.direct_connection).to.be.false

    it 'should have display_time between now and 1m from now', ->
      now    = Math.floor(new Date().getTime() / 1000)
      future = now + 61
      body = @request.body()
      expect(body.display_time).to.be.within(now, future)

    it 'should have the display_area array', ->
      displayArea = @request.body().display_area
      expect(displayArea).to.be.an.instanceOf Array
      expect(displayArea).to.have.length 1
      expect(displayArea[0].width).to.equal 1280
      expect(displayArea[0].height).to.equal 720
      expect(displayArea[0].allow_audio).to.equal true

    it 'should add mimetypes to the display area `supported_media`', ->
      displayArea = @request.body().display_area
      expect(displayArea[0].supported_media).to.exist
      expect(displayArea[0].supported_media).to.include 'text/x-injected-test-value'

    it 'should have the device_attribute array', ->
      body = @request.body()
      expect(body.device_attribute).to.be.an.instanceOf Array
      expect(body.device_attribute).to.have.length 2
      expect(body.device_attribute[1].name).to.equal 'MimeTypes'
      expect(body.device_attribute[1].value)
        .to.equal @request.supportedMedia().join(', ')

  describe '#fetch', ->

    it 'should include mime types in display_area supported_media', (done) ->
      url = 'http://test.api.vistarmedia.com/api/v1/get_ad/json'
      @http.match url: url, type: 'POST', (req, promise) ->
        requestBody = JSON.parse(req.data)
        mimeTypes = requestBody.display_area[0].supported_media
        expect(mimeTypes).to.exist
        expect(mimeTypes).to.include 'text/x-injected-test-value'
        done()

      @request.fetch()

    it 'should POST an ad request of the expected format', (done) ->
      url = 'http://test.api.vistarmedia.com/api/v1/get_ad/json'
      @http.match url: url, type: 'POST', (req, promise) ->
        requestBody = JSON.parse(req.data)
        expect(requestBody.network_id).to.exist
        expect(requestBody.api_key).to.exist
        expect(requestBody.display_area).to.have.length 1
        done()

      @request.fetch()

    it 'should resolve with the ad response', (done) ->
      url = 'http://test.api.vistarmedia.com/api/v1/get_ad/json'
      @http.match url: url, type: 'POST', (req, promise) =>
        promise.resolve @fixtures.adResponse

      success = (response) ->
        expect(response).to.be.an.instanceOf Object
        expect(response.advertisement).to.have.length 2
        done()
      @request.fetch().then(success).done()

  describe '#supportedMedia', ->

    context 'when config.mimeTypes is undefined', ->

      beforeEach ->
        @_origMimeTypes = @request.config.mimeTypes
        @request.config.mimeTypes = undefined

      afterEach ->
        @request.config.mimeTypes = @_origMimeTypes

      it 'should return a list of mime types supported by browsers', ->
        mimeTypes = @request.supportedMedia()

        expect(mimeTypes).to.include 'image/gif'
        expect(mimeTypes).to.include 'image/jpeg'
        expect(mimeTypes).to.include 'image/png'
        expect(mimeTypes).to.include 'video/webm'

      it 'should return a list include mime types read from window.navigator', ->
        mimeTypes = @request.supportedMedia()

        expect(mimeTypes).to.include 'text/x-navigator-mime-type'

    context 'when config.mimeTypes is empty list', ->

      beforeEach ->
        @_origMimeTypes = @request.config.mimeTypes
        @request.config.mimeTypes = []

      afterEach ->
        @request.config.mimeTypes = @_origMimeTypes

      it 'should return a list of default mime types supported by browsers', ->
        mimeTypes = @request.supportedMedia()

        expect(mimeTypes).to.include 'image/gif'
        expect(mimeTypes).to.include 'image/jpeg'
        expect(mimeTypes).to.include 'image/png'
        expect(mimeTypes).to.include 'video/webm'

    context 'when config.MimeTypes is not empty', ->

      beforeEach ->
        @_origMimeTypes = @request.config.mimeTypes
        @request.config.mimeTypes = ['text/x-injected-test-value']

      afterEach ->
        @request.config.mimeTypes = @_origMimeTypes

      it 'should not be empty', ->
        expect(@request.config.mimeTypes.length).to.be.at.least 1

      it 'should return a list including only injected mime types', ->
        mimeTypes = @request.supportedMedia()

        expect(mimeTypes).to.include 'text/x-injected-test-value'
        expect(mimeTypes).to.have.length 1
