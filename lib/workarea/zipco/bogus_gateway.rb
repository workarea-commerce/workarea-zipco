module Workarea
  module Zipco
    class BogusGateway
      def create_order(order)
        Response.new(response(create_order_body))
      end

      def capture(attrs, request_id = nil)
        Response.new(response(capture_body))
      end

      def authorize(attrs, request_id = nil)
        if attrs[:authority][:value] == "timeout_token"
          Response.new(response(nil, 502))
        else
          Response.new(response(capture_body))
        end
      end

      def purchase(attrs, request_id = nil)
        Response.new(response(capture_body))
      end

      private

        def response(body, status = 200)
          response = Faraday.new do |builder|
            builder.adapter :test do |stub|
              stub.get("/v1/bogus") { |env| [ status, {}, body.to_json ] }
            end
          end
          response.get("/v1/bogus")
        end

        def create_order_body
          {
            "id": "co_P9GOgSVE9qMnL0VA6Jy8z6",
            "uri": "https://account.sandbox.zipmoney.com.au/?co=co_P9GOgSVE9qMnL0VA6Jy8z6&m=aa7bd4b9-f270-4eba-94b7-a64e95f6b13f",
            "type": "standard",
            "shopper": {
              "title": "Mr",
              "first_name": "John",
              "last_name": "Smith",
              "middle_name": "Joe",
              "phone": "0400000000",
              "email": "test@emailaddress.com",
              "birth_date": "2017-10-10",
              "gender": "Male",
              "statistics": {
                "account_created": "2015-09-09T19:58:47.697Z",
                "sales_total_count": 0,
                "sales_total_amount": 450,
                "sales_avg_amount": 0,
                "sales_max_amount": 0,
                "refunds_total_amount": 0,
                "previous_chargeback": false,
                "currency": "AUD"
              },
              "billing_address": {
                "line1": "10 Test st",
                "city": "Sydney",
                "state": "NSW",
                "postal_code": "2000",
                "country": "AU",
                "first_name": "John",
                "last_name": "Smith"
              }
            },
            "order": {
              "reference": "testcheckout1",
              "amount": 200,
              "currency": "AUD",
              "shipping": {
                "pickup": false,
                "tracking": {
                  "uri": "http://tracking.com?code=CBX-343",
                  "number": "CBX-343",
                  "carrier": "tracking.com"
                },
                "address": {
                  "line1": "10 Test st",
                  "city": "Sydney",
                  "state": "NSW",
                  "postal_code": "2000",
                  "country": "AU"
                }
              },
              "items": [
                {
                  "name": "Awesome shoes",
                  "amount": 200,
                  "reference": "1",
                  "quantity": 1,
                  "type": "sku"
                }
              ]
            },
            "metadata": {
              "name1": "value1"
            },
            "created": "2018-05-07T05:37:56.4794801Z",
            "state": "created",
            "config": {
              "redirect_uri": "http://www.redirectsuccess.com/zipmoney/approved"
            }
          }
        end

        def capture_body
          {
            "id": "ch_AKS81QxsiKUSnr281pX7z4",
            "reference": "nsadioghsdgoihsd",
            "amount": 200,
            "currency": "AUD",
            "state": "authorised",
            "captured_amount": 0,
            "refunded_amount": 0,
            "created_date": "2018-05-07T05:46:48.963Z",
            "order": {
              "reference": "refno1ononon",
              "shipping": {
                "pickup": false,
                "tracking": {
                  "uri": "http://tracking.com?code=CBX-343",
                  "number": "CBX-343",
                  "carrier": "tracking.com"
                },
                "address": {
                  "line1": "10 Test st",
                  "city": "Sydney",
                  "state": "NSW",
                  "postal_code": "2000",
                  "country": "AU"
                }
              },
              "items": [
                {
                  "name": "veniam qui occaecat amet ipsum",
                  "amount": 200,
                  "reference": "1",
                  "quantity": 1,
                  "type": "sku",
                  "item_uri": "https://tatum.name"
                }
              ],
              "cart_reference": "exercitation doloresdfsd"
            },
            "customer": {
              "id": "14589",
              "first_name": "John",
              "last_name": "APPROVETEST",
              "email": "tim@tmkcomputing.com.au"
            },
            "receipt_number": 155953,
            "product": "zipPay"
          }
        end
    end
  end
end
