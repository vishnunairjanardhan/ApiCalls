class GiftCardsController < ApplicationController
    def initialize
      # Path to your service account key file or use environment variable
      @key_file_path = ENV['GOOGLE_APPLICATION_CREDENTIALS'] || '/path/to/key.json'
  
      @base_url = 'https://walletobjects.googleapis.com/walletobjects/v1'
      @batch_url = 'https://walletobjects.googleapis.com/batch'
      @class_url = "#{@base_url}/giftCardClass"
      @object_url = "#{@base_url}/giftCardObject"
  
      auth
    end
  
    private
  
    def auth
      # Load the service account key JSON
      key_data = JSON.parse(File.read(@key_file_path))
  
      # Create an authenticated HTTP client
      client = Google::Auth::ServiceAccountCredentials.make_creds(
        json_key_io: StringIO.new(key_data.to_json),
        scope: 'https://www.googleapis.com/auth/wallet_object.issuer'
      )
  
      # Authorize the client
      client.fetch_access_token!
      def create_object
        issuer_id = params[:issuer_id]
        class_suffix = params[:class_suffix]
        object_suffix = params[:object_suffix]
    
        # Check if the object exists
        begin
          response = @client.request(:get, "#{@object_url}/#{issuer_id}.#{object_suffix}")
          puts "Object #{issuer_id}.#{object_suffix} already exists!"
          render plain: "#{issuer_id}.#{object_suffix}"
        rescue Google::Apis::ServerError
          # The object does not exist
        end
    
        new_object = {
          'id': "#{issuer_id}.#{object_suffix}",
          'classId': "#{issuer_id}.#{class_suffix}",
          'state': 'ACTIVE',
          'heroImage': {
            'sourceUri': {
              'uri': 'https://farm4.staticflickr.com/3723/11177041115_6e6a3b6f49_o.jpg'
            },
            'contentDescription': {
              'defaultValue': {
                'language': 'en-US',
                'value': 'Hero image description'
              }
            }
          },
          'textModulesData': [
            {
              'header': 'Text module header',
              'body': 'Text module body',
              'id': 'TEXT_MODULE_ID'
            }
          ],
          'linksModuleData': {
            'uris': [
              {
                'uri': 'http://maps.google.com/',
                'description': 'Link module URI description',
                'id': 'LINK_MODULE_URI_ID'
              },
              {
                'uri': 'tel:6505555555',
                'description': 'Link module tel description',
                'id': 'LINK_MODULE_TEL_ID'
              }
            ]
          },
          'imageModulesData': [
            {
              'mainImage': {
                'sourceUri': {
                  'uri': 'http://farm4.staticflickr.com/3738/12440799783_3dc3c20606_b.jpg'
                },
                'contentDescription': {
                  'defaultValue': {
                    'language': 'en-US',
                    'value': 'Image module description'
                  }
                }
              },
              'id': 'IMAGE_MODULE_ID'
            }
          ],
          'barcode': {
            'type': 'QR_CODE',
            'value': 'QR code'
          },
          'cardTitle': {
            'defaultValue': {
              'language': 'en-US',
              'value': 'Generic card title'
            }
          },
          'header': {
            'defaultValue': {
              'language': 'en-US',
              'value': 'Generic header'
            }
          },
          'hexBackgroundColor': '#4285f4',
          'logo': {
            'sourceUri': {
              'uri': 'https://storage.googleapis.com/wallet-lab-tools-codelab-artifacts-public/pass_google_logo.jpg'
            },
            'contentDescription': {
              'defaultValue': {
                'language': 'en-US',
                'value': 'Generic card logo'
              }
            }
          }
        }
    
        response = @client.request(:post, @object_url, body: JSON.generate(new_object), headers: { 'Content-Type': 'application/json' })
    
        puts 'Object insert response'
        puts response
    
        render plain: "#{issuer_id}.#{object_suffix}"
      end
    end
  end
  