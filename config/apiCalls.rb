require 'jwt'
require 'httparty'

class GoogleWalletService
  include HTTParty
  base_uri 'https://walletobjects.googleapis.com'

  def initialize
    # Retrieve these from your environment variables or Rails credentials
    @issuer_id = Rails.application.credentials.google[:issuer_id]
    @issuer_secret = Rails.application.credentials.google[:issuer_secret]
    @service_account_email = Rails.application.credentials.google[:service_account_email]
    @audience = 'https://walletobjects.googleapis.com/'
    @origin = 'https://your-saas-application.com'
    @scope = 'https://www.googleapis.com/auth/wallet_object.issuer'
  end

  def create_gift_card_class
    # Define the gift card class
    gift_card_class = {
      "classId": "00001",
      "merchantName": "99minds",
      "passType": "GIFT_CARD",
      "passData": {
        "expirationDate": "2023-12-31",
        "balance": {
          "micros": 10000000,
          "currencyCode": "USD"
        }
      }
    }

    # Post the class definition to Google's API
    response = self.class.post("/walletobjects/v1/giftCardClass", headers: auth_header, body: gift_card_class.to_json)
    
    # Handle the response appropriately
    response
  end

  def create_gift_card_object(class_id)
    # Define the gift card object with reference to the class ID
    gift_card_object = {
      classId: class_id,
      id: "#{@issuer_id}.#{SecureRandom.uuid}",
      state: 'ACTIVE',
      heroImage: {
        sourceUri: {
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

    # Post the object to Google's API
    response = self.class.post("/walletobjects/v1/giftCardObject", headers: auth_header, body: gift_card_object.to_json)
    
    # Handle the response
    response
  end

  private

  def auth_header
    {
      'Authorization' => "Bearer #{generate_access_token}",
      'Content-Type' => 'application/json'
    }
  end

  def generate_access_token
    # Create the JWT and sign it with your issuer_secret
    iat = Time.now.to_i
    exp = iat + 3600 # Token valid for 1 hour

    payload = {
      iss: @service_account_email,
      aud: @audience,
      iat: iat,
      exp: exp,
      scope: @scope
    }

    JWT.encode(payload, @issuer_secret, 'RS256')
  end
end
