# bugsam 03/25/2022

import json
from authlib.jose import JsonWebKey
from authlib.jose import jwt

rsaKey = JsonWebKey.generate_key(kty="RSA", crv_or_size=2048, is_private=1)

json_object = json.loads(rsaKey.as_json())
json_formatted_str = json.dumps(json_object, indent=2)
print(json_formatted_str)

header = {'typ': 'JWT',
          'alg': 'RS256',
          'jku': 'http://HOST/jwks.json'
          }
payload = {
     'user': 'blah'
}
serialized = jwt.encode(header=header, payload=payload, key=rsaKey)
print(serialized)
